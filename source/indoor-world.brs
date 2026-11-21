function IsIndoorStoryAction(action)
    return action = "story" or action = "cozyread" or action = "photos"
end function

function IndoorStoryLines(action)
    if action = "story"
        return ["Genevieve found a tiny butterfly resting beside her window.", "She opened her picture book, and imagined a garden full of colorful wings.", "Stitch curled up nearby, and they dreamed of tomorrow's backyard adventures."]
    else if action = "cozyread"
        return ["Once upon a time, Genevieve and Stitch found a shiny little star in the backyard.", "They carried it past the flowers and gave it a cozy home on the Christmas tree.", "The star twinkled, Stitch wagged her tail, and everyone smiled. The end."]
    end if
    return ["Here are Mommy, Daddy, and Genevieve. This is our family.", "We love playing together, sharing stories, and helping each other.", "Every happy day becomes another wonderful family memory."]
end function

sub PrepareIndoorActivity(task)
    if UpstairsRoom(task.area) = invalid then return
    if m.indoorWorld = invalid then m.indoorWorld = {}
    m.indoorWorld[task.area + ":" + task.action] = false
    if IsIndoorStoryAction(task.action)
        task.storyIndex = 0
        task.duration = 2147483647
    end if
end sub

function UpdateIndoorStory(task, voice)
    if not task.DoesExist("storyIndex") then task.storyIndex = 0
    if voice.speaking then return false
    lines = IndoorStoryLines(task.action)
    if task.storyIndex >= lines.Count() - 1 then return true
    task.storyIndex = task.storyIndex + 1
    voice.Say(lines[task.storyIndex])
    return false
end function

function RecordIndoorResult(world, area, action, outfitIndex)
    if UpstairsRoom(area) = invalid then return outfitIndex
    world[area + ":" + action] = true
    if action = "dressup" then return NextIndoorOutfitIndex(outfitIndex)
    return outfitIndex
end function

sub CompleteIndoorActivity(area, action)
    if UpstairsRoom(area) = invalid then return
    if m.indoorWorld = invalid then m.indoorWorld = {}
    index = m.indoorOutfitIndex
    if index = invalid then index = 0
    nextIndex = RecordIndoorResult(m.indoorWorld, area, action, index)
    if nextIndex <> index then SetIndoorWardrobeOutfit(nextIndex)
end sub

sub ResetIndoorRoomOnExit(world, previousArea, nextArea)
    if previousArea = nextArea or world = invalid then return
    if UpstairsRoom(previousArea) = invalid then return
    prefix = previousArea + ":"
    removeKeys = []
    for each key in world
        if Left(key, Len(prefix)) = prefix then removeKeys.Push(key)
    end for
    for each key in removeKeys
        world.Delete(key)
    end for
end sub

function IndoorResultReady(area, action)
    if m.indoorWorld = invalid then return false
    key = area + ":" + action
    if not m.indoorWorld.DoesExist(key) then return false
    return m.indoorWorld[key]
end function

sub LoadIndoorWorldArtwork()
    m.indoorResultSprites = []
    atlas = CreateObject("roBitmap", "pkg:/images/indoor-results.png")
    if atlas <> invalid
        for row = 0 to 2
            for column = 0 to 3
                m.indoorResultSprites.Push(CreateObject("roRegion", atlas, column * 128, row * 128, 128, 128))
            end for
        end for
    end if
    m.indoorExitDoor = CreateObject("roBitmap", "pkg:/images/indoor-exit-door.png")
end sub

sub LoadIndoorRoomResults(area)
    m.indoorTreeOn = invalid
    m.indoorPuzzleDone = invalid
    if area = "bonusroom"
        m.indoorTreeOn = CreateObject("roBitmap", "pkg:/images/indoor-tree-lit.jpg")
        m.indoorPuzzleDone = CreateObject("roBitmap", "pkg:/images/indoor-puzzle-done.jpg")
    end if
end sub

