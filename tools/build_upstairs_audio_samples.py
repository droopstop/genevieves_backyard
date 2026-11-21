"""Copy the exact bundled upstairs speech into readable review samples."""
from pathlib import Path
import hashlib
import json
import re
import shutil
import zipfile

ROOT = Path(__file__).resolve().parents[1]


def build_samples(destination=None):
    texts = json.loads((ROOT / 'tools/upstairs-narration-texts.json').read_text())
    output = ROOT / 'previews/upstairs-audio'
    output.mkdir(parents=True, exist_ok=True)
    prior = output / 'catalogue.json'
    if prior.exists():
        for item in json.loads(prior.read_text()):
            old = output / item['sample']
            if old.is_file():
                old.unlink()
    manifest = []
    for index, text in enumerate(texts, 1):
        digest = hashlib.sha256(text.encode()).hexdigest()[:16]
        source = ROOT / 'audio/narration' / (digest + '.mp3')
        slug = re.sub(r'[^a-z0-9]+', '-', text.lower()).strip('-')[:85]
        name = f'{index:02d}-{slug}.mp3'
        shutil.copyfile(source, output / name)
        manifest.append({'sample': name, 'text': text, 'runtime_clip': str(source.relative_to(ROOT))})
    (output / 'catalogue.json').write_text(json.dumps(manifest, indent=2) + '\n')
    destination = Path(destination or ROOT.parent / 'upstairs-audio-samples.zip')
    with zipfile.ZipFile(destination, 'w', zipfile.ZIP_DEFLATED) as archive:
        for item in sorted(output.iterdir()):
            archive.write(item, item.name)
    print(f'Created {len(manifest)} audio samples: {destination}')
    return destination


if __name__ == '__main__':
    build_samples()
