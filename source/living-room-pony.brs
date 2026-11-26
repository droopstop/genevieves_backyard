function CreateLivingRoomPony()
    return {x: 750, y: 560, facing: 2, mounted: false, moving: false, frame: 0}
end function

sub LoadLivingRoomPonyArtwork()
    m.livingRoomPony = CreateLivingRoomPony()
    m.livingRoomPonySprites = []
    m.livingRoomPonyRiders = []
    atlas = CreateObject("roBitmap", "pkg:/images/living-room-pony.png")
    if atlas <> invalid
        for each rect in LivingRoomPonyBounds(false)
            m.livingRoomPonySprites.Push(CreateObject("roRegion", atlas, rect[0], rect[1], rect[2], rect[3]))
        end for
    end if
end sub

sub LoadLivingRoomPonyRiders()
    if m.livingRoomPonyRiders.Count() > 0 then return
    atlas = CreateObject("roBitmap", "pkg:/images/living-room-pony-riders.png")
    if atlas <> invalid
        for each rect in LivingRoomPonyBounds(true)
            m.livingRoomPonyRiders.Push(CreateObject("roRegion", atlas, rect[0], rect[1], rect[2], rect[3]))
        end for
    end if
end sub

function IsLivingRoomPonyRide(task)
    if task = invalid then return false
    return task.action = "ridepony"
end function

function LivingRoomPonyInstructions()
    return "Hop on your pony! Use the arrow buttons to ride around the living room. Press OK to get off."
end function

function LivingRoomPonyDismountWords()
    return "You hopped off your pony. What a fun ride!"
end function

function LivingRoomPonyNearby(x, y, pony)
    if pony = invalid or pony.mounted then return false
    return Abs(x - pony.x) <= 64 and Abs(y - pony.y) <= 42
end function

function StartLivingRoomPonyRide(playerX, playerY, facing)
    if m.indoorOutfitIndex = invalid or m.indoorOutfitIndex < 4 then LoadLivingRoomPonyRiders()
    m.livingRoomPony.mounted = true
    m.livingRoomPony.moving = false
    return {area: "house", action: "ridepony", frame: 0, duration: 2147483647, x: playerX, y: playerY, facing: facing}
end function

function LivingRoomPonySafe(x, y)
    if x < 80 or x > 1200 or y < 430 or y > 610 then return false
    if PointInRect(x, y, 0, 280, 245, 210) then return false
    if PointInRect(x, y, 820, 280, 380, 300) then return false
    return true
end function

sub UpdateLivingRoomPony(pony, up, down, left, right)
    oldX = pony.x : oldY = pony.y
    dx = 0 : dy = 0
    if left then dx = dx - 4
    if right then dx = dx + 4
    if up then dy = dy - 4
    if down then dy = dy + 4
    if dx <> 0 and dy <> 0 then dx = dx * 0.7071 : dy = dy * 0.7071
    if LivingRoomPonySafe(pony.x + dx, pony.y) then pony.x = pony.x + dx
    if LivingRoomPonySafe(pony.x, pony.y + dy) then pony.y = pony.y + dy
    pony.moving = pony.x <> oldX or pony.y <> oldY
    pony.facing = FacingForMovement(pony.x - oldX, pony.y - oldY, pony.facing)
    if pony.moving then pony.frame = pony.frame + 1
end sub

function StopLivingRoomPonyRide(pony)
    pony.mounted = false : pony.moving = false
    offsets = [[95, 0], [-95, 0], [0, 65], [0, -65]]
    for each offset in offsets
        x = pony.x + offset[0] : y = pony.y + offset[1]
        if LivingRoomPonySafe(x, y) then return {x: x - 16, y: y - 50}
    end for
    return {x: pony.x - 16, y: pony.y - 50}
end function

sub DrawLivingRoomPony(screen, mounted)
    pony = m.livingRoomPony
    if pony = invalid then return
    sprite = invalid
    scale = 112 / 168
    if mounted
        index = m.indoorOutfitIndex
        if index = invalid then index = 0
        if index < 4
            riderIndex = index * 4 + pony.facing
            if m.livingRoomPonyRiders.Count() > riderIndex then sprite = m.livingRoomPonyRiders[riderIndex]
        else if m.indoorCostumeRiders <> invalid
            if m.indoorCostumeRiders.Count() > pony.facing then sprite = m.indoorCostumeRiders[pony.facing]
        end if
    end if
    if sprite = invalid
        if m.livingRoomPonySprites.Count() < 4 then return
        sprite = m.livingRoomPonySprites[pony.facing]
        if sprite = invalid then return
        scale = 64 / sprite.GetHeight()
    end if
    bob = 0
    if mounted and pony.moving then bob = Sin(pony.frame * 0.42) * 1.5
    screen.DrawScaledObject(Int(pony.x - sprite.GetWidth() * scale / 2), Int(pony.y - sprite.GetHeight() * scale + bob), scale, scale, sprite)
end sub

sub DrawLivingRoomPonyControls(screen, font)
    screen.DrawRect(330, 82, 620, 45, &h173E52DD)
    CenterLabel(screen, "Arrows: ride your pony    OK: get off", 640, 93, &hFFFFFFFF, font)
end sub

function LivingRoomPonyBounds(riding)
    if riding then return [[41, 18, 78, 168], [199, 18, 81, 168], [337, 18, 126, 168], [497, 18, 125, 168], [41, 210, 78, 168], [199, 210, 81, 168], [337, 210, 126, 168], [497, 210, 126, 168], [36, 397, 88, 173], [197, 397, 85, 173], [337, 397, 126, 173], [497, 397, 125, 173], [37, 582, 86, 180], [195, 582, 90, 180], [334, 582, 132, 180], [494, 582, 132, 180]]
    return [[37, 26, 86, 160], [199, 26, 82, 160], [323, 28, 154, 158], [483, 30, 154, 156]]
end function
