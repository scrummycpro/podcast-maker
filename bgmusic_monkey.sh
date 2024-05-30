#!bin/bash

# bash bgmusic_monkey.sh podcast_name /path/to/your/accapella_audiofiles  /path/to/your/background_music_files
#example bash bgmusic_monkey.sh mypodcast ~/Music/accapellas ~/Music/background_music
# download you accapellas or audio books and copy  them in the current directory
#Create and folder with the name of your podcast

mkdir -p "$1"_podcast && cd "$1"_podcast

# download your accapellas or audio books and place them  cp them in the current directory

cp  "$2"/*.mp3 .

#Place all  background or instrumentals in the files in the Radio directory in a folder called RADIO
mkdir -p RADIO

# download your background music and place them in the RADIO directory
cp  "$3"/*.mp3 RADIO



# Lower  all volumes to 20% using ffmpeg in the current ditectorty and rename them the same filename with _low_20 suffix

ls RADIO/*.mp3 | xargs -P8 -I {} bash -c 'ffmpeg -i "{}" -filter:a "volume=0.2" "${0%.*}_low_20.mp3"' {} && mkdir -p  BGMUSIC_LOW_20 && mv RADIO/*_low_20.mp3 BGMUSIC_LOW_20
bgmusic=$(ls -1 BGMUSIC_LOW_20/*20.mp3|shuf -n1)

#list the files in the current directory and add a random file from BGMUSIC_LOW_20S to the background of the file

ls -1 *mp3| xargs -I@ -P8 ffmpeg -i @  -stream_loop -1 -i $bgmusic  -filter_complex amerge=inputs=2 -ac 2 -shortest @_backgroundmusic.mp3 && mkdir -p BGMUSIC_BACKGROUND && mv *_backgroundmusic.mp3 BGMUSIC_BACKGROUND

#rename all  enumerate files in  BGMUSIC background folder  to BGmusic_background_1.mp3, BGmusic_background_2.mp3, BGmusic_background_3.mp3, etc
cd BGMUSIC_BACKGROUND && ls -1 *mp3 | awk '{print "mv " $0 " BGMUSIC_BACKGROUND_" NR ".mp3"}' | bash

#zip the files in the BGMUSIC_BACKGROUND folder and move them to the podcast folder
 zip -r "$1"_podcast-season.zip ./*mp3 && mv "$1"_podcast-season.zip ../

 #Clean up

 cd .. &&  rm -rf BGMUSIC_LOW_20 && rm -rf RADIO

 #chnage the name of BGMUSIC_BACKGROUND to the name of the podcast
 mv BGMUSIC_BACKGROUND "$1"_podcast-season

 #Removing all the mp3  files in the current directory
 rm  *mp3

#display the size of the podcast zip file
du -h "$1"*

