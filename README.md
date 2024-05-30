

# bgmusic_monkey.sh

This script automates the process of adding background music to podcast episodes or audio files. It combines acapella audio files with background music, adjusts volumes, and organizes the output into a structured directory.

## Usage

```bash
bash bgmusic_monkey.sh podcast_name /path/to/your/acapella_audiofiles /path/to/your/background_music_files
```

### Example

```bash
bash bgmusic_monkey.sh mypodcast ~/Music/accapellas ~/Music/background_music
```

## Prerequisites

- `ffmpeg` must be installed on your system.
- Ensure your acapella audio files and background music files are in `.mp3` format.

## Steps

1. **Setup Podcast Directory**
    - Creates a directory named `<podcast_name>_podcast` and navigates into it.

2. **Copy Acapella Files**
    - Copies all `.mp3` files from the provided acapella directory to the current directory.

3. **Setup Background Music Directory**
    - Creates a `RADIO` directory.
    - Copies all `.mp3` files from the provided background music directory to the `RADIO` directory.

4. **Adjust Background Music Volume**
    - Lowers the volume of all background music files to 20% and renames them with a `_low_20` suffix.
    - Moves these adjusted files to a `BGMUSIC_LOW_20` directory.

5. **Combine Audio Files**
    - Lists all acapella files and adds a random file from the `BGMUSIC_LOW_20` directory as background music.
    - Creates combined files with `_backgroundmusic` suffix and moves them to the `BGMUSIC_BACKGROUND` directory.

6. **Enumerate and Rename Files**
    - Renames all files in the `BGMUSIC_BACKGROUND` directory to `BGMUSIC_BACKGROUND_1.mp3`, `BGMUSIC_BACKGROUND_2.mp3`, etc.

7. **Archive the Files**
    - Zips the files in the `BGMUSIC_BACKGROUND` directory and moves the zip file to the main podcast directory.

8. **Clean Up**
    - Removes the `BGMUSIC_LOW_20` and `RADIO` directories.
    - Renames `BGMUSIC_BACKGROUND` to `<podcast_name>_podcast-season`.
    - Removes all `.mp3` files in the current directory.

9. **Display Size of Podcast Zip File**
    - Displays the size of the podcast zip file.

## Script

```bash
#!/bin/bash

# Create podcast directory and navigate into it
mkdir -p "$1"_podcast && cd "$1"_podcast

# Copy acapella files to the current directory
cp "$2"/*.mp3 .

# Create RADIO directory for background music
mkdir -p RADIO

# Copy background music files to the RADIO directory
cp "$3"/*.mp3 RADIO

# Lower volume of background music files to 20%
ls RADIO/*.mp3 | xargs -P8 -I {} bash -c 'ffmpeg -i "{}" -filter:a "volume=0.2" "${0%.*}_low_20.mp3"' {} && mkdir -p BGMUSIC_LOW_20 && mv RADIO/*_low_20.mp3 BGMUSIC_LOW_20
bgmusic=$(ls -1 BGMUSIC_LOW_20/*20.mp3 | shuf -n1)

# Combine acapella files with random background music files
ls -1 *mp3 | xargs -I@ -P8 ffmpeg -i @ -stream_loop -1 -i $bgmusic -filter_complex amerge=inputs=2 -ac 2 -shortest @_backgroundmusic.mp3 && mkdir -p BGMUSIC_BACKGROUND && mv *_backgroundmusic.mp3 BGMUSIC_BACKGROUND

# Rename files in BGMUSIC_BACKGROUND directory
cd BGMUSIC_BACKGROUND && ls -1 *mp3 | awk '{print "mv " $0 " BGMUSIC_BACKGROUND_" NR ".mp3"}' | bash

# Zip the files and move to the podcast directory
zip -r "$1"_podcast-season.zip ./*mp3 && mv "$1"_podcast-season.zip ../

# Clean up
cd .. && rm -rf BGMUSIC_LOW_20 && rm -rf RADIO

# Rename BGMUSIC_BACKGROUND to the podcast season name
mv BGMUSIC_BACKGROUND "$1"_podcast-season

# Remove all mp3 files in the current directory
rm *mp3

# Display the size of the podcast zip file
du -h "$1"*
```

## Notes

- Ensure the directories and files you provide are correctly structured.
- The script uses parallel processing (`-P8`) to speed up operations. Adjust the number based on your system's capabilities.
- The script assumes all input files are in `.mp3` format.

---

This README provides a comprehensive overview of the script, its usage, and the steps it performs.