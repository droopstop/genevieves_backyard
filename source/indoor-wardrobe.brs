function SetIndoorWardrobeOutfit(index)
    walkUri = "pkg:/images/wardrobe-walk-0.png"
    seatUri = "pkg:/images/wardrobe-sit-0.png"
    if index = 1
        walkUri = "pkg:/images/wardrobe-walk-1.png"
        seatUri = "pkg:/images/wardrobe-sit-1.png"
    else if index = 2
        walkUri = "pkg:/images/wardrobe-walk-2.png"
        seatUri = "pkg:/images/wardrobe-sit-2.png"
    end if
    walkAtlas = CreateObject("roBitmap", walkUri)
    seatAtlas = CreateObject("roBitmap", seatUri)
    if walkAtlas = invalid or seatAtlas = invalid then return false
    walkers = [] : seats = []
    bounds = IndoorWardrobeWalkBounds(index)
    for column = 0 to 3
        rect = bounds[column]
        walkers.Push(CreateObject("roRegion", walkAtlas, rect[0], rect[1], rect[2], rect[3]))
        seats.Push(CreateObject("roRegion", seatAtlas, column * 128, 0, 128, 192))
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
    if index = 2 then return [[19, 8, 90, 176], [148, 7, 88, 178], [277, 7, 87, 177], [403, 8, 89, 176]]
    return []
end function

function NextIndoorOutfitIndex(index)
    if index = invalid then index = 0
    return (index + 1) mod 3
end function
