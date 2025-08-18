# Nibbler NUC

Nibbler NUC is a server using a [12th Gen Intel N100 4C/4T 16G DDR4 500G M.2 PCIE1/SATA SSD G4][1].

## Installation

### Prerequisites

The first part of the installation is to flash a USB stick with a minimal NixOS image.

> [!NOTE]
> If you're using Windows, you'll need to use the [Raspberry Pi Imager][2]

### First boot

> [!IMPORTANT]
> Run `sudo -i` to get a root shell.
> Otherwise, you'll need to prefix all commands with `sudo`.

### Getting an internet connection

If you're using a wired connection, you can skip this step.

```bash
wpa_supplicant -B -i wlp0s20f3 -c <(wpa_passphrase "SSID" "password")
```

Verify that you have an IP address:

```bash
ip a
```

### Installing NixOS

Set the hostname:

```bash
hostname rpi
```

Clone the nix-config repo:

```bash
nix-shell -p git
git clone https://github.com/jpinz/nix-config.git
```

Start a nix-shell:

```bash
cd nix-config
nix-shell
```

Rebuild the system configuration:

```bash
nixos-rebuild boot --flake .
```

[1]: https://www.amazon.com/dp/B0C15DTJMX
[2]: https://www.raspberrypi.com/software/
