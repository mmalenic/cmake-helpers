"""
Tests for setup gtest function.
"""

from subprocess import CalledProcessError

import pytest

from tests.fixtures import enum, run_cmake_with_assert


def test_any(enum, capfd):
    """
    Test that enum executes a check successfully.
    """
    run_cmake_with_assert(capfd)


def test_any_error(enum, capfd):
    """
    Test that enum fails when more than one variable is defined.
    """
    with pytest.raises(CalledProcessError):
        run_cmake_with_assert(capfd, variables={"error": "TRUE"})
