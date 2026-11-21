' Pappy visits the firepit and waits while Genevieve explores other areas.
sub LoadPappyArtwork()
    m.pappySprite = CreateObject("roBitmap", "pkg:/images/pappy.png")
end sub

function CreatePappy()
    return {state: "waiting", stateMs: 0, x: 1310, y: 558, nearby: false, missionIndex: 0}
end function

sub UpdatePappy(pappy, area, elapsedMs, playerCenterX, playerCenterY, taskActive)
    pappy.nearby = false
    if area <> "firepit" or taskActive then return
    if pappy.state = "waiting"
        pappy.stateMs = pappy.stateMs + elapsedMs
        if pappy.stateMs >= 1500
            pappy.state = "arriving"
            pappy.stateMs = 0
        end if
    else if pappy.state = "arriving"
        pappy.stateMs = pappy.stateMs + elapsedMs
        progress = pappy.stateMs / 3000
        if progress > 1 then progress = 1
        pappy.x = 1310 - 260 * progress
        if progress >= 1
            pappy.state = "ready"
            pappy.stateMs = 0
        end if
    end if
    if pappy.state = "ready"
        pappy.nearby = Abs(playerCenterX - pappy.x) < 75 and Abs(playerCenterY - pappy.y) < 65
    end if
end sub

function PappyPrompt(mission, completed)
    if mission <> invalid
        if not completed then return "talk to Pappy about your mission"
    end if
    return "get a mission from Pappy"
end function

sub DrawPappy(screen, pappy, mission, completed, labelFont, bodyFont)
    if pappy.state = "waiting" then return
    bob = 0
    if pappy.state = "arriving" then bob = Int(Sin(pappy.stateMs * 0.014) * 3)
    if m.pappySprite <> invalid
        scale = 110 / m.pappySprite.GetHeight()
        screen.DrawScaledObject(Int(pappy.x - m.pappySprite.GetWidth() * scale / 2), Int(pappy.y - 65 + bob), scale, scale, m.pappySprite)
    end if
    CenterLabel(screen, "PAPPY", pappy.x, pappy.y + 43, &hFFF0C2FF, labelFont)
    CenterLabel(screen, "Genevieve's grandpa", pappy.x, pappy.y + 67, &hFFFFFFFF, bodyFont)
    if pappy.state = "ready"
        available = mission = invalid or completed
        if available then DrawPlanetSprite(screen, 3, pappy.x, pappy.y - 83, 24, 24)
    else
        screen.DrawRect(370, 150, 540, 40, &h173E52F2)
        CenterLabel(screen, "Pappy is here! Grandpa has missions for you!", 640, 159, &hFFFFFFFF, labelFont)
    end if
end sub

function GetPappyMission(index)
    result = {giver: "Pappy", title: "", steps: []}
    if index = 0
        result.title = "Pappy's Campfire Helpers"
        result.steps = [MakeStep("firepit", "sticks", "Gather sticks by the firepit for Pappy!"), MakeStep("firepit", "smore", "Make a yummy s'more with Grandpa!")]
    else if index = 1
        result.title = "Pappy's Birdsong Visit"
        result.steps = [MakeStep("grove", "birdbath", "Fill the bird bath in Birdsong Garden!"), MakeStep("grove", "dig", "Use the shovel to fill the yellow bucket!")]
    else if index = 2
        result.title = "Pappy's Puppy Playtime"
        result.steps = [MakeStep("yard", "stitch", "Give Stitch a loving pet for Pappy!"), MakeStep("yard", "bubbles", "Blow big bubbles to show Grandpa!")]
    else if index = 3
        result.title = "Pappy's Picnic Surprise"
        result.steps = [MakeStep("garden", "pick", "Pick fresh vegetables in the food garden!"), MakeStep("deck", "settable", "Set the patio table for Pappy's picnic!")]
    else if index = 4
        result.title = "Pappy's Bouncy Adventure"
        result.steps = [MakeStep("yard", "hippityhop", "Take a hippity hop ride around the yard!"), MakeStep("playset", "swing", "Visit the playset and swing high!")]
    else
        result.title = "Pappy's Star Explorer"
        result.steps = [MakeStep("mars", "redrock", "Use the Space Crate and collect 10 glowing Mars rocks!"), MakeStep("firepit", "fireswing1", "Come back to the firepit and rock on the bench!")]
    end if
    return result
end function
