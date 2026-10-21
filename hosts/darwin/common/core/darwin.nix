# Core functionality shared by every nix-darwin host.
{ pkgs, ... }:
{
  # Determinate Nix owns /etc/nix/nix.conf; don't let nix-darwin's nix module fight it.
  nix.enable = false;

  nixpkgs.config.allowUnfree = true;

  # nix-darwin 26.05: primary-user options (homebrew, defaults) apply to this user.
  system.primaryUser = "tane.barriball";

  # TODO: confirm against `sw_vers` (macOS 26 Tahoe -> 6; Sequoia 15 -> 5).
  system.stateVersion = 6;

  # zsh must be in /etc/shells for users.users.<name>.shell to apply.
  environment.shells = [ pkgs.zsh ];

  # The account already exists (created by IT/MDM); set its shell + home.
  users.users."tane.barriball" = {
    home = "/Users/tane.barriball";
    shell = pkgs.zsh;
  };

  # Homebrew formulae + casks. Best-effort under MDM; some may be blocked.
  homebrew = {
    enable = true;
    brews = [
      "gh"
      "jq"
      "watch"
    ];
    casks = [
      "visual-studio-code"
      "slack"
      "bitwarden"
      "orbstack"
    ];
  };

  # macOS defaults; starter set, MDM may revert some.
  system.defaults = {
    dock.autohide = true;
    finder.AppleShowAllExtensions = true;
    NSGlobalDomain.AppleShowAllExtensions = true;
    trackpad.Clicking = true;
  };
}
