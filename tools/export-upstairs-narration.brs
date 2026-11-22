sub Main()
    texts = ["Sit down and relax. Use an arrow button to stand up."]
    for each area in ["house", "upstairs", "bedroom", "playroom", "bonusroom", "parentsroom"]
        texts.Push(RoomWelcome(area))
        room = UpstairsRoom(area)
        if room <> invalid
            for each action in room.stations
                texts.Push(UpstairsPrompt(action) + ".")
                texts.Push("YOU DID IT!. " + UpstairsSuccess(action))
                if IsIndoorStoryAction(action)
                    for each line in IndoorStoryLines(action)
                        texts.Push(line)
                    end for
                end if
            end for
        end if
    end for
    texts.Push(LivingRoomPonyInstructions())
    texts.Push(LivingRoomPonyDismountWords())
    texts.Push(IndoorOutfitChooserInstruction())
    for index = 0 to 3
        texts.Push(IndoorOutfitSpokenName(index))
    end for
    texts.Push(UpstairsPrompt("stairsup") + ".")
    texts.Push(UpstairsPrompt("stairsdown") + ".")
    print "UPSTAIRS_AUDIO_JSON:" + FormatJson(texts)
end sub
