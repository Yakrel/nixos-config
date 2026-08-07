{ lib, pkgs, ... }:

{
  # Seed homelab SMB locations into KDE/Dolphin Places without system CIFS
  # mounts or credentials in Git. The file stays user-owned and mutable, and
  # existing Places entries are preserved.
  home.activation.seedDolphinPlaces = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    ${pkgs.python3}/bin/python3 <<'PY'
from pathlib import Path
from html import escape

path = Path.home() / ".local/share/user-places.xbel"
path.parent.mkdir(parents=True, exist_ok=True)

if path.exists():
    text = path.read_text(encoding="utf-8")
else:
    text = '''<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE xbel>
<xbel xmlns:mime="http://www.freedesktop.org/standards/shared-mime-info" xmlns:kdepriv="http://www.kde.org/kdepriv" xmlns:bookmark="http://www.freedesktop.org/standards/desktop-bookmarks" version="1.0">
</xbel>
'''

places = [
    ("datapool", "smb://192.168.1.102/datapool"),
    ("fastpool-config", "smb://192.168.1.102/fastpool-config"),
]

changed = not path.exists()
for title, url in places:
    if f'href="{url}"' in text:
        continue

    closing = text.rfind("</xbel>")
    if closing == -1:
        raise RuntimeError(f"Invalid KDE Places file: {path}")

    bookmark = (
        f'  <bookmark href="{escape(url, quote=True)}">\n'
        f'    <title>{escape(title)}</title>\n'
        '    <info>\n'
        '      <metadata owner="http://freedesktop.org">\n'
        '        <bookmark:icon name="folder-network"/>\n'
        '      </metadata>\n'
        '      <metadata owner="http://www.kde.org">\n'
        '        <isSystemItem>false</isSystemItem>\n'
        '        <IsHidden>false</IsHidden>\n'
        '      </metadata>\n'
        '    </info>\n'
        '  </bookmark>\n'
    )
    text = text[:closing] + bookmark + text[closing:]
    changed = True

if changed:
    path.write_text(text, encoding="utf-8")
PY
  '';
}
