# Secrets Restructure Implementation Plan

> **Status (2026-09-24):** Execution scope cut by user decision mid-run.
> Task 1 (cleanup) and the `common.yaml` creation rule (part of Task 2) were
> implemented. All per-user secrets work (Tasks 3–6 and the rest of Task 2:
> age key, `secrets/users/`, home-manager sops, bootstrap stanzas) is
> **deferred** — `deepseek-api-key` stays in the per-host files with the
> existing `hostSecretsPath` wiring. The spec remains the design to return
> to when per-user secrets are wanted.

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Reorganize the repo's secrets so user secrets live in per-user files encrypted to per-user age keys (never host keys), and machine secrets live in shared (`common.yaml`) and per-host files.

**Architecture:** System-level sops-nix keeps decrypting machine secrets (host ssh keys). Each user's home config imports the home-manager sops module, decrypting their own `secrets/users/<name>.yaml` with their age key, which is provisioned declaratively: the private key is stored encrypted in each host's machine file and decrypted by system sops to `/run/secrets/taneb-age-key`.

**Tech Stack:** NixOS flake, sops-nix (system + home-manager modules), colmena, age.

**Spec:** `docs/superpowers/specs/2026-09-24-secrets-restructure-design.md`

## Global Constraints

- User secret files are encrypted ONLY to that user's age key; host files ONLY to that host's key; `common.yaml` to host keys + user pubkeys.
- No `hostSecretsPath` specialArgs — per-host machine secrets use relative `sopsFile` paths in host modules.
- **Do not run `nixos-rebuild switch` (or colmena apply) on melchior until Tasks 3 and 4 are committed** — between the code rewire and the secret-file migration, activation would fail.
- wsl-builder is offline: never deploy or test there; its configuration must still evaluate (`nix flake check`) and build.
- All secret files are committed encrypted; plaintext values never touch git.
- User secrets are declared in each user's home module (separate namespaces — no cross-user name collisions possible).
- All commit messages end with the trailer `Co-Authored-By: Claude <noreply@anthropic.com>`.

## Review Focus

