#!/usr/bin/env bash

function _games_internal_wine {
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
    winetricks -q steam
    wineboot -fs

    winetricks -q win7 csmt=on ddr=opengl glsl=enabled
    wineboot -fs
    mkdir -p "$HOME/Downloads"
    [ ! -f "$HOME/Downloads/setup_galaxy_1.2.17.9.exe" ] && wget https://cdn.gog.com/open/galaxy/client/setup_galaxy_1.2.17.9.exe -P "$HOME/Downloads"
    wine "$HOME/Downloads/setup_galaxy_1.2.17.9.exe" /noicons
    wineboot -fs
  fi

  [ ! -f "$HOME/Downloads/xinput_x64.dll" ] && wget https://github.com/x360ce/x360ce/raw/master/x360ce.App/Resources/xinput_x64.dll -P "$HOME/Downloads"
  [ ! -f "$HOME/Downloads/dinput_x64.dll" ] && wget https://github.com/x360ce/x360ce/raw/master/x360ce.App/Resources/dinput_x64.dll -P "$HOME/Downloads"
  [ ! -f "$HOME/Downloads/xinput_x86.dll" ] && wget https://github.com/x360ce/x360ce/raw/master/x360ce.App/Resources/xinput_x86.dll -P "$HOME/Downloads"
  [ ! -f "$HOME/Downloads/dinput_x86.dll" ] && wget https://github.com/x360ce/x360ce/raw/master/x360ce.App/Resources/dinput_x86.dll -P "$HOME/Downloads"
  [ "$WINEARCH" == "win32" ] && XINPUT=xinput_x86.dll || XINPUT=xinput_x64.dll

  ln -fs "$HOME/Wine" "$(dirname "$(winepath "${STEAM_CLIENT}")")/steamapps/common"

  case "$1" in
    galaxy) wine "${GALAXY_CLIENT}" "$@";;
    steam) wine "${STEAM_CLIENT}" "$@";;
    wine*) "$@";;
    *)
      cd "$HOME"
      EXECUTABLE="$(type -p "$1")"
      EXECUTABLE="${EXECUTABLE:-$1}"
      [ ! -f "$EXECUTABLE" ] && (zenity --notification --window-icon error --text "Could not find:\n$EXECUTABLE $@"; return -1)

      EXECUTABLE="$(realpath "$EXECUTABLE")"; shift
      cd "$(dirname "$EXECUTABLE")"
      export WINEDLLOVERRIDES=xinput1_4,xinput1_3,xinput1_2,xinput1_1,xinput9_1_0=n,b
      [ ! -f "x360ce.ini" ] && cp "$HOME/Downloads/x360ce.ini" "x360ce.ini"
      ln -fs "$HOME/Downloads/$XINPUT" "./xinput1_4.dll"
      ln -fs "$HOME/Downloads/$XINPUT" "./xinput1_3.dll"
      ln -fs "$HOME/Downloads/$XINPUT" "./xinput1_2.dll"
      ln -fs "$HOME/Downloads/$XINPUT" "./xinput1_1.dll"
      ln -fs "$HOME/Downloads/$XINPUT" "./xinput9_1_0.dll"

      export LANG=fr_FR.UTF-8
      case "$EXECUTABLE" in
        *.bat) wine cmd /c "$EXECUTABLE" "$@";;
        *) wine "$EXECUTABLE" "$@";;
      esac
  esac
}

function _games_internal_wine64 {
  export WINEPREFIX="$HOME/.wine64"
  export WINEARCH=win64
  export WINEDEBUG=-all
  export GALAXY_CLIENT="C:\\Program Files (x86)\\GOG Galaxy\\GalaxyClient.exe"
  export STEAM_CLIENT="C:\\Program Files (x86)\\Steam\\Steam.exe"
  _games_internal_wine "$@"
}

function _games_internal_wine32 {
  export WINEPREFIX="$HOME/.wine32"
  export WINEARCH=win32
  export WINEDEBUG=-all
  export GALAXY_CLIENT="C:\\Program Files\\GOG Galaxy\\GalaxyClient.exe"
  export STEAM_CLIENT="C:\\Program Files\\Steam\\Steam.exe"
  _games_internal_wine "$@"
}

