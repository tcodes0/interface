# etc/ — System Configuration

Files here are symlinked (or hardlinked for `fstab`) into `/etc`. Requires root for install.
Note: all `/etc` symlinks resolve through `/home/vacation/` — root must be able to traverse it.
Ensure `chmod o+x /home/vacation` is set, otherwise systemd and other root processes silently fail to read unit files and configs at boot.
Note: `/etc/fstab` must be a **hardlink**, not a symlink — the kernel reads it before symlinks resolve.
Note: due to how the system mounts partitions at boot, and how /home/vacation is its own btrfs subvolume mount, files in etc/ might be unavailable at boot, leading to weird bugs.
The proposed solution for this is to use an install script that copies files to /etc with correct ownership and permissions.
Git hook into pull and commit, maintain hashes of all files, maybe adjacent to the files themselves but gitignored, and determine if file needs to be reinstalled.

## Filesystem & Boot

### `fstab`

Full btrfs-based layout using labels. All major mounts use `noatime,compress=lzo`.

| Label       | Mount                       | Notes                                |
| ----------- | --------------------------- | ------------------------------------ |
| `EFI-BLUE`  | `/boot`                     | vfat EFI partition                   |
| `Archlinux` | `/toplevel`                 | btrfs root, all subvolumes live here |
| `Archlinux` | `/home/vacation`            | `@vacation` subvolume                |
| `Archlinux` | `~/.local/share/lutris`     | `@lutris` — games isolated           |
| `Archlinux` | `~/.local/share/Steam`      | `@steam` — Steam isolated            |
| `Archlinux` | `/var/lib/postgres`         | `@postgres`                          |
| `Archlinux` | `~/.cache`                  | `@.cache`                            |
| `Archlinux` | `/var/lib/docker`           | `@docker`                            |
| `Archlinux` | `/swap`                     | `@swap` subvolume                    |
| `Data2TB`   | `/media/data`               | secondary data disk                  |
| `Data2TB`   | `~/.ollama`                 | Ollama model storage                 |
| `Data4TB`   | `/media/data4tb`            | tertiary data disk                   |
| `Data4TB`   | `/plex` and `~/Videos/plex` | Plex media (double-mounted)          |
| `External`  | `/media/external`           | exfat external drive, noauto         |

Swap is a swapfile at `/swap/swapfile`.

### `mkinitcpio.conf`

- **MODULES**: `fs_btrfs amdgpu` — preloaded for btrfs root and AMD GPU early KMS.
- **HOOKS**: `base udev autodetect microcode modconf kms keyboard keymap consolefont block filesystems resume`
  — notably includes `resume` for hibernation support.
- `MODULES_DECOMPRESS=yes` — decompress kernel modules in initramfs for faster boot.

### `boot/EFI/CLOVER/`

CLOVER EFI bootloader config. The pre-commit hook syncs `config.plist` to `/boot/EFI/CLOVER/config.plist` on commit.

## Display

### `X11/xorg.conf.d/settings.conf`

`DontVTSwitch=False` — allows VT switching from X11.

### `sddm.conf.d/settings.conf`

SDDM display manager config. Key settings:

- Theme: `breeze`
- `EnableHiDPI=true` (X11 and Wayland)
- `Numlock=on`
- Autologin disabled

## System Services

### `systemd/sleep.conf.d/hibernate.conf`

- Hibernate mode: `shutdown` (writes RAM to swap, powers off)
- `HibernateDelaySec=22h` — suspend-then-hibernate after 22h
- All sleep modes allowed: suspend, hibernate, hybrid, suspend-then-hibernate.

### `systemd/system.conf.d/watchdog.conf`

- `RuntimeWatchdogSec=3min` — kernel watchdog resets if systemd stalls
- `RebootWatchdogSec=15` — reboot watchdog on system reboot

### `systemd/system/` — Root system units

Timer units depend on `home-vacation.mount` — symlink targets resolve through `/home/vacation/`, which is a btrfs subvolume mounted at boot. Without this dependency, timers may activate before the mount is up and silently fail to schedule.

| Unit                      | Purpose                                                                                                  |
| ------------------------- | -------------------------------------------------------------------------------------------------------- |
| `system-snapshot.service` | Runs `~/bin/system-snapshot` as root                                                                     |
| `system-snapshot.timer`   | Triggers hourly, persistent                                                                              |
| `btrfs-scrub@.service`    | Template unit; `%i` = volume name (Archlinux/Data2TB/Data4TB). Nice=19, IO idle priority. 30min timeout. |
| `btrfs-scrub@.timer`      | Monthly, randomized by up to 1 week                                                                      |
| `memreserver.service`     | Runs before sleep (`Before=sleep.target`). Frees RAM so GPU VRAM can be evacuated on suspend.            |
| `postgres-backup.service` | Runs `/usr/local/bin/postgres-backup` as the `postgres` user. Dumps all databases, keeps newest 10.      |
| `postgres-backup.timer`   | Triggers weekly, persistent                                                                              |

## Network

### `resolvconf.conf`

- DNS: `1.1.1.1 8.8.8.8` (Cloudflare + Google)
- Blacklists Brazilian ISP DNS servers (`2804:14d:*`, `192.168.*`) and `wlp4s0` interface DNS

### `geoclue/geoclue.conf`

Geolocation daemon config. Uses Mozilla Location Service (`location.services.mozilla.com`).
Firefox and GNOME shell are whitelisted for location access.
