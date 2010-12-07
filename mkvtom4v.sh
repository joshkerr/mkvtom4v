#!/bin/bash
# 
#
# SCRIPT: mkv to m4v
# AUTHOR: Joshua Kerr
# LICENSE: BSD
# WEB: http://www.github.com/joshkerr/mkvtom4v
# CONTACT: joshkerr@gmail.com
#
#
# This script will convert all mkv files in the current directory by transcoding them into m4v files.  It assumes that you have x264 encoded video and either AC3 or DTS audio.
#
# Usage: mkvtom4v.sh
#
#

VERSION="1.1"

# Set easy to use posix path's for OSX.  Remember the original setting so we can reset it at the end.
ORIGINAL_IFS=$IFS
IFS=$'\n'

log="$PWD/log.$(date +%T-%F).txt"

cecho() {
	message=$1
	echo -e "$message"	
	echo -e "$message" >>"$log"	
	tput sgr0;
}

ncecho () {
	message=$1
	echo -ne "$message\r"	
	echo -ne "$message" >>"$log"	
	tput sgr0;
}

finish() {
	cecho "\n [o] All done!";
}

cecho "\n [x] mkvtom4v script, v$VERSION, written by Joshua Kerr\n [x] Contact him at: http://www.joshkerr.com"


for i in mplayer mencoder mkvinfo mkvextract MP4box ffmpeg; do
	if hash -r "$i" >/dev/null 2>&1; then
		ncecho;
	else
		cecho " [i] The $i command is not available, please install the required packages.\n";
		DIE=1;
	fi
done

if [[ $DIE ]]; then
	cecho " [i] Needed programs weren't found, exiting...\n";
	exit 1;
fi		

# Build the file name, directories and check for AC3 or DTS audio.

for i in *.mkv; do

	file=$i	
	file_AC3="${i%.*}"".ac3"
	file_AAC="${i%.*}"".aac"
	file_264="${i%.*}"".264"
	file_DTS="${i%.*}"".dts"

	directory=`dirname "$file"`
	title=`basename "$file" .mkv`
	DEST="${i%.*}.m4v"
	AC3=`mkvinfo "$file" | grep AC3` #check if it's AC3 audio or DTS
	AAC=`mkvinfo "$file" | grep AAC`
	order=`mkvinfo "$file" | grep "Track type" | sed 's/.*://' | head -n 1 | tr -d " "` #check if the video track is first or the audio track

	cecho " [x] Source filename: $file\n [x] Destination filename: $DEST \n";

	# Check for destination track before transcoding.
	if [[ -f $DEST ]];
	then
		cecho ' [i] Destination filename already exists.\n';
		exit 1;
	fi

	# Video is first in the order of tracks
	if [ "$order" = "video" ]; then
	  fps=`mkvinfo "$file" | grep duration | sed 's/.*(//' | sed 's/f.*//' | head -n 1` #store the fps of the video track
 
		if [ -n "$AC3" ]; then
	   		mkvextract tracks "$file" 1:"${title}".264 2:"${title}".ac3
			ffmpeg -i "./$file_AC3" -acodec libfaac -ab 576k "./$file_AAC"

		elif [ -n "$AAC" ]; then	
	   		mkvextract tracks "$file" 1:"${title}".264 2:"${title}".aac 
		else
	   		mkvextract tracks "$file" 1:"${title}".264 2:"${title}".dts
	   		ffmpeg -i "./$file_DTS" -acodec libfaac -ab 576k "./$file_AAC".aac
	  	fi
	
	# Audio is first in the track order
	else
	  	fps=`mkvinfo "$file" | grep duration | sed 's/.*(//' | sed 's/f.*//' | tail -n 1`
  	
		if [ -n "$AC3" ]; then
	   		mkvextract tracks "$file" 1:"${title}".ac3 2:"${title}".264 
	   		ffmpeg -i "./$file_AC3" -acodec libfaac -ab 576k "./$file_AAC"

	  	elif [ -n "$AAC" ]; then
	   		mkvextract tracks "$file" 1:"${title}".264 2:"${title}".aac 
	  	else
	   		mkvextract tracks "$file" 1:"${title}".dts 2:"${title}".264
	   		ffmpeg -i "./$file_DTS" -acodec libfaac -ab 576k "./$file_AAC"
	  	fi
	fi

	# Build container
	MP4Box -new "${directory}/${title}".m4v -add "${title}".264 -add "${title}".aac -fps $fps 

	rm -f "$title".aac "$title".dts "$title".ac3 "$title".264 "${title}".wav 

	if [ -f "${directory}/${title}".m4v ]; then
		rm -f "$file"
	fi

	# set the tag on this to HD

	mp4tags -H 1 "${directory}/${title}".m4v

	finish;

done

rm -f "$log"

IFS=$ORIGINAL_IFS


growlnotify -m "Converted: ${title}.m4v" "Completed conversion of MKV file into M4V file." > /dev/null 2>&1

open -a /Applications/iFlicks.app "${directory}/${title}".m4v
