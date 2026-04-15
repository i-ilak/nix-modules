{
  ...
}:
{
  power.sleep.display = "never";

  # systemsetup (used by nix-darwin's power.sleep.display) is deprecated on
  # modern macOS and its changes don't propagate to pmset. Set it via pmset
  # directly so the setting actually takes effect.
  system.activationScripts.postActivation.text = ''
    pmset -a displaysleep 0
  '';
}
