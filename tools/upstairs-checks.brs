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
    pony = m.livingRoomPony
    CheckIndoor(LivingRoomPonyNearby(750, 560, pony), "walking to the parked pony activates it")
    CheckIndoor(not LivingRoomPonyNearby(400, 560, pony), "distant pony does not activate")
    ride = StartLivingRoomPonyRide(734, 510, 2)
    CheckIndoor(IsLivingRoomPonyRide(ride) and pony.mounted, "pony can be mounted")
    CheckIndoor(not LivingRoomPonyNearby(750, 560, pony), "mounted pony cannot be mounted twice")
    UpdateLivingRoomPony(pony, false, false, true, false)
    CheckIndoor(pony.x = 746 and pony.facing = 2 and pony.moving, "left arrow steers the pony")
    UpdateLivingRoomPony(pony, true, false, false, false)
    CheckIndoor(pony.y = 556 and pony.facing = 1, "up arrow steers the pony")
    pony.x = 816 : pony.y = 550
    UpdateLivingRoomPony(pony, false, false, false, true)
    CheckIndoor(pony.x = 816, "pony cannot ride through Pops or his furniture")
    pony.x = 80 : pony.y = 600
    UpdateLivingRoomPony(pony, false, false, true, false)
    CheckIndoor(pony.x = 80, "pony stays inside the living room")
    landing = StopLivingRoomPonyRide(pony)
    CheckIndoor(not pony.mounted and LivingRoomPonySafe(landing.x + 16, landing.y + 50), "getting off finds clear floor beside the pony")
    CheckIndoor(clips.DoesExist(LivingRoomPonyInstructions()), "pony riding instructions are recorded")
    CheckIndoor(clips.DoesExist(LivingRoomPonyDismountWords()), "pony getting-off narration is recorded")
    pony.x = 630 : pony.y = 580 : pony.facing = 3 : pony.mounted = true
    outfitCount = IndoorOutfitNames().Count()
    for outfit = 0 to outfitCount - 1
        m.indoorOutfitIndex = outfit
        assets = IndoorWardrobeAssets(outfit)
        if not assets.DoesExist("seat")
            m.indoorCostumeRiders = []
            for col = 0 to 3
                m.indoorCostumeRiders.Push(PreviewBitmap(Mid(assets.walk, 6), 160, 192, [col * 160, 416, 160, 192]))
            end for
        end if
        DrawHouse(screen, titleFont, labelFont, labelFont, bodyFont)
        DrawPops(screen, CreatePops(), invalid, false, labelFont, bodyFont)
        DrawLivingRoomPony(screen, true)
        DrawLivingRoomPonyControls(screen, labelFont)
        SaveIndoorPreview(screen, "pony-outfit-" + outfit.ToStr())
    end for
    m.indoorOutfitPreviews = []
    for outfit = 0 to outfitCount - 1
        rect = IndoorOutfitPreviewBounds(outfit)
        m.indoorOutfitPreviews.Push(PreviewBitmap("images/wardrobe-previews.png", rect[2], rect[3], rect))
    end for
    m.indoorOutfitIndex = 0
    for each selected in [2, 4, 8]
        DrawUpstairs(screen, "bedroom", titleFont, labelFont, bodyFont, {})
        DrawIndoorOutfitChooser(screen, {selectedOutfit: selected}, titleFont, labelFont, bodyFont)
        name = "outfit-picker"
        if selected > 2 then name = name + "-" + selected.ToStr()
        SaveIndoorPreview(screen, name)
    end for
    for outfit = 2 to outfitCount - 1
        m.indoorOutfitIndex = outfit
        assets = IndoorWardrobeAssets(outfit)
        seatUri = assets.walk
        seatY = 208
        if assets.DoesExist("seat") then seatUri = assets.seat : seatY = 0
        m.indoorSeatSprites = []
        for col = 0 to 3
            m.indoorSeatSprites.Push(PreviewBitmap(Mid(seatUri, 6), 160, 208, [col * 160, seatY, 160, 208]))
        end for
        DrawHouse(screen, titleFont, labelFont, labelFont, bodyFont)
        DrawIndoorSitting(screen, FindIndoorSeat("house", "sit_livingsofa"), 0, &hF05A9DFF)
        SaveIndoorPreview(screen, "seated-outfit-" + outfit.ToStr())
    end for
    InitializeIndoorPreviewSprites()
    m.livingRoomPony = CreateLivingRoomPony()
    print "PASS: pony mount, steering, furniture boundaries, dismount and outfit artwork"
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
    CheckIndoor(RecordIndoorResult(world, "bedroom", "dressup", 0) = 0, "finishing dress-up does not automatically rotate clothes")
    CheckIndoor(RecordIndoorResult(world, "bedroom", "dressup", 3) = 3, "completion preserves the chosen cowgirl outfit")
    picker = {action: "dressup"}
    InitializeIndoorOutfitChooser(picker, 1)
    CheckIndoor(IsIndoorOutfitChooser(picker) and picker.selectedOutfit = 1, "picker starts on the outfit currently worn")
    CheckIndoor(HandleIndoorOutfitChoice(picker, 5, true) = "changed" and picker.selectedOutfit = 2, "right selects princess")
    CheckIndoor(HandleIndoorOutfitChoice(picker, 5, true) = "changed" and picker.selectedOutfit = 3, "right selects cowgirl")
    for each costume in ["BALLERINA", "LADYBUG", "FAIRY", "ANNA", "ELSA", "DOCTOR", "PIRATE"]
        CheckIndoor(HandleIndoorOutfitChoice(picker, 5, true) = "changed" and IndoorOutfitName(picker.selectedOutfit) = costume, "picker reaches " + costume)
    end for
    CheckIndoor(HandleIndoorOutfitChoice(picker, 5, true) = "changed" and picker.selectedOutfit = 0, "picker wraps to original clothes")
    CheckIndoor(HandleIndoorOutfitChoice(picker, 4, true) = "changed" and picker.selectedOutfit = outfitCount - 1, "left wraps to pirate")
    CheckIndoor(HandleIndoorOutfitChoice(picker, 6, true) = "confirm" and picker.selectedOutfit = outfitCount - 1, "OK confirms the selected outfit")
    CheckIndoor(HandleIndoorOutfitChoice(picker, 0, true) = "cancel", "Back cancels the picker")
    CheckIndoor(HandleIndoorOutfitChoice(picker, 4, false) = "" and picker.selectedOutfit = outfitCount - 1, "button release does not change the selection")
    CheckIndoor(clips.DoesExist(IndoorOutfitChooserInstruction()), "picker instructions have recorded narration")
    for index = 0 to outfitCount - 1
        CheckIndoor(clips.DoesExist(IndoorOutfitSpokenName(index)), "each outfit has a recorded spoken label")
    end for
    for outfitIndex = 0 to outfitCount - 1
        bounds = IndoorWardrobeWalkBounds(outfitIndex)
        assets = IndoorWardrobeAssets(outfitIndex)
        m.indoorOutfitIndex = outfitIndex
        for direction = 0 to 3
            rect = bounds[direction]
            m.characterSprites[direction] = PreviewBitmap(Mid(assets.walk, 6), rect[2], rect[3], rect)
        end for
        for direction = 0 to 3
            screen.commands = []
            DrawGenevieve(screen, 950, 380, &hF05A9DFF, 0, direction)
            walkDraw = screen.commands[0]
            DrawIndoorActivityFrame(screen, {area: "bedroom", action: "dressup", frame: 74, x: 950, y: 380, facing: direction}, &hF05A9DFF)
            outfitDraw = screen.commands[1]
            CheckIndoor(walkDraw[1] = outfitDraw[1] and walkDraw[2] = outfitDraw[2], "dress-up stays at the walking position")
            CheckIndoor(walkDraw[3] = outfitDraw[3] and walkDraw[4] = outfitDraw[4], "dress-up keeps the walking scale")
            CheckIndoor(Abs(walkDraw[4] * IndoorWardrobeBodyHeight(outfitIndex, direction) - 78) < 0.01, "every outfit keeps the same body scale under its accessories")
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
    m.indoorOutfitIndex = 1
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
