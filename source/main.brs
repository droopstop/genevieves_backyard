sub Main()
    screen = CreateObject("roScreen", true, 1280, 720)
    port = CreateObject("roMessagePort")
    screen.SetMessagePort(port)
    screen.SetAlphaEnable(true)
    LoadAreaArtwork()
    LoadCharacterArtwork()
    LoadActivityPoses()
    LoadPlanetArtwork()
    LoadMommyArtwork()
    LoadYardDetailArtwork()
    LoadCowArtwork()
    LoadFarmArtwork()
    m.yardProjection = false

    fontRegistry = CreateObject("roFontRegistry")
    titleFont = fontRegistry.GetDefaultFont(34, true, false)
    labelFont = fontRegistry.GetDefaultFont(20, true, false)
    promptFont = fontRegistry.GetDefaultFont(27, true, false)
    bodyFont = fontRegistry.GetDefaultFont(18, false, false)

    cowMoo = CreateObject("roAudioResource", "pkg:/audio/cow-moo.wav")
    cows = CreateCows()
    nearbyCow = -1

    missionVoice = CreateObject("roTextToSpeech")
    if missionVoice <> invalid
        missionVoice.SetMessagePort(port)
        missionVoice.SetVolume(900)
        missionVoice.SetRate(-3)
    end if
    narrationPort = CreateObject("roMessagePort")
    narrationPlayer = CreateObject("roAudioPlayer")
    narrationPlayer.SetMessagePort(narrationPort)
    backgroundMusic = CreateBackgroundMusic()
    missionVoice = CreateGameNarrator(missionVoice, narrationPlayer, narrationPort)
    missionPresentation = CreateMissionPresentation()
    mommy = CreateMommy()
    mommyClock = CreateObject("roTimespan")
    mommyClock.Mark()
    mommyLastTick = 0

    playerX = 735
    playerY = 380
    dressColor = &hF05A9DFF
    currentArea = "yard"

    dogX = 430
    dogY = 285
    dogTargetX = 690
    dogTargetY = 170
    dogPauseFrames = 0
    dogAnimationFrame = 0
    playerFacing = 0
    dogFacing = 0
    stitchNearby = false
    stitchLoveFrames = 0
    nearbyPlace = ""
    currentAction = ""
    actionMessage = ""
    actionHeading = "YOU DID IT!"
    activeTask = invalid
    actionDoneFrames = 0
    completedActions = CreateObject("roAssociativeArray")
    mission = invalid
    missionOrder = BuildMissionOrder()
    missionOrderPosition = 0
    missionIndex = missionOrder[missionOrderPosition]
    missionStepIndex = 0
    missionCompleted = false
    planetItems = []
    planetCollected = 0
    spaceFrame = 0

    upHeld = false
    downHeld = false
    leftHeld = false
    rightHeld = false
    running = true

    while running
        message = port.GetMessage()
        while message <> invalid
            if type(message) = "roUniversalControlEvent"
                button = message.GetKey()
                pressed = message.IsPress()

                ' Back cancels an unfinished activity; OK cannot restart it mid-animation.
                if button = 0 and pressed
                    cancelledYardTask = currentArea = "yard" and activeTask <> invalid
                    activeTask = invalid
                    upHeld = false : downHeld = false : leftHeld = false : rightHeld = false
                end if
                if button = 0 and pressed
                    if currentArea = "yard"
                        if not cancelledYardTask then running = false
                    else if IsPlanetArea(currentArea)
                        currentArea = "firepit"
                        playerX = 170
                        playerY = 355
                        completedActions = CreateObject("roAssociativeArray")
                    else
                        currentArea = "yard"
                        playerX = 735
                        playerY = 380
                        completedActions = CreateObject("roAssociativeArray")
                    end if
                else if button = 2
                    upHeld = pressed
                else if button = 3
                    downHeld = pressed
                else if button = 4
                    leftHeld = pressed
                else if button = 5
                    rightHeld = pressed
                else if button = 13 and pressed and activeTask = invalid
                    activeTask = {area: currentArea, action: "twirl", frame: 0, duration: 96, x: playerX, y: playerY}
                    actionDoneFrames = 0
                    upHeld = false : downHeld = false : leftHeld = false : rightHeld = false
                else if button = 6 and pressed and activeTask = invalid
                    if currentArea = "yard" and mommy.nearby
                        mission = GetMommyMission(mommy.missionIndex)
                        missionStepIndex = 0
                        missionCompleted = false
                        mommy.gaveMission = true
                        mommy.nearby = false
                        mommy.stateMs = 0
                        mommy.announcementMs = 0
                        actionHeading = "MOMMY'S MISSION!"
                        actionMessage = mission.title
                        actionDoneFrames = 210
                    else if currentArea = "yard" and nearbyCow >= 0
                        cows[nearbyCow].state = "peeking"
                        cows[nearbyCow].stateMs = 5000
                        cows[nearbyCow].peek = 1
                        activeTask = {area: "yard", action: "cow", frame: 0, duration: 150, cowIndex: nearbyCow, cow: cows[nearbyCow]}
                        actionDoneFrames = 0
                        upHeld = false : downHeld = false : leftHeld = false : rightHeld = false
                    else if currentArea = "yard" and stitchNearby
                        ' Face each other and keep Stitch still for the whole cuddle.
                        petSide = -1
                        dogFacing = 2
                        if dogX < 100
                            petSide = 1
                            dogFacing = 3
                        end if
                        activeTask = {area: "yard", action: "stitch", frame: 0, duration: 150, dogX: dogX, dogY: dogY, side: petSide}
                        stitchLoveFrames = 0
                        actionDoneFrames = 0
                        upHeld = false : downHeld = false : leftHeld = false : rightHeld = false
                    else if currentArea = "yard" and nearbyPlace <> ""
                        currentArea = nearbyPlace
                        playerX = 624
                        playerY = 535
                        upHeld = false : downHeld = false : leftHeld = false : rightHeld = false
                    else if currentArea = "firepit" and currentAction = "daddy"
                        replacingMission = mission <> invalid
                        if replacingMission
                            missionOrderPosition = missionOrderPosition + 1
                            if missionOrderPosition >= missionOrder.Count()
                                missionOrder = BuildMissionOrder()
                                missionOrderPosition = 0
                            end if
                            missionIndex = missionOrder[missionOrderPosition]
                        end if
                        mission = GetMission(missionIndex)
                        missionStepIndex = 0
                        missionCompleted = false
                        actionHeading = "NEW MISSION!"
                        actionMessage = mission.title
                        actionDoneFrames = 210
                    else if currentArea = "firepit" and currentAction = "spacecrate"
                        destination = "mars"
                        if mission <> invalid and missionCompleted = false
                            nextStep = mission.steps[missionStepIndex]
                            if IsPlanetArea(nextStep.area) then destination = nextStep.area
                        else
                            planetPick = Rnd(3)
                            if planetPick = 2 then destination = "saturn"
                            if planetPick = 3 then destination = "neptune"
                        end if
                        currentArea = destination
                        planetItems = BuildPlanetItems()
                        planetCollected = 0
                        playerX = 624
                        playerY = 535
                        completedActions = CreateObject("roAssociativeArray")
                        actionDoneFrames = 0
                        upHeld = false : downHeld = false : leftHeld = false : rightHeld = false
                    else if currentArea <> "yard" and not IsPlanetArea(currentArea) and currentAction <> ""
                        activeTask = {area: currentArea, action: currentAction, frame: 0, duration: 150}
                        actionDoneFrames = 0
                        upHeld = false : downHeld = false : leftHeld = false : rightHeld = false
                    else
                        if currentArea = "yard" and dressColor = &hF05A9DFF
                            dressColor = &hFF8FC5FF
                        else if currentArea = "yard"
                            dressColor = &hF05A9DFF
                        end if
                    end if
                end if
            end if
            message = port.GetMessage()
        end while
        missionVoice.Poll()
        backgroundMusic.Update(missionVoice.speaking)

        if activeTask <> invalid
            activeTask.frame = activeTask.frame + 1
            if activeTask.action = "cow" and activeTask.frame = 24
                backgroundMusic.DuckFor(2300)
                backgroundMusic.Update(missionVoice.speaking)
                PlayCowMoo(cowMoo)
            end if
            if activeTask.frame >= activeTask.duration
                actionMessage = ActionSuccessMessage(activeTask.area, activeTask.action)
                actionHeading = "YOU DID IT!"
                completedActions[activeTask.area + ":" + activeTask.action] = true
                if mission <> invalid and missionCompleted = false
                    stepInfo = mission.steps[missionStepIndex]
                    if stepInfo.area = activeTask.area and stepInfo.action = activeTask.action
                        if missionStepIndex = mission.steps.Count() - 1
                            missionCompleted = true
                            actionHeading = "MISSION COMPLETE!"
                            actionMessage = mission.title
                        else
                            missionStepIndex = missionStepIndex + 1
                            actionHeading = "STEP COMPLETE!"
                            actionMessage = "Next: " + mission.steps[missionStepIndex].hint
                        end if
                    end if
                end if
                if activeTask.action = "stitch" then stitchLoveFrames = 90
                if activeTask.action = "cow" then FinishCowPet(activeTask.cow)
                actionDoneFrames = 180
                activeTask = invalid
                upHeld = false : downHeld = false : leftHeld = false : rightHeld = false
            end if
        end if

        oldPlayerX = playerX
        oldPlayerY = playerY
        if activeTask = invalid
            if upHeld then playerY = playerY - 4
            if downHeld then playerY = playerY + 4
            if leftHeld then playerX = playerX - 4
            if rightHeld then playerX = playerX + 4
        end if

        minimumX = 28
        if currentArea = "yard" then minimumX = 140
        if playerX < minimumX then playerX = minimumX
        if playerX > 1220 then playerX = 1220
        if playerY < 92 then playerY = 92
        if playerY > 665 then playerY = 665

        playerFacing = FacingForMovement(playerX - oldPlayerX, playerY - oldPlayerY, playerFacing)
        centerX = playerX + 16
        centerY = playerY + 20

        if currentArea <> "yard" and PointInRect(centerX, centerY, 555, 625, 170, 75)
            if IsPlanetArea(currentArea)
                currentArea = "firepit"
                playerX = 170
                playerY = 355
            else
                if currentArea = "firepit"
                    playerX = 274
                    playerY = 272
                else if currentArea = "garden"
                    playerX = 602
                    playerY = 258
                else if currentArea = "playset"
                    playerX = 382
                    playerY = 405
                else if currentArea = "grove"
                    playerX = 520
                    playerY = 560
                else if currentArea = "deck"
                    playerX = 900
                    playerY = 350
                end if
                currentArea = "yard"
            end if
            completedActions = CreateObject("roAssociativeArray")
            upHeld = false : downHeld = false : leftHeld = false : rightHeld = false
        end if

        nearbyPlace = ""
        currentAction = ""
        if currentArea = "yard"
            if PointInRect(centerX, centerY, 205, 110, 165, 190)
                nearbyPlace = "firepit"
            else if PointInRect(centerX, centerY, 505, 105, 230, 205)
                nearbyPlace = "garden"
            else if PointInRect(centerX, centerY, 72, 535, 870, 145)
                nearbyPlace = "grove"
            else if PointInRect(centerX, centerY, 175, 300, 240, 225)
                nearbyPlace = "playset"
            else if PointInRect(centerX, centerY, 875, 250, 190, 235)
                nearbyPlace = "deck"
            end if
        else if currentArea = "garden"
            if PointInRect(centerX, centerY, 90, 135, 310, 430)
                currentAction = "water"
            else if PointInRect(centerX, centerY, 475, 155, 305, 400)
                currentAction = "pick"
            else if PointInRect(centerX, centerY, 845, 155, 325, 400)
                currentAction = "ladybug"
            end if
        else if currentArea = "playset"
            if PointInRect(centerX, centerY, 65, 170, 350, 365)
                currentAction = "slide"
            else if PointInRect(centerX, centerY, 465, 160, 340, 375)
                currentAction = "swing"
            else if PointInRect(centerX, centerY, 855, 160, 340, 375)
                currentAction = "clubhouse"
            end if
        else if currentArea = "grove"
            if PointInRect(centerX, centerY, 40, 155, 250, 420)
                currentAction = "treehang"
            else if PointInRect(centerX, centerY, 350, 165, 260, 410)
                currentAction = "birdbath"
            else if PointInRect(centerX, centerY, 665, 170, 270, 405)
                currentAction = "bushes"
            else if PointInRect(centerX, centerY, 980, 170, 270, 405)
                currentAction = "weed"
            end if
        else if currentArea = "deck"
            if PointInRect(centerX, centerY, 60, 145, 350, 430)
                currentAction = "deckflowers"
            else if PointInRect(centerX, centerY, 450, 160, 380, 405)
                currentAction = "settable"
            else if PointInRect(centerX, centerY, 865, 155, 350, 415)
                currentAction = "windchimes"
            end if
        else if currentArea = "firepit"
            if PointInRect(centerX, centerY, 70, 280, 180, 225)
                currentAction = "spacecrate"
            else if PointInRect(centerX, centerY, 300, 420, 220, 175)
                currentAction = "sticks"
            else if PointInRect(centerX, centerY, 530, 250, 220, 225)
                currentAction = "smore"
            else if PointInRect(centerX, centerY, 235, 130, 235, 220)
                currentAction = "fireswing1"
            else if PointInRect(centerX, centerY, 680, 130, 235, 220)
                currentAction = "fireswing2"
            else if PointInRect(centerX, centerY, 700, 420, 220, 175)
                currentAction = "lounger"
            else if PointInRect(centerX, centerY, 930, 235, 270, 300)
                currentAction = "daddy"
            end if
        end if

        spaceFrame = (spaceFrame + 1) mod 3600
        if IsPlanetArea(currentArea)
            for each item in planetItems
                if item.collected
                    if item.sparkFrames > 0 then item.sparkFrames = item.sparkFrames - 1
                else if Abs(centerX - item.x) < 30 and Abs(centerY - item.y) < 38
                    item.collected = true
                    item.sparkFrames = 28
                    planetCollected = planetCollected + 1
                    if planetCollected = planetItems.Count()
                        planetAction = PlanetActionForArea(currentArea)
                        completedActions[currentArea + ":" + planetAction] = true
                        actionHeading = "GREAT EXPLORING!"
                        actionMessage = "All treasures collected!"
                        if mission <> invalid and missionCompleted = false
                            stepInfo = mission.steps[missionStepIndex]
                            if stepInfo.area = currentArea and stepInfo.action = planetAction
                                if missionStepIndex = mission.steps.Count() - 1
                                    missionCompleted = true
                                    actionHeading = "MISSION COMPLETE!"
                                    actionMessage = "Fly home to " + mission.giver + "!"
                                else
                                    missionStepIndex = missionStepIndex + 1
                                    actionHeading = "STEP COMPLETE!"
                                    actionMessage = "Fly home for your next trip!"
                                end if
                            end if
                        end if
                        actionDoneFrames = 180
                    end if
                end if
            end for
        end if

        mommyTick = mommyClock.TotalMilliseconds()
        mommyElapsed = mommyTick - mommyLastTick
        mommyLastTick = mommyTick
        if mommyElapsed > 250 then mommyElapsed = 250
        UpdateMommy(mommy, currentArea, mommyElapsed, centerX, centerY, activeTask <> invalid)
        nearbyCow = UpdateCows(cows, currentArea, mommyElapsed, centerX, centerY, activeTask)

        stitchNearby = false
        if currentArea = "yard"
            dogCenterX = dogX + 24
            dogCenterY = dogY + 18
            if activeTask <> invalid
                ' A task locks movement, including Stitch wandering away mid-pet.
                if activeTask.action = "stitch" then stitchNearby = true
            else if Abs(centerX - dogCenterX) < 72 and Abs(centerY - dogCenterY) < 65
                stitchNearby = true
            else if dogPauseFrames > 0
                dogPauseFrames = dogPauseFrames - 1
            else
                dogDeltaX = dogTargetX - dogX
                dogDeltaY = dogTargetY - dogY

                if Abs(dogDeltaX) < 4 and Abs(dogDeltaY) < 4
                    dogTargetX = 190 + Rnd(690)
                    dogTargetY = 95 + Rnd(490)
                    dogPauseFrames = Rnd(100)
                else
                    dogFacing = FacingForMovement(dogDeltaX, dogDeltaY, dogFacing)
                    if dogDeltaX <> 0 then dogX = dogX + (Sgn(dogDeltaX) * 2)
                    if dogDeltaY <> 0 then dogY = dogY + (Sgn(dogDeltaY) * 2)
                    dogAnimationFrame = dogAnimationFrame + 1
                    if dogAnimationFrame > 20 then dogAnimationFrame = 0
                end if
            end if
        end if

        if stitchLoveFrames > 0 then stitchLoveFrames = stitchLoveFrames - 1
        if actionDoneFrames > 0 then actionDoneFrames = actionDoneFrames - 1

        missionHud = BuildMissionHudText(mission, missionStepIndex, missionCompleted)
        showActionBanner = actionDoneFrames > 0 and activeTask = invalid
        UpdateMissionPresentation(missionPresentation, missionHud, actionHeading, actionMessage, showActionBanner, missionCompleted, mommyElapsed, missionVoice)

        m.renderTask = activeTask
        m.yardProjection = currentArea = "yard"
        if currentArea = "yard"
            DrawYard(screen, titleFont, labelFont, bodyFont)
        else if currentArea = "garden"
            DrawGarden(screen, titleFont, labelFont, promptFont, bodyFont, completedActions)
        else if currentArea = "playset"
            DrawPlayset(screen, titleFont, labelFont, promptFont, bodyFont, completedActions)
        else if currentArea = "grove"
            DrawGrove(screen, titleFont, labelFont, promptFont, bodyFont, completedActions)
        else if currentArea = "deck"
            DrawDeck(screen, titleFont, labelFont, promptFont, bodyFont, completedActions)
        else if IsPlanetArea(currentArea)
            DrawPlanet(screen, currentArea, titleFont, labelFont, promptFont, bodyFont, planetItems, planetCollected, spaceFrame)
        else
            DrawFirepit(screen, titleFont, labelFont, promptFont, bodyFont, completedActions)
        end if

        if currentArea = "yard"
            DrawCows(screen, cows)
            DrawMommy(screen, mommy, labelFont)
        end if
        if currentArea = "yard" and activeTask = invalid
            DrawStitch(screen, dogX, dogY, dogAnimationFrame, labelFont, dogFacing)
        end if
        walkBob = 0
        if upHeld or downHeld or leftHeld or rightHeld then walkBob = Int(Sin(spaceFrame * 0.45) * 2)
        if activeTask <> invalid
            DrawTaskAnimation(screen, activeTask, dressColor, labelFont)
            screen.DrawRect(275, 82, 730, 52, &h173E52FF)
            CenterLabel(screen, ActionPrompt(activeTask.area, activeTask.action) + "...", 640, 88, &hFFFFFFFF, labelFont)
            screen.DrawRect(460, 119, 360, 5, &h617E87FF)
            screen.DrawRect(460, 119, Int(360 * activeTask.frame / activeTask.duration), 5, &hFFE06AFF)
        else
            DrawGenevieve(screen, playerX, playerY, dressColor, walkBob, playerFacing)
        end if
        if activeTask = invalid
            if currentArea = "yard" and mommy.nearby
                screen.DrawRect(390, 82, 500, 52, &h173E52EE)
                CenterLabel(screen, "Press OK for Mommy's mission", 640, 94, &hFFFFFFFF, promptFont)
            else if currentArea = "yard" and nearbyCow >= 0
                screen.DrawRect(390, 82, 500, 52, &h173E52EE)
                CenterLabel(screen, "Press OK to pet the cow", 640, 94, &hFFFFFFFF, promptFont)
            else if currentArea = "yard" and stitchNearby
                screen.DrawRect(414, 82, 452, 52, &h173E52EE)
                screen.DrawText("Press OK to pet Stitch", 477, 94, &hFFFFFFFF, promptFont)
            else if currentArea = "yard" and nearbyPlace = "firepit"
                screen.DrawRect(400, 82, 480, 52, &h173E52EE)
                screen.DrawText("Press OK to enter the firepit", 434, 94, &hFFFFFFFF, promptFont)
            else if currentArea = "yard" and nearbyPlace = "garden"
                screen.DrawRect(414, 82, 452, 52, &h173E52EE)
                screen.DrawText("Press OK to enter the food garden", 423, 94, &hFFFFFFFF, promptFont)
            else if currentArea = "yard" and nearbyPlace = "playset"
                screen.DrawRect(405, 82, 470, 52, &h173E52EE)
                screen.DrawText("Press OK to enter the playset", 437, 94, &hFFFFFFFF, promptFont)
            else if currentArea = "yard" and nearbyPlace = "grove"
                screen.DrawRect(390, 82, 500, 52, &h173E52EE)
                screen.DrawText("Press OK to enter Birdsong Garden", 421, 94, &hFFFFFFFF, promptFont)
            else if currentArea = "yard" and nearbyPlace = "deck"
                screen.DrawRect(414, 82, 452, 52, &h173E52EE)
                screen.DrawText("Press OK to go onto the deck", 449, 94, &hFFFFFFFF, promptFont)
            end if
        end if
        if currentArea <> "yard" and currentAction <> "" and actionDoneFrames = 0 and activeTask = invalid
            screen.DrawRect(275, 82, 730, 52, &h173E52EE)
            CenterLabel(screen, "Press OK to " + ActionPrompt(currentArea, currentAction), 640, 94, &hFFFFFFFF, promptFont)
        end if
        if actionDoneFrames > 0 and activeTask = invalid
            screen.DrawRect(275, 76, 730, 68, &h2E7D32F2)
            CenterLabel(screen, actionHeading, 640, 81, &hFFFFFFFF, labelFont)
            CenterLabel(screen, actionMessage, 640, 110, &hFFFFFFFF, labelFont)
        end if
        if currentArea = "yard" and stitchLoveFrames > 0
            heartBob = Int(Sin(spaceFrame * 0.15) * 3)
            DrawPetHeart(screen, dogX + 24, dogY - 37 + heartBob, 30)
        end if
        if currentArea <> "yard" then screen.DrawText("Play/Pause: twirl", 40, 691, &hFFF0C2FF, bodyFont)
        DrawMissionFireworks(screen, missionPresentation)
        DrawMissionHud(screen, missionHud, labelFont, bodyFont)
        screen.SwapBuffers()
        sleep(16)
    end while
