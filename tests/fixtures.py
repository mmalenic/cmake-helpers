import os
from os.path import dirname, realpath
from pathlib import Path
from shutil import copytree, copy
from subprocess import run
from typing import Dict, Optional, List

import pytest


@pytest.fixture
def check_includes(tmp_path, monkeypatch) -> Path:
    """
    Fixture which sources the check_includes data.
    """
    return setup_cmake_project(tmp_path, monkeypatch, "check_includes")


@pytest.fixture
def check_symbol(tmp_path, monkeypatch) -> Path:
    """
    Fixture which sources the check_symbol data.
    """
    return setup_cmake_project(tmp_path, monkeypatch, "check_symbol")


@pytest.fixture
def create_header_file(tmp_path, monkeypatch) -> Path:
    """
    Fixture which sources the create_header_file data.
    """
    return setup_cmake_project(tmp_path, monkeypatch, "create_header_file")


@pytest.fixture
def program_dependencies(tmp_path, monkeypatch) -> Path:
    """
    Fixture which sources the program_dependencies data.
    """
    tmp_path = setup_cmake_project(tmp_path, monkeypatch, "program_dependencies")

    return install_conanfile(tmp_path, monkeypatch)


@pytest.fixture
def setup_testing(tmp_path, monkeypatch) -> Path:
    """
    Fixture which sources the setup_testing data.
    """
    tmp_path = setup_cmake_project(tmp_path, monkeypatch, "setup_testing")

    return install_conanfile(tmp_path, monkeypatch)


def install_conanfile(tmp_path, monkeypatch) -> Path:
    """
    Install a conanfile for a cmake project.
    """
    monkeypatch.setenv("CONAN_HOME", tmp_path.as_posix())
    run("conan profile detect --force".split(), check=True)
    run(f"conan install . --build=missing".split(), check=True)

    return tmp_path


def run_cmake_with_assert(capfd, contains_messages: Optional[List[str]] = None,
                          not_contains_messages: Optional[List[str]] = None,
                          variables: Optional[Dict[str, str]] = None,
                          preset: Optional[str] = None,
                          run_ctest: bool = False):
    """
    Run cmake with an expected assert message and additional variables to define.
    """

    def add_preset(for_command):
        if preset is not None:
            for_command += f"--preset {preset} "
        return for_command

    # Run cmake with the preset
    command = add_preset("cmake . ")
    if variables is not None:
        for key, value in variables.items() or []:
            command += f"-D {key}={value} "
    run(command.split(), check=True)

    out, _ = capfd.readouterr()

    # Assert expected messages in output.
    for message in contains_messages or []:
        assert message in out
    for message in not_contains_messages or []:
        assert message not in out

    # Build program.
    command = add_preset("cmake --build . ")
    run(command.split(), check=True)

    # Consume extra output so next command has output without build information.
    capfd.readouterr()

    # Run the program or the tests.
    if run_ctest:
        run("ctest", check=True)
    else:
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
