# Activity artwork

Created with the built-in OpenAI image-generation tool, using the existing
character and yard atlases as references. Runtime assets:

- `images/activity-poses.png`: twelve illustrated activity poses, plus two mirrored petting poses generated at load time.
- `images/swing-frame.png`: wooden swing support without a fixed seat or ropes.
- Pose bounds and rendering: `source/activity-poses.brs`.

## Final prompt set

### Activity atlas

Create one transparent game sprite atlas, exactly four columns by three rows of
equally sized cells, twelve separate full-body poses with transparent gutters.
Preserve Genevieve's identity from the character reference: brown hair, pink bow,
pink puff-sleeve floral dress, pink Mary Jane shoes and white socks. Preserve her
face and toddler proportions. Use natural short upper arms, bent elbows, normal
hands and bent knees; avoid rubber limbs and detached hands. Keep head size
consistent. Row one: two kneeling right-facing petting poses with small hand
movements, then two standing right-facing watering poses holding a small red can
close to the waist with both elbows bent. Row two: two front-facing hanging poses
with raised hands and bent knees, then two seated swing poses with thighs
horizontal, bent knees and hands beside the shoulders gripping imaginary ropes.
Draw no branch, ropes or seat. Row three: two right-facing crouching garden
poses, one reaching near the knees and one lifting a carrot, then two standing
reaching poses touching a nearby wind chime with a bent arm. Only the girl and
specified handheld items, no scenery, labels or background.

### Swing support

Recreate the single wooden A-frame swingset from the top-right cell of the yard
reference atlas. Preserve the honey-brown carved wood, rounded crossbeam and
slightly three-quarter perspective. Remove all hanging ropes, chains and seats,
leaving the center opening transparent. Retain both triangular side supports
and stabilizer struts. Show one complete isolated frame with transparent margin,
no child, ground, other objects or text.

## Animation changes

Activity poses replace skin-colored arm overlays. Petting uses a kneeling pose;
watering holds the illustrated can; gardening crouches; tree hanging has raised
hands and bent knees; swing riding uses seated poses. The swingset's frame is
separate from the moving ropes and seat. One pendulum calculation positions the
seat and rider together and keeps the rope length fixed. The arc stays inside
the wooden supports.
