sub LoadCraftPoses()
    atlas = CreateObject("roBitmap", "pkg:/images/table-smores-poses.png")
    if atlas = invalid then return
    m.craftAnchors = [63.0, 96.0, 57.5, 73.5, 76.0, 76.5]
    bounds = [[82, 6, 126, 279], [284, 9, 162, 276], [567, 6, 122, 279], [62, 285, 189, 210], [301, 285, 194, 210], [553, 285, 152, 211]]
    for each rect in bounds
        m.activityPoses.Push(CreateObject("roRegion", atlas, rect[0], rect[1], rect[2], rect[3]))
    end for
end sub

sub DrawCraftPose(screen, index, x, bottom, height)
    if m.activityPoses.Count() <= index then return
    sprite = m.activityPoses[index]
    scale = height / sprite.GetHeight()
    anchor = m.craftAnchors[index - 14]
    screen.DrawScaledObject(Int(SceneX(x) - anchor * scale), Int(bottom - height), scale, scale, sprite)
end sub
