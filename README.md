# tituba-os &nbsp; [![bluebuild build badge](https://github.com/felipefbs/tituba-os/actions/workflows/build.yml/badge.svg)](https://github.com/felipefbs/tituba-os/actions/workflows/build.yml)

Personal Fedora Atomic images built with [BlueBuild](https://blue-build.org), one recipe per machine, sharing the modules in `recipes/common/`.

| Machine | Recipe | Image | Base | Interface |
| --- | --- | --- | --- | --- |
| PC | `recipes/pc.yml` | `ghcr.io/felipefbs/tituba-os` | `ublue-os/kinoite-main` | SDDM + noctalia |
| Laptop | `recipes/laptop.yml` | `ghcr.io/felipefbs/tituba-os-laptop` | `ublue-os/base-main` | Cinnamon (minimal) |
| Raspberry Pi 4 | `recipes/pi.yml` | `ghcr.io/felipefbs/tituba-os-pi` (arm64) | `fedora/fedora-iot` | none (TTY) |

All three ship Docker Engine + compose with `docker.service` enabled; compose files are not part of the image. The laptop and the Pi also enable SSH and keep host port 53 free for pihole.

Local commands take the machine as `HOST` (default `pc`): `make generate HOST=laptop`, `make build HOST=pi`. `make validate` checks every recipe.

## Empacotamento

Política RPM/Flatpak/Distrobox/Homebrew em [docs/empacotamento.md](docs/empacotamento.md). Para o Homebrew (opt-in, fora da imagem): `just brew-install`.

## Installation

> [!WARNING]  
> [This is an experimental feature](https://www.fedoraproject.org/wiki/Changes/OstreeNativeContainerStable), try at your own discretion.

To rebase an existing atomic Fedora installation to the latest build (replace `tituba-os` with `tituba-os-laptop` or `tituba-os-pi` for the other machines):

- First rebase to the unsigned image, to get the proper signing keys and policies installed:
  ```
  rpm-ostree rebase ostree-unverified-registry:ghcr.io/felipefbs/tituba-os:latest
  ```
- Reboot to complete the rebase:
  ```
  systemctl reboot
  ```
- Then rebase to the signed image, like so:
  ```
  rpm-ostree rebase ostree-image-signed:docker://ghcr.io/felipefbs/tituba-os:latest
  ```
- Reboot again to complete the installation
  ```
  systemctl reboot
  ```

### Raspberry Pi 4

Flash the stock Fedora IoT aarch64 raw image to the SD card/SSD (it carries the Pi firmware and bootloader), boot it, then rebase as above:

```
sudo arm-image-installer --image=Fedora-IoT-raw-44-*.aarch64.raw.xz --target=rpi4 --media=/dev/sdX --resizefs
```

The `latest` tag will automatically point to the latest build. That build will still always use the Fedora version specified in the recipe, so you won't get accidentally updated to the next major version.

## ISO

If build on Fedora Atomic, you can generate an offline ISO with the instructions available [here](https://blue-build.org/how-to/generate-iso/#_top). These ISOs cannot unfortunately be distributed on GitHub for free due to large sizes, so for public projects something else has to be used for hosting.

## Verification

These images are signed with [Sigstore](https://www.sigstore.dev/)'s [cosign](https://github.com/sigstore/cosign). You can verify the signature by downloading the `cosign.pub` file from this repo and running the following command:

```bash
cosign verify --key cosign.pub ghcr.io/felipefbs/tituba-os
```
