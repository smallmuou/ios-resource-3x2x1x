#!/bin/bash
#
# Copyright (C) 2014 Wenva <lvyexuwenfa100@126.com>
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is furnished
# to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

set -e

spushd() {
     pushd "$1" 2>&1> /dev/null
}

spopd() {
     popd 2>&1> /dev/null
}

info() {
     local green="\033[1;32m"
     local normal="\033[0m"
     echo -e "[${green}INFO${normal}] $1"
}

error() {
     local red="\033[1;31m"
     local normal="\033[0m"
     echo -e "[${red}ERROR${normal}] $1"
}

# 获取当前目录
current_dir() {
    if [ ${0:0:1} = '/' ] || [ ${0:0:1} = '~' ]; then
        echo "$(dirname $0)"
    else
        echo "`pwd`/$(dirname $0)"
    fi
}

usage() {
cat << EOF

USAGE: $0 srcdir dstdir

DESCRIPTION:
    This script aim to convert 3x to 2x and 1x.

    srcfile - The source path. Must be 3x.
    dstpath - The destination path where the icons generate to.

    This script is depend on ImageMagick. So you must install ImageMagick first
    You can use 'sudo brew install ImageMagick' to install it

AUTHOR:
    Pawpaw<lvyexuwenfa100@126.com>

LICENSE:
    This script follow MIT license.

EXAMPLE:
    $0 ~/input ~/output
EOF
}

# Check ImageMagick
command -v convert >/dev/null 2>&1 || { error >&2 "The ImageMagick is not installed. Please use brew to install it first."; exit -1; }

SRC_PATH=$1
DST_PATH=$2
DST_PATH_2X=$DST_PATH/2X
DST_PATH_1X=$DST_PATH/1X

# Check param
if [ $# != 2 ];then
    usage
    exit -1
fi

# Check src path whether exist.
if [ ! -d "$SRC_PATH" ];then
    error 'The source path does not exist.'
    exit -1
fi

# Check dst path whether exist.
if [ ! -d "$DST_PATH" ];then
    mkdir -p "$DST_PATH"
fi

info "mkdir $DST_PATH_2X ..."
mkdir -p "$DST_PATH_2X"
info "mkdir $DST_PATH_1X ..."
mkdir -p "$DST_PATH_1X"

function scan_and_scale() {
    local workdir
    workdir=$1
    for file in $(ls ${SRC_PATH})
    do
        local path=$workdir/$file
        if test -d $path;then
            scan_and_scale $path
        else
            filename=${file%.*}
            # only for 3x
            if [ -n "`echo $filename|awk '/@3x$/{print $0}'`" ];then
                basename=`echo $filename|sed 's/@3x$//g'`
                ext=${file##*.}
                dst2x=$DST_PATH_2X/$basename@2x.$ext
                info "$dst2x ..."
                convert -resize 66.7% $path $dst2x
                dst1x=$DST_PATH_1X/$basename.$ext
                info "$dst1x ..."
                convert -resize 33.3% $path $dst1x
            fi
        fi
    done
}

scan_and_scale $SRC_PATH

info "Done"