function _games_internal_start {
  cd "$HOME"
  EXECUTABLE="$(type -p "$1")"
  EXECUTABLE="${EXECUTABLE:-$1}"
  [ ! -f "$EXECUTABLE" ] && (zenity --notification --window-icon error --text "Could not find:\n$EXECUTABLE $@"; return -1)

  EXECUTABLE="$(realpath "$EXECUTABLE")"; shift
  cd "$(dirname "$EXECUTABLE")"

  LD_PRELOAD="/usr/lib/x86_64-linux-gnu/libgobject-2.0.so.0:/lib/x86_64-linux-gnu/libglib-2.0.so.0"
  LD_PRELOAD="$LD_PRELOAD:/usr/lib/i386-linux-gnu/libgobject-2.0.so.0:/lib/i386-linux-gnu/libglib-2.0.so.0"
  export LD_PRELOAD

  LD_LIBRARY_PATH="$HOME/.local/share/Steam/ubuntu12_32/steam-runtime/amd64/lib/x86_64-linux-gnu"
  LD_LIBRARY_PATH="$LD_LIBRARY_PATH:$HOME/.local/share/Steam/ubuntu12_32/steam-runtime/amd64/usr/lib/x86_64-linux-gnu"
  LD_LIBRARY_PATH="$LD_LIBRARY_PATH:$HOME/.local/share/Steam/ubuntu12_32/steam-runtime/i386/lib/i386-linux-gnu"
  LD_LIBRARY_PATH="$LD_LIBRARY_PATH:$HOME/.local/share/Steam/ubuntu12_32/steam-runtime/i386/usr/lib/i386-linux-gnu"
  export LD_LIBRARY_PATH

  export LANG=fr_FR.UTF-8
  [ -f "$EXECUTABLE" ] && "$EXECUTABLE" "$@"
}

function _games_start {
  if [[ "${container}" == "" ]]; then
    mkdir -p "$HOME/Games/.local/bin"
    cp "${BASH_SOURCE[0]}" "$HOME/Games/.local/bin/games"
    chmod +x "$HOME/Games/.local/bin/games"
    git -C "$HOME/Games" pull --rebase
    firejail --noprofile "--private=$HOME/Games" "--env=PATH=$HOME/.local/bin:$PATH" games internal-start "$@"
    git -C "$HOME/Games" add -u
    git -C "$HOME/Games" commit -m "Update $(date)"
    git -C "$HOME/Games" push origin master
  else
    _games_internal_start "$@"
  fi
}

function _games_wine64 {
  if [[ "${container}" == "" ]]; then
    mkdir -p "$HOME/Games/.local/bin"
    cp "${BASH_SOURCE[0]}" "$HOME/Games/.local/bin/games"
    chmod +x "$HOME/Games/.local/bin/games"
    git -C "$HOME/Games" pull --rebase
    firejail --noprofile "--private=$HOME/Games" "--env=PATH=$HOME/.local/bin:$PATH" games internal-wine64 "$@"
    git -C "$HOME/Games" add -u
    git -C "$HOME/Games" commit -m "Update $(date)"
    git -C "$HOME/Games" push origin master
  else
    _games_internal_wine64 "$@"
  fi
}

function _games_wine32 {
  if [[ "${container}" == "" ]]; then
    mkdir -p "$HOME/Games/.local/bin"
    cp "${BASH_SOURCE[0]}" "$HOME/Games/.local/bin/games"
    chmod +x "$HOME/Games/.local/bin/games"
    git -C "$HOME/Games" pull --rebase
    firejail --noprofile "--private=$HOME/Games" "--env=PATH=$HOME/.local/bin:$PATH" games internal-wine32 "$@"
    git -C "$HOME/Games" add -u
    git -C "$HOME/Games" commit -m "Update $(date)"
    git -C "$HOME/Games" push origin master
  else
    _games_internal_wine32 "$@"
  fi
}

function _games_lutris {
  mkdir -p "$HOME/Games/.local/bin"
  cp "${BASH_SOURCE[0]}" "$HOME/Games/.local/bin/games"
  chmod +x "$HOME/Games/.local/bin/games"
  git -C "$HOME/Games" pull --rebase
  firejail --noprofile "--private=$HOME/Games" "--env=PATH=$HOME/.local/bin:$PATH" /usr/bin/lutris "$@"
  git -C "$HOME/Games" add -u
  git -C "$HOME/Games" commit -m "Update $(date)"
  git -C "$HOME/Games" push origin master
}

function games {
  local command="$1"; shift;
  case $command in
    start)
      _games_start "$@"
      ;;
    lutris)
      _games_lutris "$@"
      ;;
    wine64)
      _games_wine64 "$@"
      ;;
    wine32)
      _games_wine32 "$@"
      ;;
  esac
}

case "$0" in
  "${BASH_SOURCE[0]}")
    command="$1"; shift;
    case $command in
      internal-start)
        _games_internal_start "$@"
        ;;
      internal-wine64)
        _games_internal_wine64 "$@"
        ;;
      internal-wine32)
        _games_internal_wine32 "$@"
        ;;
      start)
        _games_start "$@"
        ;;
      lutris)
        _games_lutris "$@"
        ;;
      wine64)
        _games_wine64 "$@"
        ;;
      wine32)
        _games_wine32 "$@"
        ;;
    esac
    exit $?
    ;;
esac

cite about-plugin
about-plugin 'games helper functions'
