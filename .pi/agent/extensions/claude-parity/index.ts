/**
 * claude-parity - a minimal, Claude Code-like surface for Pi.
 *
 * Owns exactly three shallow UI components and nothing else:
 *
 *   SlimPiHeader  the terminal logo plus version / model+effort+provider / cwd
 *   EffortWidget  right-aligned thinking level above the composer
 *   SlimFooter    git branch and remaining context
 *
 * Tool rendering, grouping, diffs, spinner, queue steering and Ctrl+O
 * expansion belong to the cc-my-pi package. Its own header and statusline are
 * disabled in ~/.pi/settings.json so the two never race for the same rows.
 *
 * See docs/superpowers/specs/2026-08-03-claude-like-pi-design.md.
 */

import os from "node:os";
import path from "node:path";

import type { ExtensionAPI, ExtensionContext, Theme, ThemeColor } from "@earendil-works/pi-coding-agent";
import { keyText, VERSION } from "@earendil-works/pi-coding-agent";
import { truncateToWidth, visibleWidth } from "@earendil-works/pi-tui";

/** A shell prompt in a rounded frame: chevron plus underline, after Lucide's
 *  `terminal` icon. The underline sits below and right of the chevron tip, as
 *  in the source SVG (chevron y=5..17, rule at y=19, x=12..20). */
const LOGO = [
	"╭────────────────╮",
	"│  ▚             │",
	"│   ▚            │",
	"│    ▚           │",
	"│    ▞           │",
	"│   ▞            │",
	"│  ▞             │",
	"│        ▄▄▄▄▄▄  │",
	"╰────────────────╯",
];
const LOGO_WIDTH = Math.max(...LOGO.map((row) => visibleWidth(row)));
const LOGO_GAP = "   ";
/** The three text fields sit vertically centred against the logo. */
const TEXT_ROW_OFFSET = Math.max(0, Math.floor((LOGO.length - 3) / 2));

/** Bounded reveal: the logo draws itself row by row, then the timer stops.
 *  Deliberately finite. A header timer that never clears would re-render the
 *  whole TUI forever for a logo that scrolls off after the first turn. */
const REVEAL_TICK_MS = 90;

const PROVIDER_NAMES: Record<string, string> = {
	"github-copilot": "GitHub Copilot",
	anthropic: "Anthropic",
	openai: "OpenAI",
	google: "Google",
	groq: "Groq",
	openrouter: "OpenRouter",
	xai: "xAI",
	mistral: "Mistral",
};

const THINKING_COLORS: Record<string, ThemeColor> = {
	off: "thinkingOff",
	minimal: "thinkingMinimal",
	low: "thinkingLow",
	medium: "thinkingMedium",
	high: "thinkingHigh",
	xhigh: "thinkingXhigh",
	max: "thinkingMax",
};

const ACRONYMS = new Set(["gpt", "ai", "llm", "xai", "qwen"]);

function titleCasePart(part: string): string {
	if (ACRONYMS.has(part.toLowerCase())) return part.toUpperCase();
	return part.charAt(0).toUpperCase() + part.slice(1);
}

/** "gpt-5.6-sol" -> "GPT-5.6 Sol". Version-looking parts stay hyphenated to
 *  the token before them; everything else becomes a separate word. */
function formatModelName(id: string): string {
	const parts = id.split("-").filter(Boolean);
	if (parts.length === 0) return id;
	let out = titleCasePart(parts[0]);
	for (const part of parts.slice(1)) {
		out += /^[\d.]+$/.test(part) ? `-${part}` : ` ${titleCasePart(part)}`;
	}
	return out;
}

function formatProvider(provider: string): string {
	return PROVIDER_NAMES[provider] ?? provider.split("-").map(titleCasePart).join(" ");
}

function contractHome(dir: string): string {
	const home = os.homedir();
	if (dir === home) return "~";
	if (dir.startsWith(home + path.sep)) return `~${dir.slice(home.length)}`;
	return dir;
}

/** Whole percent of the context window still free. Falls back to 100 before
 *  the first assistant response, and right after a compaction, when Pi
 *  reports tokens as null. */
function contextLeftPercent(ctx: ExtensionContext): number {
	const usage = ctx.getContextUsage();
	if (!usage || usage.percent === null) return 100;
	return Math.max(0, Math.min(100, Math.round(100 - usage.percent)));
}

function thinkingLevelOf(pi: ExtensionAPI, ctx: ExtensionContext): string {
	return pi.getThinkingLevel?.() ?? ctx.thinkingLevel ?? "off";
}

