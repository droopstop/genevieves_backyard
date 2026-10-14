# Genevieve's Backyard

A BrightScript game for Roku, featuring Genevieve, Stitch, Mommy, Daddy, and
visiting cows. Explore the yard, gardens, playset, deck, firepit, and planets;
complete missions and collect treasures.

## Controls

- Arrow buttons: walk.
- OK: interact with a nearby character or activity.
- Play/Pause: twirl.
- Back: cancel an activity or return from an area; exits from the yard.

## Build and install

Run with Python 3; packaging uses only the standard library:

```sh
python3 package_game.py
```

The ZIP is written beside the project directory by default. To choose a path:

```sh
python3 package_game.py /path/to/genevieves-backyard.zip
```

Enable developer mode on a Roku, open its Development Application Installer in
a browser, and upload the ZIP. Installing replaces the sideloaded app and
restarts the game.

## Project files

- `source/`: game logic, animation rendering, music mixing, and narration mapping.
- `images/`: game sprites and original reference artwork.
- `audio/`: offline narration, music sections, sound effects, and source audio.
- `tools/`: optional asset-generation scripts, text catalogues, and artwork notes.
- `previews/`: simulator previews.
- `CREDITS.md`: artwork and audio sources and credits.

The packager includes only assets referenced by the game or manifest. Original
reference files stay in the repository without increasing the installation ZIP.

Narration is generated offline with Piper; regeneration requires `piper-tts`,
`imageio-ffmpeg`, and the voice model described in `CREDITS.md`. The game itself
does not require a speech service or an internet connection. Music sections can
be rebuilt with `tools/build_music_layer.py` using `imageio-ffmpeg`.
