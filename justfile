# Tarefas explícitas; nada aqui roda durante o build da imagem.
brewfile := justfile_directory() / "homebrew/Brewfile"
box_image := "registry.fedoraproject.org/fedora-toolbox:latest"

default:
    @just --list

# --- Homebrew ---
brew-status:
    brew --version
    brew bundle check --file {{brewfile}} || true

brew-install:
    ./scripts/bootstrap-homebrew.sh

brew-sync:
    brew bundle --file {{brewfile}}

brew-outdated:
    brew update
    brew outdated

brew-upgrade:
    brew update
    brew outdated
    @read -r -p "Aplicar brew upgrade? [y/N] " r && [[ $r =~ ^[Yy]$ ]] && brew upgrade

brew-doctor:
    brew doctor

# Revisão manual: mostra o que seria removido; só remove após confirmação.
brew-cleanup-manual:
    brew bundle cleanup --file {{brewfile}}
    @read -r -p "Remover as fórmulas listadas? [y/N] " r && [[ $r =~ ^[Yy]$ ]] && brew bundle cleanup --force --file {{brewfile}}

# --- Distrobox (sob demanda, idempotentes) ---
box-go:
    @distrobox list | grep -qw dev-go || distrobox create --yes --name dev-go --image {{box_image}} --additional-packages "golang git delve gopls make gcc pkgconf-pkg-config"

box-node:
    @distrobox list | grep -qw dev-node || distrobox create --yes --name dev-node --image {{box_image}} --additional-packages "nodejs npm git"

box-ai:
    @distrobox list | grep -qw dev-ai || distrobox create --yes --name dev-ai --image {{box_image}} --additional-packages "git python3-pip"

box-ops:
    @distrobox list | grep -qw dev-ops || distrobox create --yes --name dev-ops --image {{box_image}} --additional-packages "git kubernetes-client helm"