export default function (pi: ExtensionAPI) {
	// One TUI instance is shared by header, widget and footer. Captured from
	// whichever factory the renderer builds first.
	let tui: { requestRender(): void } | undefined;
	let revealTimer: ReturnType<typeof setInterval> | undefined;
	let revealStep = 0;

	const refresh = () => tui?.requestRender();

	const stopReveal = () => {
		if (revealTimer) {
			clearInterval(revealTimer);
			revealTimer = undefined;
		}
	};

	const startReveal = () => {
		stopReveal();
		revealStep = 0;
		revealTimer = setInterval(() => {
			revealStep += 1;
			refresh();
			if (revealStep >= LOGO.length) stopReveal();
		}, REVEAL_TICK_MS);
	};

	// --- SlimPiHeader ---------------------------------------------------

	const headerLines = (ctx: ExtensionContext, theme: Theme): string[] => {
		const model = ctx.model;
		const level = thinkingLevelOf(pi, ctx);

		const identity = model
			? [
					formatModelName(model.id),
					level === "off" ? "" : ` with ${level} effort`,
					` · ${formatProvider(model.provider)}`,
				].join("")
			: "no model";

		const text = [
			`${theme.bold(theme.fg("text", "Pi"))}${theme.fg("dim", ` v${VERSION}`)}`,
			theme.fg("muted", identity),
			theme.fg("dim", contractHome(process.cwd())),
		];

		return LOGO.map((row, i) => {
			const drawn = revealTimer === undefined || i <= revealStep;
			const glyphs = theme.fg(drawn ? "accent" : "dim", row);
			const label = text[i - TEXT_ROW_OFFSET] ?? "";
			if (!label) return glyphs;
			// Pad outside the colour span so trailing blanks stay unstyled.
			const padding = " ".repeat(Math.max(0, LOGO_WIDTH - visibleWidth(row)));
			return `${glyphs}${padding}${LOGO_GAP}${label}`;
		});
	};

	// --- EffortWidget ---------------------------------------------------

	const effortLine = (ctx: ExtensionContext, theme: Theme, width: number): string => {
		const level = thinkingLevelOf(pi, ctx);
		const dot = theme.fg(THINKING_COLORS[level] ?? "muted", "◉");
		const hint = theme.fg("dim", ` · ${keyText("app.thinking.cycle")}`);
		const content = `${dot} ${theme.fg("muted", level)}${hint}`;
		const pad = Math.max(0, width - visibleWidth(content));
		return truncateToWidth(" ".repeat(pad) + content, width);
	};

	// --- SlimFooter -----------------------------------------------------

	const footerLine = (
		ctx: ExtensionContext,
		theme: Theme,
		branch: string | null | undefined,
		width: number,
	): string => {
		const context = theme.fg("dim", `${contextLeftPercent(ctx)}% context left`);
		// Outside a git repo the branch segment is dropped entirely.
		const line = branch ? `${theme.fg("muted", branch)}${theme.fg("dim", " · ")}${context}` : context;
		return truncateToWidth(line, width);
	};

	// --- Wiring ---------------------------------------------------------

	pi.on("session_start", async (_event, ctx) => {
		if (ctx.mode !== "tui") return;

		ctx.ui.setHeader((hostTui, theme) => {
			tui = hostTui;
			startReveal();
			return {
				render: (_width: number) => headerLines(ctx, theme),
				invalidate() {},
				dispose: stopReveal,
			};
		});

		ctx.ui.setWidget(
			"claude-parity-effort",
			(hostTui, theme) => {
				tui = hostTui;
				return {
					render: (width: number) => [effortLine(ctx, theme, width)],
					invalidate() {},
				};
			},
			{ placement: "aboveEditor" },
		);

		ctx.ui.setFooter((hostTui, theme, footerData) => {
			tui = hostTui;
			const unsubscribe = footerData.onBranchChange(() => hostTui.requestRender());
			return {
				render: (width: number) => [footerLine(ctx, theme, footerData.getGitBranch(), width)],
				invalidate() {},
				dispose: unsubscribe,
			};
		});
	});

	// The components read live state in render(), so invalidation is just a
	// render request on anything that changes what they display. Registered
	// one by one rather than in a loop: pi.on is a per-event overload set, and
	// a union of event names collapses it to the wrong signature.
	pi.on("model_select", async () => refresh());
	pi.on("thinking_level_select", async () => refresh());
	pi.on("message_end", async () => refresh());
	pi.on("turn_end", async () => refresh());

	pi.on("session_shutdown", async () => {
		stopReveal();
		tui = undefined;
	});
}
