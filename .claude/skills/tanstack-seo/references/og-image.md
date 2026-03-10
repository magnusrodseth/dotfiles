# OG Image Generation

On-demand OpenGraph image generation using Satori (JSX → SVG) and Resvg (SVG → PNG). No `@vercel/og` dependency — uses the same underlying libraries directly for full control.

## How It Works

```
Social crawler fetches /og.png?title=Hello&description=World
  → Server route extracts query params
  → Load Google Fonts (fetched at runtime from Google Fonts CSS API)
  → Satori converts JSX layout to SVG string
  → Resvg renders SVG to PNG buffer
  → Response with image/png + 24-hour cache headers
```

## File 1: OG Image Generator — `src/lib/og-image.tsx`

```tsx
import { Resvg } from "@resvg/resvg-js";
import satori from "satori";

// CUSTOMIZE: Replace with your brand colors
const colors = {
  bg: "#faf9f5",           // Background
  fg: "#3d3929",           // Foreground / title text
  primary: "#c96442",      // Accent color
  muted: "#83827d",        // Description text
  border: "#dad9d4",       // Footer separator
};

const WIDTH = 1200;
const HEIGHT = 630;
const DESCRIPTION_MAX_LENGTH = 200;

// Loads a Google Font binary at runtime. Works on any server environment.
async function loadGoogleFont(
  family: string,
  weight: number,
): Promise<ArrayBuffer> {
  const url = `https://fonts.googleapis.com/css2?family=${encodeURIComponent(family)}:wght@${weight}`;
  const css = await fetch(url).then((r) => r.text());
  const match = css.match(
    /src: url\((.+?)\) format\('(opentype|truetype)'\)/,
  );
  if (!match?.[1]) {
    throw new Error(`Failed to load font: ${family} ${weight}`);
  }
  return fetch(match[1]).then((r) => r.arrayBuffer());
}

export interface OGImageOptions {
  title: string;
  description?: string;
}

