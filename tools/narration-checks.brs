' Load with game functions and CheckPappy from tools/pappy-checks.brs.
sub Main()
    clips = LoadNarrationClips()
    for group = 0 to 2
        count = 6
        if group = 1 then count = 4
        for index = 0 to count - 1
            if group = 0
                mission = GetPappyMission(index)
            else if group = 1
                mission = GetGigiMission(index)
            else
                mission = GetPopsMission(index)
            end if
            for stepIndex = 0 to 1
                hud = BuildMissionHudText(mission, stepIndex, false)
                CheckPappy(clips.DoesExist(hud.heading + ". " + hud.body), "recorded grandparent mission instructions")
                CheckPappy(clips.DoesExist("PAPPY SAYS: YOU CAN DO IT!. " + mission.steps[stepIndex].hint), "recorded Pappy reminder")
                CheckPappy(clips.DoesExist("GIGI SAYS: YOU CAN DO IT!. " + mission.steps[stepIndex].hint), "recorded Gigi reminder")
            end for
            hud = BuildMissionHudText(mission, 0, true)
            CheckPappy(clips.DoesExist(hud.heading + ". " + hud.body), "recorded return to grandparent instruction")
        end for
    end for
    hud = BuildMissionHudText(invalid, 0, false)
    CheckPappy(clips.DoesExist(hud.heading + ". " + hud.body), "updated welcome has recorded narration")
    voice = {IsEnabled: TestSpeechEnabled, Flush: TestSpeechFlush, Say: TestSpeechSay, accept: false, calls: 0}
    state = CreateMissionPresentation()
    UpdateMissionPresentation(state, hud, "", "", false, false, 16, voice)
    CheckPappy(state.lastHudText = "", "failed speech is not marked as spoken")
    voice.accept = true
    UpdateMissionPresentation(state, hud, "", "", false, false, 16, voice)
    CheckPappy(state.lastHudText = hud.heading + ". " + hud.body, "failed speech can be retried")
    callCount = voice.calls
    UpdateMissionPresentation(state, hud, "", "", false, false, 16, voice)
    CheckPappy(voice.calls = callCount, "successful speech does not repeat every frame")
    print "PASS: recorded grandparent instructions, reminders, completion, welcome and retry behavior"
end sub

function TestSpeechEnabled()
    return true
end function

sub TestSpeechFlush()
end sub

function TestSpeechSay(words)
    m.calls = m.calls + 1
    if m.accept then return 1
    return 0
end function
