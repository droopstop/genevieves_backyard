# Audio credits

“Swan Lake Op. 20, No. 10: Scène” by Pyotr Ilyich Tchaikovsky.

- Recording date: July 22, 1933
- Source: Wikimedia Commons / CHARM–HMV
- Source page: https://commons.wikimedia.org/wiki/File:Tchaikovsky_Swan_Lake_Op.20_No.10._Sc%C3%A8ne.ogg
- Copyright status: Public domain
- Bundled files: `audio/music/*.wav`, mono PCM sections of the Wikimedia Commons MP3 transcode, normalized as a whole to -16 LUFS with a -1.5 dB true-peak limit

# Artwork

Hippity hop atlas (`images/hippity-hop.png`): purple bouncing toy and Genevieve riding it, generated with the built-in OpenAI imagegen tool using the activity artwork as a reference. Prompt recorded in `tools/hippity-hop-art.md`.

Directional riding atlas (`images/hippity-hop-directions.png`): matching front, back, left, and right riding views, generated with the built-in OpenAI imagegen tool. Prompt recorded in `tools/hippity-hop-art.md`.

Bubble activity atlas (`images/bubble-activity.png`): bubble bottle, round wand,
and two animated Genevieve wand poses, generated with the built-in OpenAI
imagegen tool using the directional character atlas as a reference. Prompt
recorded in `tools/bubble-art.md`.

Birdsong Garden digging props (`images/garden-dig-props.png`) and Genevieve
digging poses (`images/garden-dig-poses.png`): generated with the built-in
OpenAI imagegen tool using the yard, activity, and directional character atlases
as references. Prompts recorded in `tools/garden-dig-art.md`.

The illustrated yard object atlas (`images/yard-objects.png`) was generated for Genevieve's Backyard using OpenAI image generation. Sprite regions are defined in `LoadAreaArtwork`.

Daddy's seated cigar sprite (`images/daddy-cigar.png`): generated using OpenAI
ImageGen with the original Daddy atlas illustration as reference. Replaces
the coffee mug with a cigar and a small wisp of smoke.

Daddy's updated character (`images/daddy-photo.png`): generated using OpenAI
ImageGen from the user's supplied photograph and the seated cigar sprite.
The photograph is used as an appearance reference; it is not bundled in the game.

House interior (`images/house-interior.png`) and Pops in his recliner
(`images/pops-recliner.png`): generated using OpenAI ImageGen for this game.
Pops is Genevieve's great-grandfather. His mission narration uses the same
Piper Lessac voice and settings as the other family missions.

Original Genevieve and Stitch reference artwork (`images/genevieve-stitch.png`) was generated using OpenAI image generation. It is retained in the source project; the game package uses the directional atlas.

Directional character atlas (`images/characters-directions.png`): four views each of Genevieve and Stitch, generated from the original character artwork with OpenAI image generation.

Photo-based Stitch directional sprites (`images/stitch-photo-directions.png`):
generated using OpenAI ImageGen from the user's supplied dog photograph.
Front, back, left, and right views depict her short brown brindle coat, darker
ears, lean legs, and gray muzzle. These replace only Stitch's four sprite
regions, including the views used while she is petted. Genevieve's original
directional sprites are preserved. The photograph is not bundled in the game.

Stitch affection heart (`images/stitch-heart.png`): transparent illustrated sprite generated using OpenAI image generation.

Planet jewel atlas (`images/planet-jewels.png`): ruby crystals, jeweled gold ring, blue crystals, and sparkle sprites generated using OpenAI image generation.

Mommy character (`images/mommy.png`): transparent illustrated character sprite generated using OpenAI image generation.

Photo-based Mommy/Mama character (`images/mommy-photo.png`): generated with
OpenAI ImageGen from the user's supplied reference photograph, matching her
brown wavy hair, coral top, and geometric-pattern trousers. The photograph is
not included in the game package.

Photo-based Gigi character (`images/gigi-photo.png`): generated with OpenAI
ImageGen from the user's supplied reference photograph, matching her dark
auburn hair, mauve cowl-neck sweater with diagonal buttons, and olive trousers.
The photograph and other people in it are not included in the game package.

Yard detail atlas (`images/yard-details.png`): cottage, deck, weed bed, and pulled weed illustrations generated using OpenAI image generation.

Cow moo (`audio/cow-moo.wav`): “Mudchute cow 1.ogg” by Secretlondon, recorded April 2007 at Mudchute City Farm, London.
Source: https://commons.wikimedia.org/wiki/File:Mudchute_cow_1.ogg
License: Creative Commons Attribution-ShareAlike 3.0 Unported, https://creativecommons.org/licenses/by-sa/3.0/ .
Converted to mono 22,050 Hz PCM WAV, volume normalized, and short edge fades applied. This audio adaptation is distributed under the same CC BY-SA 3.0 license; original recording retained in the source project.

