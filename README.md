# android-cli-nix

[![latest version](https://img.shields.io/github/v/tag/javiergarea/android-cli-nix?label=latest&sort=semver)](https://github.com/javiergarea/android-cli-nix/tags)

Nix package for [Google Android CLI](https://developer.android.com/tools/agents/android-cli), the terminal interface for Android development and agentic workflows.

**Automatically updated daily** to track the latest Android CLI release.

## Why this package?

Android CLI is distributed as a standalone binary from Google's CDN with no package manager support. This flake wraps it for Nix users so you get:

- Declarative, reproducible installation
- `autoPatchelfHook` for NixOS compatibility
- Version pinning and rollback via flake refs
- Automated updates through CI

> **Note:** Android CLI is unfree software. You need `nixpkgs.config.allowUnfree = true` in your configuration, or `NIXPKGS_ALLOW_UNFREE=1` with `--impure` for standalone usage.

## Quick Start

```bash
# Try it
NIXPKGS_ALLOW_UNFREE=1 nix run github:javiergarea/android-cli-nix --impure

# Install to profile
NIXPKGS_ALLOW_UNFREE=1 nix profile install github:javiergarea/android-cli-nix --impure
```

## Flake Usage

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    android-cli.url = "github:javiergarea/android-cli-nix";
  };

  outputs = { nixpkgs, android-cli, ... }: {
    nixosConfigurations.myhost = nixpkgs.lib.nixosSystem {
      modules = [
        ({ pkgs, ... }: {
          nixpkgs.overlays = [ android-cli.overlays.default ];
          nixpkgs.config.allowUnfree = true;
          environment.systemPackages = [ pkgs.android-cli ];
        })
      ];
    };
  };
}
```

### Home Manager

```nix
{ pkgs, ... }:
{
  nixpkgs.overlays = [ android-cli.overlays.default ];
  home.packages = [ pkgs.android-cli ];
}
```

### Version Pinning

```nix
# Track latest
android-cli.url = "github:javiergarea/android-cli-nix";

# Pin exact version
android-cli.url = "github:javiergarea/android-cli-nix?ref=v0.7.15222914";
```

## Supported Platforms

| Platform | Status |
|----------|--------|
| `x86_64-linux` | Supported |
| `aarch64-darwin` | Supported |

## Development

```bash
git clone https://github.com/javiergarea/android-cli-nix
cd android-cli-nix
NIXPKGS_ALLOW_UNFREE=1 nix build --impure
./result/bin/android --version

# Check for updates
./scripts/update-version.sh --check

# Update to latest
./scripts/update-version.sh
```

## Automated Updates

GitHub Actions checks daily for new Android CLI releases. When a new version is found, it opens a PR with updated hashes. On merge to main, a version tag is created.

## Acknowledgements

The packaging structure, update automation, and CI setup are inspired by [claude-code-nix](https://github.com/sadjow/claude-code-nix) by [@sadjow](https://github.com/sadjow), licensed under MIT.

## License

Nix packaging is MIT. Android CLI itself is proprietary software by Google, subject to the [Android SDK Terms of Service](https://developer.android.com/studio/terms).
