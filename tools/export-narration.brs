' Load the game functions without the graphical Main to export exact HUD text.
sub Main()
    texts = []
    hud = BuildMissionHudText(invalid, 0, false)
    texts.Push(hud.heading + ". " + hud.body)
    actions = ["dig", "bubbles", "hippityhop", "twirl", "cow", "weed", "stitch", "water", "pick", "ladybug", "slide", "swing", "clubhouse", "treehang", "birdbath", "bushes", "deckflowers", "settable", "windchimes", "sticks", "smore", "fireswing1", "fireswing2", "lounger", "redrock", "rings", "bluecrystal"]
    for each action in actions
        texts.Push("YOU DID IT!. " + ActionSuccessMessage("", action))
    end for
    for group = 0 to 4
        count = 35
        if group = 1 then count = 9
        if group = 2 then count = 6
        if group = 3 then count = 4
        if group = 4 then count = 6
        for index = 0 to count - 1
            if group = 0
                mission = GetMission(index)
            else if group = 1
                mission = GetMommyMission(index)
            else if group = 2
                mission = GetPappyMission(index)
            else if group = 3
                mission = GetGigiMission(index)
            else
                mission = GetPopsMission(index)
            end if
            for stepIndex = 0 to mission.steps.Count() - 1
                hud = BuildMissionHudText(mission, stepIndex, false)
                texts.Push(hud.heading + ". " + hud.body)
                texts.Push("PAPPY SAYS: YOU CAN DO IT!. " + mission.steps[stepIndex].hint)
                texts.Push("GIGI SAYS: YOU CAN DO IT!. " + mission.steps[stepIndex].hint)
            end for
            hud = BuildMissionHudText(mission, 0, true)
            texts.Push(hud.heading + ". " + hud.body)
            texts.Push("MISSION COMPLETE!. Fly home to " + mission.giver + "!")
        end for
    end for
    print "NARRATION_JSON:" + FormatJson(texts)
end sub
