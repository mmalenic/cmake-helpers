"""
Tests for create header file function.
"""

import platform

from tests.fixtures import embed, run_cmake_with_assert


def test_embed(embed, capfd):
    """
    Test that create_header_file links generated constants and outputs correctly.
    """
    run_cmake_with_assert(
        capfd,
        contains_messages=[
            "-- cmake-helpers: helpers_embed - defining auto literal",
            "-- cmake-helpers: helpers_embed - defining char literal",
            "-- cmake-helpers: helpers_embed - defining byte array",
            "-- cmake-helpers: helpers_embed - defining preprocessor macro",
            "-- cmake-helpers: helpers_embed - generated output file",
            "-- cmake-helpers: helpers_embed - linking generated file to target cmake_helpers_test",
        ],
    )

    embed_one = (embed / "embed_one.txt").read_text()
    embed_two = (embed / "embed_two.txt").read_text()

    expected = embed_one * 7 + (embed_one + embed_two) * 4

    out, _ = capfd.readouterr()

    def normalise_lines(lines):
        return [line for line in lines.splitlines() if line != ""]

    print(normalise_lines(out))
    print(normalise_lines(expected))

    assert normalise_lines(out) == normalise_lines(expected)
