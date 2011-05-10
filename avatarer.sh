#! /bin/bash

##
#   avatarer.sh
#   track a user's Twitter avatar over time
#   leverages tweetimag.es's Twitter avatar service
#
#   according to @joestump, tweetimag.es's cache time is ~12 hours, so it doesn't pay to run more often than that.
#
#   USAGE:
#     ./avatarer.sh <username>
#
#   will fetch <username>'s avatar and save it to a directory structure of:
#     $AVATAR_DIR/$USERNAME/$DATESTAMP/$FILENAME
#
#   uses MD5 to not download the same avatar file twice (this prevents against duplicate names and such)
#
#   stick this in a cron to run every 6-12 hours and come back in a couple of months to a nice collection.
#
#   Written by: Spike Grobstein <spikegrobstein@mac.com>
#
##
#
#   The MIT License
#   
#   Copyright (c) 2011 Spike Grobstein
#   
#   Permission is hereby granted, free of charge, to any person obtaining a copy
#   of this software and associated documentation files (the "Software"), to deal
#   in the Software without restriction, including without limitation the rights
#   to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
#   copies of the Software, and to permit persons to whom the Software is
#   furnished to do so, subject to the following conditions:
#   
#   The above copyright notice and this permission notice shall be included in
#   all copies or substantial portions of the Software.
#   
#   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
#   IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
#   FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
#   AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
#   LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
#   OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
#   THE SOFTWARE.
##

USERNAME=$1
AVATAR_DIR="/avatars/$USERNAME"
AVATAR_URL="http://img.tweetimag.es/i/${USERNAME}_o"
TMP_AVATAR="/tmp/avatarer.tmp"

mkdir -p "$AVATAR_DIR"

curl -s -o $TMP_AVATAR $AVATAR_URL
AVATAR_MD5=`md5sum $TMP_AVATAR | awk '{ print $1 }'`
AVATAR_FILENAME=`curl -s -v $AVATAR_URL 2>&1 | grep X-Twitter-Origin | tail -c +21 | tr '\r\n' ' '`
AVATAR_FILENAME=${AVATAR_FILENAME##*/}

if [[ $(ls $AVATAR_DIR | grep $AVATAR_MD5) ]]; then
	echo "avatar found... no need to fetch again"
else
	echo "avatar not found! fetching! w000"
	
	DATESTAMP=`date +%Y%m%d%H%M%S`
	NEW_AVATAR_DIR_NAME=${AVATAR_DIR}/${DATESTAMP}_$AVATAR_MD5
	
	mkdir $NEW_AVATAR_DIR_NAME
	cd $NEW_AVATAR_DIR_NAME
	mv $TMP_AVATAR $AVATAR_FILENAME
fi