end sub

function ActionPrompt(area, action)
    if action = "twirl" then return "twirl around"
    if action = "cow" then return "pet the cow"
    if action = "weed" then return "weed the garden"
    if action = "stitch" then return "pet Stitch"
    if action = "water" then return "water the flowers"
    if action = "pick" then return "pick the vegetables"
    if action = "ladybug" then return "find the ladybug"
    if action = "slide" then return "climb and slide"
    if action = "swing" then return "swing high"
    if action = "clubhouse" then return "visit the clubhouse"
    if action = "treehang" then return "hang from the big tree"
    if action = "birdbath" then return "fill the bird bath"
    if action = "bushes" then return "explore the bushes"
    if action = "deckflowers" then return "water the deck flowers"
    if action = "settable" then return "set the patio table"
    if action = "windchimes" then return "ring the wind chimes"
    if action = "sticks" then return "gather sticks"
    if action = "smore" then return "make a s'more"
    if action = "fireswing1" then return "sit on the rocking bench"
    if action = "fireswing2" then return "sit on the chair swing"
    if action = "lounger" then return "relax on the lounger"
    if action = "spacecrate" then return "open the Space Crate"
    if action = "redrock" then return "collect 10 glowing rocks"
    if action = "rings" then return "collect 10 sparkling rings"
    if action = "bluecrystal" then return "collect 10 blue crystals"
    if action = "daddy" then return "visit Daddy"
    return "do the activity"
