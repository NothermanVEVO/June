#!/usr/bin/env python3
"""junes.py - build, install, and export .junes song bundles for June.

A .junes file is a ZIP (deflate) archive that mirrors June's user:// song
data (see june/Global/Global.gd: SONGS_PATH="user://songs",
SIDE_EDITOR_PATH="user://sideeditor"). Its only top-level entries are
`songs/...` and/or `sideeditor/...`; at least one must be present.

Subcommands:
    pack             build a .junes file from a source folder
    install          install June and extract a .junes into user://
    export           bundle a .junes into the Godot export
    build-installer  build a standalone JuneInstaller executable
                     (PyInstaller, build machine only) embedding a .junes

is_valid_entry must accept exactly the same entries as
Global._is_valid_bundled_entry in june/Global/Global.gd.
"""
from __future__ import annotations

import argparse
import importlib.util
import os
import shutil
import subprocess
import sys
import tempfile
import time
import zipfile
from pathlib import Path

ALLOWED_ROOTS = ("songs", "sideeditor")


class JunesError(Exception):
    """A user-facing error (bad source folder, corrupt/unsafe .junes, ...)."""


def is_valid_entry(name: str) -> bool:
    """True if a .junes zip entry is a folder or file under an allowed root, with no unsafe path parts."""
    is_folder = name.endswith("/")
    parts = name.removesuffix("/").split("/")
    return (
        "\\" not in name
        and ":" not in name
        and parts[0] in ALLOWED_ROOTS
        and (is_folder or len(parts) > 1)
        and not any(part in ("", ".", "..") for part in parts)
    )


def validate_junes(junes_path: Path) -> None:
    """Raise JunesError if the .junes archive is empty or has an unsafe or unrecognized entry."""
    with zipfile.ZipFile(junes_path) as zf:
        names = zf.namelist()
    if not names:
        raise JunesError(f"{junes_path} is empty")
    for name in names:
        if not is_valid_entry(name):
            raise JunesError(f"unsafe or unrecognized entry in {junes_path}: {name}")


def godot_user_data_dir() -> Path:
    """Return June's Godot user:// directory (config/use_custom_user_dir, no custom name)."""
    if sys.platform == "win32":
        return Path(os.environ["APPDATA"]) / "June"
    xdg_data_home = os.environ.get("XDG_DATA_HOME")
    base = Path(xdg_data_home) if xdg_data_home else Path.home() / ".local" / "share"
    return base / "June"


def extract_junes(junes_path: Path, dest_dir: Path, overwrite: bool = False) -> list[str]:
    """Extract a .junes archive into dest_dir, mirroring user://.

    Rejects the whole archive if any entry is unsafe or outside the allowed
    roots. Existing files are left alone unless overwrite is True. Returns
    the entry names that were written.
    """
    written = []
    validate_junes(junes_path)
    with zipfile.ZipFile(junes_path) as zf:
        for info in zf.infolist():
            if info.is_dir():
                continue
            target = dest_dir.joinpath(*info.filename.split("/"))
            if target.exists() and not overwrite:
                continue
            target.parent.mkdir(parents=True, exist_ok=True)
            with zf.open(info) as src, open(target, "wb") as dst:
                shutil.copyfileobj(src, dst)
            written.append(info.filename)
    return written


def find_source_roots(source_dir: Path) -> dict[str, Path]:
    """Return {root_name: path} for whichever allowed roots exist under source_dir.

    A `sideeditor` folder is accepted either directly under source_dir or
    nested as `sidesongs/sideeditor`; both are stored as `sideeditor/`.
    """
    roots = {}
    songs = source_dir / "songs"
    if songs.is_dir():
        roots["songs"] = songs
    sideeditor = source_dir / "sideeditor"
    if not sideeditor.is_dir():
        sideeditor = source_dir / "sidesongs" / "sideeditor"
    if sideeditor.is_dir():
        roots["sideeditor"] = sideeditor
    return roots


