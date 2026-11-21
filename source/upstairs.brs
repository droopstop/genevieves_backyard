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
    if area = "upstairs" then return {area: "house", x: 220, y: 530}
    return {area: "upstairs", x: 624, y: 530}
end function

function HouseTravel(area, action)
    if action = "stairsup" then return {area: "upstairs", x: 624, y: 530}
    if action = "stairsdown" or action = "hallway" then return UpstairsReturn(area)
    return {area: Mid(action, 6), x: 1180, y: 600}
end function

function UpstairsActionAt(area, x, y)
    if area = "upstairs"
        rooms = ["bedroom", "playroom", "bonusroom", "parentsroom"]
        for i = 0 to 3
            if PointInRect(x, y, 60 + i * 300, 210, 255, 285) then return "room_" + rooms[i]
        end for
        if PointInRect(x, y, 510, 575, 260, 105) then return "stairsdown"
    else
        room = UpstairsRoom(area)
        if room = invalid then return ""
        for i = 0 to 2
            if PointInRect(x, y, room.targets[i] - 100, 365, 200, 165) then return room.stations[i]
        end for
        for each seat in UpstairsSeats(area)
            if PointInRect(x, y, seat.walkX - 45, 535, 90, 55) then return seat.action
        end for
        if PointInRect(x, y, 510, 610, 260, 70) then return "hallway"
    end if
    return ""
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
    if m.houseStairs <> invalid
        screen.DrawScaledObject(80, 180, 260 / m.houseStairs.GetWidth(), 375 / m.houseStairs.GetHeight(), m.houseStairs)
    else
    screen.DrawRect(88, 215, 246, 338, &h654B45FF)
    for i = 0 to 7
        screen.DrawRect(106, 242 + i * 35, 210, 30, &hD7AE7EFF)
        screen.DrawRect(106, 267 + i * 35, 210, 5, &h956D50FF)
    end for
    screen.DrawRect(87, 205, 15, 350, &hFFF0D9FF)
    screen.DrawRect(320, 205, 15, 350, &hFFF0D9FF)
    end if
    screen.DrawRect(80, 165, 260, 45, &h173E52FF)
    CenterLabel(screen, "UPSTAIRS", 210, 176, &hFFE06AFF, labelFont)
    CenterLabel(screen, "Walk here + press OK", 210, 565, &h173E52FF, bodyFont)
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
        names = ["GENEVIEVE", "PLAYROOM", "BONUS ROOM", "MOMMY + DADDY"]
        subtitles = ["Bedroom", "Play + draw", "Stories + Christmas", "Bedroom"]
        colors = [&hCB5794FF, &h3F9B86FF, &h7775B5FF, &hAB805AFF]
        for i = 0 to 3
            x = 60 + i * 300
            screen.DrawRect(x, 177, 255, 324, &hFFF8E9FF)
            screen.DrawRect(x + 13, 191, 229, 297, colors[i])
            screen.DrawRect(x + 33, 252, 189, 172, &hFFFFFF24)
            screen.DrawRect(x + 201, 362, 12, 12, &hFFE06AFF)
            screen.DrawRect(x - 3, 192, 261, 48, &h173E52FF)
            CenterLabel(screen, names[i], x + 127, 204, &hFFFFFFFF, labelFont)
            CenterLabel(screen, subtitles[i], x + 127, 439, &hFFFFFFFF, bodyFont)
        end for
        screen.DrawRect(470, 515, 340, 45, &hF7E5CFFF)
        CenterLabel(screen, "Choose a door and press OK", 640, 524, &h173E52FF, bodyFont)
        exitLabel = "DOWNSTAIRS"
    else
        if m.upstairsBackdrops <> invalid
            backdrop = m.upstairsBackdrops[area]
            if backdrop <> invalid then screen.DrawScaledObject(0, 0, 1280 / backdrop.GetWidth(), 720 / backdrop.GetHeight(), backdrop)
        end if
        DrawHeader(screen, title, titleFont, bodyFont)
        for i = 0 to 2
            action = room.stations[i]
            x = room.targets[i]
            screen.DrawRect(x - 99, 493, 198, 34, &h173E52DD)
            CenterLabel(screen, RoomActivityLabel(action), x, 499, &hFFFFFFFF, bodyFont)
            if completed.DoesExist(area + ":" + action)
                CenterLabel(screen, "DONE!", x, 473, &hFFE06AFF, bodyFont)
            end if
        end for
        for each seat in UpstairsSeats(area)
            screen.DrawRect(seat.walkX - 35, 548, 70, 28, &h173E52BB)
            CenterLabel(screen, "SIT", seat.walkX, 552, &hFFE06AFF, bodyFont)
        end for
        exitLabel = "TO THE HALL"
    end if
    screen.DrawRect(510, 610, 260, 65, &h173E52FF)
    screen.DrawRect(520, 620, 240, 40, &hFFE06AFF)
    CenterLabel(screen, exitLabel, 640, 625, &h173E52FF, labelFont)
    screen.DrawText("Back: return   |   Walk to an activity + OK", 38, 666, &h173E52FF, bodyFont)
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
    m.houseStairs = CreateObject("roBitmap", "pkg:/images/house-stairs.png")
