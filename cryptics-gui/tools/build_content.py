"""Turn the content spreadsheets into data for the design board AND the Roblox game.
Skill Made By : Crypticplay_RBLX - Only on Youtube

    python tools/build_content.py <content folder> <out folder>

<content folder> holds the CSV sheets (open/edit them in Excel or Google Sheets, save as CSV):
    currencies.csv  id,name,icon,amount
    pets.csv        id,name,rarity,power,icon,tags,equipped,locked
    shop.csv        id,section,name,description,price,currency,old_price,product_id,pass_id,gives,badge,icon,ends_in_seconds,rarity
    boosts.csv      id,name,icon,multiplier,seconds_left
    text.csv        key,text
Writes:
    <out>/content.json   read by the HTML board (assets/templates/content.js)
    <out>/UIContent.lua  ModuleScript for ReplicatedStorage (UIKit + Purchases.server.lua read it)

Empty cells stay empty (null): the board shows a labelled placeholder and the game shows nothing —
values are NEVER invented. Problems are listed; exit code 1 if any row is invalid. Standard library only.
"""
import csv
import json
import pathlib
import re
import sys

RARITIES = ["Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythic", "Secret"]
SHEETS = {
    "currencies": ["id", "name", "icon", "amount"],
    "pets": ["id", "name", "rarity", "power", "icon", "tags", "equipped", "locked"],
    "shop": ["id", "section", "name", "description", "price", "currency", "old_price", "product_id", "pass_id",
             "gives", "badge", "icon", "ends_in_seconds", "rarity"],
    "boosts": ["id", "name", "icon", "multiplier", "seconds_left"],
    "text": ["key", "text"],
}
NUMBER_FIELDS = {"amount", "power", "price", "old_price", "product_id", "pass_id", "multiplier", "seconds_left",
                 "ends_in_seconds"}
BOOL_FIELDS = {"equipped", "locked"}

problems: list[str] = []


def num(sheet: str, row: int, field: str, raw: str):
    s = raw.strip().replace(",", "").replace("_", "")
    if s == "":
        return None
    m = re.fullmatch(r"(-?\d+(?:\.\d+)?)\s*([kKmMbBtT]?)", s)
    if not m:
        problems.append(f"{sheet}.csv row {row}: '{field}' must be a number, got '{raw}'")
        return None
    v = float(m.group(1)) * {"": 1, "k": 1e3, "m": 1e6, "b": 1e9, "t": 1e12}[m.group(2).lower()]
    return int(v) if v.is_integer() else v


def load(folder: pathlib.Path, sheet: str):
    p = folder / f"{sheet}.csv"
    if not p.exists():
        return []
    with p.open(newline="", encoding="utf-8-sig") as f:
        reader = csv.DictReader(f)
        missing = [c for c in SHEETS[sheet] if c not in (reader.fieldnames or [])]
        if missing:
            problems.append(f"{sheet}.csv: missing column(s) {', '.join(missing)}")
        rows = []
        for i, r in enumerate(reader, start=2):
            if not any((v or "").strip() for v in r.values()):
                continue
            out = {}
            for k in SHEETS[sheet]:
                raw = (r.get(k) or "").strip()
                if k in NUMBER_FIELDS:
                    out[k] = num(sheet, i, k, raw)
                elif k in BOOL_FIELDS:
                    out[k] = raw.lower() in ("1", "yes", "true", "y", "x") if raw else None
                else:
                    out[k] = raw or None
            out["_row"] = i
            rows.append(out)
        return rows


def lua(v, indent=1) -> str:
    pad = "\t" * indent
    if v is None:
        return "nil"
    if isinstance(v, bool):
        return "true" if v else "false"
    if isinstance(v, (int, float)):
        return repr(v)
    if isinstance(v, str):
        return json.dumps(v, ensure_ascii=False)
    if isinstance(v, list):
        if not v:
            return "{}"
        return "{\n" + ",\n".join(pad + lua(x, indent + 1) for x in v) + ",\n" + "\t" * (indent - 1) + "}"
    if isinstance(v, dict):
        items = [(k, x) for k, x in v.items() if x is not None and not k.startswith("_")]
        if not items:
            return "{}"
        parts = []
        for k, x in items:
            key = k if re.fullmatch(r"[A-Za-z_][A-Za-z0-9_]*", k) else "[" + json.dumps(k) + "]"
            parts.append(f"{pad}{key} = {lua(x, indent + 1)}")
        return "{\n" + ",\n".join(parts) + ",\n" + "\t" * (indent - 1) + "}"
    raise TypeError(type(v))


