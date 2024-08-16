"""
Tests for setup gtest function.
"""

from tests.fixtures import setup_gtest, run_cmake_with_assert, conan_preset


def test_setup_gtest(setup_gtest, capfd):
    """
    Test that setup_gtest links GTest and runs a test successfully.
    """
    run_cmake_with_assert(
        capfd,
        contains_messages=[
            "-- cmake-helpers: helpers_add_dep - component GTest::gtest linked to cmake_helpers_test",
            "-- cmake-helpers: helpers_add_dep - component GTest::gtest_main linked to cmake_helpers_test",
            "-- cmake-helpers: helpers_add_dep - component GTest::gmock linked to cmake_helpers_test",
        ],
        preset=conan_preset(),
        build_preset="conan-release",
        run_ctest=True,
    )
