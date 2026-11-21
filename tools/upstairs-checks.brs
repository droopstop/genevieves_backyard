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
    CheckIndoor(m.indoorWorld.Count() = 0, "new room activities begin without completed results")
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
        DrawUpstairs(screen, area, titleFont, labelFont, bodyFont, completed)
        SaveIndoorPreview(screen, area + "-before")
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
                task = {area: area, action: action, frame: frame, duration: 240, storyIndex: 1}
                DrawUpstairsTask(screen, task, &hF05A9DFF, labelFont)
                if IsIndoorStoryAction(action) then DrawIndoorStoryCaption(screen, task, labelFont, bodyFont)
                CheckIndoor(screen.commands.Count() > 0, "activity renders throughout its animation")
                if frame = 74 then SaveIndoorPreview(screen, area + "-" + action)
                screen.commands = []
            end for
            completed[area + ":" + action] = true
            RecordIndoorResult(m.indoorWorld, area, action, 0)
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
        CheckIndoor(UpstairsActionAt(area, 1210, 600) = "hallway", "open side doorway is a walk-through exit")
        CheckIndoor(HouseTravel(area, "hallway").area = "upstairs", "door returns to hall")
        landing = HouseTravel(area, "hallway")
        CheckIndoor(UpstairsActionAt("upstairs", landing.x + 16, landing.y + 50) = "", "hall arrival does not bounce back into the room")
        DrawUpstairs(screen, area, titleFont, labelFont, bodyFont, completed)
        SaveIndoorPreview(screen, area)
    end for
    for each key in [2, 3, 4, 5]
        CheckIndoor(ShouldStandFromIndoorSeat(key, true, {action: "sit_chair1"}), "each arrow stands up from sitting")
        CheckIndoor(ShouldStandFromIndoorSeat(key, true, {action: "cozyread"}), "moving stops a seated couch story")
        CheckIndoor(ShouldStandFromIndoorSeat(key, true, {action: "story"}), "moving away stops book reading")
        CheckIndoor(ShouldStandFromIndoorSeat(key, true, {action: "photos"}), "moving away stops photo narration")
        CheckIndoor(not ShouldStandFromIndoorSeat(key, false, {action: "sit_chair1"}), "key release does not stand again")
        CheckIndoor(not ShouldStandFromIndoorSeat(key, true, {action: "dressup"}), "standing logic does not cancel other activities")
    end for
    world = {}
    outfit = RecordIndoorResult(world, "bedroom", "dressup", 0)
    CheckIndoor(outfit = 1 and world["bedroom:dressup"], "dress-up selects a lasting new outfit")
    CheckIndoor(RecordIndoorResult(world, "bedroom", "dressup", 1) = 2, "dress-up cycles to the blue outfit")
    CheckIndoor(RecordIndoorResult(world, "bedroom", "dressup", 2) = 0, "dress-up can return to pink")
    outfit = 0
    replayWorld = {}
    for each expectedOutfit in [1, 2, 0, 1, 2, 0]
        outfit = RecordIndoorResult(replayWorld, "bedroom", "dressup", outfit)
        CheckIndoor(outfit = expectedOutfit, "every dress-up play advances pink, lavender, blue, then pink")
        ResetIndoorRoomOnExit(replayWorld, "bedroom", "upstairs")
    end for
    for outfitIndex = 0 to 2
        bounds = IndoorWardrobeWalkBounds(outfitIndex)
        for direction = 0 to 3
            rect = bounds[direction]
            m.characterSprites[direction] = PreviewBitmap("images/wardrobe-walk-" + Str(outfitIndex).Trim() + ".png", rect[2], rect[3], rect)
        end for
        for direction = 0 to 3
            screen.commands = []
            DrawGenevieve(screen, 950, 380, &hF05A9DFF, 0, direction)
            walkDraw = screen.commands[0]
            DrawIndoorActivityFrame(screen, {area: "bedroom", action: "dressup", frame: 74, x: 950, y: 380, facing: direction}, &hF05A9DFF)
            outfitDraw = screen.commands[1]
            CheckIndoor(walkDraw[1] = outfitDraw[1] and walkDraw[2] = outfitDraw[2], "dress-up stays at the walking position")
            CheckIndoor(walkDraw[3] = outfitDraw[3] and walkDraw[4] = outfitDraw[4], "dress-up keeps the walking scale")
            CheckIndoor(Abs(walkDraw[4] * bounds[direction][3] - 78) < 0.01, "every outfit and direction has the same visible height")
        end for
    end for
    screen.commands = []
    for each action in ["story", "cozyread", "photos"]
        lines = IndoorStoryLines(action)
        CheckIndoor(lines.Count() = 3, "reading activities have actual three-part narration")
        for each words in lines
            CheckIndoor(clips.DoesExist(words), "each story sentence has a recorded clip")
        end for
        task = {area: "bonusroom", action: action, frame: 0, storyIndex: 0}
        voice = {speaking: true, Say: PreviewStorySay, words: []}
        CheckIndoor(not UpdateIndoorStory(task, voice) and task.storyIndex = 0, "story waits until current sentence finishes")
        voice.speaking = false
        CheckIndoor(not UpdateIndoorStory(task, voice) and task.storyIndex = 1, "story advances to the next sentence")
        voice.speaking = false
        CheckIndoor(not UpdateIndoorStory(task, voice) and task.storyIndex = 2, "story plays the final sentence")
        voice.speaking = false
        CheckIndoor(UpdateIndoorStory(task, voice), "story completes after all sentences finish")
    end for
    bounds = IndoorWardrobeWalkBounds(1)
    for col = 0 to 3
        rect = bounds[col]
        m.characterSprites[col] = PreviewBitmap("images/wardrobe-walk-1.png", rect[2], rect[3], rect)
    end for
    DrawUpstairs(screen, "bedroom", titleFont, labelFont, bodyFont, {})
    DrawGenevieve(screen, 960, 395, &hF05A9DFF, 0, 0)
    SaveIndoorPreview(screen, "dressup-result")
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
    CheckIndoor(clips.DoesExist("Sit down and relax. Use an arrow button to stand up."), "sitting has bundled narration")
    CheckIndoor(clips.DoesExist(UpstairsPrompt("stairsup") + "."), "upward stair narration")
    CheckIndoor(clips.DoesExist(UpstairsPrompt("stairsdown") + "."), "downward stair narration")
    resetWorld = {"playroom:drawboard": true, "bonusroom:treelights": true}
    ResetIndoorRoomOnExit(resetWorld, "playroom", "playroom")
    CheckIndoor(resetWorld["playroom:drawboard"], "activity results remain while staying in the room")
    ResetIndoorRoomOnExit(resetWorld, "playroom", "upstairs")
    CheckIndoor(not resetWorld.DoesExist("playroom:drawboard"), "walking out clears the drawing")
    CheckIndoor(resetWorld["bonusroom:treelights"], "only the room being left is reset")
    for each roomArea in rooms
        resetWorld = {}
        for each action in UpstairsRoom(roomArea).stations
            resetWorld[roomArea + ":" + action] = true
        end for
        ResetIndoorRoomOnExit(resetWorld, roomArea, "upstairs")
        CheckIndoor(resetWorld.Count() = 0, "every activity in each room resets on exit")
        for each action in UpstairsRoom(roomArea).stations
            CheckIndoor(RecordIndoorResult(resetWorld, roomArea, action, 0) >= 0, "activities remain playable on the next visit")
        end for
        ResetIndoorRoomOnExit(resetWorld, roomArea, "house")
        CheckIndoor(resetWorld.Count() = 0, "any route out of the room resets its activities")
    end for
    ResetIndoorRoomOnExit(m.indoorWorld, "bonusroom", "upstairs")
    PreviewRoomActivitySprites("bonusroom")
    DrawUpstairs(screen, "bonusroom", titleFont, labelFont, bodyFont, {})
    SaveIndoorPreview(screen, "bonusroom-reset")
    print "PASS: room activities reset on exit and replay on return"
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

sub PreviewStorySay(words)
    m.words.Push(words)
    m.speaking = true
end sub
