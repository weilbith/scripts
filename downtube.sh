#youtube-dl -x --audio-format mp3 --audio-quality 0 $1


for var in "$@"
do
	youtube-dl -x --audio-format mp3 --audio-quality 0 $var
done

