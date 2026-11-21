# Genevieve's Backyard

A BrightScript game for Roku, featuring Genevieve, Stitch, Mommy, Daddy, Pappy, Gigi, Pops, and
visiting cows. Explore the yard, gardens, playset, deck, firepit, and planets;
complete missions and collect treasures.

Genevieve wears a pink dress and matching hair bow in all four walking views
and every illustrated activity pose. Her simple fallback drawing includes
the dress and hair bow too.

## Inside the house

Walk to the **house** to the right of the deck in the yard and press **OK**.
Inside the living room, Genevieve can walk up to **Pops**, her great-grandfather,
in his brown recliner and press **OK** for a mission. He offers six two-step
missions, waits while she explores, and gives reminders during unfinished
missions. Press **Play/Pause** to twirl for the indoor celebration steps.
Walk onto **EXIT TO YARD** or press **Back** to return beside the house.

Daddy's illustrated character is modeled after the supplied photo, with a
black baseball cap, rectangular glasses, blue polo shirt, and gray trousers.
He remains seated at the firepit with his cigar.

## Upstairs rooms

Inside the house, walk to the staircase built into the far-left wall and press **OK**. Choose
one of the four colored doors upstairs and press **OK**:

- **Genevieve's bedroom:** make her bed, read a picture book, and try colorful bows.
- **Genevieve's playroom:** play with the dollhouse, cook a pretend lunch, and draw a rainbow on the whiteboard.
- **Bonus room:** read a cozy couch story, finish a rainbow puzzle, and make the Christmas tree sparkle.
- **Mommy and Daddy's bedroom:** help make their bed, enjoy family pictures, and arrange flowers.

The four rooms use artwork modeled after the supplied room photos in the same
storybook style and wide layout as Pops' living room. The staircase is visible,
and Genevieve walks up or down its steps during floor changes.

Walk near a labeled activity and press **OK** to play its animation. Activities
can be repeated; a green DONE badge marks those completed during the visit.
Press **Back** or use **TO THE HALL** to leave a room, then use **DOWNSTAIRS**
to return to Pops. Existing outdoor missions continue while exploring upstairs.

Walk onto a **SIT** marker and press **OK** to sit on a bed, either playroom
chair, any of the four couch seats, or the stationary bike seat. She stays
seated until you press **OK** or **Back** to stand up; standing preserves her
room and walking position. The downstairs sofa below the window also has a sitting spot.

All new room introductions, activity instructions and results, staircase
instructions, and sitting instructions have offline Lessac narration. Individual
MP3 samples are in `previews/upstairs-audio/`.

The menu artwork is included at Roku's required HD (290 x 218) and FHD
(540 x 405) sizes, with an HD side icon reference. Install this updated ZIP
to apply the menu artwork and the upstairs expansion.

## Pappy's visits

Pappy is Genevieve's grandpa. Enter **the firepit** and he walks in from the
right after a short pause. Walk to Pappy in the lower-right corner and press
**OK** for a mission. He waits there while Genevieve explores, so you can always
return to him after finishing. His six two-step missions include campfire
helping, gardening, playing with Stitch, a picnic, bouncing, and a Mars trip.
Talking to him during an unfinished mission gives a reminder of the next step.
Complete that mission to get the next one; his missions cycle through all six.

## Controls

Gigi is Genevieve's grandma. Find her in the lower-right corner of **the deck**
and press **OK** to talk. She offers four two-step missions: deck flowers,
a garden picnic, garden helping, and a playtime surprise. She waits while
Genevieve explores. Talk to her for a reminder during a mission, or come back
after completing it for the next mission.

- Arrow buttons: walk.
- OK: interact with a nearby character or activity.
- Play/Pause: twirl.
- Back: cancel an activity or return from an area; exits from the yard.

Walk to the purple **Hippity Hop** in the open yard and press **OK** to ride.
Genevieve climbs on, bounces a lap around the yard, and climbs off again.
Her riding view changes to match her direction: front, back, left, and right.
Press **Back** during the ride to cancel; you can ride again as often as you like.

Walk to the bubble bottle in the open yard and press **OK**. Genevieve picks up
the round wand, blows shimmering bubbles that grow as they float, and watches
them pop. The bottle remains available so the animation can be replayed.

In **Birdsong Garden**, walk to the shovel in its stand and press **OK**.
Genevieve carries it to the dirt patch, digs several scoops into the yellow
bucket, carries the shovel back, and returns it to its original position.

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

Gigi has brownish-red hair. Gigi and Pappy use recorded narration with the same
Lessac voice as the rest of the game, including mission reminders and the
instructions to return to Grandma or Grandpa after completing a mission.
Gigi's spoken name is pronounced **gee gee**. The displayed spelling stays
**Gigi**. To refresh existing recordings after a pronunciation change, pass
`--regenerate-name Gigi` to `tools/generate_narration.py`.

Gigi and Mama (Mommy in the game) are illustrated from the supplied photos.
Gigi wears her mauve buttoned cowl-neck sweater and olive trousers; Mommy wears
her coral top and colorful geometric-pattern trousers.
Stitch's four directional views are based on her photo, with her short brown
brindle coat, dark ears, and gray muzzle. Petting uses the same updated artwork.

The game uses the same audio mix on every device: background music at level
100, lowered to 25 during narration or the cow sound. Music restores to 100
after speech or effects finish. Hippity hop narration uses the same bundled
Lessac voice as the other activities.

The background recording is normalized as a whole to -16 LUFS with a
-1.5 dB true-peak limit before it is split into playback sections.
