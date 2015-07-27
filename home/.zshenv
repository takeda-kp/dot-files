# go path
export GOPATH=~/go
# export PATH=$PATH:$GOPATH/bin

#言語の設定
export LC_CTYPE=ja_JP.UTF-8
export LANG=ja_JP.UTF-8
export LC_ALL=$LANG
export LANGUAGE=$LANG
export TZ=JST-9

path=(
	#システム用
	#/usr/local/opt/coreutils/libexec/gnubin(N-/)
	$GOPATH/bin(N-/)
	/usr/local/bin(N-/)
	/bin(N-/)
	# 自分用
	# $HOME/bin(N-/)
	# システム用
	/usr/bin(N-/)
	/usr/sbin(N-/)
	/sbin(N-/)
)
typeset -U path

export EDITOR=atom

## vimを使う。
# export EDITOR=vim

## vimがなくてもvimでviを起動する。
if ! type vim > /dev/null 2>&1; then
    alias vim=vi
fi
