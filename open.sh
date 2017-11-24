#!/bin/bash

# Iterate over all given files as parameters.
for filename in "$@"
do
	# Get the file extension
	ext=${filename##*.}
	

	# Call the right open command
	case "$ext" in
	
	pdf)	gnome-open $filename;;

	png)	gnome-open $filename;;

	odt)	libreoffice --writer $filename;;

	*)	echo "Filetype $ext is not supported." ;;

esac
done
