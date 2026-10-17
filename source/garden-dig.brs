sub LoadGardenDigArtwork()
    m.gardenDigProps = []
    props = CreateObject("roBitmap", "pkg:/images/garden-dig-props.png")
    if props <> invalid
        propBounds = [[50, 0, 520, 793], [540, 200, 600, 570], [1120, 300, 850, 480]]
        for each rect in propBounds
            m.gardenDigProps.Push(CreateObject("roRegion", props, rect[0], rect[1], rect[2], rect[3]))
        end for
    end if

    m.gardenDigPoses = []
    poses = CreateObject("roBitmap", "pkg:/images/garden-dig-poses.png")
    if poses <> invalid
        poseBounds = [[0, 0, 560, 727], [560, 0, 500, 727], [1060, 0, 530, 727], [1590, 0, 573, 727]]
        for each rect in poseBounds
            m.gardenDigPoses.Push(CreateObject("roRegion", poses, rect[0], rect[1], rect[2], rect[3]))
        end for
    end if
end sub

sub DrawGardenDigSprite(screen, sprites, index, x, bottomY, width, height)
    if sprites.Count() <= index then return
    sprite = sprites[index]
    scale = width / sprite.GetWidth()
    if height / sprite.GetHeight() < scale then scale = height / sprite.GetHeight()
    screen.DrawScaledObject(Int(x - sprite.GetWidth() * scale / 2), Int(bottomY - sprite.GetHeight() * scale), scale, scale, sprite)
end sub

sub DrawFilledBucketDirt(screen)
    screen.DrawRect(1065, 525, 50, 8, &h70402AFF)
    screen.DrawRect(1071, 520, 13, 8, &h8B5332FF)
    screen.DrawRect(1085, 517, 16, 11, &h8B5332FF)
    screen.DrawRect(1103, 521, 10, 7, &h9A6038FF)
end sub

sub DrawGardenDigStation(screen, task, completedActions, labelFont)
    showShovel = true
    showBucket = true
    if task <> invalid
        if task.action = "dig"
            if task.frame >= 30 and task.frame < 435 then showShovel = false
            if task.frame >= 145 and task.frame < 330
                cycle = (task.frame - 145) mod 60
                if cycle >= 39 then showBucket = false
            end if
        end if
    end if

    if showShovel then DrawGardenDigSprite(screen, m.gardenDigProps, 0, 305, 610, 95, 120)
    DrawGardenDigSprite(screen, m.gardenDigProps, 2, 920, 608, 190, 85)
    if showBucket
        DrawGardenDigSprite(screen, m.gardenDigProps, 1, 1090, 600, 90, 90)
        if completedActions.DoesExist("grove:dig") then DrawFilledBucketDirt(screen)
    end if
    CenterLabel(screen, "DIG & FILL THE BUCKET", 445, 558, &hFFF0C2FF, labelFont)
    DrawDone(screen, completedActions, "grove:dig", 399, 586, labelFont)
end sub

sub DrawFlyingDirt(screen, frame, phase)
    for crumb = 0 to 7
        progress = ((frame * 3 + crumb * 9) mod 54) / 54
        x = 925 + progress * 120
        y = 530 - Sin(progress * 3.14159265) * (36 + crumb mod 3 * 5)
        if phase = 2 then x = 1010 + progress * 70
        screen.DrawRect(Int(x), Int(y), 5 + crumb mod 3, 4 + crumb mod 2, &h8B5332FF)
    end for
end sub

sub DrawGardenDigActivity(screen, task, dressColor)
    frame = task.frame
    toolX = 285
    toolY = 545
    patchX = 915
    poseBottom = 600

    if frame < 30
        progress = frame / 30
        x = task.x + (toolX - task.x) * progress
        y = task.y + (toolY - task.y) * progress
        DrawGenevieve(screen, x, y, dressColor, Int(Sin(frame * 0.45) * 2), FacingForMovement(toolX - task.x, toolY - task.y, task.facing))
    else if frame < 65
        DrawGardenDigSprite(screen, m.gardenDigPoses, 0, toolX + 22, poseBottom, 115, 118)
    else if frame < 145
        progress = (frame - 65) / 80
        x = toolX + (patchX - toolX) * progress
        bob = Int(Sin(frame * 0.42) * 3)
        DrawGardenDigSprite(screen, m.gardenDigPoses, 0, x, poseBottom + bob, 115, 118)
    else if frame < 330
        cycle = (frame - 145) mod 60
        if cycle < 19
            DrawGardenDigSprite(screen, m.gardenDigPoses, 1, patchX, poseBottom, 120, 126)
        else if cycle < 39
            DrawGardenDigSprite(screen, m.gardenDigPoses, 2, patchX + 15, poseBottom, 124, 128)
            DrawFlyingDirt(screen, frame, 1)
        else
            DrawGardenDigSprite(screen, m.gardenDigPoses, 3, 1015, poseBottom, 132, 130)
            DrawFlyingDirt(screen, frame, 2)
        end if
    else if frame < 410
        progress = (frame - 330) / 80
        x = patchX + (toolX - patchX) * progress
        bob = Int(Sin(frame * 0.42) * 3)
        DrawGardenDigSprite(screen, m.gardenDigPoses, 0, x, poseBottom + bob, 115, 118)
    else if frame < 435
        DrawGardenDigSprite(screen, m.gardenDigPoses, 0, toolX + 22, poseBottom, 115, 118)
    else
        progress = (frame - 435) / 35
        x = toolX + (task.x - toolX) * progress
        y = toolY + (task.y - toolY) * progress
        DrawGenevieve(screen, x, y, dressColor, Int(Sin(frame * 0.45) * 2), FacingForMovement(task.x - toolX, task.y - toolY, task.facing))
    end if
end sub
