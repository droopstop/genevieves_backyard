"""Package runtime assets; keep original reference artwork in the source project."""
from pathlib import Path
import argparse
import re
import struct
import zipfile

ROOT = Path(__file__).resolve().parent


def validate_menu_icons(manifest):
    attributes = dict(line.split('=', 1) for line in manifest.splitlines()
                      if '=' in line and not line.startswith('#'))
    for key, expected in [('mm_icon_focus_hd', (290, 218)),
                          ('mm_icon_focus_fhd', (540, 405)),
                          ('mm_icon_side_hd', (290, 218))]:
        uri = attributes.get(key, '')
        if not uri.startswith('pkg:/images/'):
            raise ValueError(f'{key} must reference a bundled menu icon')
        image = (ROOT / uri[5:]).read_bytes()
        if image[:8] != b'\x89PNG\r\n\x1a\n':
            raise ValueError(f'{key} must reference a PNG image')
        if struct.unpack('>II', image[16:24]) != expected:
            raise ValueError(f'{key} must have dimensions {expected}')


def package_game(destination, main_source=None):
    source_paths = sorted((ROOT / 'source').rglob('*.brs'))
    source_texts = {
        str(path.relative_to(ROOT)): (
            main_source if path.name == 'main.brs' and main_source is not None
            else path.read_text()
        )
        for path in source_paths
    }
    manifest = (ROOT / 'manifest').read_text()
    validate_menu_icons(manifest)
    references = set(re.findall(
        r'pkg:/([A-Za-z0-9_./-]+)',
        manifest + '\n' + '\n'.join(source_texts.values()),
    ))
    entries = {'manifest', 'CREDITS.md'} | set(source_texts) | references
    for name in entries:
        if not (ROOT / name).is_file():
            raise FileNotFoundError(f'Missing runtime asset: {name}')
    destination = Path(destination)
    with zipfile.ZipFile(destination, 'w', zipfile.ZIP_DEFLATED) as archive:
        for name in sorted(entries):
            if name in source_texts:
                archive.writestr(name, source_texts[name])
            else:
                archive.write(ROOT / name, name)
    return destination


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('destination', nargs='?', default=str(ROOT.with_suffix('.zip')))
    args = parser.parse_args()
    path = package_game(args.destination)
    print(f'Packaged {path}: {path.stat().st_size:,} bytes')
