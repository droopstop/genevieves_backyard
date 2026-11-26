function SetIndoorWardrobeOutfit(index)
    assets = IndoorWardrobeAssets(index)
    if assets = invalid then return false
    walkAtlas = CreateObject("roBitmap", assets.walk)
    seatAtlas = walkAtlas
    if assets.DoesExist("seat") then seatAtlas = CreateObject("roBitmap", assets.seat)
    if walkAtlas = invalid or seatAtlas = invalid then return false
    walkers = [] : seats = []
    riders = []
    bounds = IndoorWardrobeWalkBounds(index)
    seatTileWidth = Int(seatAtlas.GetWidth() / 4)
    seatY = 0 : seatHeight = seatAtlas.GetHeight()
    if not assets.DoesExist("seat") then seatY = 208 : seatHeight = 208
    for column = 0 to 3
        rect = bounds[column]
        walker = CreateObject("roRegion", walkAtlas, rect[0], rect[1], rect[2], rect[3])
        seat = CreateObject("roRegion", seatAtlas, column * seatTileWidth, seatY, seatTileWidth, seatHeight)
        if walker = invalid or seat = invalid then return false
        walkers.Push(walker)
        seats.Push(seat)
        if seatY > 0
            rider = CreateObject("roRegion", walkAtlas, column * seatTileWidth, 416, seatTileWidth, 192)
            if rider = invalid then return false
            riders.Push(rider)
        end if
    end for
    for direction = 0 to 3
        m.characterSprites[direction] = walkers[direction]
    end for
    m.indoorSeatSprites = seats
    m.indoorCostumeRiders = riders
    m.indoorOutfitIndex = index
    return true
end function

function IndoorWardrobeWalkBounds(index)
    if index = 0 then return [[18, 7, 91, 178], [147, 7, 89, 178], [276, 8, 87, 177], [404, 8, 88, 177]]
    if index = 1 then return [[19, 7, 90, 177], [148, 7, 88, 178], [276, 7, 88, 177], [403, 7, 88, 177]]
    if index = 2 then return [[26, 15, 107, 186], [185, 15, 109, 186], [351, 15, 98, 186], [509, 15, 100, 186]]
    if index = 3 then return [[31, 5, 98, 196], [192, 5, 96, 195], [355, 5, 89, 196], [516, 5, 88, 195]]
    if index = 4 then return [[34, 24, 92, 178], [194, 24, 92, 178], [353, 24, 94, 178], [514, 24, 92, 178]]
    if index = 5 then return [[31, 11, 98, 191], [191, 11, 98, 191], [357, 11, 85, 191], [518, 11, 84, 191]]
    if index = 6 then return [[31, 24, 98, 178], [191, 24, 98, 178], [353, 24, 93, 178], [514, 24, 91, 178]]
    if index = 7 then return [[36, 24, 87, 178], [196, 24, 87, 178], [359, 24, 82, 178], [518, 24, 84, 178]]
    if index = 8 then return [[26, 24, 108, 178], [188, 24, 103, 178], [352, 24, 95, 178], [511, 24, 97, 178]]
    if index = 9 then return [[35, 24, 89, 178], [196, 24, 88, 178], [360, 24, 79, 178], [520, 24, 79, 178]]
    if index = 10 then return [[27, 4, 105, 198], [190, 4, 100, 198], [353, 4, 94, 198], [515, 4, 90, 198]]
    return []
end function

function IndoorWardrobeAssets(index)
    if index = 0 then return {walk: "pkg:/images/wardrobe-walk-0.png", seat: "pkg:/images/wardrobe-sit-0.png"}
    if index = 1 then return {walk: "pkg:/images/wardrobe-walk-1.png", seat: "pkg:/images/wardrobe-sit-1.png"}
    if index = 2 then return {walk: "pkg:/images/wardrobe-walk-princess.png", seat: "pkg:/images/wardrobe-sit-princess.png"}
    if index = 3 then return {walk: "pkg:/images/wardrobe-walk-cowgirl.png", seat: "pkg:/images/wardrobe-sit-cowgirl.png"}
    if index = 4 then return {walk: "pkg:/images/wardrobe-ballerina.png"}
    if index = 5 then return {walk: "pkg:/images/wardrobe-ladybug.png"}
    if index = 6 then return {walk: "pkg:/images/wardrobe-fairy.png"}
    if index = 7 then return {walk: "pkg:/images/wardrobe-anna.png"}
    if index = 8 then return {walk: "pkg:/images/wardrobe-elsa.png"}
    if index = 9 then return {walk: "pkg:/images/wardrobe-doctor.png"}
    if index = 10 then return {walk: "pkg:/images/wardrobe-pirate.png"}
    return invalid
