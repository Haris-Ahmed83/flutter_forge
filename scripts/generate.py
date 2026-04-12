"""
====================================================
  Flutter Forge - Daily Project Generator
  Generates 2 Flutter projects per run using Claude AI.
  Writes into beginner/, intermediate/, advanced/ folders.
  Tracks progress in progress.json so no project is skipped.
  Author: HarisAhmed83
====================================================
"""

import json
import os
import re
import sys
from datetime import datetime
from pathlib import Path

import anthropic

ANTHROPIC_KEY = os.environ.get("ANTHROPIC_API_KEY", "")
MODEL = os.environ.get("CLAUDE_MODEL", "claude-sonnet-4-5-20250929")
PROJECTS_PER_RUN = int(os.environ.get("PROJECTS_PER_RUN", "2"))

REPO_ROOT = Path(__file__).resolve().parent.parent
PROJECTS_FILE = REPO_ROOT / "scripts" / "projects.json"
PROGRESS_FILE = REPO_ROOT / "progress.json"

TOKEN_LIMITS = {
    "beginner":     6000,
    "intermediate": 10000,
    "advanced":     16000,
}


def slugify(text: str) -> str:
    s = text.lower().strip()
    s = re.sub(r"[^a-z0-9]+", "-", s)
    return s.strip("-")


def strip_fences(text: str, lang_hint: str = "") -> str:
    t = text.strip()
    t = re.sub(rf"^```(?:{lang_hint}|[a-zA-Z]+)?\n?", "", t)
    t = re.sub(r"\n?```$", "", t.strip())
    return t.strip()


def load_projects():
    with open(PROJECTS_FILE, "r", encoding="utf-8") as f:
        return json.load(f)


def load_progress():
    if PROGRESS_FILE.exists():
        return json.loads(PROGRESS_FILE.read_text(encoding="utf-8"))
    return {"next_number": 1, "completed": [], "last_run": None}


def save_progress(progress: dict):
    PROGRESS_FILE.write_text(
        json.dumps(progress, indent=2) + "\n", encoding="utf-8"
    )


def call_claude(client, prompt: str, max_tokens: int) -> str:
    res = client.messages.create(
        model=MODEL,
        max_tokens=max_tokens,
        messages=[{"role": "user", "content": prompt}],
    )
    return res.content[0].text


def generate_main_dart(client, project: dict, max_tokens: int) -> str:
    prompt = (
        f"Write a complete, production-quality Flutter app in a SINGLE file (lib/main.dart) for:\n\n"
        f"Project: {project['name']}\n"
        f"Category: {project['category']}\n"
        f"Key Concepts: {project['concepts']}\n\n"
        f"STRICT REQUIREMENTS:\n"
        f"1. Entire app in one main.dart — runnable with `flutter run`.\n"
        f"2. Material 3 design (useMaterial3: true).\n"
        f"3. Null safety, proper widget structure, const where possible.\n"
        f"4. Clean, modern UI with good spacing, colors, and typography.\n"
        f"5. Must demonstrate the key concepts: {project['concepts']}.\n"
        f"6. Brief inline comments on non-trivial logic only (no trivial comments).\n"
        f"7. Reasonable default data if the project needs sample content.\n"
        f"8. If the project requires external APIs/SDKs (Firebase, Google Maps, etc.), "
        f"   write the UI + logic with clearly commented TODO hooks for credentials — "
        f"   do NOT put real secrets. The app should still compile.\n\n"
        f"Return ONLY raw Dart code. No markdown. No backticks. No prose."
    )
    return strip_fences(call_claude(client, prompt, max_tokens), "dart")


def generate_pubspec(client, project: dict, package_name: str) -> str:
    prompt = (
        f"Write a pubspec.yaml for a Flutter app.\n\n"
        f"Package name: {package_name}\n"
        f"Project: {project['name']}\n"
        f"Category: {project['category']}\n"
        f"Key Concepts: {project['concepts']}\n\n"
        f"RULES:\n"
        f"- Use environment sdk: '>=3.3.0 <4.0.0', flutter: '>=3.19.0'.\n"
        f"- Include ONLY the dependencies actually needed for the key concepts.\n"
        f"- Use current stable versions.\n"
        f"- Include flutter: uses-material-design: true.\n"
        f"- NO comments except the description line.\n\n"
        f"Return ONLY raw YAML. No markdown. No backticks."
    )
    return strip_fences(call_claude(client, prompt, 1200), "yaml")


