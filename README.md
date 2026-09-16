# thestranger

NixOS 26.05 for a Framework Laptop 13 Pro, Intel Core Ultra Series 3, user `vechs`.
Melbourne time, US keyboard, Catppuccin Mocha. Dependencies are pinned in `flake.lock`.

This repository prepares the configuration; it has not installed or boot-tested the laptop.
Before installation, set the internal disk ID and collect the real hardware report.
Those requirements deliberately block the normal system build until completed.

## Structure

This follows the [Dendritic pattern](https://github.com/mightyiam/dendritic): every
file under `modules/features` is a flake-parts module. A feature can contribute both
`flake.modules.nixos.<feature>` and `flake.modules.homeManager.<feature>`.
`import-tree` discovers features; the host explicitly composes them. Inputs are
captured by the outer module, without global `specialArgs` plumbing.

- `flake.nix`: inputs, automatic feature imports, formatting/development shell.
- `modules/hosts/thestranger/default.nix`: host composition and hardware profile.
- `modules/hosts/thestranger/facter.json`: replace the empty scaffold on the laptop.
- `modules/features/`: system and user features grouped by purpose.
- `assets/wallpaper.svg`: local Mocha wallpaper, converted to PNG for awww.
- `examples/quadlets/`: opt-in rootless container example.
- `tests/eval.nix`: full derivation evaluation with only the two installation prerequisites omitted.

The existing empty scaffolds for other hosts are not imported or changed.
Home Manager activates as part of the NixOS rebuild; there is no separate home-manager switch.

## Storage

Only the internal disk appears in disko. The 1 TiB USB-C expansion drive is left alone,
including after installation, until you intentionally repurpose it.

| Partition/subvolume | Mount | Allocation |
| --- | --- | --- |
| EFI system partition | `/boot` | 1 GiB, FAT32, unencrypted |
| LUKS2 + Btrfs | all below | remainder of internal disk |
| `@root` | `/` | shared free space |
| `@home` | `/home` | shared free space |
| `@nix` | `/nix` | shared free space |
| `@log` | `/var/log` | shared free space |
| `@snapshots` | `/.snapshots` | shared free space |

There are no fixed `/nix` or `/home` sizes. Btrfs uses light Zstd compression,
monthly scrubs and weekly trim. LUKS allows discard so trim reaches the SSD;
this reveals allocated-block patterns. Set `settings.allowDiscards = false` in
`storage.nix` if that tradeoff is unwanted.

Zram provides compressed RAM swap. Hibernation is not configured: its encrypted
swap sizing and Btrfs resume offset need a separate decision. Snapshots are not
automatically created or retained; the subvolume is reserved for an eventual
snapshot policy. Snapshots on the same disk are not a backup.

Tang/Clevis is intentionally omitted following the wireless-only boot decision.
Unlock with a LUKS passphrase. The login password for `vechs` is a separate credential.
Secure Boot is not configured; disable it for this installation. LUKS encrypts data,
but does not authenticate the unencrypted EFI boot files.

## Install on the laptop

Use a current NixOS 26.05 installer with a kernel supporting this hardware, following
[Framework's installation guidance](https://guides.frame.work/Guide/NixOS+on+the+Framework+Laptop+13+Pro/780?lang=en).
Connect Wi-Fi in the live environment and copy this repository to a writable directory.
Do not run disk commands on the development Mac.

1. Identify the internal NVMe by model, serial and size:

   ```sh
   lsblk -d -o NAME,SIZE,MODEL,SERIAL,TRAN
   ls -l /dev/disk/by-id/nvme-*
   ```

   Add `thestranger.diskDevice = "/dev/disk/by-id/nvme-YOUR_INTERNAL_DRIVE";`
   to the host's NixOS settings beside `networking.hostName`. Select the whole-disk
   ID, not a `-partN` link and never the USB installer. Review `storage.nix`.

2. Capture hardware on the actual laptop, not on another machine:

   ```sh
   sudo nix --extra-experimental-features 'nix-command flakes' run \
     --inputs-from . nixpkgs#nixos-facter -- > /tmp/thestranger-facter.json
   nix run --inputs-from . nixpkgs#jq -- empty /tmp/thestranger-facter.json
   cp /tmp/thestranger-facter.json modules/hosts/thestranger/facter.json
   ```

   If you put the repository in Git, add all required files (including the report)
   before evaluating the flake. Review the report before publishing it; hardware
   identifiers can be identifying. Facter supplies hardware detection; disko
   supplies filesystems. Do not also import a generated hardware-configuration.nix.

3. Evaluate and review the final configuration:

   ```sh
   nix flake check --no-build
   nix eval --raw .#nixosConfigurations.thestranger.config.system.build.toplevel.drvPath
   nix eval --json .#nixosConfigurations.thestranger.config.disko.devices.disk.internal.device
   ```

4. **The next command erases the selected internal disk.** Check the printed device
   ID against step 1 first. Disko prompts for the LUKS passphrase; keep it recoverable.

   ```sh
   sudo nix --extra-experimental-features 'nix-command flakes' run \
     --inputs-from . disko -- --mode destroy,format,mount --flake .#thestranger
   sudo nixos-install --flake .#thestranger
   sudo nixos-enter --root /mnt -c 'passwd vechs'
   ```

   Do not skip `passwd vechs`: no default password or autologin is supplied.
   `nixos-install` also prompts for the root password unless told otherwise.

5. Copy the configuration onto the installed system before rebooting:

   ```sh
   sudo mkdir -p /mnt/home/vechs/nixos
   sudo cp -a . /mnt/home/vechs/nixos/
   sudo nixos-enter --root /mnt -c 'chown -R vechs:users /home/vechs/nixos'
   sudo reboot
   ```

   Boot the internal disk, unlock LUKS, log in at tuigreet, and connect Wi-Fi again
   through Noctalia or `nmtui`. Live installer Wi-Fi credentials are not copied.
   Back up the LUKS header to a separate secure device after installation using
   `cryptsetup luksHeaderBackup`; do not store the only copy on this laptop.

## Desktop

MangoWM/MangoWC handles windows; Noctalia v5 provides notifications and desktop
controls. Waybar is the visible bar. Walker uses Elephant for applications,
calculator, commands and symbols. Cliphist owns clipboard history; awww owns
wallpaper; gammastep owns gamma adjustment. Noctalia's overlapping services and
application theme writing are disabled so Stylix remains authoritative.

See [SHORTCUTS.md](SHORTCUTS.md) for the complete keyboard and mouse reference,
or press **Super+F1** to open it in Ghostty. Common entry points are Super+Enter
for the terminal, Super+Space for Walker, Super+comma for Noctalia, and
Super+Shift+L to lock.

The session imports Wayland variables before starting user services, and stops
the graphical targets on logout. Swayidle locks after 10 minutes and before sleep.
Waybar's idle-inhibitor button suppresses idle locking while needed. Noctalia's
own idle rules are not enabled. Gammastep uses Melbourne coordinates with
6500 K daytime and 4000 K night; change coordinates when relocating.

Grimblast is installed as requested, but it relies on Hyprland-specific interfaces.
The working Mango binding therefore uses grim + slurp + Satty. Firefox is the default
browser; Brave is also installed. The wallpaper starts with the repository asset;
use `awww img /path/to/image.png` for a session change.

Cliphist persists copied content under your encrypted home. Use `cliphist wipe`
to clear it. Avoid putting secrets into clipboard history; configure Bitwarden's
clipboard clearing and test your password-copy workflow.

## Gaming

Steam, GE-Proton, Lutris, Heroic, Wine staging, Winetricks, Protontricks, Gamescope,
GameMode, MangoHud and GOverlay are included, with 32-bit graphics/audio and
controller udev rules. Firmware and Mesa come from the pinned system inputs.

- In Steam, enable compatibility for other titles; choose GE-Proton per title when
  needed. Start with Valve's default Proton for games that already work.
- Useful per-game launch option: `gamemoderun mangohud %command%`.
- Gamescope is available for per-game scaling and a Steam session; Mango is the
  default login session. Do not force Gamescope or experimental environment flags
  globally. Some anti-cheat games do not support Linux.
- Set performance mode on AC when useful: `powerprofilesctl set performance`.
  Restore `balanced` afterward. Blur is off and animations are short.
- Steam LAN streaming/transfer firewall openings are opt-in in `gaming.nix`.

No global disabling of mitigations, firewall, or compositor sync is applied.

## Virtualisation and containers

Podman is rootless by default; subordinate UID/GID ranges and user lingering are
configured. `docker` resolves to Podman; no Docker daemon is installed.
Podman Desktop, Compose, Buildah, Skopeo, Dive and Distrobox are included.

For Podman Desktop's local API connection:

```sh
systemctl --user enable --now podman.socket
podman info
```

The socket is local at `$XDG_RUNTIME_DIR/podman/podman.sock`. Do not expose it over TCP.
Native Quadlets work without another abstraction:

```sh
mkdir -p ~/.config/containers/systemd
cp ~/nixos/examples/quadlets/whoami.container ~/.config/containers/systemd/
systemctl --user daemon-reload
systemctl --user start whoami.service
curl http://127.0.0.1:8080
```

The `[Install]` section makes the generated service start on subsequent user-manager
starts; do not `systemctl enable` the generated service. Pin real workloads by digest
and define backup policies for their volumes. This example is not activated by Nix.

KVM/libvirt, virt-manager, virt-viewer, UEFI support and software TPM are available.
Open virt-manager's `qemu:///system` connection. If the default NAT network is inactive:

```sh
sudo virsh net-start default
sudo virsh net-autostart default
```

Keep VM disks and container volumes on internal storage initially. The removable
1 TiB drive is a later candidate for extra game storage or a separate backup;
using it for `/nix` or VM boot dependencies would tie the laptop to that device.

## Development, Kubernetes and Git

Rust: rustup, cargo-nextest, audit, deny, edit, expand, outdated, machete and bacon;
LLDB/Clang/build tooling; per-project direnv with nix-direnv. Initialise a toolchain:

```sh
rustup default stable
rustup component add clippy rustfmt rust-src
```

Prefer a committed `rust-toolchain.toml` or project flake for project reproducibility.
Neovim is configured through Nixvim with Rust, Go, Python, YAML/Kubernetes, Nix,
TOML, Bash and JSON language servers; completion, Treesitter, Telescope, Git signs
and explicit formatting (`Space f`). `Space ff` finds files; `Space fg` searches;
`gd`, `gr`, `K`, `Space rn` and `Space ca` provide LSP navigation/actions.
Kubernetes schemas match `k8s/`, `kubernetes/` and `manifests/` YAML. For other
locations/CRDs add YAML schema modelines or project configuration; Helm templates
are not plain Kubernetes YAML. Go and Python tooling include Delve, golangci-lint,
uv, Ruff and BasedPyright. Project dependencies belong in project environments.

CLI defaults include ripgrep, fd, bat, eza, Yazi, zoxide, fzf, dust, duf, procs,
sd, tokei, hyperfine, watchexec, just, xh and ouch. `yabai` is macOS-only;
Yazi is the Rust file manager. Rust coreutils is installed with `uutils-*` names
to avoid breaking scripts that expect GNU coreutils.

Kubernetes includes kubectl, krew, kubectx/kubens, neat, tree, df-pv, view-secret,
kubelogin, stern, k9s, Helm, Helmfile, Kustomize, kubeconform, kubeseal, OpenShift
`oc`, kind, minikube, Talos, Cilium, Flux and Argo CD CLIs.
Common packaged plugins are pinned declaratively. Use krew for extra plugins:

```sh
kubectl krew update
kubectl krew search
# Optional examples, managed by krew rather than the flake:
kubectl krew install access-matrix get-all who-can
```

Do not install duplicate krew versions of plugins already provided by Nix.
Keep kubeconfigs and tokens out of the repository. For rootless kind, consult
the project's rootless Podman requirements before creating a cluster.

Git uses fast-forward-only pulls, pruning, rerere, zdiff3 conflicts, Delta, Lazygit
and GitHub CLI. Identity/signing are deliberately personal settings:

```sh
git config --file ~/.config/git/identity user.name 'Your Name'
git config --file ~/.config/git/identity user.email 'you@example.org'
gh auth login
```

Home Manager owns `~/.config/git/config`, which includes the mutable identity file
above. You can instead declare identity in `shell.nix` under
`programs.git.settings.user`. No identity or signing key is invented here.

## Accounts and VPNs

Bitwarden Desktop, official `bw`, and Rust `rbw` are installed. The CLIs maintain
independent sessions. For rbw, set email/server as needed, then register/login:

```sh
rbw config set email you@example.org
rbw config set pinentry pinentry-qt
# Only for Vaultwarden/self-hosted Bitwarden:
rbw config set base_url https://vault.example.org
rbw register
rbw login
```

Tailscale and NetBird services are available but unenrolled. Authenticate after boot:
`sudo tailscale up` or `sudo netbird up`. Prefer one active VPN initially. If using
both, explicitly decide which controls DNS and exit/default routes; neither is
configured as an exit node, subnet router or automatic enrollment here.

Proton Mail Desktop, Discord, Slack and Element (Matrix) are installed; sign in
interactively. Browser extensions, mail subscriptions and service accounts are
not provisioned by this flake.

## Maintenance and validation

From `~/nixos` on the laptop:

```sh
nix flake update
nix flake check --no-build
nh os build
nh os test
nh os switch
```

Review and commit the lockfile after testing updates. NixOS/Home Manager
`stateVersion` stays `26.05` across upgrades unless a documented migration requires
changing it. Weekly GC removes generations older than 30 days; ten boot entries
are retained. Use the boot menu for rollback, or `sudo nixos-rebuild switch --rollback`.
`nvd`, `nix-diff`, `nix-tree`, `nom`, `nh`, statix, deadnix and nixfmt are available.

On this development machine before hardware details are available:

```sh
nix eval --impure --json --file tests/eval.nix
nix fmt
```

The evaluation checks the complete system and Home Manager derivations, while
retaining all upstream assertions. It skips only the explicit disk-ID/report
prerequisites, reports them in the output, and never formats a disk. A real
`nix flake check` must pass after those prerequisites are supplied. Building the
Linux system and build-time Mango/Noctalia config validators requires x86_64 Linux
or a suitable remote builder; macOS evaluation alone cannot verify runtime behavior.

After the first boot, check `systemctl --failed`, `systemctl --user --failed`,
`journalctl -b -p warning`, `vulkaninfo --summary`, `wpctl status`, screen sharing,
locking/suspend/resume, Wi-Fi, Bluetooth, external monitors and one game/VM.
Use `fwupdmgr get-updates` to review firmware updates. Kernel, firmware and hardware
module updates should be tested with an older working boot generation retained.

## Upstream references

- [nixos-hardware Framework profiles](https://github.com/NixOS/nixos-hardware/tree/master/framework)
- [Facter's upstream NixOS integration](https://github.com/nix-community/nixos-facter-modules)
- [Disko encrypted Btrfs example](https://github.com/nix-community/disko/blob/master/example/luks-btrfs-subvolumes.nix)
- [Mango Nix modules](https://github.com/mangowm/mango/tree/main/nix)
- [Noctalia v5 NixOS integration](https://docs.noctalia.dev/noctalia/getting-started/nixos/)
- [Walker](https://github.com/abenz1267/walker)
- [Stylix](https://nix-community.github.io/stylix/)
- [Nixvim](https://nix-community.github.io/nixvim/)
