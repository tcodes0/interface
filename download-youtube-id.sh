#! /usr/bin/env bash

set -euo pipefail
shopt -s globstar

vid_id=${1:-}
format=${2:-}
destination=${3:-}

audio_only_format=251
video_audio_720p=22
desktop=~/Desktop

err() {
  echo "Error: $1"
  exit 1
}

msg() {
  echo "> $*"
}

if [ -z "$vid_id" ]; then
  err "No video id provided"
fi

if [ -z "$format" ]; then
  msg defaulting to 720p video format
  msg available formats:
  msg audio only: $audio_only_format
  msg video 720p: $video_audio_720p
  msg more formats use yt-dlp --list-formats \$vid_id
  format=$video_audio_720p
fi

if [ -z "$destination" ]; then
  msg defaulting destination to desktop
  destination=$desktop
fi

temp_dir=$(mktemp -d youtube_dl-XXXXXX -p /tmp)
current_wd=$(pwd)

msg using temp "$temp_dir"
cd "$temp_dir"

# download from youtube
if ! yt-dlp -f "$format" "$vid_id" --output "%(title)s-%(release_date)s.%(ext)s"; then
  yt-dlp "$vid_id" --list-formats
  err "yt-dlp error, formats supported above"
fi

# sanitize filename
if ! rename -z -c -S ___ _ -S _-_ - ./*; then
  err "rename video error"
fi

if [ "$format" == $audio_only_format ]; then
  # convert to mp3
  # we don't know filename but it's the only file in the folder because we used mktemp
  if ! ffmpeg -i "$temp_dir"/* -codec:a libmp3lame -q:a 0 out.mp3; then
    err "mp3 ffmpeg error"
  fi

  if ! find . -name "*.webm" -exec mv out.mp3 {}.mp3 \;; then
    err "mp3 find error"
  fi

  if ! rename -S .webm.mp3 .mp3 ./*; then
    err "mp3 rename webm to mp3 error"
  fi

  if ! mv ./*.mp3 ~/Desktop; then
    err "mp3 mv error"
  fi

  exit 0
fi

if ! mv ./* "$destination"; then
  err "mv error"
fi

cd "$current_wd"

msg "done"

#  for id in N0u2kK11Pzc bu-WzIqffuA ivDbcw_R6dI oFXg7-69fJ0 djGlyTcW30Q SreqkvzVe5s wubJeU9G_gA VKio7bKURlc 8gzOH83I1W0; do download-youtube-id.sh $id; done
