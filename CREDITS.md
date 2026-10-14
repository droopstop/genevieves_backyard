# Audio credits

“Swan Lake Op. 20, No. 10: Scène” by Pyotr Ilyich Tchaikovsky.

- Recording date: July 22, 1933
- Source: Wikimedia Commons / CHARM–HMV
- Source page: https://commons.wikimedia.org/wiki/File:Tchaikovsky_Swan_Lake_Op.20_No.10._Sc%C3%A8ne.ogg
- Copyright status: Public domain
- Bundled files: `audio/music/*.wav`, mono PCM sections of the Wikimedia Commons MP3 transcode

# Artwork

The illustrated yard object atlas (`images/yard-objects.png`) was generated for Genevieve's Backyard using OpenAI image generation. Sprite regions are defined in `LoadAreaArtwork`.

Original Genevieve and Stitch reference artwork (`images/genevieve-stitch.png`) was generated using OpenAI image generation. It is retained in the source project; the game package uses the directional atlas.

Directional character atlas (`images/characters-directions.png`): four views each of Genevieve and Stitch, generated from the original character artwork with OpenAI image generation.

Stitch affection heart (`images/stitch-heart.png`): transparent illustrated sprite generated using OpenAI image generation.

Planet jewel atlas (`images/planet-jewels.png`): ruby crystals, jeweled gold ring, blue crystals, and sparkle sprites generated using OpenAI image generation.

Mommy character (`images/mommy.png`): transparent illustrated character sprite generated using OpenAI image generation.

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
