sub InitializeIndoorPreviewSprites()
    m.houseBackdrop = PreviewBitmap("images/house-interior-wall-stairs.jpg", 1280, 720, invalid)
    m.popsSprite = PreviewBitmap("images/pops-recliner.png", 655, 700, invalid)
    m.houseStairs = PreviewBitmap("images/house-stairs.png", 520, 750, invalid)
    m.upstairsActivitySprites = []
    m.indoorWorld = {}
    m.indoorResultSprites = []
    m.indoorOutfitIndex = 0
    m.livingRoomPony = CreateLivingRoomPony()
    m.livingRoomPonySprites = [] : m.livingRoomPonyRiders = []
    for each rect in LivingRoomPonyBounds(false)
        m.livingRoomPonySprites.Push(PreviewBitmap("images/living-room-pony.png", rect[2], rect[3], rect))
    end for
    for each rect in LivingRoomPonyBounds(true)
        m.livingRoomPonyRiders.Push(PreviewBitmap("images/living-room-pony-riders.png", rect[2], rect[3], rect))
    end for
    m.indoorExitDoor = PreviewBitmap("images/indoor-exit-door.png", 176, 352, invalid)
    m.indoorTreeOn = PreviewBitmap("images/indoor-tree-lit.jpg", 388, 390, invalid)
    m.indoorPuzzleDone = PreviewBitmap("images/indoor-puzzle-done.jpg", 200, 95, invalid)
    for row = 0 to 2
        for col = 0 to 3
            m.indoorResultSprites.Push(PreviewBitmap("images/indoor-results.png", 128, 128, [col * 128, row * 128, 128, 128]))
        end for
    end for
    m.indoorSeatSprites = []
    for col = 0 to 3
        m.indoorSeatSprites.Push(PreviewBitmap("images/wardrobe-sit-0.png", 128, 192, [col * 128, 0, 128, 192]))
    end for
    m.upstairsBackdrops = {}
    m.upstairsBackdrops["upstairs"] = PreviewBitmap("images/upstairs-hall.jpg", 1280, 720, invalid)
    m.upstairsDoorFont = {size: 12, GetOneLineWidth: TestWidth}
    m.upstairsBackdrops["bedroom"] = PreviewBitmap("images/upstairs-bedroom.jpg", 1280, 720, invalid)
    m.upstairsBackdrops["playroom"] = PreviewBitmap("images/upstairs-playroom.jpg", 1280, 720, invalid)
    m.upstairsBackdrops["bonusroom"] = PreviewBitmap("images/upstairs-bonusroom-ready.jpg", 1280, 720, invalid)
    m.upstairsBackdrops["parentsroom"] = PreviewBitmap("images/upstairs-parentsroom.jpg", 1280, 720, invalid)
    m.heartSprite = PreviewBitmap("images/stitch-heart.png", 128, 128, invalid)
    m.characterSprites = []
    m.characterSprites.Push(PreviewBitmap("images/characters-directions.png", 262, 450, [125, 32, 262, 450]))
    m.characterSprites.Push(PreviewBitmap("images/characters-directions.png", 243, 446, [554, 31, 243, 446]))
    m.characterSprites.Push(PreviewBitmap("images/characters-directions.png", 229, 454, [1015, 30, 229, 454]))
    m.characterSprites.Push(PreviewBitmap("images/characters-directions.png", 224, 454, [1410, 28, 224, 454]))
    m.characterSprites.Push(PreviewBitmap("images/characters-directions.png", 270, 343, [116, 500, 270, 343]))
    m.characterSprites.Push(PreviewBitmap("images/characters-directions.png", 248, 336, [547, 506, 248, 336]))
    m.characterSprites.Push(PreviewBitmap("images/characters-directions.png", 351, 315, [921, 527, 351, 315]))
    m.characterSprites.Push(PreviewBitmap("images/characters-directions.png", 352, 316, [1370, 526, 352, 316]))
    m.activityPoses = []
    m.activityPoses.Push(PreviewBitmap("images/activity-poses.png", 199, 228, [39, 16, 199, 228]))
    m.activityPoses.Push(PreviewBitmap("images/activity-poses.png", 192, 231, [304, 15, 192, 231]))
    m.activityPoses.Push(PreviewBitmap("images/activity-poses.png", 167, 253, [586, 3, 167, 253]))
    m.activityPoses.Push(PreviewBitmap("images/activity-poses.png", 158, 251, [829, 5, 158, 251]))
    m.activityPoses.Push(PreviewBitmap("images/activity-poses.png", 143, 241, [71, 261, 143, 241]))
    m.activityPoses.Push(PreviewBitmap("images/activity-poses.png", 145, 238, [323, 263, 145, 238]))
    m.activityPoses.Push(PreviewBitmap("images/activity-poses.png", 143, 256, [566, 256, 143, 256]))
    m.activityPoses.Push(PreviewBitmap("images/activity-poses.png", 144, 256, [823, 256, 144, 256]))
    m.activityPoses.Push(PreviewBitmap("images/activity-poses.png", 176, 219, [44, 523, 176, 219]))
    m.activityPoses.Push(PreviewBitmap("images/activity-poses.png", 170, 222, [309, 522, 170, 222]))
    m.activityPoses.Push(PreviewBitmap("images/activity-poses.png", 159, 249, [568, 512, 159, 249]))
    m.activityPoses.Push(PreviewBitmap("images/activity-poses.png", 155, 250, [833, 512, 155, 250]))
    m.planetSprites = []
    m.planetSprites.Push(PreviewBitmap("images/planet-jewels.png", 128, 128, [0, 0, 128, 128]))
    m.planetSprites.Push(PreviewBitmap("images/planet-jewels.png", 128, 128, [128, 0, 128, 128]))
    m.planetSprites.Push(PreviewBitmap("images/planet-jewels.png", 128, 128, [0, 128, 128, 128]))
    m.planetSprites.Push(PreviewBitmap("images/planet-jewels.png", 128, 128, [128, 128, 128, 128]))
