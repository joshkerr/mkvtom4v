PROJECT: MKV to M4V processing Script
Author: Joshua Kerr
License: BSD
WEB: http://www.github.com/joshkerr/mkvtom4v
CONTACT: joshkerr@gmail.com

I am regularly downloading 720p H264 mkv files from the Internet and I wanted a quick way to get them into iTunes and use them on my iOS devices.  I found a few scripts and compiled them into this one script.  It identifies and extracts the video and audio.  It then encodes the audio into AAC and packages into a M4V container.

Usage: mkvtom4v.sh

The script will process all files in the current folder.  You can use the script to create a watch folder.  Let OSX automatically process movie files using folder script actions.  


[2010-12-06: REVISION 2]

[NEW] Now scans a given folder for all MKV's.  Processes everything.

[FIXED] Would error out on ffmpeg when trying to convert certain AC3 files.

[FIXED] Progress function on success would quit the script rather than go on to the next step.