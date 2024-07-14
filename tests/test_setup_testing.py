from tests.fixtures import setup_testing, run_cmake_with_assert


def test_program_dependencies(setup_testing, capfd):
    """
    Test that program dependencies links components to the project target.
    """
    run_cmake_with_assert(capfd, contains_messages=[
        "-- cmake-helpers: program dependencies - component GTest::gtest linked to cmake_helpers_test",
        "-- cmake-helpers: program dependencies - component GTest::gtest_main linked to cmake_helpers_test",
        "-- cmake-helpers: program dependencies - component GTest::gmock linked to cmake_helpers_test"],
                          preset="conan-release", run_ctest=True)