1. **Applying before migration completes** (switch after Task 5's commit but before 3–4, or any partial state) breaks activation with sops decrypt errors. → Pinned by Global Constraints + Task 5's warning step; proven by Task 6's runtime checks.
2. **`users/taneb.yaml` accidentally encrypted to host keys** would silently defeat the isolation this whole change exists for. → Task 3's verify step counts recipients and asserts only `taneb_user`'s pubkey is present.
3. **Missing or wrong `taneb-age-key` value** → home-manager sops fails loudly at login (`generateKey = false`), user sees broken ANTHROPIC_AUTH_TOKEN. → Task 4 verifies the decrypted host yaml contains both key lines; Task 6 checks `/run/secrets/taneb-age-key` exists and is 0400.
4. **`common.yaml` has no creation rule today** (the stale `secrets/secrets.yaml` rule is its leftover from a rename) — editing common.yaml would fail until a rule exists. → Task 2 creates the `common.yaml` rule; Task 3-style recipient checks confirm the existing file matches it.
5. **wsl-builder forgotten when it comes back online** — its migration (host yaml edit done in Task 4, config from Task 5) would never be applied. → Task 6's final step documents the deploy commands and checks to run then.

---

### Task 1: Cleanup — delete dead module and stale sops rule

**Files:**
- Delete: `modules/configuration.nix`
- Modify: `.sops.yaml`

**Interfaces:**
- Consumes: nothing.
- Produces: `.sops.yaml` with only host rules (flow-style `age: [...]` lists); no references to `modules/configuration.nix` anywhere.

- [ ] **Step 1: Delete the dead module**

```bash
rm modules/configuration.nix
```

- [ ] **Step 2: Update `.sops.yaml`**

Remove the stale `secrets/secrets.yaml$` rule and normalize the remaining two rules to flow-style lists. The file becomes:

```yaml
keys:
  - &melchior age16z5tcjvw0zh4q7df3hwsa66wdsd7cckmr3cpgh7hwamdea68lpts94sae3
  - &wsl_builder age1ksap09kgagxk8jkzmqel5df5vukcec62sq57x4cmyxcmmw50ue0sctm0k9
creation_rules:
  - path_regex: secrets/melchior\.yaml$
    key_groups:
    - age: [*melchior]
  - path_regex: secrets/wsl-builder\.yaml$
    key_groups:
    - age: [*wsl_builder]
```

- [ ] **Step 3: Verify nothing references the deleted module and the flake still checks**

```bash
grep -rn "modules/configuration" --exclude-dir=.git . ; test $? -eq 1
nix flake check
```

Expected: grep finds nothing (exit 1), `nix flake check` passes.

- [ ] **Step 4: Commit**

```bash
git add -A modules/configuration.nix .sops.yaml
git commit -m "chore: remove dead configuration.nix and stale sops rule"
```

---

### Task 2: Generate taneb's age key and add creation rules

**Files:**
- Modify: `.sops.yaml`

**Interfaces:**
- Consumes: Task 1's cleaned `.sops.yaml`.
- Produces: `&taneb_user` anchor (taneb's age pubkey), a `secrets/users/taneb\.yaml$` rule → `[*taneb_user]`, and a `secrets/common\.yaml$` rule → `[*melchior, *wsl_builder, *taneb_user]`.

- [ ] **Step 1: Generate taneb's user age keypair (user action)**

Run and keep the output safe; paste the `age1...` public key into the next step:

```bash
age-keygen -o ~/.config/sops/age/keys.txt
```

- [ ] **Step 2: Add the anchor and the two creation rules**

`.sops.yaml` becomes (substitute the real public key for `<taneb-user-pubkey>`, which is the `# public key:` line of keys.txt):

```yaml
keys:
  - &melchior age16z5tcjvw0zh4q7df3hwsa66wdsd7cckmr3cpgh7hwamdea68lpts94sae3
  - &wsl_builder age1ksap09kgagxk8jkzmqel5df5vukcec62sq57x4cmyxcmmw50ue0sctm0k9
  - &taneb_user <taneb-user-pubkey>
creation_rules:
  - path_regex: secrets/common\.yaml$
    key_groups:
    - age: [*melchior, *wsl_builder, *taneb_user]
  - path_regex: secrets/melchior\.yaml$
    key_groups:
    - age: [*melchior]
  - path_regex: secrets/wsl-builder\.yaml$
    key_groups:
    - age: [*wsl_builder]
  - path_regex: secrets/users/taneb\.yaml$
    key_groups:
    - age: [*taneb_user]
```

- [ ] **Step 3: Verify existing files still decrypt and rules reference the right keys**

```bash
sops --config .sops.yaml decrypt secrets/common.yaml >/dev/null && echo "common.yaml decrypts"
grep -c "recipient:" secrets/common.yaml          # expect 2 (existing recipients, unchanged)
grep -c "&taneb_user" .sops.yaml                   # expect 1
grep -c "secrets/common" .sops.yaml                # expect 1 (the new rule)
grep -c "secrets/users" .sops.yaml                 # expect 1 (the new rule)
```

Expected: `common.yaml decrypts` (requires your local sops keys as today), counts `2`, `1`, `1`, `1`.

- [ ] **Step 4: Commit**

```bash
git add .sops.yaml
git commit -m "chore(sops): add user key and common/users creation rules"
```

---

### Task 3: Create secrets/users/taneb.yaml with the user secret

**Files:**
- Create: `secrets/users/taneb.yaml`

**Interfaces:**
- Consumes: Task 2's `users/` creation rule and `&taneb_user` anchor; the existing `deepseek-api-key` value in `secrets/melchior.yaml`.
- Produces: `secrets/users/taneb.yaml` containing `deepseek-api-key`, encrypted to `taneb_user` only. Later tasks reference it as `../secrets/users/taneb.yaml` and the home sops secret name `deepseek-api-key`.

- [ ] **Step 1: Recover the plaintext value**

```bash
sops --config .sops.yaml decrypt secrets/melchior.yaml
```

Expected: output shows `deepseek-api-key: <the key>`.

- [ ] **Step 2: Write the plaintext file at its final path**

```bash
mkdir -p secrets/users
cat > secrets/users/taneb.yaml <<'EOF'
deepseek-api-key: <PASTE THE VALUE FROM STEP 1>
EOF
```

- [ ] **Step 3: Encrypt in place (creation rule matches the path)**

```bash
sops --config .sops.yaml -e -i secrets/users/taneb.yaml
```

- [ ] **Step 4: Verify encryption targets and content**

```bash
grep -c "recipient:" secrets/users/taneb.yaml
grep "recipient:" secrets/users/taneb.yaml
sops --config .sops.yaml decrypt secrets/users/taneb.yaml
```

Expected: exactly 1 recipient, matching the `&taneb_user` pubkey from `.sops.yaml`; decrypted output shows `deepseek-api-key`. No melchior/wsl-builder pubkey may appear in the file.

- [ ] **Step 5: Commit**

```bash
git add secrets/users/taneb.yaml
git commit -m "feat(secrets): per-user secret file for taneb"
```

---

### Task 4: Migrate host yamls — drop user secret, add age-key bootstrap

**Files:**
- Modify: `secrets/melchior.yaml`, `secrets/wsl-builder.yaml`

**Interfaces:**
- Consumes: Task 2's rules; taneb's age private key (keys.txt).
- Produces: each host yaml containing `taneb-age-key` (the two-line age private key, encrypted to that host's key only) and no `deepseek-api-key`. Task 5's config references these as system secret `taneb-age-key` → `/run/secrets/taneb-age-key`.

- [ ] **Step 1: Decrypt melchior.yaml to a working copy and edit it**

```bash
sops --config .sops.yaml decrypt secrets/melchior.yaml > /tmp/melchior.plain.yaml
```

Edit `/tmp/melchior.plain.yaml`: delete the `deepseek-api-key` line and append the contents of `~/.config/sops/age/keys.txt` as a block scalar:

```yaml
taneb-age-key: |
  # created: <date line from keys.txt>
  # public key: age1...
  AGE-SECRET-KEY-1...
```

- [ ] **Step 2: Encrypt melchior.yaml in place**

```bash
cp /tmp/melchior.plain.yaml secrets/melchior.yaml
sops --config .sops.yaml -e -i secrets/melchior.yaml
rm /tmp/melchior.plain.yaml
```

- [ ] **Step 3: Repeat for wsl-builder.yaml**

```bash
sops --config .sops.yaml decrypt secrets/wsl-builder.yaml > /tmp/wsl-builder.plain.yaml
```

Edit `/tmp/wsl-builder.plain.yaml` exactly as in Step 1: delete the `deepseek-api-key` line and append the same `taneb-age-key: |` block with the contents of `~/.config/sops/age/keys.txt`.

```bash
cp /tmp/wsl-builder.plain.yaml secrets/wsl-builder.yaml
sops --config .sops.yaml -e -i secrets/wsl-builder.yaml
rm /tmp/wsl-builder.plain.yaml
```

- [ ] **Step 4: Verify both files**

```bash
for f in secrets/melchior.yaml secrets/wsl-builder.yaml; do
  sops --config .sops.yaml decrypt "$f" | grep -q "taneb-age-key" && echo "$f: age key present"
  sops --config .sops.yaml decrypt "$f" | grep -q "deepseek-api-key" && echo "$f: ERROR deepseek still present"
  echo "$f recipients: $(grep -c 'recipient:' $f)"   # expect 1
done
```

Expected: both files have `age key present`, no ERROR line, 1 recipient each (their own host key).

- [ ] **Step 5: Commit**

```bash
git add secrets/melchior.yaml secrets/wsl-builder.yaml
git commit -m "feat(secrets): bootstrap taneb's age key via host files"
```

---

### Task 5: Rewire nix code — drop hostSecretsPath, add home-manager sops

**Files:**
- Modify: `flake.nix`, `modules/common.nix`, `users/taneb.nix`, `hosts/melchior/default.nix`, `hosts/wsl-builder/default.nix`

**Interfaces:**
- Consumes: `secrets/users/taneb.yaml` (Task 3), `taneb-age-key` entries in host yamls (Task 4).
- Produces: eval-clean flake; system secret `sops.secrets.taneb-age-key` (owner taneb, mode 0400) on each host; home-manager sops config with `sops.secrets.deepseek-api-key` for taneb.

- [ ] **Step 1: Edit `flake.nix` — remove all hostSecretsPath plumbing**

In both `nixosConfigurations` entries, reduce specialArgs:

```nix
          specialArgs = {
            inherit inputs;
          };
```

In `colmena.meta`, delete the entire `nodeSpecialArgs` block:

```nix
        meta = {
          nixpkgs = import nixpkgs {
            system = "x86_64-linux";
          };
          specialArgs = { inherit inputs; };
        };
```

- [ ] **Step 2: Edit `modules/common.nix`**

Remove `hostSecretsPath` from the function arguments (line 5), and delete this block:

```nix
  sops.secrets.deepseek-api-key = {
    owner = config.users.users.taneb.name;
    sopsFile = hostSecretsPath;
  };
```

In the home-manager section, after `home-manager.backupFileExtension = "backup";`, add:

```nix
  home-manager.extraSpecialArgs = {
    inherit inputs;
  };
```

- [ ] **Step 3: Rewrite `users/taneb.nix`**

Full new content:

```nix
{
  config,
  pkgs,
  nixosConfig,
  inputs,
  ...
}:

{
  imports = [
    ../modules/home.nix
    inputs.sops-nix.homeManagerModules.sops
  ];

  sops = {
    defaultSopsFile = ../secrets/users/taneb.yaml;
    age.keyFile = "${nixosConfig.sops.secrets.taneb-age-key.path}";
    age.generateKey = false;
  };

  sops.secrets.deepseek-api-key = { };

  home.packages = with pkgs; [
    claude-code
    bitwarden-cli
  ];

  programs = {
    bash = {
      enable = true;
      initExtra = ''
        export ANTHROPIC_AUTH_TOKEN="$(cat ${config.sops.secrets.deepseek-api-key.path})"
      '';
    };
    git = {
      enable = true;
      settings.user = {
        name = "Tane Barriball";
        email = "tane.barriball@gmail.com";
      };
    };
  };

  home.sessionVariables = {
    ANTHROPIC_BASE_URL = "https://api.deepseek.com/anthropic";
    ANTHROPIC_MODEL = "deepseek-v4-pro[1m]";
    ANTHROPIC_DEFAULT_OPUS_MODEL = "deepseek-v4-pro[1m]";
    ANTHROPIC_DEFAULT_SONNET_MODEL = "deepseek-v4-pro[1m]";
    ANTHROPIC_DEFAULT_HAIKU_MODEL = "deepseek-v4-flash";
    CLAUDE_CODE_SUBAGENT_MODEL = "deepseek-flash";
    CLAUDE_CODE_EFFORT_LEVEL = "max";
  };
}
```

- [ ] **Step 4: Add the bootstrap stanza to each host module**

`hosts/melchior/default.nix`, before the final `}`:

```nix
  # ── Secrets ─────────────────────────────────────────────
  sops.secrets.taneb-age-key = {
    sopsFile = ../../secrets/melchior.yaml;
    owner = "taneb";
    mode = "0400";
  };
```

`hosts/wsl-builder/default.nix` gets the same stanza with `sopsFile = ../../secrets/wsl-builder.yaml;`.

- [ ] **Step 5: Verify — flake check, eval spot-checks, dry-build**

```bash
nix flake check
nix eval --json .#nixosConfigurations.melchior.config.sops.secrets.taneb-age-key.owner   # "taneb"
nix eval --json .#nixosConfigurations.melchior.config.home-manager.users.taneb.sops.age.keyFile  # "/run/secrets/taneb-age-key"
nix eval --json .#nixosConfigurations.melchior.config.home-manager.users.taneb.sops.secrets.deepseek-api-key.path  # under ~/.config/sops-nix/secrets/
nixos-rebuild dry-build --flake .#melchior
```

Expected: all pass; dry-build succeeds.

> **Do NOT run `nixos-rebuild switch` yet** — Tasks 3–4 are committed at this point (this task is ordered after them), so a switch after this step is safe, but the plan applies in Task 6 so the runtime checks follow immediately.

- [ ] **Step 6: Commit**

```bash
git add flake.nix modules/common.nix users/taneb.nix hosts/melchior/default.nix hosts/wsl-builder/default.nix
git commit -m "feat: per-user sops secrets with declarative age-key bootstrap"
```

---

### Task 6: Apply on melchior and verify at runtime

**Files:** none (deployment only)

**Interfaces:**
- Consumes: all committed changes from Tasks 1–5.

- [ ] **Step 1: Apply on melchior**

```bash
sudo nixos-rebuild switch --flake .#melchior
```

(Or your usual colmena flow: `colmena apply` targeting melchior.)

- [ ] **Step 2: Verify the bootstrap key landed**

```bash
ls -l /run/secrets/taneb-age-key
```

Expected: `-r--------` owned by `taneb` (Review Focus #3: if missing or root-owned, home sops will fail).

- [ ] **Step 3: Verify the user secret decrypts**

```bash
cat ~/.config/sops-nix/secrets/deepseek-api-key
```

Expected: prints the API key (matches what was in the old `secrets/melchior.yaml`).

- [ ] **Step 4: Verify the shell wiring**

```bash
bash -i -c 'echo $ANTHROPIC_AUTH_TOKEN'
```

Expected: prints the API key.

- [ ] **Step 5: Note wsl-builder (do not run now — it is offline)**

When wsl-builder is next reachable, apply there and repeat Steps 2–4:

```bash
colmena apply   # or: on wsl-builder, nixos-rebuild switch --flake .#wsl-builder
ls -l /run/secrets/taneb-age-key
cat ~/.config/sops-nix/secrets/deepseek-api-key
bash -i -c 'echo $ANTHROPIC_AUTH_TOKEN'
```
