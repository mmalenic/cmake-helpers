from subprocess import CalledProcessError

import pytest

from tests.fixtures import check_symbol, run_cmake_with_assert


def test_check_symbol(check_symbol, capfd):
    """
    Test that check symbols compiles an existing symbol.
    """
    run_cmake_with_assert(capfd, contains_messages=["cmake-helpers: check_symbol - using check_cxx_symbol_exists"],
                          not_contains_messages=[
                              "cmake-helpers: prepare_check_function - check result for \"EXIT_EXISTS\" cached with value: 1"],
                          )


def test_check_symbol_mode(check_symbol, capfd):
    """
    Test that check symbols compiles an existing symbol and check_symbol_exists mode.
    """
    run_cmake_with_assert(capfd, contains_messages=["cmake-helpers: check_symbol - using check_symbol_exists"], \
                          not_contains_messages=[
                              "cmake-helpers: prepare_check_function - check result for \"EXIT_EXISTS\" cached with value: 1"],
                          variables={"mode": "check_symbol_exists"})


def test_check_symbol_invalid_mode(check_symbol, capfd):
    """
    Test that check symbols fails with an unknown mode.
    """
    with pytest.raises(CalledProcessError):
        run_cmake_with_assert(capfd, variables={"mode": "invalid_mode"})


def test_non_existent_symbol(check_symbol, capfd):
    """
    Test that check symbols program fails with a non-existent symbol.
    """
    with pytest.raises(CalledProcessError):
        run_cmake_with_assert(capfd, contains_messages=["cmake-helpers: check_symbol - using check_cxx_symbol_exists"],
                              not_contains_messages=[
                                  "cmake-helpers: prepare_check_function - check result for \"EXIT_EXISTS\" cached with value: 1"],
                              variables={"symbol": "non_existent_symbol"})


def test_check_symbol_cached(check_symbol, capfd):
    """
    Test that check symbols compiles an existing cached symbol.
    """
    run_cmake_with_assert(capfd, contains_messages=[
        "cmake-helpers: prepare_check_function - check result for \"EXIT_EXISTS\" cached with value: 1"],
                          variables={"run_twice": "TRUE"})
