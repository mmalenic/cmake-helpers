from os.path import dirname, realpath
from pathlib import Path
from shutil import copytree, copy

import pytest


def setup_cmake_project(tmp_path, monkeypatch, test_directory) -> Path:
    file_path = Path(dirname(realpath(__file__)))

    copytree(file_path / test_directory, tmp_path, dirs_exist_ok=True)
    copy(file_path.parent / "helpers.cmake", tmp_path)

    monkeypatch.chdir(tmp_path)

    return tmp_path


@pytest.fixture
def check_symbols(tmp_path, monkeypatch):
    return setup_cmake_project(tmp_path, monkeypatch, "test_data/check_symbols")
