#! /bin/bash
if [ $# != 1 ]; then
  echo --usage
  echo "mp3-parallel.sh [format]"
  echo "format is: mp3, flac, m4a, alac, ..."
  echo "...defaulting to '.aif' in 3s..."
  read -rt 3
  if [ "$REPLY" == "n" ]; then
    exit 1
  else
    format="aif"
  fi
else
  format="$1"
fi
parallel -i -j"$(sysctl -n hw.ncpu)" ffmpeg -i {} -qscale:a 0 {}.mp3 -- ./*."$format"
rename -s ."$format".mp3 .mp3 ./*.mp3