def generate_readme(client, project: dict) -> str:
    prompt = (
        f"Write a professional README.md for this Flutter project.\n\n"
        f"Project #{project['number']}: {project['name']}\n"
        f"Category: {project['category'].capitalize()}\n"
        f"Key Concepts: {project['concepts']}\n\n"
        f"Sections (in this order):\n"
        f"# Title with a single relevant emoji\n"
        f"> 1-line tagline\n\n"
        f"## Description (2-3 sentences)\n"
        f"## Features (5-7 bullets)\n"
        f"## Key Concepts Demonstrated (bullets mapping to: {project['concepts']})\n"
        f"## Getting Started (flutter pub get, flutter run)\n"
        f"## Screenshots (placeholder note)\n"
        f"## Author\n"
        f"- HarisAhmed83 — https://github.com/Haris-Ahmed83\n\n"
        f"Part of the [flutter_forge](https://github.com/Haris-Ahmed83/flutter_forge) series.\n\n"
        f"Return ONLY markdown. No backticks wrapping."
    )
    return strip_fences(call_claude(client, prompt, 1500), "markdown")


GITIGNORE_CONTENT = """# Flutter
.dart_tool/
.flutter-plugins
.flutter-plugins-dependencies
.packages
.pub-cache/
.pub/
build/
.idea/
.vscode/
*.iml
*.log
.DS_Store
pubspec.lock
"""


def generate_project(client, project: dict) -> Path:
    number = project["number"]
    category = project["category"]
    name = project["name"]
    slug = slugify(name)
    folder_name = f"{number:02d}-{slug}"
    project_dir = REPO_ROOT / category / folder_name
    package_name = re.sub(r"[^a-z0-9_]", "_", slug).strip("_") or f"project_{number}"

    print(f"\n--- Generating #{number:02d} [{category}] {name} ---")
    max_tokens = TOKEN_LIMITS[category]

    print("  Writing main.dart ...")
    main_dart = generate_main_dart(client, project, max_tokens)

    print("  Writing pubspec.yaml ...")
    pubspec = generate_pubspec(client, project, package_name)

    print("  Writing README.md ...")
    readme = generate_readme(client, project)

    lib_dir = project_dir / "lib"
    lib_dir.mkdir(parents=True, exist_ok=True)
    (lib_dir / "main.dart").write_text(main_dart + "\n", encoding="utf-8")
    (project_dir / "pubspec.yaml").write_text(pubspec + "\n", encoding="utf-8")
    (project_dir / "README.md").write_text(readme + "\n", encoding="utf-8")
    (project_dir / ".gitignore").write_text(GITIGNORE_CONTENT, encoding="utf-8")

    print(f"  -> {category}/{folder_name}")
    return project_dir


def main():
    if not ANTHROPIC_KEY:
        print("ERROR: ANTHROPIC_API_KEY is not set.")
        sys.exit(1)

    projects = load_projects()
    progress = load_progress()
    start = progress["next_number"]
    total = len(projects)

    if start > total:
        print(f"All {total} projects already generated. Nothing to do.")
        return

    print(f"Starting from project #{start}. Will generate {PROJECTS_PER_RUN} project(s) this run.")
    client = anthropic.Anthropic(api_key=ANTHROPIC_KEY)

    generated_numbers = []
    for i in range(PROJECTS_PER_RUN):
        number = start + i
        if number > total:
            break
        project = next((p for p in projects if p["number"] == number), None)
        if project is None:
            print(f"WARN: project #{number} not found in projects.json — stopping.")
            break
        generate_project(client, project)
        generated_numbers.append(number)

    if not generated_numbers:
        print("No projects generated this run.")
        return

    progress["next_number"] = generated_numbers[-1] + 1
    progress["completed"] = sorted(set(progress.get("completed", []) + generated_numbers))
    progress["last_run"] = datetime.utcnow().strftime("%Y-%m-%dT%H:%M:%SZ")
    save_progress(progress)

    print(f"\nGenerated projects: {generated_numbers}")
    print(f"Next project number: {progress['next_number']} / {total}")


if __name__ == "__main__":
    main()