Cow head (`images/cow-head.png`): transparent illustrated sprite generated using OpenAI image generation.

Barn pasture atlas (`images/barn-pasture.png`): barn, walking cow, evergreen tree, and pasture fence illustrations generated using OpenAI image generation, with the existing cow head as a style reference.

# Neural narration

Mission and activity narration is synthesized offline using Piper and the
`en_US-lessac-high` English voice. Bundled MP3 clips play locally on each Roku;
no speech service or network connection is required while playing.

- Synthesis engine: https://github.com/OHF-Voice/piper1-gpl (GPL-3.0)
- Voice/model card: https://huggingface.co/rhasspy/piper-voices/tree/main/en/en_US/lessac/high
- Voice training data and terms: https://www.cstr.ed.ac.uk/projects/blizzard/2013/lessac_blizzard2013/
- Generator: `tools/generate_narration.py`; exported narration: `tools/narration-texts.json`.
- Piper and the voice model are generation tools and are not included in the Roku package.

Background music is split into mono 22,050 Hz PCM sections for an independent
sound layer. A continuous song clock preserves playback position when narration
or effects lower the music volume. The original downloaded MP3 remains in the
source project. Rebuild the music sections with `tools/build_music_layer.py`.

Activity poses (`images/activity-poses.png`) and separate wooden swing frame
(`images/swing-frame.png`): generated with OpenAI image generation using the
existing character and yard artwork as references. Prompts and implementation
notes are in `tools/activity-art.md`.

Table setting and s'more activity poses (`images/table-smores-poses.png`):
generated with OpenAI image generation using Genevieve's activity atlas as a
reference. The poses include a plate, low step stool, roasting skewer,
marshmallow and finished s'more. Final prompts are in `tools/table-smores-art.md`.
# Pappy addition

Gigi character artwork generated with OpenAI ImageGen for this game.
Gigi character behavior and mission text added for Genevieve's grandma.
Gigi's hair corrected to brownish red (auburn) using OpenAI ImageGen.
Gigi's name is synthesized as "Gee Gee" while retaining "Gigi" in game text.

Gigi and Pappy mission instructions, reminders, and completion messages use
the same Piper `en_US-lessac-high` voice and generation settings as the original
game narration. Exact speech text is exported by `tools/export-narration.brs`.

Pappy character artwork generated with OpenAI ImageGen for this game.
Pappy character behavior and mission text added for Genevieve's grandpa.


# Upstairs expansion

The four `images/upstairs-*.jpg` room backgrounds and transparent
`images/house-stairs.png` were created with the built-in OpenAI image generation
tool, using the user's room photographs as furnishing/color references and
`house-interior.png` as the storybook style and layout reference. The bedroom's
ballerina was corrected to exactly two arms. Prompts and asset notes are in
`tools/upstairs-art.json`. The user's original room photographs are not included
in the repository or installation package.

All 33 new room, activity, staircase and sitting speech clips use the same
Piper `en_US-lessac-high` voice and synthesis settings as the existing game.
Text is exported by `tools/export-upstairs-narration.brs` and recorded in
`tools/upstairs-narration-texts.json`. Named MP3 samples can be rebuilt with
`tools/build_upstairs_audio_samples.py`.

The living room's `images/house-interior-wall-stairs.jpg` was edited with the
built-in OpenAI image generator to integrate the staircase into the far-left
wall and place the sofa below the window. Navigation, climbing, and sitting
positions match the new architecture. The original living room art is retained
as a source reference.

The illustrated upstairs landing (`images/upstairs-hall.jpg`), four indoor
activity atlases (`images/indoor-activity-*.png`), seated directional sprite
sheet (`images/indoor-sitting.png`), and drawing step stool were generated
with the built-in OpenAI image generator. The existing character atlas and
room backgrounds guided their storybook style, identity and interaction props.
Prompts are in `tools/indoor-activity-art.json`; sprite bounds are in
`tools/indoor-animation-bounds.json`.

The persistent activity-result props, walk-through side doorway, wardrobe walking
and sitting sprites, and unlit bonus-room scene were created with the built-in
OpenAI image generator. Prompts are in `tools/indoor-results-art.json`. Original
three-part stories and family-picture narration use the same offline Lessac voice.
Whole-character runtime images for Pappy, Gigi, Mommy, Daddy, and Pops are scaled
to multiple times their on-screen size to reduce Roku texture memory and installer
storage while retaining their illustrated appearance and transparency.

Princess and cowgirl walking/seated costumes and the cream-and-pink ride-on pony
with sixteen mounted outfit/direction poses were created with the built-in OpenAI
image generator. The supplied toy photograph guided the pony. Prompts and atlas
bounds are in `tools/outfit-pony-art.json`, `tools/wardrobe-walk-bounds.json`, and
`tools/living-room-pony-bounds.json`. New choices and pony controls have offline
Lessac narration and matching named audio samples.
