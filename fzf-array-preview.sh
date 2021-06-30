# -*- mode: sh; sh-shell: bash; -*-

# Copyright (c) 2021 https://github.com/slowpeek
#
# Permission is hereby granted, free of charge, to any person
# obtaining a copy of this software and associated documentation files
# (the "Software"), to deal in the Software without restriction,
# including without limitation the rights to use, copy, modify, merge,
# publish, distribute, sublicense, and/or sell copies of the Software,
# and to permit persons to whom the Software is furnished to do so,
# subject to the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
# BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
# ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
# CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
#
# Homepage: https://github.com/slowpeek/fzf-array-preview

# It works with arrays, sparse arrays and assoc arrays. Just call it
# with a variable name as the only argument to make fzf render
# key=>val mapping.
#
# Target shell: bash.
#
# The generic idea is taken from this reddit comment
# https://www.reddit.com/r/bash/comments/o9djvn/arrays_with_fzf/h3alju1
fzf_array_preview () {
    if (($# < 1)); then
        echo "${FUNCNAME[0]} requires a var name argument" >&2
        return 1
    fi

    # All local vars should be prefixed with some junk to reduce risk
    # of shadowing the var name passed as $1. Let it be 'fzfap_'.
    local fzfap_type fzfap_def

    if ! read -r fzfap_type fzfap_type fzfap_def < <(declare -p "$1" 2>/dev/null); then
        echo "${FUNCNAME[0]}: '$1' is not defined" >&2
        return 1
    fi

    if [[ ! $fzfap_type == *[aA]* ]]; then
        echo "${FUNCNAME[0]}: '$1' is not an array" >&2
        return 1
    fi

    if [[ $fzfap_def == "$1=()" ]]; then
        echo "'$1' is empty" >&2
        return 1
    fi

    local fzfap_header
    [[ ! $fzfap_type == *A* ]] || fzfap_header='assoc '

    fzfap_header+="array '$1'"

    # Use some safe var name in $fzfap_def instead of raw $1. For
    # example $BASH_VERSINFO is always set and is readonly hence
    # trying to declare it below in fzf call would fail.
    fzfap_def="declare -A ${fzfap_def/$1/fzfap_it}"
    local -n fzfap_var=$1

    printf '%s\0' "${!fzfap_var[@]}" | sort -Vz |\
        fzf --header="$fzfap_header" -e --read0 --reverse --preview \
            "$fzfap_def; printf '%s\n' \"\${fzfap_it[{}]}\""

    return 0
}