end function

function ActionSuccessMessage(area, action)
    if action = "twirl" then return "What a lovely twirl!"
    if action = "cow" then return "The cow loved those cuddles!"
    if action = "weed" then return "The garden is free of weeds!"
    if action = "stitch" then return "Stitch loved those cuddles!"
    if action = "water" then return "The flowers are watered!"
    if action = "pick" then return "You picked the vegetables!"
    if action = "ladybug" then return "You found the ladybug!"
    if action = "slide" then return "You went down the slide!"
    if action = "swing" then return "You swung so high!"
    if action = "clubhouse" then return "You explored the clubhouse!"
    if action = "treehang" then return "You hung from the big tree!"
    if action = "birdbath" then return "The birds have fresh water!"
    if action = "bushes" then return "You explored the secret bushes!"
    if action = "deckflowers" then return "You watered the deck flowers!"
    if action = "settable" then return "You set the patio table!"
    if action = "windchimes" then return "The wind chimes made a pretty song!"
    if action = "sticks" then return "You gathered the sticks!"
    if action = "smore" then return "You made a yummy s'more!"
    if action = "fireswing1" then return "You rocked on the rocking bench!"
    if action = "fireswing2" then return "You enjoyed the chair swing!"
    if action = "lounger" then return "You relaxed on the lounger!"
    if action = "redrock" then return "You collected all 10 glowing rocks!"
    if action = "rings" then return "You collected all 10 sparkling rings!"
    if action = "bluecrystal" then return "You collected all 10 blue crystals!"
    return "You did the activity!"
end function

function GetMission(index)
    result = CreateObject("roAssociativeArray")
    result.giver = "Daddy"
    if index = 0
        result.title = "Swing Mission"
        result.steps = [MakeStep("playset", "swing", "Go to the playset and swing high!")]
    else if index = 1
        result.title = "Rainbow Mission"
        result.steps = [MakeStep("garden", "water", "Water the flowers to make a rainbow!")]
    else if index = 2
        result.title = "Campfire Helper Mission"
        result.steps = [MakeStep("firepit", "sticks", "Gather sticks by the firepit!")]
    else if index = 3
        result.title = "Puppy Pal Mission"
        result.steps = [MakeStep("yard", "stitch", "Find Stitch in the yard and pet her!")]
    else if index = 4
        result.title = "Flower Power Mission"
        result.steps = [MakeStep("garden", "water", "Give the garden flowers a big drink!")]
    else if index = 5
        result.title = "Veggie Victory"
        result.steps = [MakeStep("garden", "pick", "Pick the vegetables in the garden!")]
    else if index = 6
        result.title = "Ladybug Detective"
        result.steps = [MakeStep("garden", "ladybug", "Find the hidden ladybug!")]
    else if index = 7
        result.title = "Slide Superstar"
        result.steps = [MakeStep("playset", "slide", "Climb up and zoom down the slide!")]
    else if index = 8
        result.title = "Secret Clubhouse Mission"
        result.steps = [MakeStep("playset", "clubhouse", "Explore the secret clubhouse!")]
    else if index = 9
        result.title = "S'more Sparkle"
        result.steps = [MakeStep("firepit", "smore", "Make a yummy s'more at the firepit!")]
    else if index = 10
        result.title = "Garden Helper Quest"
        result.steps = [MakeStep("garden", "water", "First, water the flowers!"), MakeStep("garden", "pick", "Now pick the vegetables!")]
    else if index = 11
        result.title = "Playset Parade"
        result.steps = [MakeStep("playset", "slide", "Start with the slide!"), MakeStep("playset", "swing", "Next, swing high!"), MakeStep("playset", "clubhouse", "Finish in the secret clubhouse!")]
    else if index = 12
        result.title = "Campfire Crew"
        result.steps = [MakeStep("firepit", "sticks", "Gather sticks for the fire!"), MakeStep("firepit", "smore", "Celebrate by making a s'more!")]
    else if index = 13
        result.title = "Backyard Best Friends"
        result.steps = [MakeStep("yard", "stitch", "Give Stitch a friendly pet!"), MakeStep("playset", "swing", "Then go swing at the playset!")]
    else if index = 14
        result.title = "Rainbow Picnic Adventure"
        result.steps = [MakeStep("garden", "water", "Water the colorful flowers!"), MakeStep("garden", "pick", "Pick vegetables for the picnic!"), MakeStep("firepit", "smore", "Make a s'more for dessert!")]
    else if index = 15
        result.title = "Tiny Explorer Quest"
        result.steps = [MakeStep("garden", "ladybug", "Find the tiny ladybug!"), MakeStep("playset", "clubhouse", "Explore the secret clubhouse!")]
    else if index = 16
        result.title = "Three-Place Challenge"
        result.steps = [MakeStep("garden", "water", "Help at the garden first!"), MakeStep("playset", "swing", "Swing high at the playset!"), MakeStep("firepit", "sticks", "Finish by gathering sticks!")]
    else if index = 17
        result.title = "Genevieve's Grand Adventure"
        result.steps = [MakeStep("yard", "stitch", "Begin by petting Stitch!"), MakeStep("garden", "water", "Water the flowers!"), MakeStep("garden", "pick", "Pick the vegetables!"), MakeStep("playset", "slide", "Zoom down the slide!"), MakeStep("playset", "swing", "Swing as high as you can!"), MakeStep("playset", "clubhouse", "Explore the clubhouse!"), MakeStep("firepit", "sticks", "Gather sticks at the firepit!"), MakeStep("firepit", "smore", "Finish with a yummy s'more!")]
    else if index = 18
        result.title = "Red Planet Rock Hunt"
        result.steps = [MakeStep("mars", "redrock", "Fly to Mars. Walk over all 10 glowing rocks!")]
    else if index = 19
        result.title = "Saturn Ring Mission"
        result.steps = [MakeStep("saturn", "rings", "Fly to Saturn. Collect 10 sparkling rings!")]
    else if index = 20
        result.title = "Neptune Crystal Quest"
        result.steps = [MakeStep("neptune", "bluecrystal", "Fly to Neptune. Collect 10 blue crystals!")]
    else if index = 21
        result.title = "Planet Hopper Mission"
        result.steps = [MakeStep("mars", "redrock", "First, collect 10 glowing rocks on Mars!"), MakeStep("saturn", "rings", "Next, collect 10 sparkling rings on Saturn!"), MakeStep("neptune", "bluecrystal", "Finish with 10 blue crystals on Neptune!")]
    else if index = 22
        result.title = "Bird Bath Helper"
        result.steps = [MakeStep("grove", "birdbath", "Visit Birdsong Garden and fill the bird bath!")]
    else if index = 23
        result.title = "Tree Hanger Mission"
        result.steps = [MakeStep("grove", "treehang", "Find the big tree in Birdsong Garden and hang from it!")]
    else if index = 24
        result.title = "Bushy Treasure Hunt"
        result.steps = [MakeStep("grove", "bushes", "Explore the bushes in Birdsong Garden!")]
    else if index = 25
        result.title = "Birdsong Garden Adventure"
        result.steps = [MakeStep("grove", "treehang", "First, hang from the big tree!"), MakeStep("grove", "bushes", "Next, explore the bushes!"), MakeStep("grove", "birdbath", "Fill the bird bath!"), MakeStep("grove", "weed", "Finish by pulling the weeds!")]
    else if index = 26
        result.title = "Deck Flower Helper"
        result.steps = [MakeStep("deck", "deckflowers", "Go onto the deck and water the flowers!")]
    else if index = 27
        result.title = "Patio Table Mission"
        result.steps = [MakeStep("deck", "settable", "Go onto the deck and set the patio table!")]
    else if index = 28
        result.title = "Wind Chime Song"
        result.steps = [MakeStep("deck", "windchimes", "Ring the wind chimes on the deck!")]
    else if index = 29
        result.title = "Deck Party Mission"
        result.steps = [MakeStep("deck", "deckflowers", "First, water the deck flowers!"), MakeStep("deck", "settable", "Next, set the patio table!"), MakeStep("deck", "windchimes", "Finish by ringing the wind chimes!")]
    else if index = 30
        result.title = "Garden Weed Helper"
        result.steps = [MakeStep("grove", "weed", "Pull the weeds in Birdsong Garden!")]
    else if index = 31
        result.title = "Birdsong Garden Helpers"
        result.steps = [MakeStep("grove", "weed", "First, pull the garden weeds!"), MakeStep("grove", "birdbath", "Then give the birds fresh water!")]
    else if index = 32
        result.title = "Twirling Star"
        result.steps = [MakeStep("yard", "twirl", "In the yard, press Play/Pause to twirl!")]
    else if index = 33
        result.title = "Dance and Play"
        result.steps = [MakeStep("yard", "twirl", "First, press Play/Pause to twirl in the yard!"), MakeStep("playset", "swing", "Next, have a ride on the swing!")]
    else
        result.title = "Friendly Cow Cuddles"
        result.steps = [MakeStep("yard", "cow", "Pet a cow peeking through the left trees!")]
    end if
    return result
