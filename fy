#!/bin/bash
# ------------------------------------------------------------------
# Title: Fuzzy Yogurt 
# Created: 2020-04-19, version 0.0.1
# Copyright (C) 2020 Niklas Adam
#               
#          Description:
#               a fuzzy yogurt that finds and selects 
#               pacman and aur packages for installation
#
# Dependencies:
#     yay, fzf
# ------------------------------------------------------------------
#
# Email:    salkinmada@protonmail.com
# URL:	    https://niklasadam.oddodd.org
#
# ------------------------------------------------------------------
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

version=0.0.1
identity=fuzzy-yogurt # not used, you can simultaneously run as many fy's as you like
usage="usage: fy -sqrmfy {args} -hv"

display_help() {
    echo
    echo "╔════════════════════╗"
    echo "║░   FUZZY YOGURT   ░║"
    echo "╚════════════════════╝"
    echo
    echo "$usage"
    echo "path: $0 "
    echo
    echo "   -s, -style             select [(l|light)|(m|mono)(p|paper)]"
    echo "   -q, -query             input starting search query"
    echo "   -r, -repository        browse a specific repo [core|extra|community|aur]"
    echo "   -m, -margin            set the margin 10|2,5|5,3,8|1,5,2,3"
    echo "   -f, -fuzzy             fuzzy does nothing"
    echo "   -y, -yogurt            yogurt does nothing"
    echo "   -h, -help              show this help"
    echo "   -v, -version           get the fuzzy yogurt version"
    echo
    echo "   ctrl-space             toggle package"
    echo "   ctrl-d                 deselect-all"
    echo "   ctrl-l                 clear-query"
    echo "   ctrl-p                 toggle-preview"
    echo "   ctrl-w                 toggle-preview-wrap"
    echo "   shift-up               preview-up"
    echo "   shift-down             preview-down"
    echo "   shift-left             preview-page-up"
    echo "   shift-right            preview-page-down"
    echo "   ctrl-s                 see package stats"
    echo "   ctrl-u                 list updatable packages"
    echo "   ctrl-n                 read the news"
    echo "   ctrl-g                 get info about installed packages"
    echo "   enter                  install package(s)"
    echo "   esc                    leave, do nothing"
    echo "   tab                    toggle package and move pointer down"
    echo "   shift-tab              toggle package and move pointer up"
    echo "   ctrl-h                 list keybindings (help)"
    echo 
    exit 0
}

# array declaration
declare -a repo
declare -a not_supported_repo
declare -a tmp_array

supported_repositories='testing|core|extra|community|multilib|dvzrv|aur'
margin=2,3 # default margin

check_supported_repo() {
    # get length of the array
    num_repos_requested=${#repo[@]}

    # check support
    for (( i=1; i<${num_repos_requested}+1; i++ ));
    do
        if [[ ${repo[$i-1]} =~ ^($supported_repositories)$ ]]; then
            echo "queried repo: ${repo[$i-1]}"
        else
            echo " ! ${repo[$i-1]} is not a supported repo"
            not_supported_repo+=($(eval "echo \${repo[$i-1]}"))
        fi
    done

    #echo "the not supported elements are: ${not_supported_repo[@]} "

    # delete the array elements (repos) that are not supported
    for element_for_deletion in ${not_supported_repo[@]}
    do
        repo=("${repo[@]/$element_for_deletion}") #delete the not supported element in question
    done

    # bash arrays are not mutable by design..
    # rebuild the array to fill the gaps left after deletion
    for i in "${!repo[@]}"; do
        # if it is not empty fill tmp
        if  [ -n "${repo[i]}" ]; then
            tmp_array+=("${repo[i]}")
            #echo "tmp: ${tmp_array[@]}"
        fi
    done
    # rebuild repo array
    repo=("${tmp_array[@]}")
    unset tmp_array # empty the tmp_array
    
    # results
    #echo "result: ${repo[@]}"
}

#unset -v repo
while getopts s:q:r:m:f:hv option
    do
    case "${option}" in
        s | style) style=${OPTARG}
            info_style="-s ${OPTARG}" # for fyinfo
            ;;
        q | query) query=${OPTARG}
            ;;
        r | repository) repo=("$OPTARG")
            # get all args input after -r . stop at new option
            until [[ $(eval "echo \${$OPTIND}") =~ ^-.* ]] || [ -z $(eval "echo \${$OPTIND}") ]; do
                repo+=($(eval "echo \${$OPTIND}"))
                OPTIND=$((OPTIND + 1))
            done
            check_supported_repo
            ;;
        m | margin) margin=${OPTARG}
            info_margin="-m ${OPTARG}" # for fyinfo
            ;;
        f | fuzzy) fuzzy=${OPTARG}
            ;;
        y | yogurt) yugurt=${OPTARG}
            ;;
        h | help)
            display_help
            ;;
        v | version)
            echo "fuzzy yogurt v$version"
            exit 0
            ;;
        *)
            echo $usage
            exit 0
            ;;
    esac
