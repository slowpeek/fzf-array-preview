#!/usr/bin/env bash

# MIT license (c) 2021 https://github.com/slowpeek
# Homepage: https://github.com/slowpeek/fzf-array-preview

countries=(

"AUT=Austria" "BEL=Belgium" "BGR=Bulgaria" "HRV=Croatia" "CYP=Cyprus"
"CZE=Czech Republic" "DNK=Denmark" "EST=Estonia" "FIN=Finland"
"FRA=France" "DEU=Germany" "GRC=Greece" "HUN=Hungary" "IRL=Ireland"
"ITA=Italy" "LVA=Latvia" "LTU=Lithuania" "LUX=Luxembourg" "MLT=Malta"
"NLD=Netherlands" "POL=Poland" "PRT=Portugal" "ROM=Romania"
"SVK=Slovakia" "SVN=Slovenia" "ESP=Spain" "SWE=Sweden"

)

# Remove line breaks.
countries=("${countries[@]/$'\n'/ }")

bye () {
    printf '%s\n' "$1"
    exit 1
}

type -P fzf >/dev/null || bye "'fzf' tool not found"

req=fzf-array-preview.sh
# shellcheck disable=SC1090
source "$req" 2>/dev/null || bye "'$req' not found"

demos=(
    'sq:number => its square'  # array
    'rsq:number => its root'   # sparse array
    'cc2c:country code => country' # assoc
    'c2cc:country => country code' # assoc
)

n=0
for el in "${demos[@]%%:*}"; do
    declare -n var=demo_$el
    # shellcheck disable=SC2034
    var=$((++n))
done

unset -n var

PS3=$'\n-----\nq Quit\n-----\n\nMenu item: '

# shellcheck disable=SC2034,SC2154
while true; do
    clear -x
    printf '%s demo\n\n' "$req"

    select _ in "${demos[@]#*:}"; do
        break
    done <<< a

    read -r

    case $REPLY in
        "$demo_sq")
            sq=()
            for ((i=0; i<=100; i++)); do
                sq[i]=$((i*i))
            done

            fzf_array_preview sq
            unset -v sq
            ;;
        "$demo_rsq")
            rsq=()
            for ((i=0; i<=100; i++)); do
                rsq[i*i]=$i
            done

            fzf_array_preview rsq
            unset -v rsq
            ;;
        "$demo_cc2c")
            declare -A cc2c=()
            for s in "${countries[@]}"; do
                cc2c[${s%%=*}]=${s##*=}
            done

            fzf_array_preview cc2c
            unset -v cc2c
            ;;
        "$demo_c2cc")
            declare -A c2cc=()
            for s in "${countries[@]}"; do
                c2cc[${s##*=}]=${s%%=*}
            done

            fzf_array_preview c2cc
            unset -v c2cc
            ;;
        [qQ])
            break
            ;;
    esac
done
