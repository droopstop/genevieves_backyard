"""Package runtime assets; keep original reference artwork in the source project."""
from pathlib import Path
import argparse
import re
import zipfile

ROOT = Path(__file__).resolve().parent


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
