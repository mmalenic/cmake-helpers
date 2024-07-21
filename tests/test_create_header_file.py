"""
Tests for create header file function.
"""

from tests.fixtures import create_header_file, run_cmake_with_assert


def test_create_header_file(create_header_file, capfd):
    """
    Test that create_header_file links generated constants and outputs correctly.
    """
    run_cmake_with_assert(capfd, contains_messages=[
        "-- cmake-helpers: create_header_file - using constexpr_auto",
        "-- cmake-helpers: create_header_file - using const_char",
        "-- cmake-helpers: create_header_file - using define_constant",
        "-- cmake-helpers: create_header_file - generated output file",
        "-- cmake-helpers: create_header_file - linking generated file to target cmake_helpers_test"])

    embed_one = (create_header_file / "embed_one.txt").read_text()
    embed_two = (create_header_file / "embed_two.txt").read_text()
    expected = embed_one * 6 + (embed_one + embed_two) * 3

    out, _ = capfd.readouterr()

    assert out == expected

