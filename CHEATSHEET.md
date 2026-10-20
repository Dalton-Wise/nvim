# Neovim Keybinding Cheatsheet

**The left sidebar is Neo-tree:** press **`\`** to open/focus it, then **`\` again while inside it** to close it. For a true toggle from anywhere, run `:Neotree toggle`.

These are **all configured shortcuts**, plus the main plugin controls. **Leader = Space**. Unless noted, use Normal mode.

## Files and searching

| Keys | Action |
| --- | --- |
| `Space sf` or `gf` | Find files |
| `Space sg` or `gz` | Search project text |
| `Space sw` | Search word under cursor |
| `Space sr` | Resume previous search |
| `Space s.` | Recent files |
| `Space Space` | Open buffers |
| `Space /` | Search current buffer |
| `Space s/` | Search across open files |
| `Space sd` | Search diagnostics |
| `Space sh` | Search help |
| `Space sk` | Search keybindings |
| `Space ss` | Browse Telescope searches |
| `Space sn` | Search your Neovim config |
| `Space e` | Open built-in directory browser |
| `\` | Open/focus Neo-tree; close from inside it |

### Inside Telescope

| Keys | Action |
| --- | --- |
| `Ctrl-n` / `Ctrl-p` | Next / previous result |
| `Enter` | Open result |
| `Ctrl-v` | Open in vertical split |
| `Ctrl-x` | Open in horizontal split |
| `Ctrl-t` | Open in new tab |
| `Tab` / `Shift-Tab` | Toggle selection and move |
| `Ctrl-u` / `Ctrl-d` | Scroll preview up / down |
| `Ctrl-q` | Send filtered results to quickfix |
| `Ctrl-/` | Show picker shortcuts |
| `Ctrl-c` | Close picker |

## Java / language-server navigation

Available when a language server is attached. Hierarchies and hints require server support.

| Keys | Action |
| --- | --- |
| `gd` or `grd` | Go to definition |
| `gD` or `grD` | Go to declaration |
| `gi` or `gri` | Find implementations |
| `gu` or `grr` | Find usages/references |
| `grt` | Go to type definition |
| `gO` | Search symbols in current file |
| `gW` or `Space ws` | Search workspace symbols |
| `gh` | Show documentation |
| `gp` | Show parameter information |
| `gH` | Show diagnostic details |
| `grn` | Rename symbol |
| `gra` | Code actions—Normal or Visual mode |
| `Space ci` | Incoming calls |
| `Space co` | Outgoing calls |
| `Space ts` | Show subtypes |
| `Space tu` | Show supertypes |
| `Space th` | Toggle inlay hints |

## Completion — Insert mode

| Keys | Action |
| --- | --- |
| `Ctrl-Space` | Open completion / documentation |
| `Ctrl-n` / `Ctrl-p` | Next / previous suggestion |
| `Ctrl-y` | Accept suggestion |
| `Ctrl-e` | Dismiss completion |
| `Tab` / `Shift-Tab` | Next / previous snippet placeholder |
| `Ctrl-k` | Toggle signature help |

## Windows and editing

| Keys | Action |
| --- | --- |
| `Ctrl-h` | Focus left window |
| `Ctrl-j` | Focus lower window |
| `Ctrl-k` | Focus upper window |
| `Ctrl-l` | Focus right window |
| `Ctrl-v` | Create vertical split |
| `Ctrl-s` | Create horizontal split |
| `Ctrl-c` | Close current window |
| `Esc` | Clear search highlights |
| `]e` / `[e` | Next / previous diagnostic |
| `Space q` | Open diagnostic list |
| `Space f` | Format buffer—or selection in Visual mode |
| `<` / `>` | Indent and keep selection—Visual mode |
| `Esc Esc` | Leave terminal-input mode |
| `Space mp` | Toggle Markdown browser preview |

**Java/Kotlin formatting is manual**, not automatic on save.

### Surround editing — plugin defaults

| Keys | Action |
| --- | --- |
| `sa{motion}{surround}` | Add surrounding quotes/brackets |
| `sd{surround}` | Delete surrounding quotes/brackets |
| `sr{old}{new}` | Replace surrounding characters |
| `sf{surround}` | Find surrounding character to the right |
| `sF{surround}` | Find surrounding character to the left |
| `sh{surround}` | Highlight surrounding characters |
| `sn` | Update surround search range |

Examples: `saiw"` surrounds a word with quotes; `sd"` removes surrounding quotes.

## Git

| Keys | Action |
| --- | --- |
| `Space gg` | Open LazyGit |
| `gb` | Show blame for current line |
| `gB` | Open current line—or Visual selection—on GitHub |
| `]c` / `[c` | Next / previous changed hunk |
| `Space hp` | Preview hunk |
| `Space hs` | Stage hunk |
| `Space hr` | **Reset/discard hunk changes** |

Press **Space and pause** to discover shortcuts, or **`Space sk`** to search the mappings available in your current session.
