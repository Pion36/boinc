#!/bin/sh

# This file is part of BOINC.
# http://boinc.berkeley.edu
# Copyright (C) 2014 University of California
#
# BOINC is free software; you can redistribute it and/or modify it
# under the terms of the GNU Lesser General Public License
# as published by the Free Software Foundation,
# either version 3 of the License, or (at your option) any later version.
#
# BOINC is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
# See the GNU Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public License
# along with BOINC.  If not, see <http://www.gnu.org/licenses/>.
#
#
# Script to build Macintosh 32-bit Intel library of sqlite 3.11.0 for
# use in building BOINC Manager.
#
# by Charlie Fenton 12/11/12
# Updated 2/11/14 for sqlite 3.8.3
# Updated 1/5/16 for sqlite 3.9.2
# Updated 3/2/16 for sqlite 3.11.0
#
## This script requires OS 10.6 or later
#
## If you drag-install Xcode 4.3 or later, you must have opened Xcode 
## and clicked the Install button on the dialog which appears to 
## complete the Xcode installation before running this script.
#
## In Terminal, CD to the sqlite-autoconf-3110000 directory.
##     cd [path]/sqlite-autoconf-3110000/
## then run this script:
##     source [path]/buildsqlite3.sh [ -clean ]
##
## the -clean argument will force a full rebuild.
##

if [ "$1" != "-clean" ]; then
    if [ -f .libs/libsqlite3.a ]; then
        echo "sqlite-3.11.0 already built"
        return 0
    fi
fi

export PATH=/usr/local/bin:$PATH

GCCPATH=`xcrun -find gcc`
if [  $? -ne 0 ]; then
    echo "ERROR: can't find gcc compiler"
    return 1
fi

GPPPATH=`xcrun -find g++`
if [  $? -ne 0 ]; then
    echo "ERROR: can't find g++ compiler"
    return 1
fi

MAKEPATH=`xcrun -find make`
if [  $? -ne 0 ]; then
    echo "ERROR: can't find make tool"
    return 1
fi

TOOLSPATH1=${MAKEPATH%/make}

ARPATH=`xcrun -find ar`
if [  $? -ne 0 ]; then
    echo "ERROR: can't find ar tool"
    return 1
fi

TOOLSPATH2=${ARPATH%/ar}

export PATH="${TOOLSPATH1}":"${TOOLSPATH2}":/usr/local/bin:$PATH

SDKPATH=`xcodebuild -version -sdk macosx Path`

rm -f .libs/libsqlite3.a

if [  $? -ne 0 ]; then return 1; fi

export PATH=/usr/local/bin:$PATH
export CC="${GCCPATH}";export CXX="${GPPPATH}"
export LDFLAGS="-Wl,-syslibroot,${SDKPATH},-arch,i386"
export CPPFLAGS="-Os -isysroot ${SDKPATH} -arch i386 -DMAC_OS_X_VERSION_MAX_ALLOWED=1040 -DMAC_OS_X_VERSION_MIN_REQUIRED=1040"
export CFLAGS="-Os -isysroot ${SDKPATH} -arch i386 -DMAC_OS_X_VERSION_MAX_ALLOWED=1040 -DMAC_OS_X_VERSION_MIN_REQUIRED=1040"
export SDKROOT="${SDKPATH}"
export MACOSX_DEPLOYMENT_TARGET=10.4

./configure --enable-shared=NO --host=i386
if [  $? -ne 0 ]; then return 1; fi

if [ "$1" = "-clean" ]; then
    make clean
fi

make
if [  $? -ne 0 ]; then return 1; fi

export CC="";export CXX=""
export LDFLAGS=""
export CPPFLAGS=""
export CFLAGS=""
export SDKROOT=""

return 0
