' The yard cottage opens into a living room with Pops in his recliner.
sub LoadHouseArtwork()
    m.houseBackdrop = CreateObject("roBitmap", "pkg:/images/house-interior.png")
    m.popsSprite = CreateObject("roBitmap", "pkg:/images/pops-recliner.png")
end sub

function IsHouseEntrance(x, y)
    return PointInRect(x, y, 1068, 250, 175, 235)
end function

function HouseReturnPosition()
    return {x: 1094, y: 425}
end function

function CreatePops()
    return {x: 1000, y: 510, nearby: false, missionIndex: 0}
end function

sub UpdatePops(pops, area, playerCenterX, playerCenterY, taskActive)
    pops.nearby = false
    if area <> "house" or taskActive then return
    pops.nearby = Abs(playerCenterX - pops.x) < 100 and Abs(playerCenterY - pops.y) < 85
end sub

function PopsPrompt(mission, completed)
    if mission <> invalid
        if not completed then return "talk to Pops about your mission"
    end if
    return "get a mission from Pops"
end function

sub DrawHouse(screen, titleFont, labelFont, promptFont, bodyFont)
    screen.Clear(&hB9956FFF)
    if m.houseBackdrop <> invalid
        screen.DrawScaledObject(0, 0, 1280 / m.houseBackdrop.GetWidth(), 720 / m.houseBackdrop.GetHeight(), m.houseBackdrop)
    end if
    DrawHouseStairs(screen, labelFont, bodyFont)
    DrawHeader(screen, "INSIDE THE HOUSE", titleFont, bodyFont)
    DrawExit(screen, labelFont, bodyFont)
end sub

sub DrawPops(screen, pops, mission, completed, labelFont, bodyFont)
    if m.popsSprite <> invalid
        scale = 300 / m.popsSprite.GetHeight()
        if 280 / m.popsSprite.GetWidth() < scale then scale = 280 / m.popsSprite.GetWidth()
        screen.DrawScaledObject(Int(pops.x - m.popsSprite.GetWidth() * scale / 2), Int(370 - m.popsSprite.GetHeight() * scale / 2), scale, scale, m.popsSprite)
    end if
    screen.DrawRect(860, 525, 280, 56, &h173E52EE)
    CenterLabel(screen, "POPS", pops.x, 529, &hFFE06AFF, labelFont)
    CenterLabel(screen, "Genevieve's great-grandpa", pops.x, 554, &hFFFFFFFF, bodyFont)
    if mission = invalid or completed then DrawPlanetSprite(screen, 3, pops.x, 205, 26, 26)
end sub

function GetPopsMission(index)
    result = {giver: "Pops", title: "", steps: []}
    if index = 0
        result.title = "Pops' Happy Visit"
        result.steps = [MakeStep("yard", "stitch", "Give Stitch a loving pet for Pops!"), MakeStep("house", "twirl", "Come inside and show Pops a twirl! Press Play/Pause.")]
    else if index = 1
        result.title = "Pops' Garden Helpers"
        result.steps = [MakeStep("garden", "water", "Water the garden flowers for Pops!"), MakeStep("garden", "pick", "Pick fresh vegetables to tell Pops about!")]
    else if index = 2
        result.title = "Pops' Birdsong Morning"
        result.steps = [MakeStep("grove", "birdbath", "Give the garden birds fresh water for Pops!"), MakeStep("grove", "dig", "Fill the yellow bucket with the shovel!")]
    else if index = 3
        result.title = "Pops' Family Picnic"
        result.steps = [MakeStep("deck", "deckflowers", "Water the deck flowers for our family picnic!"), MakeStep("deck", "settable", "Set the patio table for Pops' picnic!")]
    else if index = 4
        result.title = "Pops' Bouncy Story"
        result.steps = [MakeStep("yard", "hippityhop", "Ride the hippity hop to make Pops smile!"), MakeStep("yard", "bubbles", "Blow big bubbles for Pops' backyard story!")]
    else
        result.title = "Pops' Space Adventure"
        result.steps = [MakeStep("mars", "redrock", "Use the Space Crate and collect 10 Mars rocks for Pops!"), MakeStep("house", "twirl", "Come back inside and celebrate with Pops! Press Play/Pause.")]
    end if
    return result
end function
