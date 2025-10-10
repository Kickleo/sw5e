#!/usr/bin/env python3
"""Fetches the upstream SW5e equipment compendium and normalizes it for the app."""
from __future__ import annotations

import json
import re
import unicodedata
import urllib.request
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
DEST = ROOT / "assets" / "catalog" / "equipment.json"
SOURCE_URL = "https://raw.githubusercontent.com/sw5e-foundry/sw5e-fvtt-import/main/raw/equipment.json"

POUND_TO_GRAM = 453.59237


def slugify(name: str) -> str:
    normalized = unicodedata.normalize("NFKD", name)
    ascii_name = normalized.encode("ascii", "ignore").decode("ascii")
    ascii_name = ascii_name.lower()
    ascii_name = re.sub(r"[^a-z0-9]+", "-", ascii_name).strip("-")
    if not ascii_name:
        raise ValueError(f"Unable to compute slug for name: {name!r}")
    return ascii_name


def format_type(category: str) -> str:
    # Convert camel case categories like "WeaponOrArmorAccessory" to
    # user-friendly lowercase strings: "weapon or armor accessory".
    spaced = re.sub(r"([a-z0-9])([A-Z])", r"\1 \2", category)
    # Collapse any duplicate spaces introduced by replacements.
    spaced = re.sub(r"\s+", " ", spaced).strip()
    return spaced.lower()


def weight_to_grams(weight: str) -> int:
    pounds = float(weight)
    grams = int(round(pounds * POUND_TO_GRAM))
    return grams


def fetch_source() -> list[dict]:
    with urllib.request.urlopen(SOURCE_URL) as response:  # nosec: B310 - trusted GitHub raw URL
        charset = response.headers.get_content_charset() or "utf-8"
        data = response.read().decode(charset)
    return json.loads(data)


def convert_entries(raw_items: list[dict]) -> list[dict]:
    seen: dict[str, dict] = {}
    for item in raw_items:
        slug = slugify(item["name"])
        if slug in seen:
            # Keep the first occurrence; the upstream dataset occasionally duplicates
            # entries (e.g. EC vs PHB) with identical payloads.
            continue
        converted = {
            "id": slug,
            "name": {
                "en": item["name"],
                "fr": item["name"],  # TODO: add localized translations when available
            },
            "type": format_type(item["equipmentCategory"]),
            "weight_g": weight_to_grams(item["weight"]),
            "cost": int(item["cost"]),
        }
        seen[slug] = converted
    entries = list(seen.values())
    entries.sort(key=lambda entry: entry["name"]["en"].lower())
    return entries


def main() -> None:
    raw_items = fetch_source()
    entries = convert_entries(raw_items)
    DEST.write_text(json.dumps(entries, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(f"Wrote {len(entries)} equipment entries to {DEST.relative_to(ROOT)}")


if __name__ == "__main__":
    main()