end function

function BuildMissionOrder()
    order = []
    for missionId = 0 to 34
        order.Push(missionId)
    end for

    ' Fisher-Yates shuffle gives every mission a random place in the list.
    for position = order.Count() - 1 to 1 step -1
        swapPosition = Rnd(position + 1) - 1
        savedMission = order[position]
        order[position] = order[swapPosition]
        order[swapPosition] = savedMission
    end for
    return order
end function

function MakeStep(area, action, hint)
    stepInfo = CreateObject("roAssociativeArray")
    stepInfo.area = area
    stepInfo.action = action
    stepInfo.hint = hint
    return stepInfo
end function

function BuildMissionHudText(mission, missionStepIndex, missionCompleted)
    if mission = invalid
        return {heading: "MISSION", body: "Visit Daddy or Mommy for a mission"}
    else if missionCompleted
        return {heading: "MISSION COMPLETE!", body: "Return to " + mission.giver + " for another mission"}
    end if
    stepLabel = "Step " + (missionStepIndex + 1).ToStr() + "/" + mission.steps.Count().ToStr() + ": "
    return {heading: "MISSION: " + mission.title, body: stepLabel + mission.steps[missionStepIndex].hint}
end function

sub DrawMissionHud(screen, hud, labelFont, bodyFont)
    screen.DrawRect(785, 626, 455, 70, &h173E52EE)
    screen.DrawText(hud.heading, 805, 634, &hFFE06AFF, labelFont)
    screen.DrawText(hud.body, 805, 662, &hFFFFFFFF, bodyFont)
end sub

sub DrawDone(screen, completedActions, key, x, y, labelFont)
    if completedActions.DoesExist(key)
        screen.DrawRect(x, y, 92, 34, &h2E7D32FF)
        screen.DrawText("DONE!", x + 15, y + 5, &hFFFFFFFF, labelFont)
    end if
end sub

sub DrawStitch(screen, dogX, dogY, animationFrame, labelFont, dogFacing)
    if m.characterSprites.Count() = 8
        bob = Int(Sin(animationFrame * 0.3) * 2)
        DrawCharacterSprite(screen, 4 + dogFacing, dogX + 24, dogY + 12 + bob, 76, 58)
        CenterLabel(screen, "STITCH", SceneX(dogX + 24), dogY + 45, &h173E52FF, labelFont)
        return
    end if
    dogX = SceneX(dogX + 24) - 24
    ' Stitch is a small brown dog with a cream face and a wagging tail.
    if animationFrame < 10
        screen.DrawRect(dogX, dogY + 7, 13, 6, &h8A5734FF)
    else
        screen.DrawRect(dogX + 1, dogY + 2, 6, 13, &h8A5734FF)
    end if

    screen.DrawRect(dogX + 10, dogY + 8, 28, 22, &hA96B3FFF)
    screen.DrawRect(dogX + 32, dogY + 3, 21, 21, &hA96B3FFF)
    screen.DrawRect(dogX + 29, dogY, 7, 12, &h6C422CFF)
    screen.DrawRect(dogX + 48, dogY, 7, 12, &h6C422CFF)
    screen.DrawRect(dogX + 39, dogY + 12, 14, 10, &hE2B88CFF)
    screen.DrawRect(dogX + 48, dogY + 14, 5, 5, &h252525FF)
    screen.DrawRect(dogX + 38, dogY + 7, 3, 3, &h252525FF)

    screen.DrawRect(dogX + 13, dogY + 28, 7, 11, &h6C422CFF)
    screen.DrawRect(dogX + 29, dogY + 28, 7, 11, &h6C422CFF)
    screen.DrawText("STITCH", dogX + 1, dogY + 42, &h173E52FF, labelFont)
end sub

function PointInRect(x, y, left, top, width, height)
    return x >= left and x <= left + width and y >= top and y <= top + height
end function

function IsPlanetArea(area)
    return area = "mars" or area = "saturn" or area = "neptune"
end function

sub DrawHeader(screen, title, titleFont, bodyFont)
    screen.DrawRect(0, 0, 1280, 70, &h173E52FF)
    screen.DrawText(title, 35, 16, &hFFFFFFFF, titleFont)
    screen.DrawText("Genevieve's Backyard", 1040, 24, &hCDE8D0FF, bodyFont)
end sub

sub DrawExit(screen, labelFont, bodyFont)
    screen.DrawRect(548, 628, 184, 63, &h173E52FF)
    screen.DrawRect(558, 638, 164, 43, &hFFE06AFF)
    screen.DrawText("EXIT TO YARD", 572, 647, &h173E52FF, labelFont)
    screen.DrawText("Walk onto the exit", 40, 663, &hFFFFFFFF, bodyFont)
end sub

sub DrawYard(screen, titleFont, labelFont, bodyFont)
    screen.Clear(&h6FA653FF)
    DrawHeader(screen, "GENEVIEVE'S BACKYARD", titleFont, bodyFont)
    DrawPasture(screen, labelFont)
    for stripe = 0 to 9
        screen.DrawRect(SceneX(95 + stripe * 112), 78, 37, 574, &h75AD59FF)
    end for

    screen.DrawRect(SceneX(72), 642, 688, 38, &h245C38FF)
    for bushX = 84 to 900 step 58
        screen.DrawRect(SceneX(bushX), 650, 34, 23, &h3E804AFF)
        screen.DrawRect(SceneX(bushX + 9), 642, 20, 14, &h559A56FF)
    end for
    DrawAreaObject(screen, 6, 150, 604, 100, 105)
    DrawAreaObject(screen, 6, 770, 604, 100, 105)
    for lowerBushX = 250 to 680 step 86
        DrawAreaObject(screen, 8, lowerBushX, 630, 80, 60)
    end for
    DrawAreaObject(screen, 7, 452, 604, 48, 58)
    CenterLabel(screen, "BIRDSONG GARDEN", SceneX(480), 550, &h173E52FF, labelFont)

    DrawAreaObject(screen, 12, 286, 185, 82, 82)
    CenterLabel(screen, "FIREPIT", SceneX(286), 230, &h173E52FF, labelFont)
    DrawAreaObject(screen, 1, 618, 187, 145, 100)
    CenterLabel(screen, "FOOD GARDEN", SceneX(618), 238, &h173E52FF, labelFont)
    DrawAreaObject(screen, 3, 250, 386, 100, 100)
    DrawAreaObject(screen, 4, 342, 386, 95, 100)
    CenterLabel(screen, "PLAYSET", SceneX(296), 439, &h173E52FF, labelFont)

    DrawYardDetail(screen, 0, 1117, 340, 126, 132)
    CenterLabel(screen, "HOUSE", SceneX(1117), 415, &h173E52FF, bodyFont)
    DrawYardDetail(screen, 1, 966, 354, 185, 175)
    CenterLabel(screen, "DECK", SceneX(966), 448, &h173E52FF, labelFont)
    screen.DrawText("Walk near a place to explore | Play/Pause: twirl", 340, 692, &h173E52FF, bodyFont)
end sub

sub LoadAreaArtwork()
    m.areaSprites = []
    atlas = CreateObject("roBitmap", "pkg:/images/yard-objects.png")
    if atlas = invalid then return
    ' Explicit atlas bounds preserve the full silhouettes and avoid neighboring art.
    bounds = [[0,20,286,263], [292,31,287,247], [592,20,249,260], [845,10,288,279], [1139,3,263,282], [0,285,285,276], [286,273,305,291], [599,290,232,271], [837,310,302,254], [1140,285,262,265], [0,564,334,267], [354,568,194,280], [559,562,282,252], [844,579,299,249], [1146,560,256,291], [0,831,306,283], [308,870,285,240], [591,813,243,307], [844,869,295,223], [1143,870,259,210]]
    for each rect in bounds
        sprite = CreateObject("roRegion", atlas, rect[0], rect[1], rect[2], rect[3])
        m.areaSprites.Push(sprite)
    end for
end sub

sub DrawAreaObject(screen, index, x, y, width, height)
    x = SceneX(x)
    if m.yardProjection = true
        width = width * 0.8
        height = height * 0.8
    end if
    if m.areaSprites.Count() <= index then return
    sprite = m.areaSprites[index]
    scale = width / sprite.GetWidth()
    if height / sprite.GetHeight() < scale then scale = height / sprite.GetHeight()
    screen.DrawScaledObject(Int(x - sprite.GetWidth() * scale / 2), Int(y - sprite.GetHeight() * scale / 2), scale, scale, sprite)
end sub

sub CenterLabel(screen, text, x, y, color, font)
    screen.DrawText(text, Int(x - font.GetOneLineWidth(text, 1280) / 2), y, color, font)
end sub

sub DrawActivity(screen, spriteIndex, x, y, width, height, label, key, completedActions, labelFont)
    DrawAreaObject(screen, spriteIndex, x, y, width, height)
    CenterLabel(screen, label, x, y + height / 2 + 2, &hFFF0C2FF, labelFont)
    DrawDone(screen, completedActions, key, x - 46, y + height / 2 + 28, labelFont)
end sub

sub DrawGrassFloor(screen, color)
    screen.Clear(color)
    for i = 0 to 70
        x = 35 + ((i * 179) mod 1200)
        y = 149 + ((i * 113) mod 450)
        screen.DrawRect(x, y, 2, 6, &hA6C67E66)
        screen.DrawRect(x + 5, y + 3, 2, 4, &hA6C67E66)
    end for
end sub

sub DrawGarden(screen, titleFont, labelFont, promptFont, bodyFont, completedActions)
    DrawGrassFloor(screen, &h6F9952FF)
    DrawHeader(screen, "THE FOOD GARDEN", titleFont, bodyFont)
    CenterLabel(screen, "LITTLE GARDEN HELPERS", 640, 94, &hFFF0C2FF, promptFont)
    DrawActivity(screen, 0, 250, 340, 270, 245, "WATER THE FLOWERS", "garden:water", completedActions, labelFont)
    DrawActivity(screen, 1, 640, 340, 270, 245, "PICK THE VEGETABLES", "garden:pick", completedActions, labelFont)
    DrawActivity(screen, 2, 1030, 340, 250, 235, "FIND THE LADYBUG", "garden:ladybug", completedActions, labelFont)
    DrawExit(screen, labelFont, bodyFont)
