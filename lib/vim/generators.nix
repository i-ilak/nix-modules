{ lib }:
let
  keybindings = import ./keybindings.nix;

  inherit (builtins)
    filter
    map
    elemAt
    replaceStrings
    ;
  inherit (lib)
    concatMapStringsSep
    optionalString
    ;

  # ── Helpers ─────────────────────────────────────────────────────────

  # Resolve the action for a target, with fallback chain:
  #   neovim -> vim,  idea -> vim,  vscode -> no fallback
  resolveAction =
    target: km:
    if target == "neovim" then
      km.neovim or km.vim or null
    else if target == "idea" then
      km.idea or km.vim or null
    else if target == "vscode" then
      km.vscode or null
    else
      km.vim or null;

  hasTarget = target: km: (resolveAction target km) != null;

  # Filter keymaps that have an action for the given target
  forTarget = target: filter (hasTarget target) keybindings.keymaps;

  # Escape | in vimscript key (| is a command separator)
  escapeVimKey = replaceStrings [ "|" ] [ "\\|" ];

  # Vimscript map command prefix
  mapCmd =
    mode: remap:
    let
      table = {
        "n" = if remap then "nmap" else "nnoremap";
        "v" = if remap then "vmap" else "vnoremap";
        "i" = if remap then "imap" else "inoremap";
        "t" = if remap then "tmap" else "tnoremap";
        "x" = if remap then "xmap" else "xnoremap";
        "s" = if remap then "smap" else "snoremap";
        "" = if remap then "map" else "noremap";
      };
    in
    table.${mode};

  # Generate one vimscript mapping line
  vimLine =
    target: km: mode:
    let
      cmd = mapCmd mode (km.remap or false);
      silentFlag = optionalString (km.silent or false) " <silent>";
      key = escapeVimKey km.key;
      action = resolveAction target km;
    in
    "${cmd}${silentFlag} ${key} ${action}";

  # Parse a vim key notation into VS Code "before" array
  # e.g. "<leader>gd" -> ["<leader>" "g" "d"]
  #      "<C-k><C-o>" -> ["<C-k>" "<C-o>"]
  #      "[d"         -> ["[" "d"]
  #
  # Nix regex and stringToCharacters operate on bytes, not Unicode codepoints.
  # We handle known multi-byte keys (ä, Ä, etc.) via placeholder substitution.
  knownMultibyteKeys = {
    "ä" = "<_MB_ae_>";
    "Ä" = "<_MB_AE_>";
  };
  multibytePlaceholders = lib.attrsets.mapAttrs' (
    k: v: lib.attrsets.nameValuePair v k
  ) knownMultibyteKeys;

  parseVscodeKey =
    key:
    let
      # Replace multi-byte chars with ASCII placeholders
      sanitized =
        replaceStrings (builtins.attrNames knownMultibyteKeys) (builtins.attrValues knownMultibyteKeys)
          key;

      go =
        s:
        if s == "" then
          [ ]
        else
          let
            special = builtins.match "(<[^>]+>)(.*)" s;
            char = builtins.match "(.)(.*)" s;
          in
          if special != null then
            [ (elemAt special 0) ] ++ go (elemAt special 1)
          else if char != null then
            [ (elemAt char 0) ] ++ go (elemAt char 1)
          else
            [ s ];

      tokens = go sanitized;

      # Restore multi-byte chars from placeholders
      restore =
        t:
        replaceStrings (builtins.attrNames multibytePlaceholders)
          (builtins.attrValues multibytePlaceholders)
          t;
    in
    map restore tokens;

  # Generate one VS Code vim binding attrset
  vscodeBinding =
    km:
    let
      before = parseVscodeKey km.key;
      action = resolveAction "vscode" km;
    in
    {
      inherit before;
      commands = [ action ];
    };

  # ── Generators ──────────────────────────────────────────────────────

  generateVimrc =
    {
      extraConfig ? "",
    }:
    let
      s = keybindings.settings;

      settingsBlock = ''
        " Leader key
        let mapleader = "${s.leader}"

        " Settings
        ${optionalString s.vim.showmode "set showmode"}
        set scrolloff=${toString s.vim.scrolloff}
        ${optionalString s.vim.incsearch "set incsearch"}
        ${optionalString s.vim.number "set number"}
        ${optionalString s.vim.relativenumber "set relativenumber"}
      '';

      kms = forTarget "vim";

      # Group by mode, generate mapping lines
      mappingLines = concatMapStringsSep "\n" (
        km: concatMapStringsSep "\n" (mode: vimLine "vim" km mode) km.mode
      ) kms;
    in
    ''
      ${settingsBlock}
      " Keybindings
      ${mappingLines}
      ${optionalString (extraConfig != "") "\n${extraConfig}"}
    '';

  generateIdeavimrc =
    {
      extraConfig ? "",
    }:
    let
      s = keybindings.settings;

      header = ''
        " Leader key
        let mapleader = "${s.leader}"

        " IdeaVim Plugins
        ${concatMapStringsSep "\n" (p: "set ${p}") s.idea.plugins}

        " IdeaVim Settings
        ${concatMapStringsSep "\n" (
          name:
          let
            v = s.idea.settings.${name};
          in
          if builtins.isBool v then
            (if v then "set ${name}" else "set no${name}")
          else
            "set ${name}=${toString v}"
        ) (builtins.attrNames s.idea.settings)}
        set clipboard+=${s.idea.clipboard}

        " Shared vim settings
        ${optionalString s.vim.showmode "set showmode"}
        set scrolloff=${toString s.vim.scrolloff}
        ${optionalString s.vim.incsearch "set incsearch"}
        ${optionalString s.vim.number "set number"}
        ${optionalString s.vim.relativenumber "set relativenumber"}
      '';

      kms = forTarget "idea";

      mappingLines = concatMapStringsSep "\n" (
        km: concatMapStringsSep "\n" (mode: vimLine "idea" km mode) km.mode
      ) kms;
    in
    ''
      ${header}
      " Keybindings
      ${mappingLines}
      ${optionalString (extraConfig != "") "\n${extraConfig}"}
    '';

  generateVscodeSettings =
    {
      extraSettings ? { },
    }:
    let
      s = keybindings.settings;

      kms = forTarget "vscode";

      # Partition keymaps by mode
      normalKms = filter (km: builtins.elem "n" km.mode && (resolveAction "vscode" km) != null) kms;
      visualKms = filter (km: builtins.elem "v" km.mode && (resolveAction "vscode" km) != null) kms;

      remap = km: km.remap or false;

      # Split normal bindings by remap
      normalNonRecursive = map vscodeBinding (filter (km: !(remap km)) normalKms);
      normalRecursive = map vscodeBinding (filter remap normalKms);
      visualNonRecursive = map vscodeBinding (filter (km: !(remap km)) visualKms);
      visualRecursive = map vscodeBinding (filter remap visualKms);
    in
    {
      "vim.leader" = s.leader;
    }
    // s.vscode
    // (
      if normalNonRecursive != [ ] then
        { "vim.normalModeKeyBindingsNonRecursive" = normalNonRecursive; }
      else
        { }
    )
    // (if normalRecursive != [ ] then { "vim.normalModeKeyBindings" = normalRecursive; } else { })
    // (
      if visualNonRecursive != [ ] then
        { "vim.visualModeKeyBindingsNonRecursive" = visualNonRecursive; }
      else
        { }
    )
    // (if visualRecursive != [ ] then { "vim.visualModeKeyBindings" = visualRecursive; } else { })
    // s.vscodeExtra
    // extraSettings;

  generateVscodeKeybindings =
    {
      extraKeybindings ? [ ],
    }:
    let
      native = filter (km: (km.vscodeNative or null) != null) keybindings.keymaps;
    in
    (map (km: km.vscodeNative) native) ++ extraKeybindings;

  nixvimKeymaps =
    let
      kms = forTarget "neovim";
    in
    builtins.concatMap (
      km:
      let
        action = resolveAction "neovim" km;
        modes = km.mode;
      in
      map (mode: {
        inherit mode action;
        inherit (km) key;
        options = {
          inherit (km) desc;
        }
        // (if km.silent or false then { silent = true; } else { })
        // (if km.remap or false then { remap = true; } else { noremap = true; });
      }) modes
    ) kms;

  nixvimGlobals = {
    mapleader = keybindings.settings.leader; # statix false positive: attr name differs
  };

in
{
  inherit keybindings;
  inherit
    generateVimrc
    generateIdeavimrc
    generateVscodeSettings
    generateVscodeKeybindings
    nixvimKeymaps
    nixvimGlobals
    ;
}
