' Preserve Genevieve's atlas regions and replace only Stitch's four directions.
sub LoadStitchPhotoArtwork()
    if m.characterSprites.Count() <> 8 then return
    atlas = CreateObject("roBitmap", "pkg:/images/stitch-photo-directions.png")
    if atlas = invalid then return
    ' Front, back, left, right. Bounds include the full paws and thin tails.
    bounds = [[236, 35, 253, 528], [949, 33, 227, 527], [41, 568, 659, 485], [736, 569, 664, 484]]
    sprites = []
    for each rect in bounds
        sprite = CreateObject("roRegion", atlas, rect[0], rect[1], rect[2], rect[3])
        if sprite = invalid then return
        sprites.Push(sprite)
    end for
    for facing = 0 to 3
        m.characterSprites[4 + facing] = sprites[facing]
    end for
end sub