end sub

sub DrawPlayset(screen, titleFont, labelFont, promptFont, bodyFont, completedActions)
    DrawGrassFloor(screen, &h72A35AFF)
    DrawHeader(screen, "THE PLAYSET", titleFont, bodyFont)
    CenterLabel(screen, "A LITTLE ADVENTURE", 640, 94, &hFFF0C2FF, promptFont)
    DrawActivity(screen, 3, 250, 335, 260, 245, "CLIMB AND SLIDE", "playset:slide", completedActions, labelFont)
    swingFrame = 0
    if m.renderTask <> invalid
        if m.renderTask.action = "swing" then swingFrame = m.renderTask.frame
    end if
    DrawPlaysetSwing(screen, swingFrame)
    CenterLabel(screen, "SWING HIGH", 640, 459, &hFFF0C2FF, labelFont)
    DrawDone(screen, completedActions, "playset:swing", 594, 485, labelFont)
    DrawActivity(screen, 5, 1030, 335, 260, 245, "SECRET CLUBHOUSE", "playset:clubhouse", completedActions, labelFont)
    DrawExit(screen, labelFont, bodyFont)
end sub

sub DrawDeck(screen, titleFont, labelFont, promptFont, bodyFont, completedActions)
    screen.Clear(&hA8734FFF)
    for boardY = 135 to 600 step 34
        screen.DrawRect(25, boardY, 1230, 29, &hB98159FF)
        screen.DrawRect(25, boardY + 28, 1230, 4, &h81533BFF)
    end for
    screen.DrawRect(25, 144, 1230, 10, &hE1B882FF)
    screen.DrawRect(25, 154, 1230, 5, &h7D5138FF)
    for postX = 45 to 1230 step 145
        screen.DrawRect(postX, 124, 8, 43, &hC79764FF)
    end for
    DrawAreaObject(screen, 9, 79, 191, 80, 78)
    DrawAreaObject(screen, 9, 1201, 191, 80, 78)
    DrawHeader(screen, "THE DECK", titleFont, bodyFont)
    CenterLabel(screen, "OUR COZY OUTDOOR ROOM", 640, 94, &hFFF0C2FF, promptFont)
    DrawActivity(screen, 9, 250, 335, 235, 230, "WATER THE FLOWERS", "deck:deckflowers", completedActions, labelFont)
    DrawActivity(screen, 10, 640, 335, 270, 245, "SET THE PATIO TABLE", "deck:settable", completedActions, labelFont)
    DrawActivity(screen, 11, 1030, 335, 230, 240, "RING THE WIND CHIMES", "deck:windchimes", completedActions, labelFont)
    DrawExit(screen, labelFont, bodyFont)
end sub

sub DrawGrove(screen, titleFont, labelFont, promptFont, bodyFont, completedActions)
    DrawGrassFloor(screen, &h4F7F48FF)
    DrawHeader(screen, "BIRDSONG GARDEN", titleFont, bodyFont)
    CenterLabel(screen, "A GARDEN FOR RELAXING", 640, 94, &hE8F4D8FF, promptFont)
    DrawActivity(screen, 6, 160, 335, 210, 230, "HANG FROM A TREE", "grove:treehang", completedActions, labelFont)
    DrawActivity(screen, 7, 480, 340, 200, 220, "FILL THE BIRD BATH", "grove:birdbath", completedActions, labelFont)
    DrawActivity(screen, 8, 800, 340, 225, 220, "EXPLORE THE BUSHES", "grove:bushes", completedActions, labelFont)
    DrawYardDetail(screen, 2, 1120, 340, 225, 220)
    CenterLabel(screen, "WEED THE GARDEN", 1120, 452, &hFFF0C2FF, labelFont)
    DrawDone(screen, completedActions, "grove:weed", 1074, 480, labelFont)
    DrawExit(screen, labelFont, bodyFont)
end sub

sub DrawFirepit(screen, titleFont, labelFont, promptFont, bodyFont, completedActions)
    DrawGrassFloor(screen, &h527C49FF)
    DrawHeader(screen, "THE FIREPIT", titleFont, bodyFont)
    CenterLabel(screen, "THE COZY CAMPFIRE", 640, 91, &hFFF0C2FF, promptFont)
    DrawActivity(screen, 13, 365, 217, 215, 165, "ROCKING BENCH", "firepit:fireswing1", completedActions, labelFont)
    DrawActivity(screen, 14, 795, 217, 200, 165, "CHAIR SWING", "firepit:fireswing2", completedActions, labelFont)
    DrawAreaObject(screen, 18, 160, 365, 160, 150)
    CenterLabel(screen, "SPACE CRATE", 160, 444, &hFFF0C2FF, labelFont)
    DrawActivity(screen, 12, 640, 350, 140, 130, "MAKE A S'MORE", "firepit:smore", completedActions, labelFont)
    DrawActivity(screen, 16, 410, 480, 175, 125, "GATHER STICKS", "firepit:sticks", completedActions, labelFont)
    DrawActivity(screen, 15, 810, 480, 200, 135, "LOUNGER", "firepit:lounger", completedActions, labelFont)
    DrawAreaObject(screen, 17, 1060, 350, 215, 220)
    CenterLabel(screen, "VISIT DADDY", 1060, 470, &hFFF0C2FF, labelFont)
    DrawExit(screen, labelFont, bodyFont)
end sub

function BuildPlanetItems()
    ' A spread-out route keeps treasures away from the landing spot and exit.
    positions = [[150, 205], [370, 185], [610, 215], [870, 190], [1100, 235], [235, 370], [490, 390], [770, 355], [1045, 440], [350, 550]]
    items = []
    for i = 0 to positions.Count() - 1
        items.Push({x: positions[i][0] + Rnd(31) - 16, y: positions[i][1] + Rnd(31) - 16, phase: i * 11, collected: false, sparkFrames: 0})
    end for
    return items
end function

function PlanetActionForArea(area)
    if area = "mars" then return "redrock"
    if area = "saturn" then return "rings"
    return "bluecrystal"
end function

sub DrawPlanet(screen, planet, titleFont, labelFont, promptFont, bodyFont, items, collected, frame)
    ground = &h9D4E35FF
    shade = &h713B32FF
    title = "MARS: RED ROCK VALLEY"
    treasureName = "GLOWING ROCKS"
    if planet = "saturn"
        ground = &h27264FFF
        shade = &h49406AFF
        title = "SATURN: SPARKLING RINGS"
        treasureName = "SPARKLING RINGS"
    else if planet = "neptune"
        ground = &h163B72FF
        shade = &h245A91FF
        title = "NEPTUNE: CRYSTAL CAVES"
        treasureName = "BLUE CRYSTALS"
    end if
    screen.Clear(ground)
    DrawHeader(screen, title, titleFont, bodyFont)
    screen.DrawText("Walk over the sparkling treasures to pick them up!", 40, 96, &hFFFFFFFF, promptFont)
    screen.DrawRect(918, 82, 330, 48, &h173E52FF)
    screen.DrawText(treasureName + " " + collected.ToStr() + "/" + items.Count().ToStr(), 933, 95, &hFFE06AFF, labelFont)

    ' Small scenery leaves plenty of room to explore between the treasures.
    for i = 0 to 17
        x = 65 + ((i * 193) mod 1130)
        y = 155 + ((i * 137) mod 430)
        if planet = "saturn"
            screen.DrawRect(x, y, 3, 3, &hD7C8E9FF)
            screen.DrawRect(x + 22, y + 18, 2, 2, &hBBAAD6FF)
        else
            screen.DrawRect(x, y, 38, 15, shade)
            screen.DrawRect(x + 8, y - 5, 23, 8, shade)
        end if
    end for
    for each item in items
        if not item.collected
            DrawSpaceTreasure(screen, planet, item, frame, ground)
        else if item.sparkFrames > 0
            progress = (28 - item.sparkFrames) / 28
            ' The jewel lifts and shrinks while illustrated sparkles fan outward.
            jewelSize = 56 * (1 - progress)
            DrawPlanetSprite(screen, PlanetTreasureSpriteIndex(planet), item.x, item.y - progress * 36, jewelSize, jewelSize)
            radius = 10 + progress * 44
            sparkleSize = 16 - progress * 12
            for spark = 0 to 5
                angle = spark * 1.0472 + item.phase * 0.03
                sx = item.x + Cos(angle) * radius
                sy = item.y + Sin(angle) * radius - progress * 16
                DrawPlanetSprite(screen, 3, sx, sy, sparkleSize, sparkleSize)
            end for
            screen.DrawText("+1", item.x - 10, item.y - 32 - Int(progress * 42), &hFFF3B0FF, labelFont)
        end if
    end for
    if collected = items.Count()
        screen.DrawText("All treasures found! Head to the Space Crate.", 330, 583, &hFFF3B0FF, promptFont)
    end if
    screen.DrawRect(548, 628, 184, 63, &h173E52FF)
    screen.DrawRect(558, 638, 164, 43, &hFFE06AFF)
    screen.DrawText("FLY HOME", 594, 647, &h173E52FF, labelFont)
    screen.DrawText("Walk into the Space Crate", 40, 663, &hFFFFFFFF, bodyFont)
end sub

sub DrawFallbackSpaceTreasure(screen, planet, item, frame, ground)
    phase = (frame + item.phase) mod 120
    bob = Int(Sin(phase * 0.05236) * 4)
    x = item.x
    y = item.y + bob
    shine = &hFFD475FF
    if phase < 60 then shine = &hFFF8D6FF
    screen.DrawRect(x - 14, item.y + 17, 28, 5, &h101C3855)
    if planet = "mars"
        screen.DrawRect(x - 13, y - 8, 26, 23, &hF07845FF)
        screen.DrawRect(x - 8, y - 14, 17, 8, &hFFAA66FF)
        screen.DrawRect(x - 6, y - 8, 9, 11, shine)
        screen.DrawRect(x + 5, y + 6, 7, 7, &hC94C39FF)
    else if planet = "saturn"
        width = 12 + Int(Abs(Cos(phase * 0.05236)) * 18)
        screen.DrawRect(x - width / 2, y - 11, width, 23, shine)
        screen.DrawRect(x - width / 2 + 5, y - 6, width - 10, 13, ground)
    else
        screen.DrawRect(x - 6, y - 17, 12, 33, &h54D5FFFF)
        screen.DrawRect(x - 13, y - 7, 26, 17, &h32A5DCFF)
        screen.DrawRect(x - 3, y - 14, 5, 25, shine)
    end if
    ' A slow shimmer never hides the item; stagger phases across the field.
    if phase < 60
        screen.DrawRect(x + 18, y - 22, 3, 11, shine)
        screen.DrawRect(x + 14, y - 18, 11, 3, shine)
    else
        screen.DrawRect(x - 23, y - 8, 3, 9, shine)
        screen.DrawRect(x - 26, y - 5, 9, 3, shine)
    end if
