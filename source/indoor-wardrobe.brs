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
    for column = 0 to 3
        walkers.Push(CreateObject("roRegion", walkAtlas, column * 128, 0, 128, 192))
        seats.Push(CreateObject("roRegion", seatAtlas, column * 128, 0, 128, 192))
    end for
    for direction = 0 to 3
        m.characterSprites[direction] = walkers[direction]
    end for
    m.indoorSeatSprites = seats
    m.indoorOutfitIndex = index
    return true
end function