done

default_colors() {
    header=#fabd2f
    bg=#1d2021
    bgp=#504945
    fg=#fe8019
    fgp=#fabd2f
    previewbg=#1d2001
    previewfg=#b8bb26
    info=#83a598
    border=#fb4934
    spinner=#fe8019
    hl=#83a598
    hlp=#8ec07c
    pointer=#fb4934
    prompt=#fb4934
    gutter=#3c3836
    marker=#fb4934
}

light_colors() {
    header=#fe5009
    bg=#ebdbb2
    bgp=#d5c4a1
    fg=#000000
    fgp=#504945
    previewbg=#8ec07c
    previewfg=#000000
    info=#665c54
    border=#d3869b
    spinner=#fe8019
    hl=#1102aa
    hlp=#1102fb
    pointer=#fe5009
    prompt=#b8bb26
    gutter=#8ec07c
    marker=#1f92fb
}

mono_colors() {
    header=#a1efe4
    bg=#272822
    bgp=#223aa2
    fg=#a6e22e
    fgp=#fc6633
    previewbg=#125849
    previewfg=#fc6633
    info=#f5f4f1
    border=#a1efe4
    spinner=#f4bf75
    hl=#66d9ef
    hlp=#66d9af
    pointer=#ae81ff
    prompt=#f8a8f2
    gutter=#383830
    marker=#fc6633
}

paper_colors() {
    header=#d7875f
    bg=#1c1c1c
    bgp=#000a58
    #5f8787
    fg=#5fafd7
    fgp=#1ae00f
    previewbg=#585858
    previewfg=#ffaf00
    info=#afd700
    border=#af005f
    spinner=#00afaf
    hl=#d7af5f
    hlp=#f9cf50
    pointer=#af005f
    prompt=#808080
    gutter=#4c8787
    marker=#af005f
}

# set colors
case $style in
    light | l)
		light_colors
		;;
    mono | m)
        mono_colors
		;;
    paper | p)
        paper_colors
		;; 
	*)
		default_colors
        info_style=""  # for fyinfo
		;;
esac

#yay -Ps
stats="yay --show --stats | fzf --phony --reverse --no-bold --margin $margin% \
--header=$'╔════════════════════╗ \n║░   YOGURT STATS   ░║\n╚════════════════════╝\n ' \
--pointer='O' --prompt='' --border=sharp \
--bind 'enter:abort' \
--color='bg:'$bg,'bg+:'$bg,'border:'$border,'spinner:'$spinner \
--color='hl:'$hl,'fg:'$fg,'fg+:'$fg,'pointer:'$fg,'header:'$header \
--color='hl+:'$hlp,'marker:'$marker,'info:'$bg"

upgrade_hints='echo \
"list of upgradable packages\n\n\
* yay -Syy\n\
  sync package database\n\n\
* yay -Sua\n\
  update all currently installed AUR packages\n\n\
* yay -Syu
  update package list and upgrade all\n\
  currently installed repo and AUR packages"'

