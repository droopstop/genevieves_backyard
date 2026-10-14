"""Generate offline neural narration from an exported game text catalogue.

Requires piper-tts and imageio-ffmpeg. Supply the Lessac high ONNX model
and the JSON text list exported from the game's mission definitions.
"""
from pathlib import Path
import argparse,hashlib,json,re,subprocess,wave
import imageio_ffmpeg
from piper import PiperVoice, SynthesisConfig

ROOT=Path(__file__).resolve().parents[1]
def spoken_text(text):
    text=re.sub(r'Step (\d+)/(\d+):',r'Step \1 of \2.',text)
    text=text.replace('MISSION: ', '').replace('MISSION. ', '')
    text=text.replace('!.', '!').replace('Play/Pause','play pause')
    text=text.replace('YOU DID IT!', 'You did it!').replace('STEP COMPLETE!', 'Step complete!')
    text=text.replace('MISSION COMPLETE!', 'Mission complete!').replace('GREAT EXPLORING!', 'Great exploring!')
    return text

def main():
    parser=argparse.ArgumentParser()
    parser.add_argument('model');parser.add_argument('catalogue')
    args=parser.parse_args()
    texts=json.loads(Path(args.catalogue).read_text())
    # New assignments and completion banners duplicate the HUD, which is narrated first.
    texts=[t for t in texts if not t.startswith(('NEW MISSION!',"MOMMY'S MISSION!"))
           and not t.startswith('STEP COMPLETE!. Next: ')
           and not (t.startswith('MISSION COMPLETE!') and not ('Return to ' in t or 'Fly home to ' in t))]
    target=ROOT/'audio/narration';target.mkdir(parents=True,exist_ok=True)
    voice=PiperVoice.load(args.model)
    ffmpeg=imageio_ffmpeg.get_ffmpeg_exe()
    mapping={}
    for i,text in enumerate(texts):
        key=hashlib.sha256(text.encode()).hexdigest()[:16]
        dest=target/(key+'.mp3')
        if not dest.exists():
            wav=Path('/tmp/backyard-narration.wav')
            with wave.open(str(wav),'wb') as output:
                voice.synthesize_wav(spoken_text(text),output,syn_config=SynthesisConfig(length_scale=1.03))
            subprocess.run([ffmpeg,'-loglevel','error','-y','-i',str(wav),'-ac','1','-ar','22050','-b:a','32k',str(dest)],check=True)
        mapping[text]='pkg:/audio/narration/'+dest.name
        if i%10==0:print(f'Generated {i+1}/{len(texts)}',flush=True)
    # Keep literal pkg references so the runtime packager includes every clip.
    rows=['function LoadNarrationClips()','    clips = {}']
    for text,url in mapping.items():
        rows.append('    clips['+json.dumps(text)+'] = '+json.dumps(url))
    rows+=['    return clips','end function','']
    (ROOT/'source/narration-clips.brs').write_text('\n'.join(rows))
    (ROOT/'tools/narration-texts.json').write_text(json.dumps(texts,indent=2)+'\n')
    print('Narration bytes:',sum(p.stat().st_size for p in target.glob('*.mp3')),flush=True)
if __name__=='__main__':main()
