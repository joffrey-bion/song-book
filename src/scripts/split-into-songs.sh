#!/bin/bash
# inspired by https://stackoverflow.com/questions/8544197/splitting-a-file-in-linux-based-on-content

# create a helper to clean artist / song title
friendly_name () { \
echo $1 \
| sed -e 's/\\//g' \
| sed -e "s/'//g" \
| sed -e "s/!//g" \
| sed -e "s/\.//g" \
| sed -e "s/(//g" \
| sed -e "s/)//g" \
| sed -e 'y/āáǎàâçēéěèêīíǐìîōóǒòôūúǔùǖǘǚǜûĀÁǍÀÂÇĒÉĚÈÊĪÍǏÌÎŌÓǑÒÔŪÚǓÙǕǗǙǛÛ/aaaaaceeeeeiiiiiooooouuuuuuuuuAAAAACEEEEEIIIIIOOOOOUUUUUUUUU/' \
| sed -e 's/[^a-zA-Z0-9_&\+-]/-/g' \
| awk '{print tolower($0)}'; \
}

# define the path of the file containing all the songs concatenated
file_path="$SRC_DIR/songs/_all_songs.tex"

# get line numbers for all songs
line_numbers=$(grep -n -e 'begin{Song}' $file_path | cut -d: -f1)

read -a LINE_NUMBERS<<< $line_numbers

for i in $(seq 0 1 $((${#LINE_NUMBERS[@]}-1))); do
    start=${LINE_NUMBERS[i]}
    end=$((${LINE_NUMBERS[i+1]}-1))
    if [[ $end == -1 ]] # handle last song
    then
      end=$(wc -l < $file_path)
    fi
    line=$(sed -n "$start{p;q;}" $file_path)
    line=$(echo $line | sed -e 's/\[\([^]]*\)\]//g')
    artist=$(echo $line | sed -e 's/begin{Song}{[^}]*}{\([^}]*\)}$/\1/')
    friendly_artist=$(friendly_name "$artist")
    song_title=$(echo $line | sed -e 's/begin{Song}{\([^}]*\)}{[^}]*}$/\1/')
    friendly_song_title=$(friendly_name "$song_title")
    file_name="${friendly_artist}_${friendly_song_title}"
    echo $file_name
    sed -n "${start},${end}p" $file_path > "$SRC_DIR/songs/$file_name.tex"
done
