# Format all Nix files (treefmt: nixfmt)
fmt:
    nix --extra-experimental-features 'nix-command flakes' fmt

# Run all flake checks (tests)
check:
    nix --extra-experimental-features 'nix-command flakes' flake check

# Lint Nix code with statix
lint:
    nix --extra-experimental-features 'nix-command flakes' run nixpkgs#statix -- check .

# Find dead/unused Nix code
deadnix:
    nix --extra-experimental-features 'nix-command flakes' run nixpkgs#deadnix -- .

# Update all flake inputs
update:
    nix --extra-experimental-features 'nix-command flakes' flake update

# Update a single flake input
update-input input:
    nix --extra-experimental-features 'nix-command flakes' flake update {{input}}
