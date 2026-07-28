# =============================================================================
# Brewfile
# =============================================================================
# Note: organized by category for readability. `brew bundle dump --force` will
# overwrite this structure, so prefer manual edits when adding new packages.

# === Taps ===
# `trusted:` below is not decoration. Homebrew 6 requires trust for non-official
# taps, and it omits untrusted taps from `brew bundle dump` silently, with no
# warning and no error. opencode, idb-companion and sgpt were therefore invisible
# to every dump-vs-Brewfile drift check until their INSTALL_RECEIPT.json files
# were read directly. Enumerate on-request formulae from receipts, not from dump.
#
# Trust otherwise lives only in ~/.config/homebrew/trust.json, which is untracked
# and machine-local, so a fresh clone would silently lose it and go blind again.
# Declaring it here makes it reproducible and reviewable in a diff. Note the two
# forms: `trusted: true` on a formula, and `trusted: { formulae: [...] }` on a
# tap (which is how a tap added by URL, like doppler, resolves).
tap "anomalyco/tap"
tap "aws/tap"
tap "beeftornado/rmtree"
tap "dopplerhq/cli"
tap "dopplerhq/doppler", trusted: { formulae: ["doppler"] }
tap "facebook/fb"
tap "hashicorp/tap"
tap "homebrew/bundle"
tap "homebrew/services"
tap "jandedobbeleer/oh-my-posh"
tap "jesseduffield/lazydocker"
tap "jesseduffield/lazygit"
tap "mobile-dev-inc/tap"
tap "oven-sh/bun"
tap "steipete/tap"
tap "stripe/stripe-cli"
tap "supabase/tap"

# === Languages & SDKs ===
brew "deno"
brew "go"
brew "kotlin"
brew "node"
# Two versioned JDKs remain: @21 is pulled in by kotlin-language-server, @11 is
# required by pdftk-java. @17 was a leftover with no consumer and was removed on
# 28.07.2026. A plain openjdk (26) is also present as a dependency.
brew "openjdk@11"
brew "openjdk@21"
brew "perl"
brew "pipx"
brew "pnpm"
brew "poetry"
brew "python@3.12"
# uv must stay brew-managed. It was previously installed by Astral's standalone
# script into ~/.cargo/bin, where nothing upgraded it: it sat at 0.4.28 (Oct
# 2024) for ~2 years while its cache grew to 105 GB unchecked. brew puts it on
# `brew upgrade` and makes `brew bundle check` (doctor.sh) notice its absence.
brew "uv"
brew "oven-sh/bun/bun", trusted: true

# === Databases ===
brew "supabase"

# === Build tools & libraries ===
brew "arm-none-eabi-gcc"
brew "berkeley-db", link: true
brew "cffi"
brew "cocoapods"
brew "cryptography"
brew "glib"
brew "cairo"
brew "harfbuzz"
brew "libavif"
brew "libffi"
brew "libfido2"
brew "libgit2"
brew "libidn2"
brew "libproxy"
brew "librsvg"
brew "libtiff"
brew "libxslt"
brew "luajit"
brew "make"
brew "netpbm"
brew "pango"
brew "pkgconf"
brew "portaudio"
brew "pycparser"
brew "qemu"
brew "tree-sitter"
brew "webp"
brew "jpeg-xl"
brew "aom"
brew "gd"
brew "gdk-pixbuf"
brew "gobject-introspection"
brew "gnutls"

