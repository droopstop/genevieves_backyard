sub Main()
    texts = ["Sit down and relax. Press OK or Back to stand up."]
    for each area in ["house", "upstairs", "bedroom", "playroom", "bonusroom", "parentsroom"]
        texts.Push(RoomWelcome(area))
        room = UpstairsRoom(area)
        if room <> invalid
            for each action in room.stations
                texts.Push(UpstairsPrompt(action) + ".")
                texts.Push("YOU DID IT!. " + UpstairsSuccess(action))
            end for
        end if
    end for
    texts.Push(UpstairsPrompt("stairsup") + ".")
    texts.Push(UpstairsPrompt("stairsdown") + ".")
    print "UPSTAIRS_AUDIO_JSON:" + FormatJson(texts)
end sub
