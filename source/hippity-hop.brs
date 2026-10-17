sub LoadHippityHopArtwork()
    m.hippityHopSprites = []
    atlas = CreateObject("roBitmap", "pkg:/images/hippity-hop.png")
    if atlas = invalid then return
    bounds = [[240, 350, 440, 527], [1030, 10, 620, 877]]
    for each rect in bounds
        m.hippityHopSprites.Push(CreateObject("roRegion", atlas, rect[0], rect[1], rect[2], rect[3]))
    end for
    m.hippityHopRiders = []
    riders = CreateObject("roBitmap", "pkg:/images/hippity-hop-directions.png")
    if riders = invalid then return
    for direction = 0 to 3
        m.hippityHopRiders.Push(CreateObject("roRegion", riders, direction * 543, 0, 543, 724))
    end for
end sub

' A complete lap begins and ends at the toy. Each hop lands before the next.
function HippityHopMotion(frame)
    progress = (frame - 30) / 360
    if progress < 0 then progress = 0
    if progress > 1 then progress = 1
    angle = progress * 6.2831853
    hopPhase = ((frame - 30) mod 30) / 30
    if frame < 30 or frame >= 390 then hopPhase = 0
    lift = Sin(hopPhase * 3.14159265) * 32
    squash = 1
    if hopPhase < 0.15 then squash = 0.88 + hopPhase * 0.8
    if hopPhase > 0.85 then squash = 0.88 + (1 - hopPhase) * 0.8
    facing = FacingForMovement(Cos(angle) * 160, -Sin(angle) * 100, 3)
    return {x: 750 + Sin(angle) * 200, groundY: 410 + Cos(angle) * 100, lift: lift, squash: squash, facing: facing}
end function

sub DrawHippityHopSprite(screen, riding, x, bottomY, height, squash, facing = 0)
    index = 0
    if riding then index = 1
    if m.hippityHopSprites.Count() <= index then return
    sprite = m.hippityHopSprites[index]
    if riding and m.hippityHopRiders.Count() = 4 then sprite = m.hippityHopRiders[facing]
    scale = height / sprite.GetHeight()
    scaleX = scale * (2 - squash)
    scaleY = scale * squash
    screen.DrawScaledObject(Int(SceneX(x) - sprite.GetWidth() * scaleX / 2), Int(bottomY - height * squash), scaleX, scaleY, sprite)
end sub

sub DrawHippityHopRide(screen, task, dressColor)
    if task.frame < 30
        progress = task.frame / 30
        x = task.x + (734 - task.x) * progress
        y = task.y + (449 - task.y) * progress
        DrawGenevieve(screen, x, y, dressColor, Int(Sin(task.frame * 0.45) * 2), FacingForMovement(734 - task.x, 449 - task.y, task.facing))
    else if task.frame >= 390
        progress = (task.frame - 390) / 30
        x = 734 + (task.x - 734) * progress
        y = 449 + (task.y - 449) * progress
        DrawGenevieve(screen, x, y, dressColor, Int(Sin(task.frame * 0.45) * 2), FacingForMovement(task.x - 734, task.y - 449, task.facing))
    else
        motion = HippityHopMotion(task.frame)
        shadowWidth = Int(34 - motion.lift * 0.35)
        screen.DrawRect(SceneX(motion.x) - shadowWidth / 2, Int(motion.groundY - 2), shadowWidth, 4, &h173E5233)
        DrawHippityHopSprite(screen, true, motion.x, motion.groundY - motion.lift, 100, motion.squash, motion.facing)
    end if
end sub