end sub

sub UpdateUpstairsArtwork(area)
    if m.loadedUpstairsArea = area then return
    m.upstairsBackdrops = {}
    m.loadedUpstairsArea = area
    uri = ""
    if area = "bedroom" then uri = "pkg:/images/upstairs-bedroom.jpg"
    if area = "playroom" then uri = "pkg:/images/upstairs-playroom.jpg"
    if area = "bonusroom" then uri = "pkg:/images/upstairs-bonusroom.jpg"
    if area = "parentsroom" then uri = "pkg:/images/upstairs-parentsroom.jpg"
    if uri <> "" then m.upstairsBackdrops[area] = CreateObject("roBitmap", uri)
end sub

function IsSeatAction(action)
    return Left(action, 4) = "sit_"
end function

function UpstairsSeats(area)
    if area = "bedroom" then return [{action: "sit_childbed", walkX: 165, x: 165, y: 392}]
    if area = "playroom" then return [{action: "sit_chair1", walkX: 535, x: 535, y: 425}, {action: "sit_chair2", walkX: 635, x: 635, y: 425}]
    if area = "bonusroom" then return [{action: "sit_sofa1", walkX: 105, x: 125, y: 350}, {action: "sit_sofa2", walkX: 210, x: 220, y: 335}, {action: "sit_sofa3", walkX: 315, x: 315, y: 324}, {action: "sit_sofa4", walkX: 420, x: 420, y: 320}]
    if area = "parentsroom" then return [{action: "sit_parentbed", walkX: 170, x: 170, y: 393}, {action: "sit_bike", walkX: 1150, x: 1140, y: 370}]
    if area = "house" then return [{action: "sit_livingsofa", walkX: 48, x: 55, y: 420}]
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
    if m.activityPoses <> invalid and m.activityPoses.Count() > 6
        DrawActivityPose(screen, 6, seat.x, seat.y, 82)
    else
        DrawGenevieve(screen, seat.x - 16, seat.y - 20, dressColor, 0, 0)
    end if
end sub

