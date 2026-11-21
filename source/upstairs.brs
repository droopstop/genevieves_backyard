' House navigation is explicit: OK enters a doorway; Back returns one floor/room.
function IsUpstairsArea(area)
    return area = "upstairs" or UpstairsRoom(area) <> invalid
end function

function UpstairsRoom(area)
    if area = "bedroom"
        return {title: "GENEVIEVE'S BEDROOM", color: &hF8D7E7FF, accent: &hCB5794FF, targets: [160, 620, 1000], stations: ["makebed", "story", "dressup"]}
    else if area = "playroom"
        return {title: "GENEVIEVE'S PLAYROOM", color: &hD4EEDFFF, accent: &h3F9B86FF, targets: [140, 370, 920], stations: ["dollhouse", "playkitchen", "drawboard"]}
    else if area = "bonusroom"
        return {title: "THE BONUS ROOM", color: &hDDDFF6FF, accent: &h7775B5FF, targets: [260, 680, 1060], stations: ["cozyread", "puzzle", "treelights"]}
    else if area = "parentsroom"
        return {title: "MOMMY AND DADDY'S ROOM", color: &hF1E5D2FF, accent: &hAB805AFF, targets: [170, 640, 1060], stations: ["parentsbed", "photos", "vase"]}
    end if
    return invalid
end function

function IsHouseTravelAction(area, action)
    if area = "house" then return action = "stairsup"
    if not IsUpstairsArea(area) then return false
    return action = "stairsdown" or action = "hallway" or Left(action, 5) = "room_"
end function

function UpstairsReturn(area)
    if area = "upstairs" then return {area: "house", x: 100, y: 475}
    return {area: "upstairs", x: 624, y: 530}
end function

function HouseTravel(area, action)
    if action = "stairsup" then return {area: "upstairs", x: 624, y: 530}
    if action = "stairsdown" or action = "hallway" then return UpstairsReturn(area)
    return {area: Mid(action, 6), x: 1180, y: 600}
end function

function IndoorActivityRects(area)
    if area = "bedroom" then return [{action: "makebed", x: 40, y: 405, w: 125, h: 80}, {action: "story", x: 550, y: 360, w: 150, h: 100}, {action: "dressup", x: 880, y: 380, w: 200, h: 95}]
    if area = "playroom" then return [{action: "dollhouse", x: 35, y: 390, w: 185, h: 100}, {action: "playkitchen", x: 265, y: 365, w: 145, h: 100}, {action: "drawboard", x: 820, y: 320, w: 200, h: 105}]
    if area = "bonusroom" then return [{action: "cozyread", x: 190, y: 445, w: 155, h: 45}, {action: "puzzle", x: 590, y: 345, w: 180, h: 90}, {action: "treelights", x: 970, y: 355, w: 210, h: 110}]
    if area = "parentsroom" then return [{action: "parentsbed", x: 20, y: 425, w: 140, h: 80}, {action: "photos", x: 535, y: 365, w: 195, h: 90}, {action: "vase", x: 1020, y: 300, w: 95, h: 90}]
    return []
end function

function UpstairsActionAt(area, x, y)
    if area = "upstairs"
        rooms = ["bedroom", "playroom", "bonusroom", "parentsroom"]
        doorX = [240, 505, 775, 1040]
        for i = 0 to 3
            if PointInRect(x, y, doorX[i] - 75, 325, 150, 100) then return "room_" + rooms[i]
        end for
        if PointInRect(x, y, 1040, 565, 210, 115) then return "stairsdown"
    else
        for each seat in UpstairsSeats(area)
            if PointInRect(x, y, seat.walkX - 32, seat.touchY - 25, 64, 50) then return seat.action
        end for
        for each item in IndoorActivityRects(area)
            if PointInRect(x, y, item.x, item.y, item.w, item.h) then return item.action
        end for
    end if
    return ""
end function

function IsAutomaticIndoorAction(area, action)
    return (area = "house" or IsUpstairsArea(area)) and action <> "" and action <> "pops" and action <> "twirl"
end function

