# One-off: reads phrase_seedv1.json (fallback phrases_seed.json)
# and emits tool/_phrase_seed_run.sql for Supabase MCP.
import json
from pathlib import Path


def esc(s: str) -> str:
    return "'" + s.replace("'", "''") + "'"


def main() -> None:
    root = Path(__file__).resolve().parent.parent
    seed_v1 = root / "phrase_seedv1.json"
    path = seed_v1 if seed_v1.exists() else (root / "phrases_seed.json")
    data = json.loads(path.read_text(encoding="utf-8"))
    phrases = data["phrases"]

    val_rows: list[str] = []
    for p in phrases:
        val_rows.append(
            "  ("
            + ", ".join(
                [
                    esc(p["urdu_phrase"]),
                    esc(p["romanised"]),
                    esc(p["correct_meaning"]),
                    esc(p["example_sentence"]),
                    esc(p["category"]),
                    esc(p["difficulty"]),
                    esc(p.get("image_url") or ""),
                    esc(p.get("reveal_url") or ""),
                    "true",
                ]
            )
            + ")"
        )

    urdu_list = ", ".join(esc(p["urdu_phrase"]) for p in phrases)

    wo_rows: list[str] = []
    po_rows: list[str] = []
    for p in phrases:
        pid = f"(SELECT id FROM phrases WHERE urdu_phrase = {esc(p['urdu_phrase'])} LIMIT 1)"
        for w in p["wrong_options"]:
            wo_rows.append(f"  ({pid}, {esc(w)})")
        phrase_options = p.get("phrase_options") or {}
        correct_phrase = phrase_options.get("correct") or p["urdu_phrase"]
        po_rows.append(f"  ({pid}, {esc(correct_phrase)}, true)")
        for w in phrase_options.get("wrong", []):
            po_rows.append(f"  ({pid}, {esc(w)}, false)")

    lines = [
        "BEGIN;",
        "",
        "INSERT INTO phrases (urdu_phrase, romanised, meaning_urdu, example_sentence, category, difficulty, image_url, reveal_image_url, is_active)",
        "VALUES",
        ",\n".join(val_rows),
        """ON CONFLICT (urdu_phrase) DO UPDATE SET
  romanised = EXCLUDED.romanised,
  meaning_urdu = EXCLUDED.meaning_urdu,
  example_sentence = EXCLUDED.example_sentence,
  category = EXCLUDED.category,
  difficulty = EXCLUDED.difficulty,
  image_url = EXCLUDED.image_url,
  reveal_image_url = EXCLUDED.reveal_image_url,
  is_active = EXCLUDED.is_active;""",
        "",
        "DELETE FROM wrong_options WHERE phrase_id IN (SELECT id FROM phrases WHERE urdu_phrase IN (" + urdu_list + "));",
        "DELETE FROM phrase_options WHERE phrase_id IN (SELECT id FROM phrases WHERE urdu_phrase IN (" + urdu_list + "));",
        "",
        "INSERT INTO wrong_options (phrase_id, option_text)",
        "VALUES",
        ",\n".join(wo_rows) + ";",
        "",
        "INSERT INTO phrase_options (phrase_id, option_text, is_correct)",
        "VALUES",
        ",\n".join(po_rows) + ";",
        "",
        "COMMIT;",
    ]

    out = root / "tool" / "_phrase_seed_run.sql"
    out.write_text("\n".join(lines), encoding="utf-8")


if __name__ == "__main__":
    main()
