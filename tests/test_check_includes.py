"""
Tests for check include function.
"""

from subprocess import CalledProcessError

import pytest

from tests.fixtures import check_includes, run_cmake_with_assert


def test_check_includes(check_includes, capfd):
    """
    Test that check includes compiles an existing symbol.
    """
    run_cmake_with_assert(capfd,
                          contains_messages=["cmake-helpers: helpers_check_includes - checking stdlib.h can be included"])


def test_check_includes_c_language(check_includes, capfd):
    """
    Test that check includes compiles an existing symbol with C as the language.
    """
    run_cmake_with_assert(capfd, contains_messages=["cmake-helpers: helpers_check_includes - checking stdlib.h can be included",
                                                    "cmake-helpers: helpers_check_includes -     language = C"],
                          variables={"language": "C"})


def test_check_includes_cxx_language(check_includes, capfd):
    """
    Test that check includes compiles an existing symbol with CXX as the language.
    """
    run_cmake_with_assert(capfd, contains_messages=["cmake-helpers: helpers_check_includes - checking stdlib.h can be included",
                                                    "cmake-helpers: helpers_check_includes -     language = CXX"],
                          variables={"language": "CXX"})


def test_check_includes_invalid_language(check_includes, capfd):
    """
    Test that check includes fails with an unknown language.
    """
    with pytest.raises(CalledProcessError):
        run_cmake_with_assert(capfd, variables={"language": "invalid_language"})


def test_check_non_existent_includes(check_includes, capfd):
    """
    Test that check includes program fails with a non-existent include.
    """
    with pytest.raises(CalledProcessError):
        run_cmake_with_assert(capfd, contains_messages=[
            "cmake-helpers: helpers_check_includes - checking non_existent_include.h can be included"],
                              variables={"include": "non_existent_include.h"})


def test_check_includes_cached(check_includes, capfd):
    """
    Test that check includes compiles an existing cached value.
    """
    run_cmake_with_assert(capfd, contains_messages=[
        "cmake-helpers: helpers_check_includes - check result for \"STDLIB_EXISTS\" cached with value: 1"],
                          variables={"run_twice": "TRUE"})