end sub

sub PreviewRoomActivitySprites(area)
    m.upstairsActivitySprites = []
    m.indoorBedForeground = invalid
    m.indoorDrawingSteps = invalid
    if area = "bedroom" then m.indoorBedForeground = PreviewBitmap("images/upstairs-bedroom.jpg", 315, 125, [0, 380, 315, 125])
    if area = "parentsroom" then m.indoorBedForeground = PreviewBitmap("images/upstairs-parentsroom.jpg", 390, 150, [0, 385, 390, 150])
    if area = "playroom" then m.indoorDrawingSteps = PreviewBitmap("images/indoor-drawing-steps.png", 192, 185, invalid)
    if area = "bedroom"
        m.upstairsActivitySprites.Push(PreviewBitmap("images/indoor-activity-bedroom.png", 244, 244, [6, 6, 244, 244]))
        m.upstairsActivitySprites.Push(PreviewBitmap("images/indoor-activity-bedroom.png", 244, 244, [262, 6, 244, 244]))
        m.upstairsActivitySprites.Push(PreviewBitmap("images/indoor-activity-bedroom.png", 244, 244, [518, 6, 244, 244]))
        m.upstairsActivitySprites.Push(PreviewBitmap("images/indoor-activity-bedroom.png", 244, 244, [774, 6, 244, 244]))
        m.upstairsActivitySprites.Push(PreviewBitmap("images/indoor-activity-bedroom.png", 244, 244, [6, 262, 244, 244]))
        m.upstairsActivitySprites.Push(PreviewBitmap("images/indoor-activity-bedroom.png", 244, 244, [262, 262, 244, 244]))
        m.upstairsActivitySprites.Push(PreviewBitmap("images/indoor-activity-bedroom.png", 244, 244, [518, 262, 244, 244]))
        m.upstairsActivitySprites.Push(PreviewBitmap("images/indoor-activity-bedroom.png", 244, 244, [774, 262, 244, 244]))
        m.upstairsActivitySprites.Push(PreviewBitmap("images/indoor-activity-bedroom.png", 244, 244, [6, 518, 244, 244]))
        m.upstairsActivitySprites.Push(PreviewBitmap("images/indoor-activity-bedroom.png", 244, 244, [262, 518, 244, 244]))
        m.upstairsActivitySprites.Push(PreviewBitmap("images/indoor-activity-bedroom.png", 244, 244, [518, 518, 244, 244]))
        m.upstairsActivitySprites.Push(PreviewBitmap("images/indoor-activity-bedroom.png", 244, 244, [774, 518, 244, 244]))
    end if
    if area = "playroom"
        m.upstairsActivitySprites.Push(PreviewBitmap("images/indoor-activity-playroom.png", 244, 244, [6, 6, 244, 244]))
        m.upstairsActivitySprites.Push(PreviewBitmap("images/indoor-activity-playroom.png", 244, 244, [262, 6, 244, 244]))
        m.upstairsActivitySprites.Push(PreviewBitmap("images/indoor-activity-playroom.png", 244, 244, [518, 6, 244, 244]))
        m.upstairsActivitySprites.Push(PreviewBitmap("images/indoor-activity-playroom.png", 244, 244, [774, 6, 244, 244]))
        m.upstairsActivitySprites.Push(PreviewBitmap("images/indoor-activity-playroom.png", 244, 244, [6, 262, 244, 244]))
        m.upstairsActivitySprites.Push(PreviewBitmap("images/indoor-activity-playroom.png", 244, 244, [262, 262, 244, 244]))
        m.upstairsActivitySprites.Push(PreviewBitmap("images/indoor-activity-playroom.png", 244, 244, [518, 262, 244, 244]))
        m.upstairsActivitySprites.Push(PreviewBitmap("images/indoor-activity-playroom.png", 244, 244, [774, 262, 244, 244]))
        m.upstairsActivitySprites.Push(PreviewBitmap("images/indoor-activity-playroom.png", 244, 186, [6, 518, 244, 186]))
        m.upstairsActivitySprites.Push(PreviewBitmap("images/indoor-activity-playroom.png", 244, 186, [262, 518, 244, 186]))
        m.upstairsActivitySprites.Push(PreviewBitmap("images/indoor-activity-playroom.png", 244, 186, [518, 518, 244, 186]))
        m.upstairsActivitySprites.Push(PreviewBitmap("images/indoor-activity-playroom.png", 244, 186, [774, 518, 244, 186]))
    end if
    if area = "bonusroom"
        m.upstairsActivitySprites.Push(PreviewBitmap("images/indoor-activity-bonusroom.png", 244, 244, [6, 6, 244, 244]))
        m.upstairsActivitySprites.Push(PreviewBitmap("images/indoor-activity-bonusroom.png", 244, 244, [262, 6, 244, 244]))
        m.upstairsActivitySprites.Push(PreviewBitmap("images/indoor-activity-bonusroom.png", 244, 244, [518, 6, 244, 244]))
        m.upstairsActivitySprites.Push(PreviewBitmap("images/indoor-activity-bonusroom.png", 244, 244, [774, 6, 244, 244]))
        m.upstairsActivitySprites.Push(PreviewBitmap("images/indoor-activity-bonusroom.png", 244, 244, [6, 262, 244, 244]))
        m.upstairsActivitySprites.Push(PreviewBitmap("images/indoor-activity-bonusroom.png", 244, 244, [262, 262, 244, 244]))
        m.upstairsActivitySprites.Push(PreviewBitmap("images/indoor-activity-bonusroom.png", 244, 244, [518, 262, 244, 244]))
        m.upstairsActivitySprites.Push(PreviewBitmap("images/indoor-activity-bonusroom.png", 244, 244, [774, 262, 244, 244]))
        m.upstairsActivitySprites.Push(PreviewBitmap("images/indoor-activity-bonusroom.png", 244, 244, [6, 518, 244, 244]))
        m.upstairsActivitySprites.Push(PreviewBitmap("images/indoor-activity-bonusroom.png", 244, 244, [262, 518, 244, 244]))
        m.upstairsActivitySprites.Push(PreviewBitmap("images/indoor-activity-bonusroom.png", 244, 244, [518, 518, 244, 244]))
        m.upstairsActivitySprites.Push(PreviewBitmap("images/indoor-activity-bonusroom.png", 244, 244, [774, 518, 244, 244]))
    end if
    if area = "parentsroom"
        m.upstairsActivitySprites.Push(PreviewBitmap("images/indoor-activity-parentsroom.png", 244, 244, [6, 6, 244, 244]))
        m.upstairsActivitySprites.Push(PreviewBitmap("images/indoor-activity-parentsroom.png", 244, 244, [262, 6, 244, 244]))
        m.upstairsActivitySprites.Push(PreviewBitmap("images/indoor-activity-parentsroom.png", 244, 244, [518, 6, 244, 244]))
        m.upstairsActivitySprites.Push(PreviewBitmap("images/indoor-activity-parentsroom.png", 244, 244, [774, 6, 244, 244]))
        m.upstairsActivitySprites.Push(PreviewBitmap("images/indoor-activity-parentsroom.png", 244, 244, [6, 262, 244, 244]))
        m.upstairsActivitySprites.Push(PreviewBitmap("images/indoor-activity-parentsroom.png", 244, 244, [262, 262, 244, 244]))
        m.upstairsActivitySprites.Push(PreviewBitmap("images/indoor-activity-parentsroom.png", 244, 244, [518, 262, 244, 244]))
        m.upstairsActivitySprites.Push(PreviewBitmap("images/indoor-activity-parentsroom.png", 244, 244, [774, 262, 244, 244]))
        m.upstairsActivitySprites.Push(PreviewBitmap("images/indoor-activity-parentsroom.png", 244, 244, [6, 518, 244, 244]))
        m.upstairsActivitySprites.Push(PreviewBitmap("images/indoor-activity-parentsroom.png", 244, 244, [262, 518, 244, 244]))
        m.upstairsActivitySprites.Push(PreviewBitmap("images/indoor-activity-parentsroom.png", 244, 244, [518, 518, 244, 244]))
        m.upstairsActivitySprites.Push(PreviewBitmap("images/indoor-activity-parentsroom.png", 244, 244, [774, 518, 244, 244]))
    end if
end sub
