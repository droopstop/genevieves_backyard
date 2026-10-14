"""Build short PCM music sections for independent, adjustable sound playback."""
from pathlib import Path
import subprocess,wave
import imageio_ffmpeg
ROOT=Path(__file__).resolve().parents[1]
rate=22050
raw=subprocess.run([imageio_ffmpeg.get_ffmpeg_exe(),'-loglevel','error','-i',str(ROOT/'audio/swan_lake_scene-original.mp3'),'-ac','1','-ar',str(rate),'-f','s16le','-'],check=True,capture_output=True).stdout
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