export async function generateOGImage(
  options: OGImageOptions,
): Promise<Response> {
  const { title, description } = options;

  // CUSTOMIZE: Change font families and weights as needed.
  // Any Google Font works. Load only the weights you use.
  const [titleFont, titleFontMedium, bodyFont, bodyFontSemibold] =
    await Promise.all([
      loadGoogleFont("Lora", 400),
      loadGoogleFont("Lora", 500),
      loadGoogleFont("Inter", 400),
      loadGoogleFont("Inter", 600),
    ]);

  const truncatedDescription =
    description && description.length > DESCRIPTION_MAX_LENGTH
      ? `${description.slice(0, DESCRIPTION_MAX_LENGTH)}…`
      : description;

  // IMPORTANT: Satori supports a subset of CSS. Key limitations:
  // - Every element needs `display: "flex"` (no block/inline)
  // - No CSS Grid
  // - Use inline styles only (no classes)
  // - Flexbox is the only layout model
  const svg = await satori(
    <div
      style={{
        width: "100%",
        height: "100%",
        display: "flex",
        flexDirection: "column",
        justifyContent: "space-between",
        padding: "60px 80px",
        backgroundColor: colors.bg,
        // Subtle gradient overlays using primary color at low opacity
        backgroundImage: `radial-gradient(ellipse at 0% 0%, ${colors.primary}44 0%, transparent 63%), radial-gradient(ellipse at 100% 100%, ${colors.primary}2B 0%, transparent 63%)`,
        fontFamily: "Inter",
      }}
    >
      {/* Top accent bar */}
      <div
        style={{
          display: "flex",
          width: "80px",
          height: "4px",
          backgroundColor: colors.primary,
          borderRadius: "2px",
        }}
      />

      {/* Main content — vertically centered */}
      <div
        style={{
          display: "flex",
          flexDirection: "column",
          gap: "24px",
          flex: 1,
          justifyContent: "center",
        }}
      >
        {/* Title — responsive font size based on character count */}
        <div
          style={{
            fontFamily: "Lora",
            fontSize: title.length > 50 ? 48 : title.length > 30 ? 60 : 72,
            fontWeight: 500,
            color: colors.fg,
            lineHeight: 1.15,
            letterSpacing: "-0.01em",
          }}
        >
          {title}
        </div>

        {/* Description (optional) */}
        {truncatedDescription && (
          <div
            style={{
              fontFamily: "Inter",
              fontSize: 24,
              color: colors.muted,
              lineHeight: 1.5,
              maxWidth: "900px",
            }}
          >
            {truncatedDescription}
          </div>
        )}
      </div>

      {/* Footer — brand name + optional CTA */}
      <div
        style={{
          display: "flex",
          alignItems: "center",
          justifyContent: "space-between",
          borderTop: `1px solid ${colors.border}`,
          paddingTop: "24px",
        }}
      >
        <div
          style={{
            display: "flex",
            alignItems: "center",
            gap: "12px",
          }}
        >
          {/* Brand dot */}
          <div
            style={{
              display: "flex",
              width: "12px",
              height: "12px",
              borderRadius: "50%",
              backgroundColor: colors.primary,
            }}
          />
          {/* CUSTOMIZE: Replace with your brand name */}
          <div
            style={{
              fontFamily: "Inter",
              fontSize: 20,
              fontWeight: 600,
              color: colors.fg,
            }}
          >
            Your App Name
          </div>
        </div>

        {/* CUSTOMIZE: Replace or remove this CTA section */}
        <div
          style={{
            display: "flex",
            alignItems: "center",
            gap: "8px",
            fontFamily: "Inter",
            fontSize: 16,
          }}
        >
          <span style={{ color: colors.muted }}>yoursite.com</span>
        </div>
      </div>
    </div>,
    {
      width: WIDTH,
      height: HEIGHT,
      fonts: [
        { name: "Lora", data: titleFont, weight: 400, style: "normal" as const },
        { name: "Lora", data: titleFontMedium, weight: 500, style: "normal" as const },
        { name: "Inter", data: bodyFont, weight: 400, style: "normal" as const },
        { name: "Inter", data: bodyFontSemibold, weight: 600, style: "normal" as const },
      ],
    },
  );

  const resvg = new Resvg(svg);
  const png = resvg.render().asPng();

  return new Response(new Uint8Array(png), {
    headers: {
      "Content-Type": "image/png",
      "Cache-Control": "public, max-age=86400, s-maxage=86400",
    },
  });
}
```

## File 2: Route Handler — `src/routes/og[.]png.ts`

The `[.]` in the filename escapes the dot for TanStack Router, so it matches the URL path `/og.png`.

```typescript
import { createFileRoute } from "@tanstack/react-router";

import { generateOGImage } from "@/lib/og-image";

export const Route = createFileRoute("/og.png")({
  server: {
    handlers: {
      GET: ({ request }) => {
        const url = new URL(request.url);
        // CUSTOMIZE: Change the default title fallback
        const title = url.searchParams.get("title") ?? "Your App";
        const description = url.searchParams.get("description") ?? undefined;

        return generateOGImage({ title, description });
      },
    },
  },
});
```

No React component — this is a server-only route that returns a PNG response.

## Satori CSS Limitations

Satori only supports a subset of CSS. Keep these in mind when customizing the layout:

- Every element MUST have `display: "flex"` — no block, inline-block, or grid
- Only flexbox layout (no CSS Grid)
- Inline styles only (no className, no Tailwind)
- Supported: `flexDirection`, `justifyContent`, `alignItems`, `gap`, `padding`, `margin`, `border`, `borderRadius`, `backgroundColor`, `backgroundImage` (gradients), `color`, `fontSize`, `fontWeight`, `fontFamily`, `lineHeight`, `letterSpacing`, `maxWidth`, `overflow`
- NOT supported: `position: absolute/fixed`, `transform`, `animation`, `box-shadow`, `text-shadow`, `clip-path`
- Text wrapping works automatically within flex containers
- Images: use `<img>` with `src` as a URL or base64 data URI

## Font Loading Strategy

The `loadGoogleFont()` function:
1. Fetches the Google Fonts CSS for a given family + weight
2. Extracts the binary font URL from the CSS `src: url(...)` declaration
3. Fetches the binary font data as an `ArrayBuffer`

This means fonts are loaded on every request (cold start). The 24-hour cache header ensures repeat requests are served from CDN cache. For better cold-start performance, consider bundling font files as static assets and reading them from disk instead.

## Testing

Visit directly in the browser: `http://localhost:3000/og.png?title=Hello+World&description=Testing+OG+images`