sub DrawIndoorResultProp(screen, index, x, y, width, height)
    if m.indoorResultSprites = invalid then return
    if m.indoorResultSprites.Count() <= index then return
    sprite = m.indoorResultSprites[index]
    screen.DrawScaledObject(Int(x - width / 2), Int(y - height / 2), width / sprite.GetWidth(), height / sprite.GetHeight(), sprite)
end sub

sub DrawIndoorWorldState(screen, area)
    if area = "bedroom"
        if IndoorResultReady(area, "makebed") then DrawIndoorResultProp(screen, 6, 210, 350, 108, 66)
        if IndoorResultReady(area, "story") then DrawIndoorResultProp(screen, 11, 674, 329, 22, 44)
        if IndoorResultReady(area, "dressup") then DrawIndoorResultProp(screen, 9, 944, 277, 74, 36)
    else if area = "playroom"
        if IndoorResultReady(area, "dollhouse")
            DrawIndoorResultProp(screen, 0, 91, 319, 26, 34)
            DrawIndoorResultProp(screen, 0, 165, 410, 26, 34)
            DrawIndoorResultProp(screen, 0, 91, 465, 26, 34)
        end if
        if IndoorResultReady(area, "playkitchen") then DrawIndoorResultProp(screen, 1, 330, 375, 61, 42)
        if IndoorResultReady(area, "drawboard") then DrawIndoorResultProp(screen, 2, 915, 222, 158, 106)
    else if area = "bonusroom"
        if IndoorResultReady(area, "puzzle") and m.indoorPuzzleDone <> invalid
            screen.DrawScaledObject(580, 297, 1, 1, m.indoorPuzzleDone)
        end if
        if IndoorResultReady(area, "treelights") and m.indoorTreeOn <> invalid
            screen.DrawScaledObject(892, 70, 1, 1, m.indoorTreeOn)
            frame = 0
            if m.indoorFrame <> invalid then frame = m.indoorFrame
            for sparkle = 0 to 8
                sx = 1076 + Sin(sparkle * 2.4) * (25 + sparkle * 6)
                sy = 145 + sparkle * 28
                size = 13 + Int(Sin(frame * 0.12 + sparkle) * 6)
                DrawPlanetSprite(screen, 3, sx, sy, size, size)
            end for
            DrawIndoorResultProp(screen, 3, 1025, 250, 24, 36)
            DrawIndoorResultProp(screen, 3, 1110, 310, 24, 36)
        end if
        if IndoorResultReady(area, "cozyread") then DrawIndoorResultProp(screen, 10, 267, 337, 48, 33)
    else if area = "parentsroom"
        if IndoorResultReady(area, "parentsbed") then DrawIndoorResultProp(screen, 7, 270, 346, 115, 70)
        if IndoorResultReady(area, "photos") then DrawIndoorResultProp(screen, 8, 646, 260, 61, 58)
        if IndoorResultReady(area, "vase") then DrawIndoorResultProp(screen, 5, 1083, 319, 70, 80)
    end if
end sub

sub DrawIndoorStoryCaption(screen, task, labelFont, bodyFont)
    index = 0
    if task.DoesExist("storyIndex") then index = task.storyIndex
    words = IndoorStoryLines(task.action)[index]
    screen.DrawRect(230, 487, 800, 110, &hFFF5DFF2)
    CenterLabel(screen, RoomActivityLabel(task.action), 630, 496, &h173E52FF, labelFont)
    first = "" : second = ""
    for each word in words.Split(" ")
        candidate = word
        if first <> "" then candidate = first + " " + word
        if second <> ""
            second = second + " " + word
        else if bodyFont.GetOneLineWidth(candidate, 1280) > 752
            second = word
        else
            first = candidate
        end if
    end for
    CenterLabel(screen, first, 630, 528, &h173E52FF, bodyFont)
    if second <> "" then CenterLabel(screen, second, 630, 553, &h173E52FF, bodyFont)
    CenterLabel(screen, Str(index + 1).Trim() + " / 3", 988, 571, &h825A3FFF, bodyFont)
end sub