upgrades="yay -Qu | fzf --preview '$upgrade_hints' --phony --reverse --no-bold --margin $margin% \
--preview-window=left:35%:wrap \
--header=$'╔════════════════════╗ \n║░   UPT YOGURTS?   ░║\n╚════════════════════╝\n\n' \
--pointer='▓' --prompt='' --border=sharp \
--bind 'enter:abort' \
--color='bg:'$bg,'bg+:'$bg,'border:'$border,'spinner:'$spinner \
--color='hl:'$hl,'fg:'$fg,'fg+:'$fg,'pointer:'$fg,'header:'$header \
--color='hl+:'$hlp,'marker:'$marker,'info:'$bg \
--color='preview-bg:'$previewbg,'preview-fg:'$previewfg"

news="yay --show --news --news | fold -s -w 70 | fzf --phony --reverse --no-bold --ansi --margin $margin% \
--header=$'╔════════════════════╗ \n║░   YOGURT NEWS!   ░║\n╚════════════════════╝\n ' \
--pointer='▓' --prompt='' --border=sharp \
--bind 'enter:abort' \
--color='bg:'$bg,'bg+:'$bg,'border:'$border,'spinner:'$spinner \
--color='hl:'$hl,'fg:'$fg,'fg+:'$fg,'pointer:'$fg,'header:'$header \
--color='hl+:'$hlp,'marker:'$marker,'info:'$bg"

keybindings="printf '%s\n%s' \
'ctrl-space   toggle package' '' \
'ctrl-d       deselect-all' '' \
'ctrl-l       clear-query' '' \
'ctrl-p       toggle-preview' '' \
'ctrl-w       toggle-preview-wrap' '' \
'shift-up     preview-up' '' \
'shift-down   preview-down' '' \
'shift-left   preview-page-up' '' \
'shift-right  preview-page-down' '' \
'ctrl-s       see package stats' '' \
'ctrl-u       list updatable packages' '' \
'ctrl-n       read the news' '' \
'ctrl-g       get info about installed packages' '' \
'enter        install package[s]' '' \
'esc          leave, do nothing' '' \
'tab          toggle package and move pointer down' '' \
'shift-tab    toggle package and move pointer up' '' \
'ctrl-h       [help] show keybindings'"

fuzzy_yogurt_help="$keybindings | fzf --phony --reverse --no-bold --margin $margin% \
--header=$'╔════════════════════╗ \n║░   KEYBINDINGS!   ░║\n╚════════════════════╝\n ' \
--pointer='▓' --prompt='' --border=sharp \
--bind 'enter:abort' \
--color='bg:'$bg,'bg+:'$bg,'border:'$border,'spinner:'$spinner \
--color='hl:'$hl,'fg:'$fg,'fg+:'$fg,'pointer:'$fg,'header:'$header \
--color='hl+:'$hlp,'marker:'$marker,'info:'$bg"

# the fuzzy yogurt
yay -Sl ${repo[@]} | fzf --preview 'yay -Si {2} | tail -n +2' \
-q "$query" -e -m --reverse --margin $margin% \
--pointer='▓' --prompt='~ ' --marker='<>' \
--preview-window=right:60% --border=sharp \
--bind 'ctrl-w:toggle-preview-wrap' \
--bind 'ctrl-l:clear-query' \
--bind 'ctrl-d:deselect-all' \
--bind 'ctrl-space:toggle' \
--bind 'ctrl-p:toggle-preview' \
--bind 'shift-right:preview-page-down' \
--bind 'shift-left:preview-page-up' \
--bind 'ctrl-s:execute('"$stats"')' \
--bind 'ctrl-u:execute('"$upgrades"')' \
--bind 'ctrl-n:execute('"$news"')' \
--bind 'ctrl-g:execute('"source fyinfo $info_style $info_margin"')' \
--bind 'ctrl-h:execute('"$fuzzy_yogurt_help"')' \
--header=$'╔════════════════════╗ \n║░   FUZZY YOGURT   ░║\n╚════════════════════╝\n ' \
--color='bg:'$bg,'bg+:'$bgp,'info:'$info,'border:'$border,'spinner:'$spinner,'gutter:'$gutter \
--color='hl:'$hl,'fg:'$fg,'fg+:'$fgp,'pointer:'$pointer,'prompt:'$prompt,'header:'$header \
--color='hl+:'$hlp,'marker:'$marker,'preview-bg:'$previewbg,'preview-fg:'$previewfg \
| awk '{print $2}' | xargs -ro yay -S
