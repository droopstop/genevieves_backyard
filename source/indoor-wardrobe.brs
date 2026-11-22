function SetIndoorWardrobeOutfit(index)
    assets = IndoorWardrobeAssets(index)
    if assets = invalid then return false
    walkUri = assets.walk
    seatUri = assets.seat
    walkAtlas = CreateObject("roBitmap", walkUri)
    seatAtlas = CreateObject("roBitmap", seatUri)
    if walkAtlas = invalid or seatAtlas = invalid then return false
    walkers = [] : seats = []
    bounds = IndoorWardrobeWalkBounds(index)
    seatTileWidth = Int(seatAtlas.GetWidth() / 4)
    for column = 0 to 3
        rect = bounds[column]
        walkers.Push(CreateObject("roRegion", walkAtlas, rect[0], rect[1], rect[2], rect[3]))
        seats.Push(CreateObject("roRegion", seatAtlas, column * seatTileWidth, 0, seatTileWidth, seatAtlas.GetHeight()))
    end for
    for direction = 0 to 3
        m.characterSprites[direction] = walkers[direction]
    end for
    m.indoorSeatSprites = seats
    m.indoorOutfitIndex = index
    return true
end function

function IndoorWardrobeWalkBounds(index)
    if index = 0 then return [[18, 7, 91, 178], [147, 7, 89, 178], [276, 8, 87, 177], [404, 8, 88, 177]]
    if index = 1 then return [[19, 7, 90, 177], [148, 7, 88, 178], [276, 7, 88, 177], [403, 7, 88, 177]]
    if index = 2 then return [[26, 15, 107, 186], [185, 15, 109, 186], [351, 15, 98, 186], [509, 15, 100, 186]]
    if index = 3 then return [[31, 5, 98, 196], [192, 5, 96, 195], [355, 5, 89, 196], [516, 5, 88, 195]]
    return []
end function

function IndoorWardrobeAssets(index)
    if index = 0 then return {walk: "pkg:/images/wardrobe-walk-0.png", seat: "pkg:/images/wardrobe-sit-0.png"}
    if index = 1 then return {walk: "pkg:/images/wardrobe-walk-1.png", seat: "pkg:/images/wardrobe-sit-1.png"}
    if index = 2 then return {walk: "pkg:/images/wardrobe-walk-princess.png", seat: "pkg:/images/wardrobe-sit-princess.png"}
    if index = 3 then return {walk: "pkg:/images/wardrobe-walk-cowgirl.png", seat: "pkg:/images/wardrobe-sit-cowgirl.png"}
    return invalid
end function

function IndoorOutfitName(index)
    names = ["ORIGINAL", "PURPLE", "PRINCESS", "COWGIRL"]
    return names[index]
end function

function IndoorOutfitSpokenName(index)
    names = ["Original clothes.", "Purple outfit.", "Princess outfit.", "Cowgirl outfit."]
    return names[index]
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
    if currentIndex < 0 or currentIndex > 3 then currentIndex = 0
    task.outfitChooser = true
    task.selectedOutfit = currentIndex
    task.duration = 2147483647
end sub

function HandleIndoorOutfitChoice(task, button, pressed)
    if not pressed then return ""
    if button = 0 then return "cancel"
    if button = 6 then return "confirm"
    if button = 2 or button = 4
        task.selectedOutfit = (task.selectedOutfit + 3) mod 4
        return "changed"
    else if button = 3 or button = 5
        task.selectedOutfit = (task.selectedOutfit + 1) mod 4
        return "changed"
    end if
    return ""
end function

sub LoadIndoorOutfitPreviews()
    m.indoorOutfitPreviews = []
    for index = 0 to 3
        assets = IndoorWardrobeAssets(index)
        atlas = CreateObject("roBitmap", assets.walk)
        sprite = invalid
        if atlas <> invalid
            rect = IndoorWardrobeWalkBounds(index)[0]
            sprite = CreateObject("roRegion", atlas, rect[0], rect[1], rect[2], rect[3])
        end if
        m.indoorOutfitPreviews.Push(sprite)
    end for
end sub

sub CloseIndoorOutfitPreviews()
    m.indoorOutfitPreviews = []
end sub

function IndoorWardrobeBodyHeight(index, direction)
    if index = 2 or index = 3 then return 180
    return IndoorWardrobeWalkBounds(index)[direction][3]
end function

sub DrawIndoorOutfitChooser(screen, task, titleFont, labelFont, bodyFont)
    screen.DrawRect(0, 70, 1280, 650, &h173E5299)
    screen.DrawRect(55, 120, 1170, 500, &hFFF1D9FF)
    CenterLabel(screen, "CHOOSE YOUR OUTFIT", 640, 145, &h173E52FF, titleFont)
    for index = 0 to 3
        x = 95 + index * 280
        border = &hC6AD8FFF
        fill = &hFFFAF0FF
        if index = task.selectedOutfit then border = &hE4AE35FF : fill = &hFFE7AFFF
        screen.DrawRect(x - 6, 204, 262, 340, border)
        screen.DrawRect(x, 210, 250, 328, fill)
        if m.indoorOutfitPreviews <> invalid
            if m.indoorOutfitPreviews.Count() > index
                sprite = m.indoorOutfitPreviews[index]
                if sprite <> invalid
                    scale = 220 / IndoorWardrobeBodyHeight(index, 0)
                    screen.DrawScaledObject(Int(x + 125 - sprite.GetWidth() * scale / 2), Int(481 - sprite.GetHeight() * scale), scale, scale, sprite)
                end if
            end if
        end if
        CenterLabel(screen, IndoorOutfitName(index), x + 125, 493, &h173E52FF, labelFont)
        if m.indoorOutfitIndex = index then CenterLabel(screen, "WEARING", x + 125, 519, &h54846BFF, bodyFont)
    end for
    CenterLabel(screen, "Arrows: choose     OK: wear outfit     Back: cancel", 640, 568, &h173E52FF, labelFont)
end sub
