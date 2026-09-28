"""Tests for junes.py and june_installer.py."""
from __future__ import annotations

import contextlib
import io
import json
import os
import stat
import sys
import tempfile
import time
import unittest
import urllib.error
import zipfile
from pathlib import Path
from unittest import mock

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

import junes
import june_installer


class IsValidEntryTests(unittest.TestCase):
    def test_accepts_file_under_songs(self):
        self.assertTrue(junes.is_valid_entry("songs/a"))

    def test_accepts_file_under_sideeditor(self):
        self.assertTrue(junes.is_valid_entry("sideeditor/x.tres"))

    def test_accepts_folder_entry(self):
        self.assertTrue(junes.is_valid_entry("songs/"))

    def test_accepts_nested_folder_entry(self):
        self.assertTrue(junes.is_valid_entry("songs/sub/"))

    def test_rejects_double_slash(self):
        self.assertFalse(junes.is_valid_entry("songs//x"))

    def test_rejects_dot_segment(self):
        self.assertFalse(junes.is_valid_entry("songs/./x"))

    def test_rejects_parent_dir_escape(self):
        self.assertFalse(junes.is_valid_entry("../x"))

    def test_rejects_absolute_path(self):
        self.assertFalse(junes.is_valid_entry("/songs/x"))

    def test_rejects_windows_drive(self):
        self.assertFalse(junes.is_valid_entry("C:/x"))

    def test_rejects_backslash(self):
        self.assertFalse(junes.is_valid_entry("songs\\x"))

    def test_rejects_bare_root_name(self):
        self.assertFalse(junes.is_valid_entry("songs"))

    def test_rejects_other_root(self):
        self.assertFalse(junes.is_valid_entry("other/x"))


class ValidateJunesTests(unittest.TestCase):
    def setUp(self):
        self.tmp_dir = tempfile.TemporaryDirectory()
        self.addCleanup(self.tmp_dir.cleanup)

    def make_zip(self, names):
        path = Path(self.tmp_dir.name) / "test.junes"
        with zipfile.ZipFile(path, "w") as zf:
            for name in names:
                zf.writestr(name, "data")
        return path

    def test_empty_zip_raises(self):
        path = self.make_zip([])
        with self.assertRaises(junes.JunesError):
            junes.validate_junes(path)

    def test_bad_entry_raises(self):
        path = self.make_zip(["songs/a", "../evil"])
        with self.assertRaises(junes.JunesError):
            junes.validate_junes(path)

    def test_corrupt_file_raises_bad_zip_file(self):
        path = Path(self.tmp_dir.name) / "corrupt.junes"
        path.write_bytes(b"not a zip file")
        with self.assertRaises(zipfile.BadZipFile):
            junes.validate_junes(path)


class PackTests(unittest.TestCase):
    def setUp(self):
        self.tmp_dir = tempfile.TemporaryDirectory()
        self.addCleanup(self.tmp_dir.cleanup)
        self.source_dir = Path(self.tmp_dir.name) / "source"
        self.output = Path(self.tmp_dir.name) / "out.junes"

    def write_songs(self):
        songs = self.source_dir / "songs"
        songs.mkdir(parents=True)
        (songs / "track.mp3.tres").write_text("song data")

    def write_sideeditor(self):
        sideeditor = self.source_dir / "sideeditor"
        sideeditor.mkdir(parents=True)
        (sideeditor / "a.tres").write_text("side data")

    def test_error_when_neither_root_exists(self):
        self.source_dir.mkdir()
        with self.assertRaises(junes.JunesError):
            junes.pack(self.source_dir, self.output)

    def test_error_when_roots_exist_but_are_empty(self):
        (self.source_dir / "songs").mkdir(parents=True)
        with self.assertRaises(junes.JunesError):
            junes.pack(self.source_dir, self.output)
        self.assertFalse(self.output.exists())

    def test_packs_songs_and_sideeditor(self):
        self.source_dir.mkdir()
        self.write_songs()
        self.write_sideeditor()
        junes.pack(self.source_dir, self.output)
        with zipfile.ZipFile(self.output) as zf:
            names = set(zf.namelist())
        self.assertEqual(names, {"songs/track.mp3.tres", "sideeditor/a.tres"})

    def test_packs_nested_sidesongs_sideeditor(self):
        self.source_dir.mkdir()
        self.write_songs()
        nested = self.source_dir / "sidesongs" / "sideeditor"
        nested.mkdir(parents=True)
        (nested / "b.tres").write_text("nested side data")
        junes.pack(self.source_dir, self.output)
        with zipfile.ZipFile(self.output) as zf:
            names = set(zf.namelist())
        self.assertEqual(names, {"songs/track.mp3.tres", "sideeditor/b.tres"})

    def test_round_trip_pack_and_extract(self):
        self.source_dir.mkdir()
        self.write_songs()
        self.write_sideeditor()
        junes.pack(self.source_dir, self.output)
        dest = Path(self.tmp_dir.name) / "dest"
        written = junes.extract_junes(self.output, dest)
        self.assertEqual(set(written), {"songs/track.mp3.tres", "sideeditor/a.tres"})
        self.assertEqual((dest / "songs" / "track.mp3.tres").read_text(), "song data")
        self.assertEqual((dest / "sideeditor" / "a.tres").read_text(), "side data")