function ObserveIndoorContact(state, area, action, moving, busy)
    if not IsAutomaticIndoorAction(area, action)
        state.contact = ""
        return false
    end if
    key = area + ":" + action
    if state.contact = key or busy or not moving then return false
    state.contact = key
    return true
end function

function BeginIndoorInteraction(area, action, playerX, playerY, facing)
    if IsHouseTravelAction(area, action) and action <> "stairsup" and action <> "stairsdown"
        landing = HouseTravel(area, action)
        return {task: invalid, landing: landing, words: RoomWelcome(landing.area)}
    end if
    duration = 240
    words = UpstairsPrompt(action) + "."
    if action = "stairsup" or action = "stairsdown" then duration = 100
    if IsSeatAction(action)
        duration = 2147483647
        words = "Sit down and relax. Press OK or Back to stand up."
    end if
    return {task: {area: area, action: action, frame: 0, duration: duration, x: playerX, y: playerY, facing: facing}, landing: invalid, words: words}
end function

function UpstairsPrompt(action)
    if IsSeatAction(action) then return "sit down and relax"
    if action = "dollhouse" then return "play with the dollhouse"
    if action = "playkitchen" then return "cook a pretend lunch"
    if action = "drawboard" then return "draw a rainbow on the whiteboard"
    if action = "cozyread" then return "read a story on the couch"
    if action = "treelights" then return "make the Christmas tree twinkle"
    if action = "stairsup" then return "climb the stairs upstairs"
    if action = "stairsdown" then return "go downstairs to Pops"
    if action = "hallway" then return "return to the upstairs hall"
    if action = "room_bedroom" then return "enter Genevieve's bedroom"
    if action = "room_playroom" then return "enter Genevieve's playroom"
    if action = "room_bonusroom" then return "enter the bonus room"
    if action = "room_parentsroom" then return "enter Mommy and Daddy's room"
    if action = "makebed" then return "make your cozy bed"
    if action = "story" then return "read a picture book"
    if action = "dressup" then return "try on colorful bows"
    if action = "puzzle" then return "put together a rainbow puzzle"
    if action = "parentsbed" then return "help make Mommy and Daddy's bed"
    if action = "photos" then return "look at family pictures"
    if action = "vase" then return "arrange a vase of flowers"
    return ""
end function

function UpstairsSuccess(action)
    if action = "dollhouse" then return "The dolls loved your happy little house!"
    if action = "playkitchen" then return "Your pretend lunch looks delicious!"
    if action = "drawboard" then return "You drew a beautiful rainbow!"
    if action = "cozyread" then return "What a cozy story on the couch!"
    if action = "treelights" then return "The Christmas tree is sparkling!"
    if action = "makebed" then return "Your bed is cozy and your pillows are fluffy!"
    if action = "story" then return "What a wonderful picture book!"
    if action = "dressup" then return "You tried pink, purple, and golden bows!"
    if action = "puzzle" then return "Every rainbow puzzle piece is in place!"
    if action = "parentsbed" then return "Thank you for helping Mommy and Daddy!"
    if action = "photos" then return "So many happy family memories!"
    if action = "vase" then return "Your flowers look beautiful!"
    return ""
end function

sub DrawHouseStairs(screen, labelFont, bodyFont)
    ' The architectural stairs are already painted into the room; no text target.
end sub

