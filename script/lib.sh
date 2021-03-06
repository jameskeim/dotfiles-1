#!/bin/bash

## Some functions useful in the various install/update scripts that
## manage dotfiles.

## Copy file to destination name or destination directory, but only if
## modified.
copy_to()
{
    _src_name="$1"
    if [ -d "$2" ]; then
	_dst_name="$2/$1"
    else
	_dst_name="$2"
    fi
    if ! cmp --quiet "$_src_name" "$_dst_name"; then
	# If the files are the same, we don't need to do anything.
	/bin/cp "$_src_name" "$_dst_name"
    fi
    unset _src_name _dst_name
}

## Make directory if it doesn't exist.
maybe_mkdir()
{
    if [ ! -d "$1" ]; then
	mkdir -p "$1"
    fi
}

# Append the contents of file $3 to the file $1 if the string $2 is
# not present in $1.  The file $1 should be found in $HOME/.
maybe_append()
{
    include_from=$1
    include_this=$2
    include_template=$3
    grep -q $include_this $HOME/$include_from 2> /dev/null
    if [ 0 != $? ]; then
	cat $include_template >> $HOME/$include_from
    fi
}
