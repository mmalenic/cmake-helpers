import os
from os import chdir
from subprocess import run
from shutil import copy

def test_check_symbols(tmp_path):
    """Test that check symbols compiles an existing symbol."""
    dirname = os.path.dirname(__file__)
    cmake_lists = os.path.join(dirname, 'CMakeLists.txt')
    main = os.path.join(dirname, 'main.cpp')
    copy(cmake_lists, tmp_path)
    copy(main, tmp_path)

    chdir(tmp_path)
    run("cmake --build .".split(), check=True, cwd=tmp_path)
