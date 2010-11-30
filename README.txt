README for mkvtom4v.sh shell script.

I am regularly downloading 720p H264 mkv files from the Internet and I wanted a quick way to get them into iTunes and use them on my iOS devices.  I found a few scripts and compiled them into this one script.  It identifies and extracts the video and audio.  It then encodes the audio into AAC and packages into a M4V container.

Usage: mkvtom4v [filename]

It will delete the mkv file if it successfully creates an m4v.  You might want to comment that out.  It also uses growl to identify you that the process is done.  Lastly, it loads the output into a subtitle app which let's me easily add chapter marks.