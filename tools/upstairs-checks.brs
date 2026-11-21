sub Main()
    CheckIndoor(IsHouseTravelAction("house", "stairsup"), "stairs reachable downstairs")
    CheckIndoor(HouseActionAt(110, 380) = "stairsup", "wall staircase has a reachable entrance")
    CheckIndoor(HouseActionAt(640, 450) = "", "middle of living room is clear")
    CheckIndoor(HouseActionAt(460, 450) = "sit_livingsofa", "sofa sitting follows the relocated sofa")
    landing = UpstairsReturn("upstairs")
    CheckIndoor(HouseActionAt(landing.x + 16, landing.y + 50) = "", "downstairs arrival is clear of the automatic staircase trigger")
    hall = HouseTravel("house", "stairsup")
    CheckIndoor(hall.area = "upstairs", "stairs lead upstairs")
    CheckIndoor(UpstairsActionAt(hall.area, hall.x + 16, hall.y + 20) = "", "hall arrival is clear of stairs and doors")
    rooms = ["bedroom", "playroom", "bonusroom", "parentsroom"]
    doorXs = [240, 505, 775, 1040]
    actions = {}
    clips = LoadNarrationClips()
    m.yardProjection = false
    InitializeIndoorPreviewSprites()
    screen = {Clear: TestClear, DrawRect: TestRect, DrawText: TestText, DrawScaledObject: TestSprite, commands: []}
    titleFont = {size: 34, GetOneLineWidth: TestWidth}
    labelFont = {size: 20, GetOneLineWidth: TestWidth}
    bodyFont = {size: 18, GetOneLineWidth: TestWidth}
    DrawHouse(screen, titleFont, labelFont, labelFont, bodyFont)
    DrawPops(screen, CreatePops(), invalid, false, labelFont, bodyFont)
    SaveIndoorPreview(screen, "living-room-wall-stairs")
    DrawHouseStairs(screen, labelFont, bodyFont)
    SaveIndoorPreview(screen, "stairs")
    DrawUpstairs(screen, "upstairs", titleFont, labelFont, bodyFont, {})
    SaveIndoorPreview(screen, "upstairs")
    for i = 0 to 3
        area = rooms[i]
        PreviewRoomActivitySprites(area)
        CheckIndoor(clips.DoesExist(RoomWelcome(area)), "room welcome has bundled narration")
        doorway = UpstairsActionAt("upstairs", doorXs[i], 390)
        CheckIndoor(IsHouseTravelAction("upstairs", doorway), "door is a travel action")
        arrival = HouseTravel("upstairs", doorway)
        CheckIndoor(arrival.area = area, "each door leads to its own room")
        CheckIndoor(UpstairsActionAt(area, arrival.x + 16, arrival.y + 20) = "", "room arrival is clear of activities and exit")
        CheckIndoor(UpstairsReturn(area).area = "upstairs", "Back returns from room to hall")
        room = UpstairsRoom(area)
        completed = {}
        itemRects = IndoorActivityRects(area)
        for j = 0 to 2
            item = itemRects[j]
            action = UpstairsActionAt(area, item.x + item.w / 2, item.y + item.h / 2)
            CheckIndoor(action = room.stations[j], "activity is reachable")
            CheckIndoor(not IsHouseTravelAction(area, action), "activity does not accidentally travel")
            CheckIndoor(not actions.DoesExist(action), "each room has distinct activities")
            actions[action] = true
            CheckIndoor(UpstairsPrompt(action) <> "", "activity has clear instructions")
            CheckIndoor(UpstairsSuccess(action) <> "", "activity has a completion message")
            CheckIndoor(clips.DoesExist(UpstairsPrompt(action) + "."), "activity instruction has bundled narration")
            CheckIndoor(clips.DoesExist("YOU DID IT!. " + UpstairsSuccess(action)), "activity result has bundled narration")
            for each frame in [0, 74, 149]
                DrawUpstairs(screen, area, titleFont, labelFont, bodyFont, completed)
                DrawUpstairsTask(screen, {area: area, action: action, frame: frame}, &hF05A9DFF, labelFont)
                CheckIndoor(screen.commands.Count() > 0, "activity renders throughout its animation")
                if frame = 74 then SaveIndoorPreview(screen, area + "-" + action)
                screen.commands = []
            end for
            completed[area + ":" + action] = true
        end for
        for each seat in UpstairsSeats(area)
            CheckIndoor(UpstairsActionAt(area, seat.walkX, seat.touchY) = seat.action, "seat is reachable independently of activities")
            CheckIndoor(FindIndoorSeat(area, seat.action) <> invalid, "seat has a furniture position")
            DrawUpstairs(screen, area, titleFont, labelFont, bodyFont, completed)
            DrawUpstairsTask(screen, {area: area, action: seat.action, frame: 9000}, &hF05A9DFF, labelFont)
            SaveIndoorPreview(screen, area + "-" + seat.action)
            screen.commands = []
        end for
        CheckIndoor(UpstairsActionAt(area, 640, 640) = "", "old floor text cannot activate anything")
        CheckIndoor(HouseTravel(area, "hallway").area = "upstairs", "OK returns to hall")
        DrawUpstairs(screen, area, titleFont, labelFont, bodyFont, completed)
        SaveIndoorPreview(screen, area)
    end for
    contact = {contact: ""}
    CheckIndoor(not ObserveIndoorContact(contact, "playroom", "dollhouse", false, false), "standing still does not activate an object on arrival")
    CheckIndoor(ObserveIndoorContact(contact, "playroom", "dollhouse", true, false), "walking into an item activates it")
    CheckIndoor(not ObserveIndoorContact(contact, "playroom", "dollhouse", true, false), "completed activity does not repeat while staying at the item")
    CheckIndoor(not ObserveIndoorContact(contact, "playroom", "", true, false), "leaving an object rearms interaction")
    CheckIndoor(ObserveIndoorContact(contact, "playroom", "dollhouse", true, false), "walking back replays an activity")
    CheckIndoor(not ObserveIndoorContact(contact, "playroom", "playkitchen", true, true), "another activity cannot interrupt animation")
    for each area in rooms
        for each target in UpstairsRoom(area).targets
            CheckIndoor(UpstairsActionAt(area, target, 515) = "", "old activity text strip is inactive")
        end for
        for each seat in UpstairsSeats(area)
            CheckIndoor(UpstairsActionAt(area, seat.walkX, 560) = "", "old SIT text strip is inactive")
        end for
    end for
    CheckIndoor(actions.Count() = 12, "twelve playable activities")
    CheckIndoor(UpstairsReturn("upstairs").area = "house", "Back goes downstairs")
    CheckIndoor(HouseTravel("upstairs", "stairsdown").area = "house", "OK goes downstairs")
    CheckIndoor(UpstairsActionAt("upstairs", 1145, 620) = "stairsdown", "real stairwell is reachable")
    CheckIndoor(not IsUpstairsArea("yard"), "yard navigation unchanged")
    CheckIndoor(clips.DoesExist("Sit down and relax. Press OK or Back to stand up."), "sitting has bundled narration")
    CheckIndoor(clips.DoesExist(UpstairsPrompt("stairsup") + "."), "upward stair narration")
    CheckIndoor(clips.DoesExist(UpstairsPrompt("stairsdown") + "."), "downward stair narration")
    print "PASS: stairs, four doors, return routes, twelve activities, furniture seating, animation frames and narration"
end sub

sub CheckIndoor(condition, label)
    if not condition
        print "FAIL: " + label
        stop
    end if
end sub

sub TestClear(color)
    m.commands.Push(["clear", color])
end sub
sub TestRect(x, y, w, h, color)
    m.commands.Push(["rect", x, y, w, h, color])
end sub
sub TestText(words, x, y, color, font)
    m.commands.Push(["text", words, x, y, color, font.size])
end sub
sub TestSprite(x, y, sx, sy, sprite)
    m.commands.Push(["sprite", x, y, sx, sy, sprite.path, ParseJson(FormatJson(sprite.crop))])
end sub
function TestWidth(words, maxWidth)
    return Len(words) * m.size * 0.55
end function
sub SaveIndoorPreview(screen, name)
    print "PREVIEW " + name + " " + FormatJson(screen.commands)
    screen.commands = []
end sub

function PreviewBitmap(path, width, height, crop)
    return {path: path, width: width, height: height, crop: crop, GetWidth: PreviewWidth, GetHeight: PreviewHeight}
end function
function PreviewWidth()
    return m.width
end function
function PreviewHeight()
    return m.height
end function
