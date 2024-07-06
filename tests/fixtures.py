from os.path import dirname, realpath
from pathlib import Path
from shutil import copytree, copy
from subprocess import run
from typing import Dict, Optional

import pytest


@pytest.fixture(scope="session", autouse=True)
def conan_profile_detect(tmp_path_factory):
    """
    Detect the conan profile for tests that require installing packages.
    """
    session_path = tmp_path_factory.getbasetemp().absolute().as_posix()
    print(f"{tmp_path_factory.getbasetemp()}")
    with pytest.MonkeyPatch.context() as monkeypatch:
        monkeypatch.setenv("CONAN_HOME", session_path)
        monkeypatch.chdir(session_path)

        run("conan profile detect --force".split(), check=True)
        return session_path


@pytest.fixture(scope="session", autouse=True)
def conan_install(conan_profile_detect):
    """
    Install conan dependencies.
    """
    run(f"conan install --requires=zlib/1.3.1 --build=missing".split(), check=True)


@pytest.fixture
def check_symbol(tmp_path, monkeypatch) -> Path:
    return setup_cmake_project(tmp_path, monkeypatch, "check_symbol")


@pytest.fixture
def program_dependencies(tmp_path, monkeypatch) -> Path:
    return setup_cmake_project(tmp_path, monkeypatch, "program_dependencies")


def run_cmake_with_assert(capfd, contains_message: str, variables: Optional[Dict[str, str]] = None):
    """
    Run cmake with an expected assert message and additional variables to define.
    """
    command = "cmake . "
    if variables is not None:
        for key, value in variables.items():
            command += f"-D {key}={value}"

    run(command.split(), check=True)
    out, _ = capfd.readouterr()
    assert contains_message in out

    run("cmake --build .".split(), check=True)
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
