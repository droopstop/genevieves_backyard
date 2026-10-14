' PCM sound resources have their own mixer, independent of the narration decoder.
' The song clock never pauses or resets when another sound starts or finishes.
function CreateBackgroundMusic()
    clock = CreateObject("roTimespan")
    clock.Mark()
    return {sections: LoadMusicSections(), clock: clock, section: -1, volume: -1, resource: invalid, effectUntil: 0, serial: 0, temporaryPath: "", Update: MusicUpdate, DuckFor: MusicDuckFor, PlayAt: MusicPlayAt}
end function

sub MusicDuckFor(durationMs)
    deadline = m.clock.TotalMilliseconds() + durationMs
    if deadline > m.effectUntil then m.effectUntil = deadline
end sub

sub MusicUpdate(speaking)
    elapsed = m.clock.TotalMilliseconds()
    position = elapsed mod (m.sections.Count() * 2000)
    section = Int(position / 2000)
    volume = 45
    if speaking or elapsed < m.effectUntil then volume = 12
    if section <> m.section or volume <> m.volume
        m.PlayAt(position, volume)
    end if
end sub

sub MusicPlayAt(position, volume)
    section = Int(position / 2000)
    offsetMs = position mod 2000
    source = m.sections[section]
    header = CreateObject("roByteArray")
    body = CreateObject("roByteArray")
    if not header.ReadFile(source, 0, 44) then return
    offsetBytes = Int(offsetMs * 22.05) * 2
    remaining = 88200 - offsetBytes
    if remaining <= 0 then return
    if not body.ReadFile(source, 44 + offsetBytes, remaining) then return
    WriteMusicInteger(header, 4, body.Count() + 36)
    WriteMusicInteger(header, 40, body.Count())
    m.serial = m.serial + 1
    path = "tmp:/music-" + m.serial.ToStr() + ".wav"
    if not header.WriteFile(path) then return
    if not body.AppendFile(path) then return
    sound = CreateObject("roAudioResource", path)
    if sound = invalid then return
    if m.resource <> invalid then m.resource.Stop()
    sound.Trigger(volume, 0)
    m.resource = sound
    if m.temporaryPath <> "" then DeleteFile(m.temporaryPath)
    m.temporaryPath = path
    m.section = section
    m.volume = volume
end sub

sub WriteMusicInteger(bytes, offset, value)
    for index = 0 to 3
        bytes[offset + index] = value mod 256
        value = Int(value / 256)
    end for
end sub
