# Neovim configuration

Modular Neovim 0.11.6+ configuration, with Catppuccin and IntelliJ LSP for Java/Kotlin.
Plugins are managed by lazy.nvim; this is not a Kickstart installation.

## Layout

- `lua/dalton/set.lua`: editor options.
- `lua/dalton/remap.lua`: general shortcuts.
- `lua/dalton/autocmds.lua`: editor events.
- `lua/dalton/lsp.lua`: shared language-server navigation and diagnostics.
- `lua/dalton/lazy/`: active plugin specifications, grouped by feature.
- `lua/dalton/legacy/`: preserved, inactive JDTLS, completion, Harpoon, worktree,
  and preview configurations. lazy.nvim does not import this directory.
- `gradle/jdtls.init.gradle`: preserved for the inactive JDTLS setup only.

## Main shortcuts

Leader is **Space**. Pause after pressing it to see Which-key's shortcuts.

| Key | Action |
| --- | --- |
| `<leader>sf` / `gf` | Find files |
| `<leader>sg` / `gz` | Search project text |
| `<leader>sw` | Search the word under the cursor |
| `<leader>sr` | Resume the last search |
| `<leader>s.` | Recent files |
| `<leader><leader>` | Open buffers |
| `<leader>/` | Search the current buffer |
| `<leader>sd` | Search diagnostics |
| `<leader>sh` / `<leader>sk` | Search help / keybindings |
| `\` | Reveal the current file in Neo-tree; close the sidebar from inside it |
| `gd` / `gi` / `gu` | Definition / implementations / usages |
| `gh` / `gp` / `gH` | Documentation / parameter info / diagnostic details |
| `grn` / `gra` | Rename / code action |
| `gO` / `gW` | File symbols / workspace symbols |
| `<leader>ci` / `<leader>co` | Incoming / outgoing calls, when supported |
| `<leader>ts` / `<leader>tu` | Subtypes / supertypes, when supported |
| `<leader>th` | Toggle inlay hints, when supported |
| `<leader>f` | Format the buffer or visual selection |
| `<leader>gg` | LazyGit |
| `gb` / `gB` | Blame line / open line or selection on GitHub |
| `]c` / `[c` | Next / previous Git hunk |
| `<leader>hp` / `<leader>hs` / `<leader>hr` | Preview / stage / reset Git hunk |
| `<leader>mp` | Toggle Markdown browser preview |
| `<C-h/j/k/l>` | Move between windows |
| `<C-v>` / `<C-s>` / `<C-c>` | Vertical split / horizontal split / close window |

File search is now `<leader>sf`, not `<leader>f`; grep is `<leader>sg`, not
`<leader>g`. Telescope displays filenames first, then their directories.

Completion: `<C-Space>` opens the menu, `<C-n>/<C-p>` selects, `<C-y>` accepts,
and `<Tab>/<S-Tab>` moves between snippet placeholders.

## Java and Kotlin

IntelliJ LSP is experimental and uses a separate JetBrains server EULA and license.
EULA acceptance is enabled. The server needs an IntelliJ IDEA Ultimate license.

The plugin downloads, SHA-256 verifies and caches the server bundle its release pins,
under `~/.local/share/nvim/intellij-lsp/server/<version>/`. `lazy-lock.json` pins
the plugin revision; `:Lazy update` moves to newer server bundles and `:Lazy restore`
rolls back. Point `INTELLIJ_LSP_SERVER` at a `bin/intellij-server` launcher to use
another bundle. The server includes its own Java runtime.

On the first start, the plugin asks once for region and usage statistics. Activate
the license once with `:IntellijLspLicense` (Sign in with JetBrains Account). It is
stored per macOS user in `~/Library/Application Support/JetBrains/IntelliJServer`,
shared by every project and server version.

Project SDK configuration takes precedence; the fallback SDK comes from
`JAVA_HOME`, then macOS's `/usr/libexec/java_home -v 21`.
Gradle/Maven wrappers and project dependency credentials must be usable locally.

JDTLS remains disabled, including when it is already installed in Mason.
Formatting Java/Kotlin is **manual**; saving other supported files uses Conform.
Run/debug integration is disabled, matching the reference setup.

Useful commands:

- `:checkhealth intellij-lsp`: server, EULA, licensing and project status.
- `:IntellijLspOutput`: build import output and failures.
- `:IntellijLspReload`: re-import after changing build configuration.
- `:IntellijLspRestart`: restart the server.
- `:ConformInfo`: formatter status.
- `:Lazy`: plugins; `:Mason`: language servers and tools.

## Tests

Run each `tests/test_*.lua` with:

```
nvim --headless -u NONE -i NONE -l tests/test_config.lua
```

The `test_jdtls_config.lua`, `test_legacy_lsp_navigation.lua`, and Python Gradle
tests cover the preserved legacy setup, not the active IntelliJ server.