# === Dev tools (CLI) ===
brew "ast-grep"
brew "atuin"
brew "bat"
brew "bottom"
brew "cmatrix"
brew "eza"
brew "fd"
brew "fzf"
brew "git"
brew "git-delta"
brew "git-filter-repo"
brew "git-lfs"
# Staged-diff secret scan, wired into scripts/githooks/pre-commit. This repo is
# public and has leaked four credentials (Sanity, ngrok, Context7, Spotify);
# every other invariant here is enforced by a script, so this one is too.
brew "gitleaks"
brew "gh"
brew "gradle"
brew "facebook/fb/idb-companion", trusted: true
brew "just"
brew "lazygit"
brew "mobile-dev-inc/tap/maestro", trusted: true
brew "mole"
brew "mosh"
brew "neovim"
brew "procs"
brew "ripgrep"
brew "rm-improved"
brew "rtk"
brew "ruff"
brew "rust-analyzer"
brew "stow"
brew "tmux"
brew "tree"
brew "xcodegen"
brew "yt-dlp"
brew "zoxide"
brew "zsh"
brew "jq"
brew "keyring"
brew "mkcert"
brew "telnet"

# === Language servers ===
brew "gopls"
brew "kotlin-language-server"
brew "lua-language-server"
brew "yaml-language-server"

# === Cloud & infra ===
brew "act"
brew "awscli"
brew "azure-cli"
brew "railway"
# Must stay fully qualified with trusted:. terraform left homebrew-core over the
# BSL relicense, so a bare `brew "terraform"` resolves to hashicorp/tap and dies
# with "Refusing to load formula from untrusted tap", which aborted
# `brew bundle cleanup` entirely, leaving this file with no drift check at all.
brew "hashicorp/tap/terraform", trusted: true
brew "dopplerhq/cli/doppler"
brew "hashicorp/tap/terraform-ls", trusted: true
brew "jesseduffield/lazydocker/lazydocker", trusted: true
brew "stripe/stripe-cli/stripe", trusted: true
# Backs the `imsg` skill declared in scripts/skills/skill-lock.json; without
# it the skill installs fine and then fails at its first command.
brew "steipete/tap/imsg", trusted: true
# Terminal agent multiplexer (herdr.dev), installed on request.
brew "herdr"

# === Docs, content, media ===
brew "biber"
# Used by the Raycast strip-exif command (.config/raycast/extensions/).
brew "exiftool"
brew "ffmpeg"
brew "ghostscript"
brew "graphviz"
brew "imagemagick"
brew "markdown"
brew "mupdf"
brew "pandoc"
brew "pdftk-java"
brew "pygments"
brew "sphinx-doc"
brew "tesseract"
brew "typst"

# === AI / ML ===
brew "ollama"
brew "whisper-cpp"
brew "anomalyco/tap/opencode", trusted: true

# === Mac App Store & shell ===
brew "mas"
brew "jandedobbeleer/oh-my-posh/oh-my-posh", trusted: true

# === Casks ===
cask "1password"
cask "1password-cli"
cask "anydesk"
cask "aws-vault-binary"
cask "bitwarden"
cask "brave-browser"
cask "discord"
cask "dotnet-runtime"
cask "dropbox"
cask "figma"
cask "flux-app"
cask "font-fira-code-nerd-font"
cask "freedom"
cask "ghostty"
cask "google-drive"
cask "hazeover"
cask "jetbrains-toolbox"
cask "jordanbaird-ice"
cask "microsoft-auto-update"
cask "microsoft-outlook"
cask "microsoft-teams"
cask "ngrok"
cask "notion"
cask "obsidian"
cask "orbstack"
cask "raycast"
cask "readdle-spark"
cask "slack"
cask "spotify"
cask "tableplus"
cask "visual-studio-code"
cask "vlc"
cask "zed"
cask "zotero"

