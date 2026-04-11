# Central keybinding registry for vim-like environments.
#
# Each keymap entry:
#   key    - Key combination (vim notation)
#   mode   - List of vim modes: "n", "v", "i", "", "t"
#   desc   - Human-readable description
#   silent - Optional (default false)
#   remap  - Optional (default false = noremap)
#
# Target actions (omit or null to skip that target):
#   vim     - Plain vim action (also IdeaVim/neovim fallback)
#   neovim  - Neovim override (falls back to vim if absent)
#   idea    - JetBrains IdeaVim override (falls back to vim if absent)
#   vscode  - VS Code vim extension command (no fallback)
#
# Special fields:
#   vscodeNative - Attrset { key, command } for VS Code keybindings.json (non-vim)
{
  # ── Settings ──────────────────────────────────────────────────────────
  settings = {
    leader = "\\";

    # Plain vim / neovim shared options
    vim = {
      number = true;
      relativenumber = true;
      scrolloff = 5;
      incsearch = true;
      showmode = true;
    };

    # IdeaVim plugin and settings
    idea = {
      plugins = [
        "surround"
        "ReplaceWithRegister"
      ];
      settings = {
        ideajoin = true;
        ideastatusicon = "gray";
      };
      clipboard = "unnamed,unnamedplus";
    };

    # VS Code vim extension settings
    vscode = {
      "vim.surround" = true;
      "vim.replaceWithRegister" = true;
      "vim.useSystemClipboard" = true;
      "vim.useCtrlKeys" = true;
    };

    # VS Code non-vim settings
    vscodeExtra = {
      "git.openRepositoryInParentFolders" = "never";
    };
  };

  # ── Keymaps ───────────────────────────────────────────────────────────

  keymaps = [

    # ── Arrow key disabling ─────────────────────────────────────────────

    {
      key = "<Up>";
      mode = [ "n" ];
      desc = "Disable arrow keys";
      vim = "<NOP>";
      remap = true;
    }
    {
      key = "<Down>";
      mode = [ "n" ];
      desc = "Disable arrow keys";
      vim = "<NOP>";
      remap = true;
    }
    {
      key = "<Left>";
      mode = [ "n" ];
      desc = "Disable arrow keys";
      vim = "<NOP>";
      remap = true;
    }
    {
      key = "<Right>";
      mode = [ "n" ];
      desc = "Disable arrow keys";
      vim = "<NOP>";
      remap = true;
    }

    # ── Window navigation ───────────────────────────────────────────────

    {
      key = "<C-h>";
      mode = [ "n" ];
      desc = "Go to Left Window";
      vim = "<C-w>h";
      remap = true;
    }
    {
      key = "<C-j>";
      mode = [ "n" ];
      desc = "Go to Lower Window";
      vim = "<C-w>j";
      remap = true;
    }
    {
      key = "<C-k>";
      mode = [ "n" ];
      desc = "Go to Upper Window";
      vim = "<C-w>k";
      remap = true;
    }
    {
      key = "<C-l>";
      mode = [ "n" ];
      desc = "Go to Right Window";
      vim = "<C-w>l";
      remap = true;
    }

    # ── Window management ───────────────────────────────────────────────

    {
      key = "<leader>ww";
      mode = [ "n" ];
      desc = "Other Window";
      vim = "<C-W>p";
      remap = true;
    }
    {
      key = "<leader>wd";
      mode = [ "n" ];
      desc = "Delete Window";
      vim = "<C-W>c";
      remap = true;
    }
    {
      key = "<leader>w-";
      mode = [ "n" ];
      desc = "Split Window Below";
      vim = "<C-W>s";
      idea = ":action SplitHorizontally<CR>";
      vscode = "workbench.action.splitEditorDown";
      remap = true;
    }
    {
      key = "<leader>w|";
      mode = [ "n" ];
      desc = "Split Window Right";
      vim = "<C-W>v";
      idea = ":action SplitVertically<CR>";
      vscode = "workbench.action.splitEditorRight";
      remap = true;
    }
    {
      key = "<leader>wr";
      mode = [ "n" ];
      desc = "Close Other Splits";
      vim = ":only<CR>";
      idea = ":action UnsplitAll<CR>";
      vscode = "workbench.action.joinAllGroups";
    }

    # ── Save / quit / close ─────────────────────────────────────────────

    {
      key = "<C-s>";
      mode = [ "n" ];
      desc = "Save File";
      vim = ":w<CR>";
      neovim = "<cmd>w<cr><esc>";
      idea = ":action SaveAll<CR>";
      vscode = ":w";
      silent = true;
    }
    # Save in insert/other modes (neovim only)
    {
      key = "<C-s>";
      mode = [
        "i"
        "x"
        "s"
      ];
      desc = "Save File";
      neovim = "<cmd>w<cr><esc>";
    }
    {
      key = "<leader>x";
      mode = [ "n" ];
      desc = "Close Buffer/Tab";
      vim = ":bd<CR>";
      idea = ":action CloseContent<CR>";
      vscode = "workbench.action.closeActiveEditor";
      silent = true;
    }
    {
      key = "<leader>q";
      mode = [ "n" ];
      desc = "Quit";
      idea = ":action Exit<CR>";
      vscode = "workbench.action.quit";
    }

    # ── Editing enhancements ────────────────────────────────────────────

    {
      key = "Y";
      mode = [ "" ];
      desc = "Yank to end of line";
      vim = "y$";
      silent = true;
    }
    {
      key = "J";
      mode = [ "v" ];
      desc = "Move selected line down";
      vim = ":m '>+1<CR>gv=gv";
      silent = true;
    }
    {
      key = "K";
      mode = [ "v" ];
      desc = "Move selected line up";
      vim = ":m '<-2<CR>gv=gv";
      silent = true;
    }
    {
      key = "<";
      mode = [ "v" ];
      desc = "Indent left, keep selection";
      vim = "<gv";
      silent = true;
    }
    {
      key = ">";
      mode = [ "v" ];
      desc = "Indent right, keep selection";
      vim = ">gv";
      silent = true;
    }

    # ── Folding ─────────────────────────────────────────────────────────

    {
      key = "ä";
      mode = [ "n" ];
      desc = "Toggle fold at cursor";
      vim = "za";
      idea = ":action CollapseRegionRecursively<CR>";
      vscode = "editor.fold";
    }
    {
      key = "Ä";
      mode = [ "n" ];
      desc = "Unfold at cursor";
      vim = "zA";
      neovim = "<cmd>lua require('ufo').openAllFolds()<CR>";
      idea = ":action ExpandRegionRecursively<CR>";
      vscode = "editor.unfold";
    }
    {
      key = "<leader>zR";
      mode = [ "n" ];
      desc = "Open all folds";
      vim = "zR";
      neovim = "<cmd>lua require('ufo').openAllFolds()<CR>";
      idea = ":action ExpandAllRegions<CR>";
      vscode = "editor.unfoldAll";
    }
    {
      key = "<leader>zM";
      mode = [ "n" ];
      desc = "Close all folds";
      vim = "zM";
      neovim = "<cmd>lua require('ufo').closeAllFolds()<CR>";
      idea = ":action CollapseAllRegions<CR>";
      vscode = "editor.foldAll";
    }

    # ── File explorer ───────────────────────────────────────────────────

    {
      key = "<leader>e";
      mode = [ "n" ];
      desc = "Toggle File Explorer";
      vim = ":Explore<CR>";
      neovim = "<cmd>Neotree toggle<cr>";
      idea = ":action ActivateProjectToolWindow<CR>";
      vscode = "workbench.view.explorer";
    }

    # ── Comments ────────────────────────────────────────────────────────

    {
      key = "<leader>c";
      mode = [ "n" ];
      desc = "Toggle line comment";
      vim = "gcc";
      neovim = "<cmd>lua require('Comment.api').toggle.linewise.current()<CR>";
      idea = ":action CommentByLineComment<CR>";
      vscode = "editor.action.commentLine";
      remap = true;
    }
    {
      key = "<leader>c";
      mode = [ "v" ];
      desc = "Toggle block comment";
      vim = "gc";
      neovim = "<esc><cmd>lua require('Comment.api').toggle.linewise(vim.fn.visualmode())<CR>";
      idea = ":action CommentByBlockComment<CR>";
      vscode = "editor.action.blockComment";
      remap = true;
    }

    # ── LSP / Code navigation ──────────────────────────────────────────
    # neovim handles these via plugins.lsp.keymaps — set neovim = null

    {
      key = "<leader>gd";
      mode = [ "n" ];
      desc = "Goto Definition";
      idea = ":action GotoDeclaration<CR>";
      vscode = "editor.action.revealDefinition";
    }
    {
      key = "<leader>gr";
      mode = [ "n" ];
      desc = "Find References";
      idea = ":action ShowUsages<CR>";
      vscode = "references-view.findReferences";
    }
    {
      key = "<leader>gi";
      mode = [ "n" ];
      desc = "Goto Implementation";
      idea = ":action GotoImplementation<CR>";
      vscode = "editor.action.goToImplementation";
    }
    {
      key = "<leader>gD";
      mode = [ "n" ];
      desc = "Goto Type Definition";
      idea = ":action GotoTypeDeclaration<CR>";
      vscode = "editor.action.goToTypeDefinition";
    }
    {
      key = "<leader>rr";
      mode = [ "n" ];
      desc = "Rename Symbol";
      idea = ":action RenameElement<CR>";
      vscode = "editor.action.rename";
    }
    {
      key = "<leader>ca";
      mode = [ "n" ];
      desc = "Code Actions";
      idea = ":action ShowIntentionActions<CR>";
      vscode = "editor.action.quickFix";
    }

    # ── Search / Find ───────────────────────────────────────────────────

    {
      key = "<leader>ff";
      mode = [ "n" ];
      desc = "Find Files";
      neovim = "<cmd>Telescope find_files<CR>";
      idea = ":action GotoFile<CR>";
      vscode = "workbench.action.quickOpen";
      silent = true;
    }
    {
      key = "<leader>fg";
      mode = [ "n" ];
      desc = "Search in Files";
      neovim = "<cmd>Telescope live_grep<CR>";
      idea = ":action FindInPath<CR>";
      vscode = "workbench.action.findInFiles";
      silent = true;
    }
    {
      key = "<leader>fb";
      mode = [ "n" ];
      desc = "List Buffers / Recent Files";
      neovim = "<cmd>Telescope buffers<CR>";
      idea = ":action RecentFiles<CR>";
      vscode = "workbench.action.showAllEditors";
      silent = true;
    }
    {
      key = "<leader>fh";
      mode = [ "n" ];
      desc = "Search Help Tags";
      neovim = "<cmd>Telescope help_tags<CR>";
      silent = true;
    }
    {
      key = "<leader>fs";
      mode = [ "n" ];
      desc = "File Structure / Symbols";
      neovim = "<cmd>Telescope lsp_document_symbols<CR>";
      idea = ":action FileStructurePopup<CR>";
      vscode = "workbench.action.gotoSymbol";
    }
    {
      key = "<leader>fS";
      mode = [ "n" ];
      desc = "All Symbols";
      neovim = "<cmd>Telescope lsp_dynamic_workspace_symbols<CR>";
      idea = ":action GotoSymbol<CR>";
      vscode = "workbench.action.showAllSymbols";
    }
    {
      key = "<leader>fw";
      mode = [ "n" ];
      desc = "Search Everywhere";
      idea = ":action SearchEverywhere<CR>";
      vscode = "workbench.action.showCommands";
    }

    # ── Diagnostics ─────────────────────────────────────────────────────

    {
      key = "[d";
      mode = [ "n" ];
      desc = "Previous Diagnostic";
      neovim = "<cmd>lua vim.diagnostic.goto_prev()<CR>";
      idea = ":action GotoPreviousError<CR>";
      vscode = "editor.action.marker.prevInFiles";
    }
    {
      key = "]d";
      mode = [ "n" ];
      desc = "Next Diagnostic";
      neovim = "<cmd>lua vim.diagnostic.goto_next()<CR>";
      idea = ":action GotoNextError<CR>";
      vscode = "editor.action.marker.nextInFiles";
    }
    {
      key = "<leader>`";
      mode = [ "n" ];
      desc = "Show Diagnostics / Error Info";
      neovim = "<cmd>lua vim.diagnostic.open_float()<CR>";
      idea = ":action ShowErrorDescription<CR>";
      vscode = "editor.action.showHover";
      silent = true;
    }

    # ── IDE features (JetBrains + VS Code) ──────────────────────────────

    {
      key = "<leader>tt";
      mode = [ "n" ];
      desc = "Toggle Terminal";
      idea = ":action ActivateTerminalToolWindow<CR>";
      vscode = "workbench.action.terminal.toggleTerminal";
    }
    {
      key = "<leader>f";
      mode = [ "n" ];
      desc = "Format Code";
      idea = ":action ReformatCode<CR>";
      vscode = "editor.action.formatDocument";
    }
    {
      key = "<leader>o";
      mode = [ "n" ];
      desc = "Organize Imports";
      idea = ":action OptimizeImports<CR>";
      vscode = "editor.action.organizeImports";
    }
    {
      key = "<leader>ga";
      mode = [ "n" ];
      desc = "Quick Fix / Intentions";
      idea = ":action ShowIntentionActions<CR>";
      vscode = "editor.action.quickFix";
    }
    {
      key = "<leader>m";
      mode = [ "n" ];
      desc = "Toggle Bookmark";
      idea = ":action ToggleBookmark<CR>";
      vscode = "bookmarks.toggle";
    }
    {
      key = "<leader>M";
      mode = [ "n" ];
      desc = "Show Bookmarks";
      idea = ":action ShowBookmarks<CR>";
      vscode = "bookmarks.list";
    }
    {
      key = "<C-k><C-o>";
      mode = [ "n" ];
      desc = "Switch Header/Source";
      neovim = "<cmd>LspClangdSwitchSourceHeader<CR>";
      idea = ":action SwitchHeaderSource<CR>";
      vscode = "C_Cpp.SwitchHeaderSource";
      silent = true;
    }

    # ── Tab navigation (IdeaVim only) ───────────────────────────────────

    {
      key = "<Tab>";
      mode = [ "n" ];
      desc = "Next Tab";
      idea = ":action NextTab<CR>";
    }
    {
      key = "<S-Tab>";
      mode = [ "n" ];
      desc = "Previous Tab";
      idea = ":action PreviousTab<CR>";
    }

    # ── Focus editor ────────────────────────────────────────────────────

    {
      key = "<C-]><C-]>";
      mode = [ "n" ];
      desc = "Focus Editor";
      idea = ":action FocusEditor<CR>";
      vscodeNative = {
        key = "ctrl+] ctrl+]";
        command = "workbench.action.focusActiveEditorGroup";
      };
    }

    # ── Neovim-only: terminal mode ──────────────────────────────────────

    {
      key = "<C-h>";
      mode = [ "t" ];
      desc = "Go to Left Window";
      neovim = "<cmd>wincmd h<cr>";
    }
    {
      key = "<C-j>";
      mode = [ "t" ];
      desc = "Go to Lower Window";
      neovim = "<cmd>wincmd j<cr>";
    }
    {
      key = "<C-k>";
      mode = [ "t" ];
      desc = "Go to Upper Window";
      neovim = "<cmd>wincmd k<cr>";
    }
    {
      key = "<C-l>";
      mode = [ "t" ];
      desc = "Go to Right Window";
      neovim = "<cmd>wincmd l<cr>";
    }
    {
      key = "<C-/>";
      mode = [ "t" ];
      desc = "Hide Terminal";
      neovim = "<cmd>close<cr>";
    }

    # ── Neovim-only: extra diagnostics ──────────────────────────────────

    {
      key = "]e";
      mode = [ "n" ];
      desc = "Next Error";
      neovim = "<cmd>lua vim.diagnostic.goto_next({severity = vim.diagnostic.severity.ERROR})<CR>";
    }
    {
      key = "[e";
      mode = [ "n" ];
      desc = "Previous Error";
      neovim = "<cmd>lua vim.diagnostic.goto_prev({severity = vim.diagnostic.severity.ERROR})<CR>";
    }
    {
      key = "]w";
      mode = [ "n" ];
      desc = "Next Warning";
      neovim = "<cmd>lua vim.diagnostic.goto_next({severity = vim.diagnostic.severity.WARN})<CR>";
    }
    {
      key = "[w";
      mode = [ "n" ];
      desc = "Previous Warning";
      neovim = "<cmd>lua vim.diagnostic.goto_prev({severity = vim.diagnostic.severity.WARN})<CR>";
    }

    # ── Neovim-only: editing extras ─────────────────────────────────────

    {
      key = "d)";
      mode = [ "n" ];
      desc = "Delete up to next parenthesis";
      neovim = "d])";
      silent = true;
    }
    {
      key = "c)";
      mode = [ "n" ];
      desc = "Change up to next parenthesis";
      neovim = "c])";
      silent = true;
    }
    {
      key = "ns";
      mode = [ "n" ];
      desc = "Next spelling error";
      neovim = "]s";
      silent = true;
    }
    {
      key = "ps";
      mode = [ "n" ];
      desc = "Previous spelling error";
      neovim = "[s";
      silent = true;
    }
    {
      key = "Q";
      mode = [ "n" ];
      desc = "Quit all";
      neovim = "<cmd>qa<CR>";
      silent = true;
    }

    # ── Neovim-only: extra window aliases ───────────────────────────────

    {
      key = "<leader>wb";
      mode = [ "n" ];
      desc = "Split Window Below";
      neovim = "<C-W>s";
      remap = true;
    }
    {
      key = "<leader>|";
      mode = [ "n" ];
      desc = "Split Window Right";
      neovim = "<C-W>v";
      remap = true;
    }

    # ── Neovim-only: extra fold aliases (ufo) ───────────────────────────

    {
      key = "zR";
      mode = [ "n" ];
      desc = "Open all folds (ufo)";
      neovim = "<cmd>lua require('ufo').openAllFolds()<CR>";
    }
    {
      key = "zM";
      mode = [ "n" ];
      desc = "Close all folds (ufo)";
      neovim = "<cmd>lua require('ufo').closeAllFolds()<CR>";
    }

    # ── Neovim-only: Neotree reveal ────────────────────────────────────

    {
      key = "<leader>er";
      mode = [ "n" ];
      desc = "Reveal current file in explorer";
      neovim = "<cmd>Neotree reveal<cr>";
    }
  ];
}