class ExtractJunesOverwriteTests(unittest.TestCase):
    def setUp(self):
        self.tmp_dir = tempfile.TemporaryDirectory()
        self.addCleanup(self.tmp_dir.cleanup)
        self.junes_path = Path(self.tmp_dir.name) / "songs.junes"
        with zipfile.ZipFile(self.junes_path, "w") as zf:
            zf.writestr("songs/a.tres", "new content")
        self.dest = Path(self.tmp_dir.name) / "dest"
        (self.dest / "songs").mkdir(parents=True)
        (self.dest / "songs" / "a.tres").write_text("old content")

    def test_overwrite_false_keeps_existing_file(self):
        written = junes.extract_junes(self.junes_path, self.dest, overwrite=False)
        self.assertEqual(written, [])
        self.assertEqual((self.dest / "songs" / "a.tres").read_text(), "old content")

    def test_overwrite_true_replaces_existing_file(self):
        written = junes.extract_junes(self.junes_path, self.dest, overwrite=True)
        self.assertEqual(written, ["songs/a.tres"])
        self.assertEqual((self.dest / "songs" / "a.tres").read_text(), "new content")


class MainCliTests(unittest.TestCase):
    def setUp(self):
        self.tmp_dir = tempfile.TemporaryDirectory()
        self.addCleanup(self.tmp_dir.cleanup)

    def test_pack_default_output_name(self):
        source_dir = Path(self.tmp_dir.name) / "mysongs"
        (source_dir / "songs").mkdir(parents=True)
        (source_dir / "songs" / "a.tres").write_text("data")
        cwd = os.getcwd()
        os.chdir(self.tmp_dir.name)
        try:
            with contextlib.redirect_stdout(io.StringIO()):
                exit_code = junes.main(["pack", str(source_dir)])
        finally:
            os.chdir(cwd)
        self.assertEqual(exit_code, 0)
        self.assertTrue((Path(self.tmp_dir.name) / "mysongs.junes").is_file())

    def test_bad_input_exits_with_code_2(self):
        missing = Path(self.tmp_dir.name) / "does-not-exist"
        with contextlib.redirect_stderr(io.StringIO()):
            with self.assertRaises(SystemExit) as ctx:
                junes.main(["pack", str(missing)])
        self.assertEqual(ctx.exception.code, 2)


class ExportTests(unittest.TestCase):
    def setUp(self):
        self.tmp_dir = tempfile.TemporaryDirectory()
        self.addCleanup(self.tmp_dir.cleanup)
        self.junes_path = Path(self.tmp_dir.name) / "songs.junes"
        with zipfile.ZipFile(self.junes_path, "w") as zf:
            zf.writestr("songs/a.tres", "data")
        self.output = Path(self.tmp_dir.name) / "out" / "June.export"
        self.project_dir = Path(junes.__file__).resolve().parent.parent / "june"
        self.bundled = self.project_dir / "bundled_songs.junes"
        self.backup = self.bundled.with_suffix(".junes.backup")
        self.addCleanup(self.bundled.unlink, missing_ok=True)
        self.addCleanup(self.backup.unlink, missing_ok=True)

    def make_fake_godot(self, exit_code, record_path):
        script = Path(self.tmp_dir.name) / f"fake_godot_{exit_code}.py"
        script.write_text(
            "#!/usr/bin/env python3\n"
            "import json, pathlib, sys\n"
            f"record = {{'argv': sys.argv, 'bundled_exists': pathlib.Path({str(self.bundled)!r}).is_file()}}\n"
            f"pathlib.Path({str(record_path)!r}).write_text(json.dumps(record))\n"
            f"sys.exit({exit_code})\n"
        )
        script.chmod(0o755)
        return script

    def test_runs_godot_with_expected_argv_and_propagates_exit_code(self):
        record_path = Path(self.tmp_dir.name) / "record.json"
        godot = self.make_fake_godot(7, record_path)
        exit_code = junes.export(self.junes_path, self.output, godot, "June Linux")
        self.assertEqual(exit_code, 7)
        record = json.loads(record_path.read_text())
        self.assertTrue(record["bundled_exists"])
        self.assertEqual(record["argv"][0], str(godot))
        self.assertIn("--headless", record["argv"])
        self.assertIn("June Linux", record["argv"])
        self.assertIn(str(self.output.resolve()), record["argv"])

    def test_removes_bundled_file_when_none_existed_before(self):
        record_path = Path(self.tmp_dir.name) / "record.json"
        godot = self.make_fake_godot(0, record_path)
        junes.export(self.junes_path, self.output, godot, "June Linux")
        self.assertFalse(self.bundled.exists())
        self.assertFalse(self.backup.exists())

    def test_restores_preexisting_bundled_file(self):
        self.bundled.write_text("original content")
        record_path = Path(self.tmp_dir.name) / "record.json"
        godot = self.make_fake_godot(0, record_path)
        junes.export(self.junes_path, self.output, godot, "June Linux")
        self.assertTrue(self.bundled.is_file())
        self.assertEqual(self.bundled.read_text(), "original content")
        self.assertFalse(self.backup.exists())

    def test_restores_preexisting_bundled_file_when_godot_missing(self):
        self.bundled.write_text("original content")
        missing_godot = Path(self.tmp_dir.name) / "no-such-godot"
        with self.assertRaises(OSError):
            junes.export(self.junes_path, self.output, missing_godot, "June Linux")
        self.assertTrue(self.bundled.is_file())
        self.assertEqual(self.bundled.read_text(), "original content")
        self.assertFalse(self.backup.exists())