# === VS Code Extensions ===
vscode "4ops.terraform"
vscode "aaron-bond.better-comments"
vscode "apollographql.vscode-apollo"
vscode "ardenivanov.svelte-intellisense"
vscode "asciidoctor.asciidoctor-vscode"
vscode "astro-build.astro-vscode"
vscode "austenc.tailwind-docs"
vscode "be5invis.toml"
vscode "bradlc.vscode-tailwindcss"
vscode "codesandbox-io.codesandbox-projects"
vscode "cschlosser.doxdocgen"
vscode "davidanson.vscode-markdownlint"
vscode "dbaeumer.vscode-eslint"
vscode "deerawan.vscode-faker"
vscode "dionannd.tokyo-night-ported-nvim"
vscode "dotjoshjohnson.xml"
vscode "dqisme.sync-scroll"
vscode "eamodio.gitlens"
vscode "ecmel.vscode-html-css"
vscode "editorconfig.editorconfig"
vscode "enkia.tokyo-night"
vscode "esbenp.prettier-vscode"
vscode "formulahendry.auto-rename-tag"
vscode "github.codespaces"
vscode "github.copilot"
vscode "github.copilot-chat"
vscode "github.vscode-github-actions"
vscode "github.vscode-pull-request-github"
vscode "golang.go"
vscode "graphql.vscode-graphql"
vscode "graphql.vscode-graphql-execution"
vscode "graphql.vscode-graphql-syntax"
vscode "hashicorp.hcl"
vscode "hashicorp.terraform"
vscode "humao.rest-client"
vscode "ibm.output-colorizer"
vscode "james-yu.latex-workshop"
vscode "jbockle.jbockle-format-files"
vscode "jock.svg"
vscode "josetr.cmake-language-support-vscode"
vscode "kevinrose.vsc-python-indent"
vscode "luniclynx.lex"
vscode "mechatroner.rainbow-csv"
vscode "mikestead.dotenv"
vscode "ms-azuretools.vscode-bicep"
vscode "ms-azuretools.vscode-containers"
vscode "ms-azuretools.vscode-docker"
vscode "ms-dotnettools.csdevkit"
vscode "ms-dotnettools.csharp"
vscode "ms-dotnettools.vscode-dotnet-runtime"
vscode "ms-ossdata.vscode-postgresql"
vscode "ms-python.debugpy"
vscode "ms-python.python"
vscode "ms-python.vscode-pylance"
vscode "ms-python.vscode-python-envs"
vscode "ms-toolsai.jupyter"
vscode "ms-toolsai.jupyter-keymap"
vscode "ms-toolsai.jupyter-renderers"
vscode "ms-toolsai.vscode-jupyter-cell-tags"
vscode "ms-toolsai.vscode-jupyter-slideshow"
vscode "ms-vscode-remote.remote-containers"
vscode "ms-vscode.cmake-tools"
vscode "ms-vscode.cpptools"
vscode "ms-vscode.cpptools-extension-pack"
vscode "ms-vscode.cpptools-themes"
vscode "ms-vscode.makefile-tools"
vscode "ms-vsliveshare.vsliveshare"
vscode "naumovs.color-highlight"
vscode "peakchen90.open-html-in-browser"
vscode "pkief.material-icon-theme"
vscode "pranaygp.vscode-css-peek"
vscode "prisma.prisma"
vscode "qufiwefefwoyn.kanagawa"
vscode "quicktype.quicktype"
vscode "rangav.vscode-thunder-client"
vscode "redhat.vscode-xml"
vscode "rust-lang.rust-analyzer"
vscode "samverschueren.final-newline"
vscode "sanity-io.vscode-sanity"
vscode "sastan.twind-intellisense"
vscode "shakram02.bash-beautify"
vscode "skellock.just"
vscode "stordahl.sveltekit-snippets"
vscode "stylelint.vscode-stylelint"
vscode "sumneko.lua"
vscode "supabase.vscode-supabase-extension"
vscode "svelte.svelte-vscode"
vscode "tamasfe.even-better-toml"
vscode "tauri-apps.tauri-vscode"
vscode "torn4dom4n.latex-support"
vscode "twxs.cmake"
vscode "unifiedjs.vscode-mdx"
vscode "vadimcn.vscode-lldb"
vscode "vscodevim.vim"
vscode "william-voyek.vscode-nginx"
vscode "yoavbls.pretty-ts-errors"
vscode "yzhang.markdown-all-in-one"
vscode "zarifprogrammer.tailwind-snippets"
vscode "zixuanwang.linkerscript"

# === Go tools ===
go "honnef.co/go/tools/cmd/staticcheck"
