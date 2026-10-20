# Common git aliases.
{ ... }:
{
  programs.git.settings.alias = {
    st = "status -sb";
    lg = "log --oneline --graph --decorate --all -20";
    co = "checkout";
    cb = "checkout -b";
    br = "branch";
    ci = "commit";
    cm = "commit -m";
    ca = "commit --amend";
    can = "commit --amend --no-edit";
    d = "diff";
    dc = "diff --cached";
    ds = "diff --stat";
    last = "log -1 HEAD --stat";
    pushf = "push --force-with-lease";
    undo = "reset --soft HEAD~1";
    unstage = "reset HEAD --";
    aliases = "!git config --get-regexp '^alias\\.'";
  };
}
