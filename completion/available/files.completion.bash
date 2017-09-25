#!/usr/bin/env bash

function _files {
  local cur prev commands command
  COMPREPLY=()
  cur="${COMP_WORDS[COMP_CWORD]}"
  prev="${COMP_WORDS[COMP_CWORD-1]}"

  commands="prefix-add prefix-rm pdf-extract"
  command="${COMP_WORDS[1]}"

  case "${command}" in
    prefix-add|prefix-rm|pdf-extract)
      local IFS=$'\n'
      compopt -o filenames
      COMPREPLY=($(compgen -f -- "${cur}"))
      return 0
      ;;
  esac

  COMPREPLY=($(compgen -W "${commands}" -- "${cur}"))
  return 0
}

complete -F _files files
