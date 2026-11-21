' Gigi waits on the deck while Genevieve explores and completes missions.
sub LoadGigiArtwork()
    m.gigiSprite = CreateObject("roBitmap", "pkg:/images/gigi-photo.png")
end sub

function CreateGigi()
    return {x: 1050, y: 550, nearby: false, missionIndex: 0}
end function

sub UpdateGigi(gigi, area, playerCenterX, playerCenterY, taskActive)
    gigi.nearby = false
    if area <> "deck" or taskActive then return
    gigi.nearby = Abs(playerCenterX - gigi.x) < 75 and Abs(playerCenterY - gigi.y) < 65
end sub

function GigiPrompt(mission, completed)
    if mission <> invalid
        if not completed then return "talk to Gigi about your mission"
    end if
    return "get a mission from Gigi"
end function

sub DrawGigi(screen, gigi, mission, completed, labelFont, bodyFont)
    if m.gigiSprite <> invalid
        scale = 110 / m.gigiSprite.GetHeight()
        screen.DrawScaledObject(Int(gigi.x - m.gigiSprite.GetWidth() * scale / 2), Int(gigi.y - 65), scale, scale, m.gigiSprite)
    end if
    CenterLabel(screen, "GIGI", gigi.x, gigi.y + 43, &hFFF0C2FF, labelFont)
    CenterLabel(screen, "Genevieve's grandma", gigi.x, gigi.y + 67, &hFFFFFFFF, bodyFont)
    if mission = invalid or completed then DrawPlanetSprite(screen, 3, gigi.x, gigi.y - 83, 24, 24)
end sub

function GetGigiMission(index)
    result = {giver: "Gigi", title: "", steps: []}
    if index = 0
        result.title = "Gigi's Deck Flowers"
        result.steps = [MakeStep("deck", "deckflowers", "Give Gigi's deck flowers a nice drink!"), MakeStep("deck", "windchimes", "Ring the wind chimes for Grandma!")]
    else if index = 1
        result.title = "Gigi's Garden Picnic"
        result.steps = [MakeStep("garden", "pick", "Pick fresh vegetables for Gigi's picnic!"), MakeStep("deck", "settable", "Come back to the deck and set the patio table!")]
    else if index = 2
        result.title = "Gigi's Little Garden Helpers"
        result.steps = [MakeStep("grove", "birdbath", "Fill the bird bath for Gigi's bird friends!"), MakeStep("garden", "water", "Water the garden flowers for Grandma!")]
    else
        result.title = "Gigi's Playtime Surprise"
        result.steps = [MakeStep("yard", "bubbles", "Blow big bubbles to show Gigi!"), MakeStep("deck", "twirl", "Come back to Gigi and twirl! Press Play/Pause on the deck.")]
    end if
    return result
end function
