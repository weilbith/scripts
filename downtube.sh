command -v youtube-dl >/dev/null || {
  echo "Missing the 'youtube-dl' command!"
  exit 1
}

for object in "$@"; do
  echo "Download $object..."
  youtube-dl -x --audio-format mp3 --audio-quality 0 "$object"
done