class InstallJuneTests(unittest.TestCase):
    def setUp(self):
        self.tmp_dir = tempfile.TemporaryDirectory()
        self.addCleanup(self.tmp_dir.cleanup)
        self.base = Path(self.tmp_dir.name)
        home_dir = self.base / "home"
        xdg_data_home = self.base / "xdg-data"
        home_dir.mkdir()
        xdg_data_home.mkdir()
        env_patch = mock.patch.dict(
            os.environ, {"HOME": str(home_dir), "XDG_DATA_HOME": str(xdg_data_home)}
        )
        env_patch.start()
        self.addCleanup(env_patch.stop)
        self.install_dir = self.base / "install"
        self.marker_path = self.base / "marker.txt"

    def make_fake_june(self):
        script = self.base / "FakeJune"
        script.write_text(
            "#!/usr/bin/env python3\n"
            "import time\n"
            f"with open({str(self.marker_path)!r}, 'a') as f:\n"
            "    f.write('run\\n')\n"
            "time.sleep(5)\n"
        )
        script.chmod(0o755)
        return script

    def make_junes(self, content="song data"):
        path = self.base / "songs.junes"
        with zipfile.ZipFile(path, "w") as zf:
            zf.writestr("songs/a.tres", content)
        return path

    def wait_for_marker_lines(self, count, timeout=3):
        deadline = time.time() + timeout
        while time.time() < deadline:
            if self.marker_path.is_file() and len(self.marker_path.read_text().splitlines()) >= count:
                return
            time.sleep(0.05)

    def test_install_copies_executable_extracts_songs_and_relaunches(self):
        executable = self.make_fake_june()
        junes_path = self.make_junes(content="new song data")
        data_dir = junes.godot_user_data_dir()
        (data_dir / "songs").mkdir(parents=True)
        (data_dir / "songs" / "a.tres").write_text("old song data")

        target = junes.install_june(executable, junes_path, self.install_dir)
        self.wait_for_marker_lines(2)

        self.assertTrue(target.is_file())
        self.assertTrue(target.stat().st_mode & stat.S_IXUSR)
        self.assertEqual(target.read_bytes(), executable.read_bytes())
        self.assertEqual((data_dir / "songs" / "a.tres").read_text(), "new song data")
        self.assertEqual(self.marker_path.read_text().splitlines(), ["run", "run"])

    def test_invalid_junes_aborts_before_creating_install_dir(self):
        executable = self.base / "FakeJune"
        executable.write_text("not actually run")
        empty_junes = self.base / "empty.junes"
        with zipfile.ZipFile(empty_junes, "w"):
            pass
        with self.assertRaises(junes.JunesError):
            junes.install_june(executable, empty_junes, self.install_dir)
        self.assertFalse(self.install_dir.exists())


class PickAssetTests(unittest.TestCase):
    def make_release(self):
        return {
            "tag_name": "Beta v1.2.1",
            "assets": [
                {"name": "Beta.v1.2.1.-.Windows.zip"},
                {"name": "Beta.v1.2.1.-.Linux.zip"},
            ],
        }

    def test_picks_windows_asset(self):
        with mock.patch.object(june_installer, "IS_WINDOWS", True):
            asset = june_installer.pick_asset(self.make_release())
        self.assertEqual(asset["name"], "Beta.v1.2.1.-.Windows.zip")

    def test_picks_linux_asset(self):
        with mock.patch.object(june_installer, "IS_WINDOWS", False):
            asset = june_installer.pick_asset(self.make_release())
        self.assertEqual(asset["name"], "Beta.v1.2.1.-.Linux.zip")

    def test_no_matching_asset_raises(self):
        release = {"tag_name": "v1.2.1", "assets": [{"name": "Beta.v1.2.1.-.MacOS.zip"}]}
        with mock.patch.object(june_installer, "IS_WINDOWS", False):
            with self.assertRaises(junes.JunesError):
                june_installer.pick_asset(release)