def main() -> int:
    if len(sys.argv) != 3:
        print(__doc__)
        return 2
    src, out = pathlib.Path(sys.argv[1]), pathlib.Path(sys.argv[2])
    data = {s: load(src, s) for s in SHEETS}

    currency_ids = {c["id"] for c in data["currencies"] if c["id"]}
    for sheet in ("currencies", "pets", "shop", "boosts"):
        seen = set()
        for r in data[sheet]:
            if not r["id"]:
                problems.append(f"{sheet}.csv row {r['_row']}: needs an id")
            elif r["id"] in seen:
                problems.append(f"{sheet}.csv row {r['_row']}: duplicate id '{r['id']}'")
            seen.add(r["id"])
    for p in data["pets"] + data["shop"]:
        if p["rarity"] and p["rarity"] not in RARITIES:
            problems.append(f"{'pets' if 'power' in p else 'shop'}.csv row {p['_row']}: rarity '{p['rarity']}' must be one of {', '.join(RARITIES)}")
    for s in data["shop"]:
        cur = (s["currency"] or "").strip()
        if cur and cur.lower() != "robux" and cur not in currency_ids:
            problems.append(f"shop.csv row {s['_row']}: currency '{cur}' is not 'robux' or an id in currencies.csv")
        if cur.lower() == "robux" and s["price"] is not None and not (s["product_id"] or s["pass_id"]):
            problems.append(f"shop.csv row {s['_row']}: a Robux item needs product_id or pass_id "
                            f"(Creator Dashboard > Monetization) - it can't be sold without one")
        if s["product_id"] and s["pass_id"]:
            problems.append(f"shop.csv row {s['_row']}: set product_id OR pass_id, not both")

    text = {t["key"]: t["text"] for t in data["text"] if t["key"]}
    content = {
        "currencies": {c["id"]: c for c in data["currencies"] if c["id"]},
        "pets": data["pets"],
        "shop": data["shop"],
        "boosts": {b["id"]: b for b in data["boosts"] if b["id"]},
        "text": text,
    }

    out.mkdir(parents=True, exist_ok=True)
    clean = json.loads(json.dumps(content, default=str))
    for k in ("pets", "shop"):
        for r in clean[k]:
            r.pop("_row", None)
    for k in ("currencies", "boosts"):
        for r in clean[k].values():
            r.pop("_row", None)
    (out / "content.json").write_text(json.dumps(clean, indent=1, ensure_ascii=False), encoding="utf-8", newline="\n")

    module = ("-- UIContent (ModuleScript, ReplicatedStorage) — GENERATED by tools/build_content.py from the content\n"
              "-- spreadsheets. Edit the CSVs and rebuild; don't edit this file by hand.\n"
              "-- Skill Made By : Crypticplay_RBLX - Only on Youtube\n"
              "return " + lua(clean) + "\n")
    (out / "UIContent.lua").write_text(module, encoding="utf-8", newline="\n")

    counts = ", ".join(f"{len(v)} {k}" for k, v in clean.items())
    print(f"wrote content.json + UIContent.lua ({counts})")
    empty = [f"pets.csv row {p['_row']} ({p['id']}): " + ", ".join(k for k in ("name", "rarity", "power", "icon") if p[k] is None)
             for p in data["pets"] if any(p[k] is None for k in ("name", "rarity", "power", "icon"))]
    empty += [f"shop.csv row {s['_row']} ({s['id']}): " + ", ".join(k for k in ("name", "price", "currency", "icon") if s[k] is None)
              for s in data["shop"] if any(s[k] is None for k in ("name", "price", "currency", "icon"))]
    if empty:
        print("still empty (shown as placeholders):")
        for e in empty:
            print("  " + e)
    if problems:
        print("PROBLEMS:")
        for p in problems:
            print("  " + p)
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
