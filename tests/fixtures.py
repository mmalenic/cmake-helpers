import os
from os.path import dirname, realpath
from pathlib import Path
from shutil import copytree, copy
from subprocess import run
from typing import Dict, Optional, List

import pytest


@pytest.fixture
def check_symbol(tmp_path, monkeypatch) -> Path:
    """
    Fixture which sources the check_symbol data.
    """
    return setup_cmake_project(tmp_path, monkeypatch, "check_symbol")


@pytest.fixture
def program_dependencies(tmp_path, monkeypatch) -> Path:
    """
    Fixture which sources the program_dependencies data.
    """
    tmp_path = setup_cmake_project(tmp_path, monkeypatch, "program_dependencies")

    monkeypatch.setenv("CONAN_HOME", tmp_path.as_posix())
    run("conan profile detect --force".split(), check=True)
    run(f"conan install . --build=missing".split(), check=True)

    return tmp_path


def run_cmake_with_assert(capfd, contains_messages: Optional[List[str]] = None,
                          variables: Optional[Dict[str, str]] = None,
                          preset: Optional[str] = None):
    """
    Run cmake with an expected assert message and additional variables to define.
    """
    def add_preset(for_command):
        if preset is not None:
            for_command += f"--preset {preset} "
        return for_command

    command = add_preset("cmake . ")
    if variables is not None:
        for key, value in variables.items() or []:
            command += f"-D {key}={value} "
    run(command.split(), check=True)

    out, err = capfd.readouterr()

    for message in contains_messages or []:
        assert message in out

    command = add_preset("cmake --build . ")
    run(command.split(), check=True)
    run("./cmake_helpers_test", check=True)


def setup_cmake_project(tmp_path, monkeypatch, data_path) -> Path:
    """
    This fixture copies the requested test data into a tmp_dir for cmake to run.
    """
    file_path = Path(dirname(realpath(__file__)))

    copytree(file_path / "test_data" / data_path, tmp_path, dirs_exist_ok=True)
    copy(file_path.parent / "helpers.cmake", tmp_path)

    monkeypatch.chdir(tmp_path)

    return tmp_path
