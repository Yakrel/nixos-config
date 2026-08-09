{ lib, pkgs, ... }:

{
  # Deliberate last-resort exception to the typed-option rule:
  # plasma-manager/Home Manager currently has no high-level option for
  # incrementally seeding Dolphin's mutable user-places.xbel. Managing the
  # whole file with xdg.dataFile/home.file would make Nix own the complete
  # bookmark set and would fight normal add/remove operations in Dolphin.
  #
  # This activation therefore only inserts the two missing homelab locations,
  # preserves every user-managed entry, and never stores SMB credentials.
  home.activation.seedDolphinPlaces = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    ${pkgs.python3}/bin/python3 <<'PY'
from pathlib import Path
from html import escape

path = Path.home() / ".local/share/user-places.xbel"
path.parent.mkdir(parents=True, exist_ok=True)

if path.exists():
    text = path.read_text(encoding="utf-8")
else:
    text = """<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE xbel>
<xbel xmlns:mime="http://www.freedesktop.org/standards/shared-mime-info" xmlns:kdepriv="http://www.kde.org/kdepriv" xmlns:bookmark="http://www.freedesktop.org/standards/desktop-bookmarks" version="1.0">
</xbel>
"""

places = [
    ("datapool", "smb://192.168.1.102/datapool"),
    ("fastpool-config", "smb://192.168.1.102/fastpool-config"),
]

changed = not path.exists()
for title, url in places:
    if f'href="{url}"' in text:
        continue

    sep_pos = text.find("<separator")
    insert_pos = sep_pos if sep_pos != -1 else text.rfind("</xbel>")
    if insert_pos == -1:
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
    text = text[:insert_pos] + bookmark + text[insert_pos:]
    changed = True

if changed:
    path.write_text(text, encoding="utf-8")
PY
  '';
}
