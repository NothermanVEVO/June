#!/usr/bin/env python3
"""june_installer.py - entry script of the standalone JuneInstaller executable.

Built by `python tools/junes.py build-installer <file.junes>` (PyInstaller
onefile, with the .junes embedded). At runtime it downloads the latest June
release for this OS from GitHub, then hands off to junes.install_june.
"""
from __future__ import annotations

import json
import shutil
import sys
import tempfile
import urllib.error
import urllib.request
import zipfile
from pathlib import Path

import junes

RELEASES_URL = "https://api.github.com/repos/NothermanVEVO/June/releases/latest"
USER_AGENT = "JuneInstaller"
IS_WINDOWS = sys.platform == "win32"


def open_url(url: str, timeout: int):
    request = urllib.request.Request(url, headers={"User-Agent": USER_AGENT})
    return urllib.request.urlopen(request, timeout=timeout)


def fetch_latest_release() -> dict:
    with open_url(RELEASES_URL, timeout=30) as response:
        return json.load(response)


def pick_asset(release: dict) -> dict:
    os_name = "windows" if IS_WINDOWS else "linux"
    for asset in release.get("assets", []):
        name = asset["name"].lower()
        if name.endswith(".zip") and os_name in name:
            return asset
    raise junes.JunesError(f"the latest June release ({release.get('tag_name')}) has no {os_name} download")


def download(url: str, dest: Path) -> None:
    with open_url(url, timeout=120) as response, open(dest, "wb") as out:
        shutil.copyfileobj(response, out)


def find_binary(folder: Path) -> Path:
    pattern = "*.exe" if IS_WINDOWS else "*.x86_64"
    found = sorted(folder.rglob(pattern))
    if not found:
        raise junes.JunesError(f"the downloaded release contains no {pattern} file")
    return found[0]


def bundled_junes() -> Path:
    bundle_dir = Path(getattr(sys, "_MEIPASS", Path(__file__).parent))
    found = sorted(bundle_dir.glob("*.junes"))
    if not found:
        raise junes.JunesError("this installer has no embedded .junes file")
    return found[0]


def run() -> None:
    songs = bundled_junes()
    print("Checking the latest June release on GitHub...")
    release = fetch_latest_release()
    asset = pick_asset(release)
    with tempfile.TemporaryDirectory(ignore_cleanup_errors=True) as tmp:
        tmp_dir = Path(tmp)
        archive = tmp_dir / "release.zip"
        print(f"Downloading {asset['name']} ({release.get('tag_name')})...")
        download(asset["browser_download_url"], archive)
        print("Extracting...")
        with zipfile.ZipFile(archive) as zf:
            zf.extractall(tmp_dir / "release")
        executable = find_binary(tmp_dir / "release")
        install_dir = junes.default_install_dir()
        print(f"Installing June to {install_dir} and adding songs (June opens briefly)...")
        target = junes.install_june(executable, songs, install_dir)
    print(f"Done! June is installed at {target} and is starting now.")


def fail(message: str) -> int:
    print(f"\nInstallation failed: {message}")
    if IS_WINDOWS:
        input("Press Enter to close...")
    return 1


def main() -> int:
    try:
        run()
    except urllib.error.HTTPError as e:
        if e.code in (403, 429):
            return fail(f"GitHub refused the request (HTTP {e.code}), probably its rate limit. Wait a while and try again.")
        return fail(f"GitHub returned HTTP {e.code} ({e.reason}).")
    except (urllib.error.URLError, TimeoutError) as e:
        return fail(f"could not reach GitHub ({getattr(e, 'reason', e)}). Check your internet connection.")
    except zipfile.BadZipFile:
        return fail("the downloaded release is not a valid zip file.")
    except Exception as e:
        return fail(str(e) or type(e).__name__)
    return 0


if __name__ == "__main__":
    sys.exit(main())
