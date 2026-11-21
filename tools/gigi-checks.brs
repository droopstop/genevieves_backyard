' Load with game functions and tools/pappy-checks.brs, replacing its Main.
sub Main()
    gigi = CreateGigi()
    UpdateGigi(gigi, "deck", 1050, 550, false)
    CheckPappy(gigi.nearby, "Gigi is reachable on the deck")
    UpdateGigi(gigi, "yard", 1050, 550, false)
    CheckPappy(not gigi.nearby, "Gigi stays on the deck")
    UpdateGigi(gigi, "deck", 640, 350, false)
    CheckPappy(not gigi.nearby, "talk requires being near Gigi")
    UpdateGigi(gigi, "deck", 1050, 550, true)
    CheckPappy(not gigi.nearby, "activities cannot be interrupted")
    UpdateGigi(gigi, "deck", 1050, 550, false)
    CheckPappy(gigi.nearby, "can return to Grandma")
    titles = {}
    for index = 0 to 3
        mission = GetGigiMission(index)
        CheckPappy(mission.giver = "Gigi" and mission.steps.Count() = 2, "two-step Gigi mission")
        CheckPappy(not titles.DoesExist(mission.title), "unique Gigi missions")
        titles[mission.title] = true
        for stepIndex = 0 to 1
            stepInfo = mission.steps[stepIndex]
            CheckPappy(ActionPrompt(stepInfo.area, stepInfo.action) <> "do the activity", "playable mission action")
            hud = BuildMissionHudText(mission, stepIndex, false)
            CheckPappy(Instr(1, hud.body, stepInfo.hint) > 0, "HUD shows next step")
        end for
        hud = BuildMissionHudText(mission, 1, true)
        CheckPappy(Instr(1, hud.body, "Return to Gigi") > 0, "return to Grandma on completion")
    end for
    CheckPappy(GigiPrompt(invalid, false) = "get a mission from Gigi", "new mission prompt")
    CheckPappy(GigiPrompt(GetGigiMission(0), false) = "talk to Gigi about your mission", "reminder prompt")
    CheckPappy(GigiPrompt(GetGigiMission(0), true) = "get a mission from Gigi", "next mission prompt")
    print "PASS: Gigi deck proximity, activities, four missions, HUD and reminders"
end sub
