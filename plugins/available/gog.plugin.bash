#!/usr/bin/env bash

function _internal_run_wine {
  if [ ! -d "$WINEPREFIX" ]; then
    wineboot -i

    winetricks -q win7
    winetricks -q corefonts
    wineboot -fs
    winetricks -q vcrun2003 vcrun2005 vcrun2008 vcrun2010 vcrun2012 vcrun2013 vcrun2015
    wineboot -fs
    winetricks -q d3dx9 d3dx10
    wineboot -fs
    winetricks -q dotnet462
    wineboot -fs

    winetricks -q win7 csmt=on ddr=opengl glsl=enabled
    wineboot -fs
    mkdir -p "$HOME/Downloads"
    [ ! -f "$HOME/Downloads/setup_galaxy_1.2.17.9.exe" ] && wget https://cdn.gog.com/open/galaxy/client/setup_galaxy_1.2.17.9.exe -P "$HOME/Downloads"
    wine "$HOME/Downloads/setup_galaxy_1.2.17.9.exe" /noicons
    wineboot -fs
  fi

  case "$1" in
    galaxy) wine "${GALAXY_CLIENT}" "$@";;
    wine*) "$@";;
    *) cd "$(dirname "$1")" && wine "$@"
  esac
}

function _internal_run_wine64 {
  export WINEPREFIX="$HOME/.wine64-gog"
  export WINEARCH=win64
  export WINEDEBUG=-all
  export GALAXY_CLIENT="C:\\Program Files (x86)\\GOG Galaxy\\GalaxyClient.exe"
  _internal_run_wine "$@"
}

function _internal_run_wine32 {
  export WINEPREFIX="$HOME/.wine32-gog"
  export WINEARCH=win32
  export WINEDEBUG=-all
  export GALAXY_CLIENT="C:\\Program Files\\GOG Galaxy\\GalaxyClient.exe"
  _internal_run_wine "$@"
}

function _gog_run {
  LD_LIBRARY_PATH="$HOME/Steam/.local/share/Steam/ubuntu12_32/steam-runtime/amd64/lib/x86_64-linux-gnu"
  LD_LIBRARY_PATH="$LD_LIBRARY_PATH:$HOME/Steam/.local/share/Steam/ubuntu12_32/steam-runtime/amd64/usr/lib/x86_64-linux-gnu"
  LD_LIBRARY_PATH="$LD_LIBRARY_PATH:$HOME/Steam/.local/share/Steam/ubuntu12_32/steam-runtime/i386/lib/i386-linux-gnu"
  LD_LIBRARY_PATH="$LD_LIBRARY_PATH:$HOME/Steam/.local/share/Steam/ubuntu12_32/steam-runtime/i386/usr/lib/i386-linux-gnu"
  firejail --noprofile "--private=$HOME/Games" "--env=LD_LIBRARY_PATH=$LD_LIBRARY_PATH" "$@"
}

function _gog_run_wine {
  if [[ "${container}" == "" ]]; then
    mkdir -p "$HOME/Games/.local/bin"
    cp "${BASH_SOURCE[0]}" "$HOME/Games/.local/bin/gog"
    chmod +x "$HOME/Games/.local/bin/gog"
    firejail --noprofile "--private=$HOME/Games" "--env=PATH=$HOME/.local/bin:$PATH" gog internal-run-wine "$@"
  else
    _internal_run_wine64 "$@"
  fi
}

function _gog_run_wine32 {
  if [[ "${container}" == "" ]]; then
    mkdir -p "$HOME/Games/.local/bin"
    cp "${BASH_SOURCE[0]}" "$HOME/Games/.local/bin/gog"
    chmod +x "$HOME/Games/.local/bin/gog"
    firejail --noprofile "--private=$HOME/Games" "--env=PATH=$HOME/.local/bin:$PATH" gog internal-run-wine32 "$@"
  else
    _internal_run_wine32 "$@"
  fi
}

function lutris {
  mkdir -p "$HOME/Games/.local/bin"
  cp "${BASH_SOURCE[0]}" "$HOME/Games/.local/bin/gog"
  chmod +x "$HOME/Games/.local/bin/gog"
  firejail --noprofile "--private=$HOME/Games" "--env=PATH=$HOME/.local/bin:$PATH" /usr/bin/lutris "$@"
}

function gog {
  local command="$1"; shift;
  case $command in
    run)
      _gog_run "$@"
      ;;
    run-wine)
      _gog_run_wine "$@"
      ;;
    run-wine32)
      _gog_run_wine32 "$@"
      ;;
  esac
}

case "$0" in
  "${BASH_SOURCE[0]}")
    command="$1"; shift;
    case $command in
      internal-run-wine)
        _internal_run_wine64 "$@"
        ;;
      internal-run-wine32)
        _internal_run_wine32 "$@"
        ;;
      run)
        _gog_run "$@"
        ;;
      run-wine)
        _gog_run_wine "$@"
        ;;
      run-wine32)
        _gog_run_wine32 "$@"
        ;;
    esac
    exit $?
    ;;
esac

cite about-plugin
about-plugin 'gog helper functions'