end sub

sub DrawGenevieve(screen, playerX, playerY, dressColor, walkBob, playerFacing)
    if m.characterSprites.Count() = 8
        DrawCharacterSprite(screen, playerFacing, playerX + 16, playerY + 16 + walkBob, 60, 78)
        return
    end if
    playerX = SceneX(playerX + 16) - 16
    screen.DrawRect(playerX + 4, playerY - 17, 24, 24, &h6A3F2AFF)
    screen.DrawRect(playerX + 8, playerY - 14, 16, 17, &hF2C6A0FF)
    screen.DrawRect(playerX + 6, playerY - 17, 20, 6, &h6A3F2AFF)
    screen.DrawRect(playerX + 4, playerY - 11, 5, 15, &h6A3F2AFF)
    screen.DrawRect(playerX + 23, playerY - 11, 5, 15, &h6A3F2AFF)
    screen.DrawRect(playerX + 11, playerY - 7, 3, 3, &h173E52FF)
    screen.DrawRect(playerX + 19, playerY - 7, 3, 3, &h173E52FF)
    screen.DrawRect(playerX + 8, playerY + 4, 16, 17, dressColor)
    screen.DrawRect(playerX + 3, playerY + 7, 5, 18, &hF2C6A0FF)
    screen.DrawRect(playerX + 24, playerY + 7, 5, 18, &hF2C6A0FF)
    screen.DrawRect(playerX + 5, playerY + 20, 22, 10, dressColor)
    screen.DrawRect(playerX + 2, playerY + 29, 28, 11, dressColor)
    screen.DrawRect(playerX + 8, playerY + 40, 6, 12, &hF2C6A0FF)
    screen.DrawRect(playerX + 19, playerY + 40, 6, 12, &hF2C6A0FF)
    screen.DrawRect(playerX + 6, playerY + 50, 9, 5, &h5B315EFF)
    screen.DrawRect(playerX + 18, playerY + 50, 9, 5, &h5B315EFF)
end sub

sub LoadCharacterArtwork()
    m.heartSprite = CreateObject("roBitmap", "pkg:/images/stitch-heart.png")
    m.characterSprites = []
    atlas = CreateObject("roBitmap", "pkg:/images/characters-directions.png")
    if atlas = invalid then return
    ' Bounds are fitted to each illustration without changing the original atlas.
    bounds = [[125, 32, 262, 450], [554, 31, 243, 446], [1015, 30, 229, 454], [1410, 28, 224, 454], [116, 500, 270, 343], [547, 506, 248, 336], [921, 527, 351, 315], [1370, 526, 352, 316]]
    for each rect in bounds
        m.characterSprites.Push(CreateObject("roRegion", atlas, rect[0], rect[1], rect[2], rect[3]))
    end for
end sub

sub DrawCharacterSprite(screen, index, x, y, width, height)
    x = SceneX(x)
    sprite = m.characterSprites[index]
    scale = width / sprite.GetWidth()
    if height / sprite.GetHeight() < scale then scale = height / sprite.GetHeight()
    screen.DrawScaledObject(Int(x - sprite.GetWidth() * scale / 2), Int(y - sprite.GetHeight() * scale / 2), scale, scale, sprite)
end sub

function FacingForMovement(dx, dy, previousFacing)
    ' Atlas order: front/down, back/up, left, right. Keep the last view at rest.
    if dx = 0 and dy = 0 then return previousFacing
    if Abs(dx) >= Abs(dy)
        if dx < 0 then return 2
        return 3
    end if
    if dy < 0 then return 1
    return 0
end function

' Object-local choreography: keep the walking position so finishing or cancelling
' returns control without teleporting into another activity or the exit.
sub DrawTaskAnimation(screen, task, dressColor, labelFont)
    action = task.action
    frame = task.frame
    wave = Sin(frame * 0.09)
    bob = Int(wave * 4)
    if action = "twirl"
        DrawTwirl(screen, task, dressColor)
    else if action = "cow"
        DrawCowPetting(screen, task, dressColor)
    else if action = "stitch"
        DrawStitchPetting(screen, task, dressColor, labelFont)
    else if action = "treehang"
        ' Raised hands and bent knees are part of the pose, never stretched lines.
        pose = 4
        if wave > 0 then pose = 5
        DrawActivityPose(screen, pose, 210 + wave * 3, 398, 94)
    else if action = "water" or action = "deckflowers" or action = "birdbath"
        targetX = 250 : targetY = 328
        if action = "birdbath" then targetX = 480 : targetY = 311
        pose = 2
        if wave > 0 then pose = 3
        DrawActivityPose(screen, pose, targetX - 111, targetY + 28, 80)
        for drop = 0 to 13
            fall = ((frame * 3 + drop * 7) mod 48) / 48
            dx = targetX - 88 + fall * (25 + (drop mod 4) * 5)
            dy = targetY + 37 + fall * fall * 48
            screen.DrawRect(Int(dx), Int(dy), 3, 5, &h9DEBFFFF)
        end for
    else if action = "slide"
        phase = frame mod 100
        if phase < 40
            x = 323
            y = 387 - phase * 3.1
        else
            progress = (phase - 40) / 59
            x = 305 - progress * 130
            y = 263 + progress * 141
        end if
        DrawActivityPose(screen, 6, x, y, 73)
    else if action = "swing" or action = "fireswing1" or action = "fireswing2"
        pose = 6
        if wave > 0 then pose = 7
        if action = "swing"
            swing = SwingMotion(frame)
            DrawActivityPose(screen, pose, swing.x, swing.y - 15, 78)
        else
            x = 365 : y = 237
            if action = "fireswing2" then x = 795 : y = 243
            DrawActivityPose(screen, pose, x + wave * 4, y, 69)
        end if
    else if action = "smore"
        DrawSmoreMaking(screen, frame)
    else if action = "pick" or action = "sticks"
        x = 601 : y = 390
        if action = "sticks" then x = 385 : y = 490
        pose = 8
        if action = "pick" and wave > 0 then pose = 9
        DrawActivityPose(screen, pose, x, y, 63)
        if action = "sticks"
            DrawTaskStroke(screen, x + 16, y + 20, x + 44, y + 9, &hBE945DFF, 3)
        end if
    else if action = "windchimes"
        DrawActivityPose(screen, 10, 1069, 363, 78)
        for note = 0 to 2
            nx = 990 + note * 30 + bob
            ny = 280 - ((frame + note * 20) mod 65)
            screen.DrawRect(nx, ny, 8, 6, &hFFE06AFF)
            screen.DrawRect(nx + 6, ny - 16, 2, 20, &hFFE06AFF)
        end for
    else if action = "settable"
        DrawTableSetting(screen, frame)
    else if action = "lounger"
        DrawGenevieve(screen, 799, 453, dressColor, bob, 0)
    else if action = "clubhouse"
        ' Walk up into the doorway and peek out again.
        approach = Sin(frame * 0.02094)
        DrawGenevieve(screen, 990, 391 - Int(approach * 55), dressColor, bob, 1)
    else if action = "weed"
        pull = (Sin(frame * 0.10) + 1) / 2
        DrawActivityPose(screen, 8, 1076, 391, 63)
        DrawYardDetail(screen, 3, 1099, 406 - Int(pull * 10), 24, 29)
        for crumb = 0 to 3
            screen.DrawRect(1090 + crumb * 5, 418 + ((frame + crumb * 9) mod 17), 2, 3, &hAE8051FF)
        end for
    else if action = "ladybug" or action = "bushes"
        explorerX = 922
        if action = "bushes" then explorerX = 692
        DrawGenevieve(screen, explorerX + Int(wave * 14), 367, dressColor, bob, 3)
        if action = "ladybug"
            screen.DrawRect(990 + Int(wave * 14), 351 + bob, 12, 10, &hEF534FFF)
            screen.DrawRect(995 + Int(wave * 14), 352 + bob, 2, 8, &h302A30FF)
        else
            for leaf = 0 to 4
                screen.DrawRect(749 + leaf * 22 + bob, 360 - ((frame + leaf * 11) mod 40), 7, 4, &hA6CE6BFF)
            end for
        end if
    end if
end sub

sub DrawTaskStroke(screen, x1, y1, x2, y2, color, thickness)
    x1 = SceneX(x1)
    x2 = SceneX(x2)
    ' Small overlapping squares keep limbs and props smooth with the 2D API.
    steps = Int(Abs(x2 - x1) + Abs(y2 - y1))
    if steps < 1 then steps = 1
    for point = 0 to steps step 2
        ratio = point / steps
        screen.DrawRect(Int(x1 + (x2 - x1) * ratio), Int(y1 + (y2 - y1) * ratio), thickness, thickness, color)
    end for
end sub

sub DrawStitchPetting(screen, task, dressColor, labelFont)
    ' Stroke Stitch's head repeatedly while she nuzzles toward Genevieve's hand.
    stroke = Sin(task.frame * 0.14)
    nuzzle = Int(Sin(task.frame * 0.14) * 2)
    x = task.dogX
    y = task.dogY
    side = task.side
    facing = 2
    girlFacing = 3
    if side = 1
        facing = 3
        girlFacing = 2
    end if
    girlX = x + 24 + side * 55
    girlY = y - 1
    pose = 0
    if stroke > 0 then pose = 1
    if side = 1 then pose = pose + 12
    DrawActivityPose(screen, pose, girlX, girlY, 64)
    if m.characterSprites.Count() = 8
        DrawCharacterSprite(screen, 4 + facing, x + 24, y + 12 + nuzzle, 76, 58)
    else
        DrawStitch(screen, x, y + nuzzle, task.frame mod 20, labelFont, facing)
    end if
    ' Staggered hearts rise and disappear above Stitch instead of covering her.
    for heart = 0 to 2
        age = (task.frame + heart * 23) mod 72
        hx = x + 15 + heart * 15 + Int(Sin(age * 0.08) * 3)
        hy = y - 34 - Int(age * 0.6)
        DrawPetHeart(screen, hx, hy, 18)
    end for
end sub

sub DrawPetHeart(screen, x, y, size)
    x = SceneX(x)
    if m.heartSprite = invalid then return
    scale = size / m.heartSprite.GetWidth()
    screen.DrawScaledObject(Int(x - m.heartSprite.GetWidth() * scale / 2), Int(y - m.heartSprite.GetHeight() * scale / 2), scale, scale, m.heartSprite)
