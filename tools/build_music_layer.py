"""Build short PCM music sections for independent, adjustable sound playback."""
from pathlib import Path
import json,subprocess,wave
import imageio_ffmpeg
ROOT=Path(__file__).resolve().parents[1]
rate=22050
ffmpeg=imageio_ffmpeg.get_ffmpeg_exe()
original=str(ROOT/'audio/swan_lake_scene-original.mp3')
# Normalize the whole song before splitting it so section boundaries retain
# their dynamics. Two passes target -16 LUFS and limit true peaks to -1.5 dB.
measure=subprocess.run([ffmpeg,'-hide_banner','-i',original,'-af',
 'aformat=channel_layouts=mono,loudnorm=I=-16:TP=-1.5:LRA=7:print_format=json','-f','null','-'],
 check=True,capture_output=True,text=True)
report=measure.stderr
start=report.rfind('{')
stats=json.loads(report[start:report.rfind('}')+1])
normalize=(f'aformat=channel_layouts=mono,loudnorm=I=-16:TP=-1.5:LRA=7:measured_I={stats["input_i"]}:'
 f'measured_TP={stats["input_tp"]}:measured_LRA={stats["input_lra"]}:'
 f'measured_thresh={stats["input_thresh"]}:offset={stats["target_offset"]}:linear=true')
raw=subprocess.run([ffmpeg,'-loglevel','error','-i',original,'-af',normalize,
 '-ac','1','-ar',str(rate),'-f','s16le','-'],check=True,capture_output=True).stdout
print('Original loudness:',stats['input_i'],'LUFS; target: -16 LUFS',flush=True)
folder=ROOT/'audio/music';folder.mkdir(exist_ok=True)
rows=['function LoadMusicSections()','    return [']
count=0
for index,offset in enumerate(range(0,len(raw),rate*4)):
 data=raw[offset:offset+rate*4]
 if len(data)<rate:break
 p=folder/f'{index:03}.wav'
 with wave.open(str(p),'wb') as w:
  w.setnchannels(1);w.setsampwidth(2);w.setframerate(rate);w.writeframes(data)
 rows.append(f'        "pkg:/audio/music/{p.name}",')
 count+=1
rows[-1]=rows[-1].rstrip(',');rows+=['    ]','end function','']
(ROOT/'source/music-sections.brs').write_text('\n'.join(rows))
print('Built',count,'music sections')