end function

function IndoorOutfitNames()
    return ["Original", "Purple", "Princess", "Cowgirl", "Ballerina", "Ladybug", "Fairy", "Anna", "Elsa", "Doctor", "Pirate"]
end function

function IndoorOutfitName(index)
    return UCase(IndoorOutfitNames()[index])
end function

function IndoorOutfitSpokenName(index)
    if index = 0 then return "Original clothes."
    return IndoorOutfitNames()[index] + " outfit."
end function

function IndoorOutfitChooserInstruction()
    return "Use the arrow buttons to choose an outfit. Press OK to wear it, or Back to cancel."
end function

function IsIndoorOutfitChooser(task)
    if task = invalid then return false
    if not task.DoesExist("outfitChooser") then return false
    return task.outfitChooser
end function

sub InitializeIndoorOutfitChooser(task, currentIndex)
    if currentIndex = invalid then currentIndex = 0
    if currentIndex < 0 or currentIndex >= IndoorOutfitNames().Count() then currentIndex = 0
    task.outfitChooser = true
    task.selectedOutfit = currentIndex
    task.duration = 2147483647
end sub

function HandleIndoorOutfitChoice(task, button, pressed)
    if not pressed then return ""
    if button = 0 then return "cancel"
    if button = 6 then return "confirm"
    count = IndoorOutfitNames().Count()
    if button = 2 or button = 4
        task.selectedOutfit = (task.selectedOutfit + count - 1) mod count
        return "changed"
    else if button = 3 or button = 5
        task.selectedOutfit = (task.selectedOutfit + 1) mod count
        return "changed"
    end if
    return ""
end function

sub LoadIndoorOutfitPreviews()
    m.indoorOutfitPreviews = []
    atlas = CreateObject("roBitmap", "pkg:/images/wardrobe-previews.png")
    if atlas = invalid then return
    for index = 0 to IndoorOutfitNames().Count() - 1
        rect = IndoorOutfitPreviewBounds(index)
        m.indoorOutfitPreviews.Push(CreateObject("roRegion", atlas, rect[0], rect[1], rect[2], rect[3]))
    end for
end sub

function IndoorOutfitPreviewBounds(index)
    return [(index mod 4) * 144, Int(index / 4) * 192, 144, 192]
end function

sub CloseIndoorOutfitPreviews()
    m.indoorOutfitPreviews = []
end sub

function IndoorWardrobeBodyHeight(index, direction)
    if index = 2 or index = 3 then return 180
    if index >= 4 then return 178
    return IndoorWardrobeWalkBounds(index)[direction][3]
end function

sub DrawIndoorOutfitChooser(screen, task, titleFont, labelFont, bodyFont)
    screen.DrawRect(0, 70, 1280, 650, &h173E5299)
    screen.DrawRect(55, 120, 1170, 500, &hFFF1D9FF)
    CenterLabel(screen, "CHOOSE YOUR OUTFIT", 640, 145, &h173E52FF, titleFont)
    count = IndoorOutfitNames().Count()
    page = Int(task.selectedOutfit / 4)
    first = page * 4
    visible = count - first
    if visible > 4 then visible = 4
    for slot = 0 to visible - 1
        index = first + slot
        x = 95 + (4 - visible) * 140 + slot * 280
        border = &hC6AD8FFF
        fill = &hFFFAF0FF
        if index = task.selectedOutfit then border = &hE4AE35FF : fill = &hFFE7AFFF
        screen.DrawRect(x - 6, 204, 262, 340, border)
        screen.DrawRect(x, 210, 250, 328, fill)
        if m.indoorOutfitPreviews <> invalid
            if m.indoorOutfitPreviews.Count() > index
                sprite = m.indoorOutfitPreviews[index]
                if sprite <> invalid
                    scale = 220 / 158
                    screen.DrawScaledObject(Int(x + 125 - sprite.GetWidth() * scale / 2), Int(481 - sprite.GetHeight() * scale), scale, scale, sprite)
                end if
            end if
        end if
        CenterLabel(screen, IndoorOutfitName(index), x + 125, 493, &h173E52FF, labelFont)
        if m.indoorOutfitIndex = index then CenterLabel(screen, "WEARING", x + 125, 519, &h54846BFF, bodyFont)
    end for
    CenterLabel(screen, "Arrows: choose     OK: wear outfit     Back: cancel", 640, 554, &h173E52FF, labelFont)
    CenterLabel(screen, (page + 1).ToStr() + " / " + (Int((count - 1) / 4) + 1).ToStr(), 640, 585, &h54846BFF, bodyFont)
end sub