end sub

sub LoadPlanetArtwork()
    m.planetSprites = []
    atlas = CreateObject("roBitmap", "pkg:/images/planet-jewels.png")
    if atlas = invalid then return
    tileWidth = Int(atlas.GetWidth() / 2)
    tileHeight = Int(atlas.GetHeight() / 2)
    for row = 0 to 1
        for column = 0 to 1
            m.planetSprites.Push(CreateObject("roRegion", atlas, column * tileWidth, row * tileHeight, tileWidth, tileHeight))
        end for
    end for
end sub

function PlanetTreasureSpriteIndex(planet)
    if planet = "mars" then return 0
    if planet = "saturn" then return 1
    return 2
end function

sub DrawPlanetSprite(screen, index, x, y, width, height)
    x = SceneX(x)
    if m.planetSprites.Count() <= index or width < 1 or height < 1 then return
    sprite = m.planetSprites[index]
    scale = width / sprite.GetWidth()
    if height / sprite.GetHeight() < scale then scale = height / sprite.GetHeight()
    screen.DrawScaledObject(Int(x - sprite.GetWidth() * scale / 2), Int(y - sprite.GetHeight() * scale / 2), scale, scale, sprite)
end sub

sub DrawSpaceTreasure(screen, planet, item, frame, ground)
    if m.planetSprites.Count() < 4
        DrawFallbackSpaceTreasure(screen, planet, item, frame, ground)
        return
    end if
    phase = (frame + item.phase) mod 120
    wave = Sin(phase * 0.05236)
    bob = Int(wave * 5)
    x = item.x
    y = item.y + bob
    ' A rounded ground shadow makes the gentle hovering motion easy to see.
    for shadowRow = -3 to 3
        shadowWidth = Int(23 * Sqr(1 - (shadowRow * shadowRow) / 16))
        screen.DrawRect(x - shadowWidth, item.y + 25 + shadowRow, shadowWidth * 2, 1, &h101C3844)
    end for
    size = 58 + wave * 2
    DrawPlanetSprite(screen, PlanetTreasureSpriteIndex(planet), x, y, size, size)
    ' Illustrated glints pulse at different times without hiding the jewel.
    sparkleSize = 9 + Sin(phase * 0.10472) * 5
    DrawPlanetSprite(screen, 3, x + 24, y - 22, sparkleSize, sparkleSize)
    sparkleSize = 8 + Cos(phase * 0.10472) * 4
    DrawPlanetSprite(screen, 3, x - 24, y + 10, sparkleSize, sparkleSize)
end sub

sub LoadMommyArtwork()
    m.mommySprite = CreateObject("roBitmap", "pkg:/images/mommy.png")
end sub

function CreateMommy()
    return {state: "inside", countdownMs: 15000, stateMs: 0, announcementMs: 0, x: 1094, y: 340, nearby: false, gaveMission: false, missionIndex: 0, previousMission: -1}
end function

sub UpdateMommy(mommy, area, elapsedMs, playerCenterX, playerCenterY, taskActive)
    mommy.nearby = false
    ' Count yard time so a visit cannot be missed while exploring another area.
    if area <> "yard" or taskActive then return
    if mommy.announcementMs > 0 then mommy.announcementMs = mommy.announcementMs - elapsedMs
    if mommy.state = "inside"
        mommy.countdownMs = mommy.countdownMs - elapsedMs
        if mommy.countdownMs <= 0
            mommy.state = "walkingout"
            mommy.stateMs = 0
            mommy.gaveMission = false
            mommy.missionIndex = Rnd(9) - 1
            if mommy.missionIndex = mommy.previousMission then mommy.missionIndex = (mommy.missionIndex + 1) mod 9
            mommy.previousMission = mommy.missionIndex
        end if
    else if mommy.state = "walkingout" or mommy.state = "walkinghome"
        mommy.stateMs = mommy.stateMs + elapsedMs
        progress = mommy.stateMs / 3500
        if progress > 1 then progress = 1
        if mommy.state = "walkinghome" then progress = 1 - progress
        mommy.x = 1094 - 264 * progress
        mommy.y = 340 + 22 * progress
        if mommy.stateMs >= 3500
            if mommy.state = "walkingout"
                mommy.state = "ready"
                mommy.stateMs = 0
                mommy.announcementMs = 5000
            else
                mommy.state = "inside"
                mommy.countdownMs = 45000 + Rnd(30000)
                mommy.stateMs = 0
            end if
        end if
    else if mommy.state = "ready"
        mommy.nearby = not mommy.gaveMission and Abs(playerCenterX - mommy.x) < 72 and Abs(playerCenterY - mommy.y) < 75
        ' Give her time to talk when Genevieve reaches her.
        if not mommy.nearby then mommy.stateMs = mommy.stateMs + elapsedMs
        visitLength = 45000
        if mommy.gaveMission then visitLength = 8000
        if mommy.stateMs >= visitLength
            mommy.state = "walkinghome"
            mommy.stateMs = 0
            mommy.nearby = false
            mommy.announcementMs = 0
        end if
    end if
end sub

sub DrawMommy(screen, mommy, labelFont)
    if mommy.state = "inside" then return
    bob = 0
    if mommy.state = "walkingout" or mommy.state = "walkinghome" then bob = Int(Sin(mommy.stateMs * 0.014) * 3)
    if m.mommySprite <> invalid
        scale = 108 / m.mommySprite.GetHeight()
        screen.DrawScaledObject(Int(SceneX(mommy.x) - m.mommySprite.GetWidth() * scale / 2), Int(mommy.y - 54 + bob), scale, scale, m.mommySprite)
    end if
    CenterLabel(screen, "MOMMY", SceneX(mommy.x), mommy.y + 58, &h173E52FF, labelFont)
    if mommy.state = "ready" and not mommy.gaveMission
        DrawPlanetSprite(screen, 3, mommy.x, mommy.y - 67, 24, 24)
    end if
    if mommy.announcementMs > 0
        screen.DrawRect(675, 166, 380, 42, &h173E52F2)
        CenterLabel(screen, "Mommy has a mission for you!", 865, 176, &hFFFFFFFF, labelFont)
    end if
end sub

function GetMommyMission(index)
    result = {giver: "Mommy", title: "", steps: []}
    if index = 0
        result.title = "Mommy's Flower Helpers"
        result.steps = [MakeStep("garden", "water", "Water the garden flowers for Mommy!")]
    else if index = 1
        result.title = "Mommy's Puppy Cuddles"
        result.steps = [MakeStep("yard", "stitch", "Find Stitch and give her a loving pet!")]
    else if index = 2
        result.title = "Mommy's Patio Picnic"
        result.steps = [MakeStep("deck", "settable", "Set the patio table for our picnic!")]
    else if index = 3
        result.title = "Mommy's Bird Helpers"
        result.steps = [MakeStep("grove", "birdbath", "Fill the bird bath for our garden birds!")]
    else if index = 4
        result.title = "Mommy's Garden Basket"
        result.steps = [MakeStep("garden", "pick", "Pick fresh vegetables for Mommy!")]
    else if index = 5
        result.title = "Mommy's Deck Garden"
        result.steps = [MakeStep("deck", "deckflowers", "Give the deck flowers a nice drink!")]
    else if index = 6
        result.title = "Mommy's Weed Helpers"
        result.steps = [MakeStep("grove", "weed", "Pull weeds to help our garden grow!")]
    else if index = 7
        result.title = "Mommy's Twirling Star"
        result.steps = [MakeStep("yard", "twirl", "Show Mommy a twirl! Press Play/Pause in the yard.")]
    else
        result.title = "Mommy's Cow Friends"
        result.steps = [MakeStep("yard", "cow", "Pet a cow by the left trees for Mommy!")]
    end if
    return result
end function

sub LoadYardDetailArtwork()
    m.yardDetailSprites = []
    atlas = CreateObject("roBitmap", "pkg:/images/yard-details.png")
    if atlas = invalid then return
    ' Fit the full silhouettes: the wide weed bed extends beyond its atlas cell.
    bounds = [[0, 0, 256, 256], [256, 0, 256, 256], [0, 256, 317, 256], [321, 256, 191, 256]]
    for each rect in bounds
        m.yardDetailSprites.Push(CreateObject("roRegion", atlas, rect[0], rect[1], rect[2], rect[3]))
    end for
end sub

sub DrawYardDetail(screen, index, x, y, width, height)
    x = SceneX(x)
    if m.yardProjection = true
        width = width * 0.8
        height = height * 0.8
    end if
    if m.yardDetailSprites.Count() <= index then return
    sprite = m.yardDetailSprites[index]
    scale = width / sprite.GetWidth()
    if height / sprite.GetHeight() < scale then scale = height / sprite.GetHeight()
    screen.DrawScaledObject(Int(x - sprite.GetWidth() * scale / 2), Int(y - sprite.GetHeight() * scale / 2), scale, scale, sprite)
end sub

function CreateMissionPresentation()
    return {lastHudText: "", lastBannerText: "", wasCompleted: false, fireworksMs: 0}
end function

function SpeakMissionText(voice, words)
    if voice = invalid then return false
    if not voice.IsEnabled() then return false
    ' A changed instruction replaces stale speech rather than queuing behind it.
    voice.Flush()
    voice.Say(words)
    return true
end function

sub UpdateMissionPresentation(state, hud, bannerHeading, bannerBody, showBanner, completed, elapsedMs, voice)
    hudText = hud.heading + ". " + hud.body
    bannerText = ""
    if showBanner then bannerText = bannerHeading + ". " + bannerBody
    if hudText <> state.lastHudText
        if SpeakMissionText(voice, hudText)
            state.lastHudText = hudText
            ' The HUD already announces this change; do not repeat its banner.
            state.lastBannerText = bannerText
        end if
    else if showBanner and bannerText <> state.lastBannerText
        if SpeakMissionText(voice, bannerText) then state.lastBannerText = bannerText
    end if
    if not showBanner then state.lastBannerText = ""

    if completed and not state.wasCompleted
        state.fireworksMs = 3600
    else if not completed
        state.fireworksMs = 0
    else if state.fireworksMs > 0
        state.fireworksMs = state.fireworksMs - elapsedMs
        if state.fireworksMs < 0 then state.fireworksMs = 0
    end if
    state.wasCompleted = completed
end sub

