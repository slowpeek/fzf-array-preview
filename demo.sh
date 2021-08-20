#!/usr/bin/env bash
# shellcheck disable=SC2191,SC1090

# MIT license (c) 2021 https://github.com/slowpeek
# Homepage: https://github.com/slowpeek/fzf-array-preview

set -eu

self=${BASH_SOURCE[0]%/*}
! test -f "$self"/locate-exit.sh || source "$_"

countries=(
    "AUT=Austria" "BEL=Belgium" "BGR=Bulgaria" "HRV=Croatia"
    "CYP=Cyprus" "CZE=Czech Republic" "DNK=Denmark" "EST=Estonia"
    "FIN=Finland" "FRA=France" "DEU=Germany" "GRC=Greece"
    "HUN=Hungary" "IRL=Ireland" "ITA=Italy" "LVA=Latvia"
    "LTU=Lithuania" "LUX=Luxembourg" "MLT=Malta" "NLD=Netherlands"
    "POL=Poland" "PRT=Portugal" "ROM=Romania" "SVK=Slovakia"
    "SVN=Slovenia" "ESP=Spain" "SWE=Sweden"
)

# Remove line breaks.
countries=("${countries[@]/$'\n'/ }")

bye () {
    printf '%s\n' "$1"
    exit 1
}

type -P fzf >/dev/null || bye "'fzf' tool not found"

req=fzf-array-preview.sh
source "$self/$req" 2>/dev/null || bye "'$req' not found"

demos=(
    '  sq generic ::       number => its square'   # array
    ' rsq sparse  ::       number => its root'     # sparse array
    'cc2c assoc   :: country code => country'      # assoc
    'c2cc assoc   ::      country => country code' # assoc
)

name=${req%%.*}

header="
quit with Esc or Ctl-C
----------------------

${name^^} DEMO

"

fzf_args=(
    --phony
    --with-nth=2..
    --header="${header:1}"
    --prompt=''
    --reverse
    --no-info
    --bind=change:clear-query
    --border
)

unset -v name header

clear
while true; do
    read -r reply _ < \
         <(printf '%s\n' "${demos[@]}" | fzf "${fzf_args[@]}") || true

    # shellcheck disable=SC2034
    case $reply in
        sq)
            sq=()
            for ((i=1; i<=100; i++)); do
                ((sq[i] = i*i))
            done

            fzf_array_preview sq
            unset -v sq
            ;;
        rsq)
            rsq=()
            for ((i=1; i<=100; i++)); do
                ((rsq[i*i] = i))
            done

            fzf_array_preview rsq
            unset -v rsq
            ;;
        cc2c)
            declare -A cc2c=()
            for s in "${countries[@]}"; do
                cc2c[${s%%=*}]=${s##*=}
            done

            fzf_array_preview cc2c
            unset -v cc2c
            ;;
        c2cc)
            declare -A c2cc=()
            for s in "${countries[@]}"; do
                c2cc[${s##*=}]=${s%%=*}
            done

            fzf_array_preview c2cc
            unset -v c2cc
            ;;
        *)
            break
            ;;
    esac
done
