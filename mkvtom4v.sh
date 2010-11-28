#!/bin/bash

find . -type f | grep .mkv$ | while read file

do

directory=`dirname "$file"`
title=`basename "$file" .mkv`
AC3=`mkvinfo "$file" | grep AC3` #check if it's AC3 audio or DTS
AAC=`mkvinfo "$file" | grep AAC`
order=`mkvinfo "$file" | grep "Track type" | sed 's/.*://' | head -n 1 | tr -d " "` #check if the video track is first or the audio track

if [ "$order" = "video" ]; then
  fps=`mkvinfo "$file" | grep duration | sed 's/.*(//' | sed 's/f.*//' | head -n 1` #store the fps of the video track
  
if [ -n "$AC3" ]; then
   mkvextract tracks "$file" 1:"${title}".264 2:"${title}".ac3 
   ffmpeg -i "${title}".ac3 -acodec libfaac -ab 576k "${title}".aac
#  mplayer -ao pcm:file="${title}".wav:fast "${title}".ac3
#  faac -o "${title}".aac "${title}".wav
  elif [ -n "$AAC" ]; then
   mkvextract tracks "$file" 1:"${title}".264 2:"${title}".aac
  else
   mkvextract tracks "$file" 1:"${title}".264 2:"${title}".dts
   ffmpeg -i "${title}".dts -acodec libfaac -ab 576k "${title}".aac
  fi
else
  fps=`mkvinfo "$file" | grep duration | sed 's/.*(//' | sed 's/f.*//' | tail -n 1`
  if [ -n "$AC3" ]; then
   mkvextract tracks "$file" 1:"${title}".ac3 2:"${title}".264
   ffmpeg -i "${title}".ac3 -acodec libfaac -ab 576k "${title}".aac
  # mplayer -ao pcm:file="${title}".wav:fast "${title}".ac3
  # faac -o "${title}".aac "${title}".wav
  elif [ -n "$AAC" ]; then
   mkvextract tracks "$file" 1:"${title}".264 2:"${title}".aac
  else
   mkvextract tracks "$file" 1:"${title}".dts 2:"${title}".264
   ffmpeg -i "${title}".dts -acodec libfaac -ab 576k "${title}".aac
  fi
fi

MP4Box -new "${directory}/${title}".m4v -add "${title}".264 -add "${title}".aac -fps $fps

rm -f "$title".aac "$title".dts "$title".ac3 "$title".264 "${title}".wav


if [ -f "${directory}/${title}".m4v ]; then
	rm -f "$file"
fi

# set the tag on this to HD
mp4tags -H 1 "${directory}/${title}".m4v

growlnotify -m "Converted: ${title}.m4v" "Completed conversion of MKV file into M4V file." > /dev/null 2>&1

open -a /Applications/iSubtitle.app "${directory}/${title}".m4v

done