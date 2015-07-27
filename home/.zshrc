## ヒストリを保存するファイル
HISTFILE=~/.zsh_history
## メモリ上のヒストリ数。
## 大きな数を指定してすべてのヒストリを保存するようにしている。
HISTSIZE=10000000 ## 保存するヒストリ数
SAVEHIST=100000000
## ヒストリファイルにコマンドラインだけではなく実行時刻と実行時間も保存する。
setopt extended_history
## 同じコマンドラインを連続で実行した場合はヒストリに登録しない。
setopt hist_ignore_dups

function peco-select-history() {
    local tac
    if which tac > /dev/null; then
        tac="tac"
    else
        tac="tail -r"
    fi
    BUFFER=$(\history -n 1 | \
        eval $tac | \
        peco --query "$LBUFFER")
    CURSOR=$#BUFFER
    zle clear-screen
}
zle -N peco-select-history
bindkey '^r' peco-select-history

autoload -U compinit
compinit

## Emacsキーバインドを使う。
bindkey -e

## ディレクトリ名だけでcdする。
setopt auto_cd
## cdで移動してもpushdと同じようにディレクトリスタックに追加する。
setopt auto_pushd
## カレントディレクトリ中に指定されたディレクトリが見つからなかった場合に
## 移動先を検索するリスト。
cdpath=(~)
## ディレクトリが変わったらディレクトリスタックを表示。
chpwd_functions=($chpwd_functions dirs)


## スペースで始まるコマンドラインはヒストリに追加しない。
setopt hist_ignore_space
## すぐにヒストリファイルに追記する。
setopt inc_append_history
## zshプロセス間でヒストリを共有する。
setopt share_history
## C-sでのヒストリ検索が潰されてしまうため、出力停止・開始用にC-s/C-qを使わない。
setopt no_flow_control
## ヒストリに追加されるコマンド行が古いモノと同じなら古いモノを削除
setopt hist_ignore_all_dups

## ^Dでログアウトしないようにする。
setopt ignore_eof

alias ll="ls -lh"
alias la="ls -lhAFG"

## グローバルエイリアス
alias -g G='| grep'
alias -g H='| head'
alias -g T='| tail'
alias -g S='| sed'
alias -g C='| pbcopy'
alias -g P='| pbpaste'

typeset -A myabbrev
myabbrev=(
    "pb"    "| pbcopy"
    "tz"    "tar zxvf "
    "tzc"   "tar zcvf "
    "tj"    "tar jxvf "
    "tjc"   "tar jcvf "
)
my-expand-abbrev() {
    local left prefix
    left=$(echo -nE "$LBUFFER" | sed -e "s/[_a-zA-Z0-9]*$//")
    prefix=$(echo -nE "$LBUFFER" | sed -e "s/.*[^_a-zA-Z0-9]\([_a-zA-Z0-9]*\)$/\1/")
    LBUFFER=$left${myabbrev[$prefix]:-$prefix}" "
}
zle -N my-expand-abbrev
bindkey " "  my-expand-abbrev

## ファイル操作を確認する。
# alias rm="rm -i"
# alias cp="cp -i"
# alias mv="mv -i"

## 完全に削除。
# alias rr="command rm -rf"










autoload -Uz vcs_info
zstyle ':vcs_info:*' formats \
    '(%{%F{green}%}%s%{%f%})-[%{%F{white}%K{blue}%}%b%{%f%k%}]'
zstyle ':vcs_info:*' actionformats \
    '(%{%F{white}%K{green}%}%s%{%f%k%})-[%{%F{white}%K{blue}%}%b%{%f%k%}|%{%F{white}%K{red}%}%a%{%f%k%}]'
prompt_bar_left_self="[%{%B%}%{%F{green}%}%n%{%b%}%{%F{magenta}%}@%{%B%}%m%{%b%}%{%f%}]"
prompt_bar_left_status="(%{%B%F{white}%(?.%K{green}.%K{red})%}%?%{%k%f%b%})"
prompt_bar_left_date="<%{%B%}%D{%Y/%m/%d %H:%M}%{%b%}>"
prompt_bar_left="-${prompt_bar_left_self}-${prompt_bar_left_status}-${prompt_bar_left_date}-"
prompt_bar_right="-[%{%B%F{red}%}%~%{%f%b%}]"
prompt_left="- %(1j,(%j),)%{%B%}%#%{%b%} "
count_prompt_characters()
{
    print -n -P -- "$1" | sed -e $'s/\e\[[0-9;]*m//g' | wc -m | sed -e 's/ //g'
}
update_prompt()
{
    local bar_left_length=$(count_prompt_characters "$prompt_bar_left")
    local bar_rest_length=$[COLUMNS - bar_left_length]

    local bar_left="$prompt_bar_left"
    local bar_right_without_path="${prompt_bar_right:s/%d//}"
    local bar_right_without_path_length=$(count_prompt_characters "$bar_right_without_path")
    local max_path_length=$[bar_rest_length - bar_right_without_path_length]
    bar_right=${prompt_bar_right:s/%d/%(C,%${max_path_length}<...<%d%<<,)/}
    local separator="${(l:${bar_rest_length}::-:)}"
    bar_right="%${bar_rest_length}<<${separator}${bar_right}%<<"

    PROMPT="${bar_left}${bar_right}"$'\n'"${prompt_left}"
    RPROMPT=""
    LANG=C vcs_info >&/dev/null
    if [ -n "$vcs_info_msg_0_" ]; then
	RPROMPT="${vcs_info_msg_0_}"
    fi
}
precmd_functions+=($precmd_functions update_prompt)
