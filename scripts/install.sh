#!/usr/bin/env bash
# Install Oh My Bash with its OFFICIAL installer (tools/install.sh), pinned to one commit.
#
#   PREFIX (default ./.local)  ->  Oh My Bash lands in $PREFIX/share/oh-my-bash
#
# The installer's --prefix mode only clones and writes a sample $OSH/bashrc — it never
# moves your ~/.bashrc aside — so this is safe to run on a workstation. This repo's own
# bash/.bashrc is the rc file that loads it. Used by the Dockerfile and fleet.conf.
set -euo pipefail
OMB_REF="${OMB_REF:-abf846186ab0a8a41ec5888e827ece6277dfe446}"
here=$(cd "$(dirname "$0")/.." && pwd)
PREFIX="${PREFIX:-$here/.local}"
OSH="$PREFIX/share/oh-my-bash"

if [[ ! -d $OSH/.git ]]; then
  installer=$(mktemp)
  curl -fsSL "https://raw.githubusercontent.com/ohmybash/oh-my-bash/$OMB_REF/tools/install.sh" -o "$installer"
  bash "$installer" --unattended --prefix="$PREFIX"
  rm -f "$installer"
fi
# the installer clones master; move to the pinned commit
git -C "$OSH" fetch -q --depth=1 origin "$OMB_REF"
git -C "$OSH" -c advice.detachedHead=false checkout -q "$OMB_REF"
echo "oh-my-bash at $(git -C "$OSH" rev-parse --short HEAD) in $OSH"
