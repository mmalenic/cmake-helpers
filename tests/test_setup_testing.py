"""
Tests for setup testing function.
"""

from tests.fixtures import setup_testing, run_cmake_with_assert


def test_setup_testing(setup_testing, capfd):
    """
    Test that setup_testing links GTest and runs a test successfully.
    """
    run_cmake_with_assert(capfd, contains_messages=[
        "-- cmake-helpers: helpers_add_dep - component GTest::gtest linked to cmake_helpers_test",
        "-- cmake-helpers: helpers_add_dep - component GTest::gtest_main linked to cmake_helpers_test",
        "-- cmake-helpers: helpers_add_dep - component GTest::gmock linked to cmake_helpers_test"],
                          preset="conan-release", run_ctest=True)
