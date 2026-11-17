"""Copy the icons the templates use out of the user's own icon pack download.
Skill Made By : Crypticplay_RBLX - Only on Youtube

    python tools/icons_from_pack.py "<path to Free Icon Pack v3.1 (Basic).zip or its unzipped folder>" ui-board/assets/icons

Reads assets/icon-map.json (short name -> [folder, file] in gvesster's Free Icon Pack) and writes
<out>/<short name>.png for every icon it finds. Only PNG images are copied; nothing is executed.
Icons the pack doesn't have are listed so you can pick your own. Standard library only.
"""
import json
import pathlib
import sys
import zipfile

PNG = b"\x89PNG\r\n\x1a\n"


def main() -> int:
    if len(sys.argv) != 3:
        print(__doc__)
        return 2
    src, out = pathlib.Path(sys.argv[1]), pathlib.Path(sys.argv[2])
    here = pathlib.Path(__file__).resolve().parent.parent
    icons = json.loads((here / "assets" / "icon-map.json").read_text(encoding="utf-8"))["icons"]
    out.mkdir(parents=True, exist_ok=True)

    # index every PNG in the pack by (folder, file)
    entries = {}
    if src.is_file() and src.suffix.lower() == ".zip":
        z = zipfile.ZipFile(src)
        for name in z.namelist():
            if name.lower().endswith(".png") and "__MACOSX" not in name:
                parts = name.split("/")
                if len(parts) >= 3:
                    entries.setdefault((parts[-3], parts[-1]), lambda n=name: z.read(n))
                    entries.setdefault((parts[-4] if len(parts) >= 4 else "", parts[-1]), lambda n=name: z.read(n))
    elif src.is_dir():
        for p in src.rglob("*.png"):
            parts = p.parts
            entries.setdefault((parts[-3], parts[-1]), lambda q=p: q.read_bytes())
            entries.setdefault((parts[-4] if len(parts) >= 4 else "", parts[-1]), lambda q=p: q.read_bytes())
    else:
        print("Not a zip or folder:", src)
        return 1

    missing = []
    for short, (folder, file) in icons.items():
        getter = entries.get((folder, file))
        if getter is None:
            missing.append(short)
            continue
        data = getter()
        if not data.startswith(PNG):
            missing.append(short + " (not a PNG)")
            continue
        (out / f"{short}.png").write_bytes(data)
    print(f"copied {len(icons) - len(missing)} icons to {out}")
    if missing:
        print("not found (use your own):", ", ".join(missing))
    return 0


if __name__ == "__main__":
    sys.exit(main())