def pack(source_dir: Path, output: Path) -> None:
    """Zip source_dir's songs/ and/or sideeditor/ into output as a .junes file."""
    roots = find_source_roots(source_dir)
    if not roots:
        raise JunesError(
            f"{source_dir} has neither songs/ nor sideeditor/ "
            "(also checked sidesongs/sideeditor/)"
        )
    entry_count = 0
    with zipfile.ZipFile(output, "w", zipfile.ZIP_DEFLATED) as zf:
        for root_name, root_path in roots.items():
            for path in sorted(root_path.rglob("*")):
                if path.is_dir():
                    continue
                rel_parts = path.relative_to(root_path).parts
                arcname = "/".join((root_name, *rel_parts))
                if not is_valid_entry(arcname):
                    raise JunesError(f"refusing to pack unsafe file name: {path}")
                zf.write(path, arcname)
                entry_count += 1
    if entry_count == 0:
        output.unlink(missing_ok=True)
        raise JunesError(f"{source_dir} has songs/ and/or sideeditor/ but no files inside them")


def default_install_dir() -> Path:
    """Where June gets installed by default, per platform."""
    if sys.platform == "win32":
        return Path(os.environ["LOCALAPPDATA"]) / "Programs" / "June"
    return Path.home() / ".local" / "opt" / "June"


def launch_detached(executable: Path) -> None:
    """Launch executable without tying its lifetime to this process."""
    if sys.platform == "win32":
        subprocess.Popen([str(executable)], creationflags=subprocess.DETACHED_PROCESS)
    else:
        subprocess.Popen([str(executable)], start_new_session=True)


def stop_process(proc: subprocess.Popen) -> None:
    proc.terminate()
    try:
        proc.wait(timeout=5)
    except subprocess.TimeoutExpired:
        proc.kill()
        proc.wait()


def install_june(executable: Path, junes_path: Path, install_dir: Path) -> Path:
    """Install June into install_dir, seed it with junes_path's songs, then relaunch it.

    1. copy executable into install_dir (chmod +x on Linux)
    2. launch it briefly so it creates its own user:// dirs
    3. terminate it
    4. extract junes_path into the Godot user data dir, overwriting
    5. launch June again, detached, and return

    Reused as-is by june_installer.py.
    """
    if not executable.is_file():
        raise JunesError(f"{executable} is not a file")
    if not junes_path.is_file():
        raise JunesError(f"{junes_path} is not a file")
    validate_junes(junes_path)

    install_dir.mkdir(parents=True, exist_ok=True)
    target = install_dir / executable.name
    shutil.copy2(executable, target)
    if sys.platform != "win32":
        target.chmod(target.stat().st_mode | 0o111)

    proc = subprocess.Popen([str(target)])
    try:
        time.sleep(3)
    finally:
        stop_process(proc)

    extract_junes(junes_path, godot_user_data_dir(), overwrite=True)

    launch_detached(target)
    return target


def default_preset() -> str:
    """Which export_presets.cfg preset to use by default, per platform."""
    return "June Windows" if sys.platform == "win32" else "June Linux"


def find_godot() -> Path:
    """Find the Godot binary via the GODOT env var, else "godot" on PATH."""
    env_godot = os.environ.get("GODOT")
    if env_godot:
        return Path(env_godot)
    found = shutil.which("godot")
    if not found:
        raise JunesError("godot not found (set --godot, the GODOT env var, or add it to PATH)")
    return Path(found)


def export(junes_path: Path, output: Path, godot: Path, preset: str) -> int:
    """Bundle junes_path into the Godot project and run a headless export.

    Copies junes_path to June/june/bundled_songs.junes, runs Godot's headless
    exporter, then restores the project to its original state (backing up
    and restoring any bundled_songs.junes that was already there). Returns
    Godot's exit code.
    """
    if not junes_path.is_file():
        raise JunesError(f"{junes_path} is not a file")
    validate_junes(junes_path)
    output.parent.mkdir(parents=True, exist_ok=True)

    project_dir = Path(__file__).resolve().parent.parent / "june"
    bundled = project_dir / "bundled_songs.junes"
    backup = bundled.with_suffix(".junes.backup")

    had_bundled = bundled.exists()
    if had_bundled:
        bundled.replace(backup)
    try:
        shutil.copy2(junes_path, bundled)
        result = subprocess.run([
            str(godot),
            "--headless",
            "--path", str(project_dir),
            "--export-release", preset,
            str(output.resolve()),
        ])
        return result.returncode
    finally:
        bundled.unlink(missing_ok=True)
        if had_bundled:
            backup.replace(bundled)


