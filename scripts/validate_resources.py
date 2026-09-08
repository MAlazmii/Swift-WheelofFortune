#!/usr/bin/env python3
"""Check resource syntax and asset references without requiring Xcode."""
from pathlib import Path
import json
import plistlib
import xml.etree.ElementTree as ET

root = Path(__file__).resolve().parents[1]
checked = 0
for path in root.rglob('*'):
    relative = path.relative_to(root)
    if not path.is_file() or any(part in {'.git', 'build', 'DerivedData'} for part in relative.parts):
        continue
    if path.suffix == '.json':
        document = json.loads(path.read_text())
        if path.name == 'Contents.json':
            for image in document.get('images', []):
                if 'filename' in image:
                    assert (path.parent / image['filename']).is_file(), f'Missing asset: {path}: {image["filename"]}'
    elif path.suffix == '.plist' or path.name == '.xccurrentversion':
        plistlib.loads(path.read_bytes())
    elif path.suffix in {'.storyboard', '.gpx', '.xcscheme', '.xcworkspacedata'} or path.name == 'contents':
        ET.parse(path)
    else:
        continue
    checked += 1
print(f'Validated {checked} resource files.')
