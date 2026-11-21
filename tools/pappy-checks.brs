' Run with the game's functions loaded, without launching the graphical Main.
sub Main()
    pappy = CreatePappy()
    UpdatePappy(pappy, "yard", 10000, 1050, 558, false)
    CheckPappy(pappy.state = "waiting" and pappy.stateMs = 0, "visits only the firepit")
    UpdatePappy(pappy, "firepit", 1500, 1050, 558, false)
    CheckPappy(pappy.state = "arriving", "starts arriving")
    UpdatePappy(pappy, "firepit", 1500, 1050, 558, false)
    CheckPappy(pappy.x > 1050 and pappy.x < 1310, "walks into the scene")
    savedX = pappy.x
    UpdatePappy(pappy, "garden", 10000, 1050, 558, false)
    CheckPappy(pappy.x = savedX and not pappy.nearby, "pauses when away")
    UpdatePappy(pappy, "firepit", 10000, 1050, 558, true)
    CheckPappy(pappy.x = savedX, "pauses during activities")
    UpdatePappy(pappy, "firepit", 1500, 1050, 558, false)
    CheckPappy(pappy.state = "ready" and pappy.x = 1050 and pappy.nearby, "arrives and offers interaction")
    UpdatePappy(pappy, "yard", 10000, 1050, 558, false)
    CheckPappy(pappy.state = "ready" and not pappy.nearby, "waits during exploration")
    UpdatePappy(pappy, "firepit", 10000, 1050, 558, false)
    CheckPappy(pappy.nearby, "can return to Pappy")
    UpdatePappy(pappy, "firepit", 16, 640, 350, false)
    CheckPappy(not pappy.nearby, "cannot interact from across the firepit")
    titles = {}
    for index = 0 to 5
        mission = GetPappyMission(index)
        CheckPappy(mission.giver = "Pappy" and mission.steps.Count() = 2, "two-step Pappy mission")
        CheckPappy(not titles.DoesExist(mission.title), "distinct mission titles")
        titles[mission.title] = true
        for stepIndex = 0 to mission.steps.Count() - 1
            stepInfo = mission.steps[stepIndex]
            CheckPappy(ActionPrompt(stepInfo.area, stepInfo.action) <> "do the activity", "existing playable action")
            hud = BuildMissionHudText(mission, stepIndex, false)
            CheckPappy(Instr(1, hud.body, stepInfo.hint) > 0, "HUD shows next step")
        end for
        hud = BuildMissionHudText(mission, 1, true)
        CheckPappy(Instr(1, hud.body, "Return to Pappy") > 0, "completion returns to Grandpa")
    end for
    CheckPappy(PappyPrompt(invalid, false) = "get a mission from Pappy", "first mission prompt")
    CheckPappy(PappyPrompt(GetPappyMission(0), false) = "talk to Pappy about your mission", "unfinished mission reminder")
    CheckPappy(PappyPrompt(GetPappyMission(0), true) = "get a mission from Pappy", "next mission prompt")
    print "PASS: Pappy arrival, proximity, pause/resume, six missions, HUD and reminders"
end sub

sub CheckPappy(condition, description)
    if not condition
        print "FAIL: " + description
        stop
    end if
end sub
