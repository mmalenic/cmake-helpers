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
            "cmake-toolbelt: toolbelt_embed - defining auto literal",
            "cmake-toolbelt: toolbelt_embed - defining char literal",
            "cmake-toolbelt: toolbelt_embed - defining byte array",
            "cmake-toolbelt: toolbelt_embed - defining preprocessor macro",
            "cmake-toolbelt: toolbelt_embed - generated output file",
            "cmake-toolbelt: toolbelt_embed - linking generated file to target cmake_toolbelt_test",
        ],
    )

    embed_one = (embed / "embed_one.txt").read_text()
    embed_two = (embed / "embed_two.txt").read_text()

    expected = embed_one * 7 + (embed_one + embed_two) * 4

    out, _ = capfd.readouterr()

    def normalise_lines(lines):
        return [line for line in lines.splitlines() if line != ""]

    assert normalise_lines(out) == normalise_lines(expected)