class FindBinaryTests(unittest.TestCase):
    def setUp(self):
        self.tmp_dir = tempfile.TemporaryDirectory()
        self.addCleanup(self.tmp_dir.cleanup)
        self.folder = Path(self.tmp_dir.name)

    def test_finds_windows_exe(self):
        (self.folder / "June.exe").write_text("stub")
        with mock.patch.object(june_installer, "IS_WINDOWS", True):
            found = june_installer.find_binary(self.folder)
        self.assertEqual(found, self.folder / "June.exe")

    def test_finds_linux_binary(self):
        (self.folder / "June.x86_64").write_text("stub")
        with mock.patch.object(june_installer, "IS_WINDOWS", False):
            found = june_installer.find_binary(self.folder)
        self.assertEqual(found, self.folder / "June.x86_64")

    def test_raises_when_no_binary_found(self):
        with mock.patch.object(june_installer, "IS_WINDOWS", False):
            with self.assertRaises(junes.JunesError):
                june_installer.find_binary(self.folder)


class BundledJunesTests(unittest.TestCase):
    def setUp(self):
        self.tmp_dir = tempfile.TemporaryDirectory()
        self.addCleanup(self.tmp_dir.cleanup)

    def test_finds_junes_in_meipass(self):
        meipass = Path(self.tmp_dir.name)
        (meipass / "songs.junes").write_bytes(b"data")
        with mock.patch.object(sys, "_MEIPASS", str(meipass), create=True):
            found = june_installer.bundled_junes()
        self.assertEqual(found, meipass / "songs.junes")

    def test_raises_when_no_junes_bundled(self):
        meipass = Path(self.tmp_dir.name)
        with mock.patch.object(sys, "_MEIPASS", str(meipass), create=True):
            with self.assertRaises(junes.JunesError):
                june_installer.bundled_junes()


class MainErrorHandlingTests(unittest.TestCase):
    def setUp(self):
        bundled_patch = mock.patch.object(
            june_installer, "bundled_junes", return_value=Path("dummy.junes")
        )
        bundled_patch.start()
        self.addCleanup(bundled_patch.stop)
        install_patch = mock.patch.object(junes, "install_june")
        self.install_mock = install_patch.start()
        self.addCleanup(install_patch.stop)

    def run_main_with_fetch_error(self, error):
        with mock.patch.object(june_installer, "fetch_latest_release", side_effect=error):
            with contextlib.redirect_stdout(io.StringIO()) as buffer:
                exit_code = june_installer.main()
        return exit_code, buffer.getvalue()

    def test_http_403_reports_rate_limit(self):
        error = urllib.error.HTTPError("url", 403, "Forbidden", None, None)
        exit_code, output = self.run_main_with_fetch_error(error)
        self.assertEqual(exit_code, 1)
        self.assertIn("rate limit", output)
        self.install_mock.assert_not_called()

    def test_http_429_reports_rate_limit(self):
        error = urllib.error.HTTPError("url", 429, "Too Many Requests", None, None)
        exit_code, output = self.run_main_with_fetch_error(error)
        self.assertEqual(exit_code, 1)
        self.assertIn("rate limit", output)
        self.install_mock.assert_not_called()

    def test_other_http_error_reports_status(self):
        error = urllib.error.HTTPError("url", 500, "Server Error", None, None)
        exit_code, output = self.run_main_with_fetch_error(error)
        self.assertEqual(exit_code, 1)
        self.assertIn("HTTP 500", output)
        self.install_mock.assert_not_called()

    def test_url_error_reports_connection_message(self):
        error = urllib.error.URLError("no route to host")
        exit_code, output = self.run_main_with_fetch_error(error)
        self.assertEqual(exit_code, 1)
        self.assertIn("could not reach GitHub", output)
        self.install_mock.assert_not_called()

    def test_install_not_called_when_download_fails(self):
        release = {
            "tag_name": "v1.2.1",
            "assets": [
                {
                    "name": "Beta.v1.2.1.-.Linux.zip",
                    "browser_download_url": "https://example.invalid/x.zip",
                }
            ],
        }
        with mock.patch.object(june_installer, "fetch_latest_release", return_value=release):
            with mock.patch.object(
                june_installer, "open_url", side_effect=urllib.error.URLError("boom")
            ):
                with contextlib.redirect_stdout(io.StringIO()):
                    exit_code = june_installer.main()
        self.assertEqual(exit_code, 1)
        self.install_mock.assert_not_called()


if __name__ == "__main__":
    unittest.main()