def build_installer(junes_path: Path, dist_dir: Path) -> int:
    """Build a onefile JuneInstaller executable (for this OS) with junes_path embedded.

    Runs PyInstaller on tools/june_installer.py; build files and the .spec go
    to a temp dir, the executable to dist_dir. Returns PyInstaller's exit code.
    """
    if not junes_path.is_file():
        raise JunesError(f"{junes_path} is not a file")
    validate_junes(junes_path)
    if importlib.util.find_spec("PyInstaller") is None:
        raise JunesError("PyInstaller is not installed: pip install pyinstaller")

    entry_script = Path(__file__).resolve().parent / "june_installer.py"
    with tempfile.TemporaryDirectory() as work_dir:
        result = subprocess.run([
            sys.executable, "-m", "PyInstaller",
            "--onefile",
            "--name", "JuneInstaller",
            "--add-data", f"{junes_path.resolve()}{os.pathsep}.",
            "--distpath", str(dist_dir.resolve()),
            "--workpath", work_dir,
            "--specpath", work_dir,
            str(entry_script),
        ])
    return result.returncode


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        prog="junes.py", description="Pack, install, export, and build installers for .junes song bundles for June."
    )
    sub = parser.add_subparsers(dest="command", required=True)

    pack_parser = sub.add_parser("pack", help="Pack a songs/sideeditor folder into a .junes file")
    pack_parser.add_argument("source_dir", type=Path, help="folder containing songs/ and/or sideeditor/")
    pack_parser.add_argument("-o", "--output", type=Path, help="output .junes path (default: <source_dir name>.junes in cwd)")

    install_parser = sub.add_parser("install", help="Install June and extract a .junes into user://")
    install_parser.add_argument("executable", type=Path, help="June executable to install")
    install_parser.add_argument("junes_file", type=Path, help=".junes file to extract after install")
    install_parser.add_argument("--install-dir", type=Path, help="installation directory (default: platform-specific)")

    export_parser = sub.add_parser("export", help="Bundle a .junes into a headless Godot export")
    export_parser.add_argument("junes_file", type=Path, help=".junes file to embed in the build")
    export_parser.add_argument("output", type=Path, help="export output path (e.g. June.exe)")
    export_parser.add_argument("--godot", type=Path, help="Godot binary (default: $GODOT or 'godot' on PATH)")
    export_parser.add_argument("--preset", help="export_presets.cfg preset (default: June Windows/Linux)")

    installer_parser = sub.add_parser("build-installer", help="Build a standalone JuneInstaller executable with a .junes embedded")
    installer_parser.add_argument("junes_file", type=Path, help=".junes file to embed in the installer")
    installer_parser.add_argument("-o", "--dist-dir", type=Path, default=Path("dist"), help="output folder (default: ./dist)")

    return parser


def main(argv: list[str] | None = None) -> int:
    parser = build_parser()
    args = parser.parse_args(argv)

    try:
        if args.command == "pack":
            if not args.source_dir.is_dir():
                raise JunesError(f"{args.source_dir} is not a directory")
            output = args.output or Path.cwd() / f"{args.source_dir.resolve().name}.junes"
            pack(args.source_dir, output)
            print(f"wrote {output}")
        elif args.command == "install":
            install_dir = args.install_dir or default_install_dir()
            target = install_june(args.executable, args.junes_file, install_dir)
            print(f"installed June to {target}")
        elif args.command == "export":
            godot = args.godot or find_godot()
            preset = args.preset or default_preset()
            return export(args.junes_file, args.output, godot, preset)
        elif args.command == "build-installer":
            return build_installer(args.junes_file, args.dist_dir)
    except (JunesError, zipfile.BadZipFile, OSError) as e:
        parser.error(str(e))

    return 0


if __name__ == "__main__":
    sys.exit(main())
