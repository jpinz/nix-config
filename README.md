[![GitHub Workflow Status](https://img.shields.io/github/actions/workflow/status/jpinz/nix-config/build.yml?branch=main&style=for-the-badge)](https://github.com/jpinz/nix-config/actions/workflows/build.yml?query=branch%3Amain)
[![Built with nix](https://img.shields.io/static/v1?logo=nixos&logoColor=white&label=&message=Built%20with%20Nix&color=41439a&style=for-the-badge)](https://builtwithnix.org/)

# NixOS Configuration

This repository contains my personal NixOS and Home Manager configurations, managing multiple machines and user environments declaratively using Nix flakes.

## Hosts

This configuration manages several different machines:

- [**calculon**](./hosts/calculon/README.md) - x86_64 NUC running my Media Stack
- **julian-desktop** - Main desktop PC with AMD CPU, Nvidia GPU, gaming setup, development tools

## Structure

```
├── flake.nix           # Main flake configuration
├── hosts/              # NixOS system configurations
│   ├── calculon/       # Media Aerver
│   ├── julian-desktop/ # Main desktop
│   └── common/         # Shared system modules
├── home/               # Home Manager configurations
│   └── julian/         # User-specific configs
└── modules/            # Custom NixOS and Home Manager modules
```

## Usage

Build and switch to a configuration:

```bash
sudo nixos-rebuild switch --flake .#hostname
```

Apply Home Manager configuration:

```bash
home-manager switch --flake .#username@hostname
```

Deploy to remote systems:

```bash
nix run github:serokell/deploy-rs .#hostname
```
