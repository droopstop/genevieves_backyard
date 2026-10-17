sub LoadBubbleArtwork()
    m.bubbleSprites = []
    m.bubbleFrame = 0
    atlas = CreateObject("roBitmap", "pkg:/images/bubble-activity.png")
    if atlas = invalid then return
    ' Bottle and two full-body wand poses are kept in separate transparent regions.
    bounds = [[0, 0, 700, 756], [700, 0, 630, 756], [1330, 0, 749, 756]]
    for each rect in bounds
        m.bubbleSprites.Push(CreateObject("roRegion", atlas, rect[0], rect[1], rect[2], rect[3]))
    end for
end sub

sub DrawBubbleSprite(screen, index, x, bottomY, height)
    if m.bubbleSprites.Count() <= index then return
    sprite = m.bubbleSprites[index]
    scale = height / sprite.GetHeight()
    screen.DrawScaledObject(Int(SceneX(x) - sprite.GetWidth() * scale / 2), Int(bottomY - height), scale, scale, sprite)
end sub

sub DrawBubbleBottle(screen, frame)
    bob = Int(Sin(frame * 0.055) * 2)
    DrawBubbleSprite(screen, 0, 575, 500 + bob, 92)
end sub

sub DrawBubbleRing(screen, x, y, radius, colorIndex)
    x = SceneX(x)
    outerColor = &h9DEBFFCC
    innerColor = &hF6C7FFAA
    if colorIndex = 1
        outerColor = &hFFD1EBCC
        innerColor = &hA9F3DCAA
    else if colorIndex = 2
        outerColor = &hD8CBFFCC
        innerColor = &hFFF2A8AA
    end if
    for point = 0 to 23
        angle = point * 0.2617994
        px = Int(x + Cos(angle) * radius)
        py = Int(y + Sin(angle) * radius)
        screen.DrawRect(px, py, 4, 4, outerColor)
        if point mod 2 = 0
            screen.DrawRect(Int(x + Cos(angle) * (radius - 3)), Int(y + Sin(angle) * (radius - 3)), 2, 2, innerColor)
        end if
    end for
    screen.DrawRect(Int(x - radius * 0.45), Int(y - radius * 0.55), 5, 3, &hFFFFFFFF)
    screen.DrawRect(Int(x - radius * 0.58), Int(y - radius * 0.34), 3, 5, &hFFFFFFFF)
end sub

sub DrawBubblePop(screen, x, y, age, colorIndex)
    x = SceneX(x)
    color = &hD8CBFFFF
    if colorIndex = 1 then color = &h9DEBFFFF
    if colorIndex = 2 then color = &hFFD1EBFF
    distance = 8 + age * 2
    for ray = 0 to 7
        angle = ray * 0.7853982
        px = Int(x + Cos(angle) * distance)
        py = Int(y + Sin(angle) * distance)
        screen.DrawRect(px, py, 5, 5, color)
    end for
end sub

sub DrawBigBubbles(screen, frame)
    for bubble = 0 to 8
        age = frame - 44 - bubble * 16
        if age >= 0
            age = age mod 150
            drift = Sin(age * 0.052 + bubble * 0.83) * (28 + (bubble mod 3) * 9)
            x = 650 + bubble * 16 + drift
            y = 410 - age * 1.65 - (bubble mod 3) * 8
            if age < 122
                radius = 10 + age * 0.28 + (bubble mod 3) * 4
                DrawBubbleRing(screen, x, y, radius, bubble mod 3)
            else if age < 136
                DrawBubblePop(screen, x, y, age - 122, bubble mod 3)
            end if
        end if
    end for
end sub

sub DrawBubbleActivity(screen, task, dressColor)
    if task.frame < 30
        progress = task.frame / 30
        x = task.x + (560 - task.x) * progress
        y = task.y + (445 - task.y) * progress
        facing = FacingForMovement(560 - task.x, 445 - task.y, task.facing)
        DrawGenevieve(screen, x, y, dressColor, Int(Sin(task.frame * 0.45) * 2), facing)
    else if task.frame >= 300
        progress = (task.frame - 300) / 30
        x = 560 + (task.x - 560) * progress
        y = 445 + (task.y - 445) * progress
        facing = FacingForMovement(task.x - 560, task.y - 445, task.facing)
        DrawGenevieve(screen, x, y, dressColor, Int(Sin(task.frame * 0.45) * 2), facing)
    else
        cycle = (task.frame - 30) mod 72
        pose = 1
        if cycle >= 46 then pose = 2
        poseBob = Int(Sin(task.frame * 0.10) * 2)
        DrawBubbleSprite(screen, pose, 600, 520 + poseBob, 154)
        DrawBigBubbles(screen, task.frame)
    end if
end sub