sub DrawMissionFireworks(screen, state)
    if state.fireworksMs <= 0 then return
    projected = m.yardProjection
    m.yardProjection = false
    elapsed = 3600 - state.fireworksMs
    bursts = [[240, 265, 0], [1010, 270, 480], [625, 240, 980], [390, 350, 1560], [865, 345, 2110]]
    colors = [&hFF79B7FF, &hFFD86BFF, &h75E2FFFF, &hB9F589FF, &hC6ABFFFF]
    for burstIndex = 0 to bursts.Count() - 1
        burst = bursts[burstIndex]
        age = elapsed - burst[2]
        color = colors[burstIndex]
        if age >= 0 and age < 240
            rocketY = 590 - (590 - burst[1]) * age / 240
            screen.DrawRect(burst[0] - 1, Int(rocketY), 3, 10, &hFFF4C7FF)
            screen.DrawRect(burst[0], Int(rocketY) + 14, 2, 8, color)
        else if age >= 240 and age < 1490
            progress = (age - 240) / 1250
            radius = 12 + progress * 115
            gravity = progress * progress * 55
            tail = 5 + (1 - progress) * 12
            for particle = 0 to 15
                angle = particle * 0.392699 + burstIndex * 0.17
                px = burst[0] + Cos(angle) * radius
                py = burst[1] + Sin(angle) * radius + gravity
                tx = px - Cos(angle) * tail
                ty = py - Sin(angle) * tail
                ' Preserve the header, action banner, exit, and mission box.
                if py > 165 and py < 590
                    DrawTaskStroke(screen, tx, ty, px, py, color, 2)
                    screen.DrawRect(Int(px), Int(py), 3, 3, &hFFF6DEFF)
                    if particle mod 4 = 0
                        starSize = 5 + (1 - progress) * 7
                        DrawPlanetSprite(screen, 3, px, py, starSize, starSize)
                    end if
                end if
            end for
        end if
    end for
    m.yardProjection = projected
end sub

sub LoadCowArtwork()
    m.cowHead = CreateObject("roBitmap", "pkg:/images/cow-head.png")
end sub

function CreateCows()
    herd = []
    heights = [190, 375, 545]
    delays = [1000, 9000, 17000]
    for index = 0 to 2
        herd.Push({x: 12, y: heights[index], state: "inside", stateMs: 0, waitMs: delays[index], nextVisitMs: 60000, barnProgress: 0, peek: 0, happyMs: 0, retreatMs: 0})
    end for
    return herd
end function

function UpdateCows(cows, area, elapsedMs, playerCenterX, playerCenterY, task)
    if area <> "yard" then return -1
    nearby = -1
    for index = 0 to cows.Count() - 1
        cow = cows[index]
        petting = false
        if task <> invalid
            if task.action = "cow" then petting = task.cowIndex = index
        end if
        closeBy = cow.peek >= 0.85 and Abs(playerCenterX - cow.x) < 78 and Abs(playerCenterY - cow.y) < 68
        if cow.happyMs > 0 then cow.happyMs = cow.happyMs - elapsedMs
        if petting
            cow.state = "peeking"
            cow.stateMs = 5000
            cow.peek = 1
        else if cow.state = "inside"
            cow.peek = 0
            cow.waitMs = cow.waitMs - elapsedMs
            if cow.waitMs <= 0
                cow.state = "walkingout"
                cow.stateMs = 0
                cow.barnProgress = 0
            end if
        else if cow.state = "walkingout"
            cow.stateMs = cow.stateMs + elapsedMs
            cow.barnProgress = cow.stateMs / 3500
            if cow.barnProgress >= 1
                cow.barnProgress = 1
                cow.state = "peeking"
                cow.stateMs = 0
            end if
        else if cow.state = "peeking"
            if not closeBy or cow.stateMs < 1400 then cow.stateMs = cow.stateMs + elapsedMs
            progress = cow.stateMs / 1400
            if progress > 1 then progress = 1
            cow.peek = progress * progress * (3 - 2 * progress)
            if cow.stateMs >= 121400
                cow.state = "withdrawing"
                cow.retreatMs = 1400
                cow.nextVisitMs = 60000
            end if
        else if cow.state = "withdrawing"
            cow.retreatMs = cow.retreatMs - elapsedMs
            progress = cow.retreatMs / 1400
            if progress < 0 then progress = 0
            cow.peek = progress * progress * (3 - 2 * progress)
            if cow.retreatMs <= 0
                cow.retreatMs = 0
                cow.peek = 0
                cow.state = "walkinghome"
                cow.stateMs = 0
                cow.barnProgress = 1
            end if
        else if cow.state = "walkinghome"
            cow.stateMs = cow.stateMs + elapsedMs
            cow.barnProgress = 1 - cow.stateMs / 3500
            if cow.barnProgress <= 0
                cow.barnProgress = 0
                cow.state = "inside"
                cow.waitMs = cow.nextVisitMs
            end if
        end if
        cow.x = 12 + 96 * cow.peek
        if cow.state = "peeking" and cow.peek >= 0.85 and Abs(playerCenterX - cow.x) < 78 and Abs(playerCenterY - cow.y) < 68 then nearby = index
    end for
    return nearby
end function

sub DrawCows(screen, cows)
    ' Full bodies stay on the pasture side, underneath the tree canopy.
    m.cowPastureCanvas.Clear(&h00000000)
    for each cow in cows
        if cow.state = "walkingout" or cow.state = "walkinghome"
            progress = cow.barnProgress
            if progress > 0.08
                ' Leave through the ground-floor doorway before following the trees.
                if progress < 0.55
                    pathProgress = progress / 0.55
                    x = 151 + (306 - 151) * pathProgress
                    y = 400 + 40 * pathProgress
                else
                    x = 306
                    y = 440 + (cow.y - 440) * ((progress - 0.55) / 0.45)
                end if
                bob = Int(Sin(cow.stateMs * 0.018) * 2)
                facingSprite = 1
                if cow.state = "walkinghome" then facingSprite = 4
                DrawFarmSprite(m.cowPastureCanvas, facingSprite, x, y + bob, 83, 76)
            end if
        end if
    end for
    m.cowPastureCanvas.Finish()
    DrawFarmSprite(screen, 0, 137, 327, 235, 220)
    screen.DrawScaledObject(0, 0, 1, 1, m.cowPastureCanvas)
    if m.cowHead <> invalid
        for each cow in cows
            if cow.peek > 0
                bob = Int(Sin(cow.stateMs * 0.007) * 2)
                scale = 86 / m.cowHead.GetHeight()
                screen.DrawScaledObject(Int(SceneX(cow.x) - m.cowHead.GetWidth() * scale / 2), Int(cow.y - 43 + bob), scale, scale, m.cowHead)
                if cow.happyMs > 0 then DrawPetHeart(screen, cow.x + 25, cow.y - 55, 23)
            end if
        end for
    end if
    DrawPastureTrees(screen)
end sub

sub PlayCowMoo(sound)
    if sound <> invalid
        channel = 0
        if sound.MaxSimulStreams() > 1 then channel = 1
        sound.Trigger(85, channel)
    end if
end sub

sub DrawCowPetting(screen, task, dressColor)
    cow = task.cow
    stroke = Sin(task.frame * 0.14)
    pose = 12
    if stroke > 0 then pose = 13
    DrawActivityPose(screen, pose, 164, cow.y + 8, 64)
    for heart = 0 to 2
        age = (task.frame + heart * 23) mod 72
        DrawPetHeart(screen, cow.x + 15 + heart * 15, cow.y - 44 - age * 0.6, 18)
    end for
end sub

sub DrawTwirl(screen, task, dressColor)
    poses = [0, 2, 1, 3]
    facing = poses[Int(task.frame / 8) mod 4]
    bob = -Int(Abs(Sin(task.frame * 0.10)) * 5)
    screen.DrawRect(SceneX(task.x + 16) - 13, task.y + 53, 26, 3, &h173E5233)
    DrawGenevieve(screen, task.x, task.y, dressColor, bob, facing)
    for glint = 0 to 2
        angle = task.frame * 0.17 + glint * 2.0944
        DrawPlanetSprite(screen, 3, task.x + 16 + Cos(angle) * 33, task.y + 20 + Sin(angle) * 16, 10, 10)
    end for
end sub

sub FinishCowPet(cow)
    cow.state = "withdrawing"
    cow.happyMs = 1600
    cow.retreatMs = 1400
    cow.nextVisitMs = 60000
end sub

' Logical yard positions and hit regions are preserved; the new pasture occupies
' the left 250 screen pixels, and the whole yard is laid out to their right.
function SceneX(x)
    if m.yardProjection = true then return Int(250 + x * 0.8)
    return x
end function

sub LoadFarmArtwork()
    m.farmSprites = []
    atlas = CreateObject("roBitmap", "pkg:/images/barn-pasture.png")
    if atlas <> invalid
        bounds = [[11, 20, 245, 225], [262, 47, 240, 203], [22, 256, 218, 243], [276, 305, 224, 179]]
        for each rect in bounds
            m.farmSprites.Push(CreateObject("roRegion", atlas, rect[0], rect[1], rect[2], rect[3]))
        end for
        ' Build a mirrored walking pose once, using portable 2D drawing calls.
        cowBounds = bounds[1]
        leftCow = CreateObject("roBitmap", {width: cowBounds[2], height: cowBounds[3], alphaEnable: true})
        leftCow.Clear(&h00000000)
        for column = 0 to cowBounds[2] - 1
            strip = CreateObject("roRegion", atlas, cowBounds[0] + column, cowBounds[1], 1, cowBounds[3])
            leftCow.DrawObject(cowBounds[2] - 1 - column, 0, strip)
        end for
        leftCow.Finish()
        m.farmSprites.Push(leftCow)
    end if
    m.cowPastureCanvas = CreateObject("roBitmap", {width: 322, height: 720, alphaEnable: true})
end sub

sub DrawFarmSprite(screen, index, x, y, width, height)
    if m.farmSprites.Count() <= index then return
    sprite = m.farmSprites[index]
    scale = width / sprite.GetWidth()
    if height / sprite.GetHeight() < scale then scale = height / sprite.GetHeight()
    screen.DrawScaledObject(Int(x - sprite.GetWidth() * scale / 2), Int(y - sprite.GetHeight() * scale / 2), scale, scale, sprite)
end sub

sub DrawPasture(screen, labelFont)
    screen.DrawRect(12, 78, 250, 593, &h93B96AFF)
    for tuft = 0 to 28
        x = 27 + ((tuft * 61) mod 216)
        y = 133 + ((tuft * 97) mod 514)
        screen.DrawRect(x, y, 2, 7, &h6F9952AA)
        screen.DrawRect(x + 4, y + 3, 2, 4, &h6F9952AA)
    end for
    CenterLabel(screen, "COW PASTURE", 137, 96, &h173E52FF, labelFont)
end sub

sub DrawPastureTrees(screen)
    for treeY = 139 to 631 step 82
        DrawFarmSprite(screen, 2, 294, treeY, 108, 180)
    end for
end sub
