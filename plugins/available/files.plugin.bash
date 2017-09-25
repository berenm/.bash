#!/usr/bin/env bash

function _internal_files_prefixadd {
  local p="$1"
  local d="$(dirname "$2")"
  local b="$(basename "$2")"
  printf '%s\0' "${d}/${b}" "${d}/${p}${b}"
}

function _internal_files_prefixrm {
  local p="$1"
  local d="$(dirname "$2")"
  local b="$(basename "$2")"
  printf '%s\0' "${d}/${b}" "${d}/${b#${p}}"
}

function _internal_files_pdfextract {
  source="$(realpath "$1")"
  target="${source/.pdf/.cbt}"
  tempdir=$(mktemp -d)

  pdfimages -p -png -j "${source}" "${tempdir}/page"
  find "${tempdir}" -type f | sort | awk -F- '
BEGIN {
  lp=001;
  np=0;
}
{
  p=$2;
  if (p != lp) {
    if (np > 1) printf("%s -append page-%s.jpg && rm %s\0", a, lp, a);
    a = $0;
    np=1;
  } else {
    a = a" "$0;
    np++;
  }
  lp = p;
}
END {
  if (np > 1)
    printf("%s -append page-%s.jpg && rm %s\0", a, lp, a)
}' | xargs -P4 -rt -0 -n1 convert
  tar cf "${target}" -C "${tempdir}" .
  rm -rf $tempdir
}

case "$0" in
  ${BASH_SOURCE[0]})
    command="$1"; shift;
    case $command in
      internal-prefixadd)
        _internal_files_prefixadd "$@"
        ;;
      internal-prefixrm)
        _internal_files_prefixrm "$@"
        ;;
      internal-pdfextract)
        _internal_files_pdfextract "$@"
        ;;
    esac
    exit 0
    ;;
esac

cite about-plugin
about-plugin 'file helper functions'

function _files_prefixadd {
  local p="$1"; shift
  printf '%s\0' "$@" | xargs -0 -n1 -I% bash "${BASH_SOURCE[0]}" internal-prefixadd "${p}" % | xargs -0t -n2 mv
}

function _files_prefixrm {
  local p="$1"; shift
  printf '%s\0' "$@" | xargs -0 -n1 -I% bash "${BASH_SOURCE[0]}" internal-prefixrm "${p}" % | xargs -0t -n2 mv
}

function _files_pdfextract {
  printf '%s\0' "$@" | xargs -0 -n1 -I% bash "${BASH_SOURCE[0]}" internal-pdfextract %
}

function files {
  local command="$1"; shift;
  case $command in
    prefix-add)
      _files_prefixadd "$@"
      ;;
    prefix-rm)
      _files_prefixrm "$@"
      ;;
    pdf-extract)
      _files_pdfextract "$@"
      ;;
  esac
}
