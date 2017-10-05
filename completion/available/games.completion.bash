#!/usr/bin/env bash

function _gog {
  local cur prev commands command
  COMPREPLY=()
  cur="${COMP_WORDS[COMP_CWORD]}"
  prev="${COMP_WORDS[COMP_CWORD-1]}"

  commands="run wine64 wine32 lutris"
  command="${COMP_WORDS[1]}"

  case "${command}" in
    run|wine64|wine32|lutris)
      local IFS=$'\n'
      compopt -o filenames
      COMPREPLY=($(compgen -f -- "${cur}"))
      return 0
      ;;
  esac

  COMPREPLY=($(compgen -W "${commands}" -- "${cur}"))
  return 0
}

complete -F _gog gog
