' Neural narration is bundled, so missions remain spoken without a network.
function CreateGameNarrator(fallback, player, audioPort)
    return {audioPort: audioPort, Poll: NarratorPoll, fallback: fallback, player: player, clips: LoadNarrationClips(), speaking: false, lastWords: "", IsEnabled: NarratorEnabled, Flush: NarratorFlush, Say: NarratorSay, Finish: NarratorFinish, HandleAudioEvent: NarratorHandleAudioEvent}
end function

function NarratorEnabled()
    if m.player <> invalid then return true
    if m.fallback <> invalid then return m.fallback.IsEnabled()
    return false
end function

sub NarratorFlush()
    if m.fallback <> invalid then m.fallback.Flush()
    if m.speaking and m.player <> invalid then m.player.Stop()
    m.speaking = false
end sub

function NarratorSay(words)
    m.lastWords = words
    if m.player <> invalid and m.clips.DoesExist(words)
        m.player.Stop()
        m.player.ClearContent()
        m.player.SetLoop(false)
        m.player.AddContent({Url: m.clips[words], StreamFormat: "mp3"})
        m.speaking = true
        m.player.Play()
        return 1
    end if
    m.Finish()
    if m.fallback <> invalid
        if m.fallback.IsEnabled() then return m.fallback.Say(words)
    end if
    return 0
end function

sub NarratorFinish()
    m.speaking = false
    if m.player = invalid then return
    m.player.Stop()
    m.player.ClearContent()
end sub

sub NarratorHandleAudioEvent(event)
    if not m.speaking then return
    if event.IsRequestFailed()
        ' Retain spoken instructions if a device cannot decode a bundled clip.
        words = m.lastWords
        m.Finish()
        if m.fallback <> invalid
            if m.fallback.IsEnabled() then m.fallback.Say(words)
        end if
    else if event.IsFullResult()
        m.Finish()
    end if
end sub

sub NarratorPoll()
    if m.audioPort = invalid then return
    event = m.audioPort.GetMessage()
    while event <> invalid
        if type(event) = "roAudioPlayerEvent" then m.HandleAudioEvent(event)
        event = m.audioPort.GetMessage()
    end while
end sub
