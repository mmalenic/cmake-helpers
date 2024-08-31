"""
Tests for linting and checks.
"""

import os
import platform

import pytest

from tests.fixtures import (
    setup_gtest,
    run_cmake_with_assert,
    conan_preset,
    add_dep,
    check_includes,
    check_symbol,
    embed,
    enum,
    required,
    setup_gtest,
)


def run_check(
    capfd,
    add_dep,
    check_includes,
    check_symbol,
    embed,
    enum,
    required,
    setup_gtest,
    **kwargs
):
    """
    Run a check test.
    """

    def run(resource, preset=None, build_preset=None, run_ctest=False):
        os.chdir(resource)
        run_cmake_with_assert(
            capfd,
            preset=preset,
            build_preset=build_preset,
            run_ctest=run_ctest,
            **kwargs,
        )

    run(add_dep, preset=conan_preset(), build_preset="conan-release")
    run(check_includes)
    run(check_symbol)
    run(embed)
    run(enum)
    run(required)
    run(
        setup_gtest, preset=conan_preset(), build_preset="conan-release", run_ctest=True
    )


@pytest.mark.skipif(platform.system() != "Linux", reason="Linux only lint")
def check_clang_tidy(
    capfd, add_dep, check_includes, check_symbol, embed, enum, required, setup_gtest
):
    """
    Run clang-tidy on all test code.
    """
    run_check(
        capfd,
        add_dep,
        check_includes,
        check_symbol,
        embed,
        enum,
        required,
        setup_gtest,
        variables={"run_clang_tidy": "TRUE"},
    )


@pytest.mark.skipif(platform.system() != "Linux", reason="Linux only lint")
def check_memcheck(
    capfd, add_dep, check_includes, check_symbol, embed, enum, required, setup_gtest
):
    """
    Run valgrind on all test code.
    """
    run_check(
        capfd,
        add_dep,
        check_includes,
        check_symbol,
        embed,
        enum,
        required,
        setup_gtest,
        memcheck=True,
    )
