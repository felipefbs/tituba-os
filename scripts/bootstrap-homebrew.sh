#!/usr/bin/env bash
# Bootstrap opt-in e idempotente do Homebrew no espaço persistente do usuário.
# Não baixa nem executa nada remoto; não altera arquivos fora de $HOME.
set -euo pipefail

if [[ ${EUID} -eq 0 ]]; then
  echo "erro: não execute como root; o Homebrew é por usuário." >&2
  exit 1
fi

repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
brewfile="${repo_dir}/homebrew/Brewfile"
marker_begin="# >>> tituba-os homebrew >>>"
marker_end="# <<< tituba-os homebrew <<<"

confirm() {
  local reply
  read -r -p "$1 [y/N] " reply
  [[ ${reply} =~ ^[Yy]$ ]]
}

brew_bin=""
for candidate in "$(command -v brew || true)" \
  /home/linuxbrew/.linuxbrew/bin/brew \
  /var/home/linuxbrew/.linuxbrew/bin/brew \
  "${HOME}/.linuxbrew/bin/brew"; do
  if [[ -n ${candidate} && -x ${candidate} ]]; then
    brew_bin="${candidate}"
    break
  fi
done

if [[ -z ${brew_bin} ]]; then
  cat <<'MSG'
Homebrew não encontrado. Este script não o instala sozinho.
Revise e execute você mesmo (procedimento oficial, sem curl | bash):

  curl -fsSLo /tmp/brew-install.sh https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh
  less /tmp/brew-install.sh
  /bin/bash /tmp/brew-install.sh

Depois rode este script novamente.
MSG
  exit 0
fi

echo "Homebrew encontrado em: ${brew_bin}"
shellenv_line="eval \"\$(${brew_bin} shellenv)\""

for rc in "${HOME}/.zprofile" "${HOME}/.bashrc"; do
  if [[ -f ${rc} ]] && grep -qF "${marker_begin}" "${rc}"; then
    echo "PATH já configurado em ${rc}"
    continue
  fi
  if confirm "Adicionar o brew ao PATH em ${rc}?"; then
    printf '\n%s\n%s\n%s\n' "${marker_begin}" "${shellenv_line}" "${marker_end}" >>"${rc}"
    echo "atualizado: ${rc}"
  fi
done

echo
echo "Fórmulas em ${brewfile}:"
grep -E '^brew ' "${brewfile}" || true
echo
"${brew_bin}" bundle check --file "${brewfile}" || true
if confirm "Executar 'brew bundle --file ${brewfile}' agora?"; then
  "${brew_bin}" bundle --file "${brewfile}"
fi
