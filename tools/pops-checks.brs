' Load with game functions and CheckPappy from tools/pappy-checks.brs.
sub Main()
    CheckPappy(IsHouseEntrance(1117, 340), "yard cottage is an entrance")
    CheckPappy(not IsHouseEntrance(966, 354), "deck still has its own entrance")
    CheckPappy(not IsHouseEntrance(640, 665), "exit does not re-enter the house")
    landing = HouseReturnPosition()
    CheckPappy(IsHouseEntrance(landing.x + 16, landing.y + 20), "exit returns beside the yard cottage")
    pops = CreatePops()
    UpdatePops(pops, "house", 1000, 510, false)
    CheckPappy(pops.nearby, "Pops is reachable at the recliner")
    UpdatePops(pops, "yard", 1000, 510, false)
    CheckPappy(not pops.nearby, "Pops only interacts inside the house")
    UpdatePops(pops, "house", 640, 555, false)
    CheckPappy(not pops.nearby, "cannot talk across the room")
    UpdatePops(pops, "house", 1000, 510, true)
    CheckPappy(not pops.nearby, "Pops does not interrupt activities")
    UpdatePops(pops, "house", 1000, 510, false)
    CheckPappy(pops.nearby, "Pops waits when Genevieve returns")
    titles = {}
    for index = 0 to 5
        mission = GetPopsMission(index)
        CheckPappy(mission.giver = "Pops" and mission.steps.Count() = 2, "Pops gives two-step missions")
        CheckPappy(not titles.DoesExist(mission.title), "six distinct missions")
        titles[mission.title] = true
        for stepIndex = 0 to 1
            stepInfo = mission.steps[stepIndex]
            CheckPappy(ActionPrompt(stepInfo.area, stepInfo.action) <> "do the activity", "mission uses a playable action")
            if stepInfo.area = "house" then CheckPappy(stepInfo.action = "twirl", "indoor step is supported")
            hud = BuildMissionHudText(mission, stepIndex, false)
            CheckPappy(Instr(1, hud.body, stepInfo.hint) > 0, "HUD guides each mission step")
        end for
        hud = BuildMissionHudText(mission, 1, true)
        CheckPappy(Instr(1, hud.body, "Return to Pops") > 0, "completion returns to great-grandpa")
    end for
    CheckPappy(PopsPrompt(invalid, false) = "get a mission from Pops", "first mission prompt")
    CheckPappy(PopsPrompt(GetPopsMission(0), false) = "talk to Pops about your mission", "reminder during a mission")
    CheckPappy(PopsPrompt(GetPopsMission(0), true) = "get a mission from Pops", "next mission after completion")
    screen = {DrawRect: PopsTestRect, DrawText: PopsTestText, lines: []}
    font = {GetOneLineWidth: PopsTestTextWidth}
    hud = BuildMissionHudText(GetPopsMission(5), 1, false)
    DrawMissionHud(screen, hud, font, font)
    CheckPappy(screen.lines.Count() = 3, "long indoor instructions wrap to two lines")
    CheckPappy(screen.lines[1] + " " + screen.lines[2] = hud.body, "wrapping keeps the entire instruction")
    print "PASS: house entrance, return to yard, Pops proximity, six missions and indoor steps"
end sub

sub PopsTestRect(x, y, width, height, color)
end sub

sub PopsTestText(words, x, y, color, font)
    m.lines.Push(words)
end sub

function PopsTestTextWidth(words, maxWidth)
    return Len(words) * 9
end function