sub DrawStairClimb(screen, task, dressColor)
    progress = task.frame / task.duration
    if task.action = "stairsdown"
        if m.houseStairs <> invalid then screen.DrawScaledObject(510, 300, 260 / m.houseStairs.GetWidth(), 300 / m.houseStairs.GetHeight(), m.houseStairs)
        DrawGenevieve(screen, 624, 340 + progress * 205, dressColor, Int(Sin(task.frame * 0.5) * 3), 0)
    else
        DrawGenevieve(screen, 190, 495 - progress * 255, dressColor, Int(Sin(task.frame * 0.5) * 3), 1)
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
    room = UpstairsRoom(task.area)
    if room = invalid then return
    slot = 0
    for i = 0 to 2
        if room.stations[i] = task.action then slot = i
    end for
    x = room.targets[slot]
    frame = task.frame
    if task.DoesExist("duration") then frame = Int(149 * task.frame / task.duration)
    bob = Int(Sin(frame * 0.11) * 3)
    action = task.action
    if action = "cozyread"
        DrawIndoorSitting(screen, {x: 220, y: 335}, frame, dressColor)
    else
        pose = 0
        if frame mod 40 > 20 then pose = 1
        if action = "story" or action = "photos" then pose = 10
        if action = "dressup" then pose = 0
        if action = "vase" then pose = 2
        if action = "drawboard" then pose = 10
        activityY = 450 + bob
        if action = "drawboard"
            screen.DrawRect(x - 42, 362, 60, 10, &hAF7E5FFF)
            screen.DrawRect(x - 36, 372, 7, 40, &hAF7E5FFF)
            screen.DrawRect(x + 4, 372, 7, 40, &hAF7E5FFF)
            activityY = 320 + bob
        end if
        if m.activityPoses <> invalid and m.activityPoses.Count() > pose
            DrawActivityPose(screen, pose, x - 20, activityY, 88)
        else
            DrawGenevieve(screen, x - 36, 432, dressColor, bob, 1)
        end if
    end if
    if action = "makebed" or action = "parentsbed"
        ' A small animated folded blanket and pillow remain local to the real bed.
        color = &hAEDBE9FF
        if action = "parentsbed" then color = &hBA3F35FF
        screen.DrawRect(x + 15, 404 - Int(frame / 25), 48, 14, color)
        screen.DrawRect(x + 25, 390 - Int(frame / 25), 32, 12, &hFFF5DFFF)
    else if action = "story" or action = "cozyread" or action = "photos"
        bx = x - 25 : by = 413
        if action = "cozyread" then bx = 205 : by = 325
        screen.DrawRect(bx - 19, by, 40, 25, &hFFF5DFFF)
        screen.DrawRect(bx, by, 2, 25, &hB38561FF)
        screen.DrawRect(bx + 5, by + 5, 11, 12, &h9DBFDBFF)
    else if action = "dressup"
        colors = [&hF47FA9FF, &hB299DEFF, &hFFD365FF]
        color = colors[Int(frame / 35) mod 3]
        screen.DrawRect(x - 38, 405 + bob, 15, 11, color)
        screen.DrawRect(x - 18, 405 + bob, 15, 11, color)
    else if action = "drawboard"
        ' Paint the rainbow directly onto the photographed room's whiteboard.
        colors = [&hEF767AFF, &hF3AD61FF, &hF3D771FF, &h82BF91FF, &h80BCE3FF, &hB69DD3FF]
        for band = 0 to 5
            for stepIndex = 0 to Int(frame * 24 / 149)
                angle = 3.14159 + stepIndex * 3.14159 / 24
                r = 82 - band * 9
                dx = 916 + Cos(angle) * r
                dy = 254 + Sin(angle) * r
                screen.DrawRect(Int(dx), Int(dy), 10, 10, colors[band])
            end for
        end for
    else if action = "dollhouse"
        DrawPetHeart(screen, 145, 280 - (frame mod 65), 23)
    else if action = "playkitchen"
        screen.DrawRect(348, 375, 32, 14, &hE8BD73FF)
        for steam = 0 to 2
            sy = 370 - ((frame + steam * 13) mod 35)
            screen.DrawRect(352 + steam * 9, sy, 3, 7, &hFFFFEEBB)
        end for
    else if action = "puzzle"
        colors = [&hF47FA9FF, &hFFD365FF, &h7CBCE5FF, &h9AD69CFF, &hB299DEFF]
        for j = 0 to Int(frame / 15)
            screen.DrawRect(632 + (j mod 5) * 17, 337 + Int(j / 5) * 12, 15, 10, colors[j mod 5])
        end for
    else if action = "treelights"
        for j = 0 to 11
            dx = 1070 + Sin(j * 2.4) * (20 + j * 5)
            dy = 120 + j * 23
            size = 12 + Int(Sin(frame * 0.14 + j) * 5)
            DrawPlanetSprite(screen, 3, dx, dy, size, size)
        end for
    else if action = "vase"
        for j = 0 to Int(frame / 30)
            dx = 1077 + (j - 2) * 9
            dy = 303 + (j mod 2) * 9
            DrawTaskStroke(screen, 1085, 328, dx, dy, &h6C9D6BFF, 2)
            screen.DrawRect(dx - 3, dy - 3, 9, 9, &hF1AFB0FF)
        end for
    end if
end sub