sub DrawUpstairs(screen, area, titleFont, labelFont, bodyFont, completed)
    room = UpstairsRoom(area)
    wall = &hF5ECDFFF
    accent = &h548A98FF
    title = "UPSTAIRS - OUR FAMILY ROOMS"
    if room <> invalid
        wall = room.color : accent = room.accent : title = room.title
    end if
    screen.Clear(wall)
    screen.DrawRect(0, 330, 1280, 390, &hC89D76FF)
    for y = 340 to 700 step 48
        screen.DrawRect(0, y, 1280, 2, &hAC805EFF)
    end for
    screen.DrawRect(0, 317, 1280, 14, &hFFF8E9FF)
    DrawHeader(screen, title, titleFont, bodyFont)
    if area = "upstairs"
        if m.upstairsBackdrops <> invalid
            backdrop = m.upstairsBackdrops[area]
            if backdrop <> invalid then screen.DrawScaledObject(0, 0, 1280 / backdrop.GetWidth(), 720 / backdrop.GetHeight(), backdrop)
        end if
        DrawHeader(screen, title, titleFont, bodyFont)
        names = ["GENEVIEVE", "PLAYROOM", "BONUS", "MOM+DAD"]
        doorX = [240, 505, 775, 1040]
        font = m.upstairsDoorFont
        if font = invalid then font = bodyFont
        for i = 0 to 3
            CenterLabel(screen, names[i], doorX[i], 149, &h6E4C2DFF, font)
        end for
    else
        if m.upstairsBackdrops <> invalid
            backdrop = m.upstairsBackdrops[area]
            if backdrop <> invalid then screen.DrawScaledObject(0, 0, 1280 / backdrop.GetWidth(), 720 / backdrop.GetHeight(), backdrop)
        end if
        DrawHeader(screen, title, titleFont, bodyFont)
        exitLabel = "TO THE HALL"
    end if
    screen.DrawText("Walk up to an item to play   |   Back: return", 38, 666, &h173E52FF, bodyFont)
end sub

function RoomActivityLabel(action)
    if action = "dollhouse" then return "DOLLHOUSE"
    if action = "playkitchen" then return "PLAY KITCHEN"
    if action = "drawboard" then return "WHITEBOARD"
    if action = "cozyread" then return "COUCH STORY"
    if action = "treelights" then return "TREE LIGHTS"
    if action = "makebed" or action = "parentsbed" then return "MAKE THE BED"
    if action = "story" then return "PICTURE BOOK"
    if action = "dressup" then return "DRESS UP"
    if action = "puzzle" then return "RAINBOW PUZZLE"
    if action = "photos" then return "FAMILY PHOTOS"
    return "FLOWER ARRANGING"
end function

sub LoadUpstairsArtwork()
    ' Keep room backdrops out of the startup texture budget on smaller Roku TVs.
    m.upstairsBackdrops = {}
    m.loadedUpstairsArea = ""
    m.upstairsActivitySprites = []
    LoadIndoorSeatArtwork()
end sub

sub UpdateUpstairsArtwork(area)
    if m.loadedUpstairsArea = area then return
    m.upstairsActivitySprites = []
    m.indoorBedForeground = invalid
    m.indoorDrawingSteps = invalid
    m.upstairsBackdrops = {}
    m.loadedUpstairsArea = area
    uri = ""
    if area = "upstairs" then uri = "pkg:/images/upstairs-hall.jpg"
    if area = "bedroom" then uri = "pkg:/images/upstairs-bedroom.jpg"
    if area = "playroom" then uri = "pkg:/images/upstairs-playroom.jpg"
    if area = "bonusroom" then uri = "pkg:/images/upstairs-bonusroom.jpg"
    if area = "parentsroom" then uri = "pkg:/images/upstairs-parentsroom.jpg"
    if uri <> "" then m.upstairsBackdrops[area] = CreateObject("roBitmap", uri)
    LoadIndoorActivityArtwork(area)
end sub

function IsSeatAction(action)
    return Left(action, 4) = "sit_"
end function

function UpstairsSeats(area)
    if area = "bedroom" then return [{action: "sit_childbed", walkX: 230, touchY: 455, x: 260, y: 372, pose: 0}]
    if area = "playroom" then return [{action: "sit_chair1", walkX: 535, touchY: 450, x: 535, y: 447, pose: 0}, {action: "sit_chair2", walkX: 635, touchY: 450, x: 635, y: 447, pose: 0}]
    if area = "bonusroom" then return [{action: "sit_sofa1", walkX: 105, touchY: 405, x: 125, y: 390, pose: 0}, {action: "sit_sofa2", walkX: 210, touchY: 390, x: 220, y: 365, pose: 0}, {action: "sit_sofa3", walkX: 315, touchY: 379, x: 315, y: 350, pose: 0}, {action: "sit_sofa4", walkX: 420, touchY: 375, x: 420, y: 345, pose: 0}]
    if area = "parentsroom" then return [{action: "sit_parentbed", walkX: 255, touchY: 465, x: 335, y: 365, pose: 0}, {action: "sit_bike", walkX: 1150, touchY: 440, x: 1135, y: 350, pose: 1}]
    if area = "house" then return [{action: "sit_livingsofa", walkX: 460, touchY: 410, x: 460, y: 285, pose: 0}]
    return []
