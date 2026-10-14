sub LoadActivityPoses()
    m.activityPoses = []
    atlas = CreateObject("roBitmap", "pkg:/images/activity-poses.png")
    m.swingFrame = CreateObject("roBitmap", "pkg:/images/swing-frame.png")
    if atlas = invalid then return
    bounds = [[39,16,199,228],[304,15,192,231],[586,3,167,253],[829,5,158,251],[71,261,143,241],[323,263,145,238],[566,256,143,256],[823,256,144,256],[44,523,176,219],[309,522,170,222],[568,512,159,249],[833,512,155,250]]
    for each rect in bounds
        m.activityPoses.Push(CreateObject("roRegion", atlas, rect[0], rect[1], rect[2], rect[3]))
    end for
    ' Mirrored petting poses keep short bent arms facing the animal on either side.
    for poseIndex = 0 to 1
        sprite = m.activityPoses[poseIndex]
        mirrored = CreateObject("roBitmap", {width: sprite.GetWidth(), height: sprite.GetHeight(), alphaEnable: true})
        mirrored.SetAlphaEnable(true)
        mirrored.Clear(&h00000000)
        rect = bounds[poseIndex]
        for column = 0 to rect[2] - 1
            strip = CreateObject("roRegion", atlas, rect[0] + column, rect[1], 1, rect[3])
            mirrored.DrawObject(rect[2] - column - 1, 0, strip)
        end for
        mirrored.Finish()
        m.activityPoses.Push(CreateObject("roRegion", mirrored, 0, 0, rect[2], rect[3]))
    end for
end sub

sub DrawActivityPose(screen, index, x, y, height)
    if m.activityPoses.Count() <= index then return
    sprite = m.activityPoses[index]
    scale = height / sprite.GetHeight()
    screen.DrawScaledObject(Int(SceneX(x) - sprite.GetWidth() * scale / 2), Int(y - height / 2), scale, scale, sprite)
end sub

function SwingMotion(frame)
    angle = Sin(frame * 0.055) * 0.12
    return {x: 648 + Sin(angle) * 128, y: 245 + Cos(angle) * 128, angle: angle}
end function

sub DrawPlaysetSwing(screen, frame)
    swing = SwingMotion(frame)
    if m.swingFrame <> invalid
        scale = 260 / m.swingFrame.GetWidth()
        screen.DrawScaledObject(510, 224, scale, scale, m.swingFrame)
    end if
    ' One pair of ropes and one seat; all share the same pendulum position.
    DrawTaskStroke(screen, 626, 252, swing.x - 22, swing.y + 7, &hC8AF77FF, 2)
    DrawTaskStroke(screen, 670, 257, swing.x + 22, swing.y + 12, &hC8AF77FF, 2)
    DrawTaskStroke(screen, swing.x - 27, swing.y + 7, swing.x + 27, swing.y + 12, &h357A68FF, 6)
end sub
