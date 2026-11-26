' Only the active room's twelve painted frames occupy texture memory.
sub LoadIndoorActivityArtwork(area)
    m.upstairsActivitySprites = []
    m.indoorDrawingSteps = invalid
    uri = ""
    if area = "bedroom" then uri = "pkg:/images/indoor-activity-bedroom.png"
    if area = "playroom" then uri = "pkg:/images/indoor-activity-playroom.png"
    if area = "bonusroom" then uri = "pkg:/images/indoor-activity-bonusroom.png"
    if area = "parentsroom" then uri = "pkg:/images/indoor-activity-parentsroom.png"
    if uri = "" then return
    atlas = CreateObject("roBitmap", uri)
    if atlas = invalid then return
    if area = "playroom" then m.indoorDrawingSteps = CreateObject("roBitmap", "pkg:/images/indoor-drawing-steps.png")
    bounds = IndoorActivityBounds(area)
    for row = 0 to 2
        rect = bounds[row]
        for column = 0 to 3
            m.upstairsActivitySprites.Push(CreateObject("roRegion", atlas, column * 256 + rect[0], row * 256 + rect[1], rect[2], rect[3]))
        end for
    end for
end sub

sub LoadIndoorSeatArtwork()
    SetIndoorWardrobeOutfit(0)
end sub

function IndoorAnimationPlacement(action)
    if action = "makebed" then return {x: 225, y: 348, h: 110}
    if action = "story" then return {x: 625, y: 384, h: 100}
    if action = "dressup" then return {x: 990, y: 385, h: 78}
    if action = "dollhouse" then return {x: 220, y: 437, h: 100}
    if action = "playkitchen" then return {x: 375, y: 397, h: 110}
    if action = "drawboard" then return {x: 920, y: 286, h: 125}
    if action = "cozyread" then return {x: 220, y: 350, h: 93}
    if action = "puzzle" then return {x: 610, y: 385, h: 108}
    if action = "treelights" then return {x: 1015, y: 405, h: 110}
    if action = "parentsbed" then return {x: 290, y: 354, h: 115}
    if action = "photos" then return {x: 650, y: 387, h: 105}
    return {x: 1058, y: 369, h: 110}
end function

sub DrawIndoorActivityFrame(screen, task, dressColor)
    if task.action = "dressup"
        x = 974 : y = 369 : facing = 0
        if task.DoesExist("x") then x = task.x
        if task.DoesExist("y") then y = task.y
        if task.DoesExist("facing") then facing = task.facing
        ' Dress-up uses the walking renderer and position, so changing never resizes her.
        DrawGenevieve(screen, x, y, dressColor, 0, facing)
        sparkleSize = 11 + Int(Sin(task.frame * 0.12) * 4)
        DrawPlanetSprite(screen, 3, x - 10, y + 7, sparkleSize, sparkleSize)
        DrawPlanetSprite(screen, 3, x + 42, y - 5, sparkleSize, sparkleSize)
        return
    end if
    if task.action = "cozyread"
        DrawIndoorSitting(screen, {x: 220, y: 365, pose: 0}, task.frame, dressColor)
        DrawIndoorResultProp(screen, 10, 220, 345, 38, 26)
        return
    end if
    room = UpstairsRoom(task.area)
    if room = invalid then return
    row = 0
    for i = 0 to 2
        if room.stations[i] = task.action then row = i
    end for
    frame = task.frame
    duration = 240
    if task.DoesExist("duration") then duration = task.duration
    phase = (Int(frame / 14) mod 6)
    sequence = [0, 1, 2, 1, 0, 3]
    column = sequence[phase]
    if task.action = "drawboard" or task.action = "puzzle" or task.action = "vase"
        column = Int(4 * frame / duration)
    else if frame > duration - 35
        column = 3
    end if
    if column > 3 then column = 3
    placement = IndoorAnimationPlacement(task.action)
    if task.action = "drawboard" and m.indoorDrawingSteps <> invalid
        ladderScale = 110 / m.indoorDrawingSteps.GetHeight()
        screen.DrawScaledObject(Int(906 - m.indoorDrawingSteps.GetWidth() * ladderScale / 2), 344, ladderScale, ladderScale, m.indoorDrawingSteps)
    end if
    if m.upstairsActivitySprites <> invalid and m.upstairsActivitySprites.Count() = 12
        sprite = m.upstairsActivitySprites[row * 4 + column]
        scale = placement.h / sprite.GetHeight()
        screen.DrawScaledObject(Int(placement.x - sprite.GetWidth() * scale / 2), Int(placement.y - placement.h / 2), scale, scale, sprite)
    else
        DrawGenevieve(screen, placement.x - 16, placement.y - 20, dressColor, 0, 0)
    end if
    if (task.action = "makebed" or task.action = "parentsbed") and m.indoorBedForeground <> invalid
        top = 380
        if task.area = "parentsroom" then top = 385
        screen.DrawScaledObject(0, top, 1, 1, m.indoorBedForeground)
    end if
end sub