end function

function FindIndoorSeat(area, action)
    for each seat in UpstairsSeats(area)
        if seat.action = action then return seat
    end for
    return invalid
end function

function RoomWelcome(area)
    if area = "upstairs" then return "Welcome upstairs! Choose a door to explore a room."
    if area = "bedroom" then return "Welcome to Genevieve's bedroom! Make your bed, read a book, or try on a bow."
    if area = "playroom" then return "Welcome to your playroom! Explore the dollhouse, cook pretend food, or draw a rainbow."
    if area = "bonusroom" then return "Welcome to the bonus room! Enjoy a couch story, a rainbow puzzle, and the sparkling Christmas tree."
    if area = "parentsroom" then return "Welcome to Mommy and Daddy's room! Help make the bed, look at family pictures, and arrange flowers."
    if area = "house" then return "You are downstairs with Pops."
    return ""
end function

sub DrawIndoorSitting(screen, seat, frame, dressColor)
    pose = 0
    if seat.DoesExist("pose") then pose = seat.pose
    if m.indoorSeatSprites <> invalid and m.indoorSeatSprites.Count() = 4
        sprite = m.indoorSeatSprites[pose]
        height = 92
        scale = height / sprite.GetHeight()
        hipX = 0.5
        if pose = 1 then hipX = 0.70
        if pose = 2 then hipX = 0.30
        if pose = 3 then hipX = 0.58
        ' Anchor the bottom of the hips to the cushion; legs remain in front.
        screen.DrawScaledObject(Int(seat.x - sprite.GetWidth() * scale * hipX), Int(seat.y - height * 0.70), scale, scale, sprite)
    else
        DrawGenevieve(screen, seat.x - 16, seat.y - 48, dressColor, 0, 0)
    end if
end sub

sub DrawStairClimb(screen, task, dressColor)
    progress = task.frame / task.duration
    if task.action = "stairsdown"
        DrawGenevieve(screen, 1110 + progress * 45, 520 + progress * 120, dressColor, Int(Sin(task.frame * 0.5) * 3), 0)
    else
        DrawGenevieve(screen, 80 + progress * 110, 365 - progress * 300, dressColor, Int(Sin(task.frame * 0.5) * 3), 1)
    end if
end sub

sub DrawUpstairsTask(screen, task, dressColor, labelFont)
    if IsSeatAction(task.action)
        seat = FindIndoorSeat(task.area, task.action)
        if seat <> invalid then DrawIndoorSitting(screen, seat, task.frame, dressColor)
        return
    end if
    if task.action = "stairsup" or task.action = "stairsdown"
        DrawStairClimb(screen, task, dressColor)
        return
    end if
    DrawIndoorActivityFrame(screen, task, dressColor)
end sub

sub DrawIndoorActionPopup(screen, task, font)
    x = 640 : y = 160
    text = RoomActivityLabel(task.action)
    for each item in IndoorActivityRects(task.area)
        if item.action = task.action
            x = item.x + item.w / 2 : y = item.y - 160
        end if
    end for
    if IsSeatAction(task.action)
        seat = FindIndoorSeat(task.area, task.action)
        if seat <> invalid then x = seat.x : y = seat.y - 120
        text = "OK / Back: stand up"
    end if
    if task.action = "stairsup" then x = 390 : y = 190 : text = "GOING UPSTAIRS"
    if task.action = "stairsdown" then x = 930 : y = 475 : text = "GOING DOWNSTAIRS"
    if x < 155 then x = 155
    if x > 1125 then x = 1125
    if y < 145 then y = 145
    screen.DrawRect(Int(x - 150), Int(y), 300, 46, &h173E52EE)
    CenterLabel(screen, text, Int(x), Int(y + 10), &hFFFFFFFF, font)
    if not IsSeatAction(task.action)
        screen.DrawRect(Int(x - 140), Int(y + 39), Int(280 * task.frame / task.duration), 4, &hFFE06AFF)
    end if
end sub
