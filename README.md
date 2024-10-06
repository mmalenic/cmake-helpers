<picture>
   <source media="(prefers-color-scheme: dark)" srcset="https://github.com/mmalenic/cmake-toolbelt/blob/main/docs/_static/primary_logo_light.svg">
   <source media="(prefers-color-scheme: light)" srcset="https://github.com/mmalenic/cmake-toolbelt/blob/main/docs/_static/primary_logo_dark.svg">
   <img alt="Logo" src="https://github.com/mmalenic/cmake-toolbelt/blob/main/docs/_static/primary_logo_dark.svg">
</picture>
<br>
<a href="https://github.com/mmalenic/cmake-toolbelt/blob/main/LICENSE" target="_blank"><img
   alt="MIT licensed" src="https://img.shields.io/badge/license-MIT-blue.svg"/></a>
<a href="https://github.com/mmalenic/cmake-toolbelt/actions?query=workflow%3Atest+branch%3Amain" target="_blank"><img
   alt="Build status" src="https://github.com/mmalenic/cmake-toolbelt/actions/workflows/test.yaml/badge.svg"/></a>

# cmake-toolbelt

A small collection of CMake build code which adds some missing functionality and reduces repetitive build
configurations.

This repository contains a C23 [#embed](https://en.cppreference.com/w/c/preprocessor/embed) replacement, functions for better dependency management, utilities for
defining required args and enums, and combinator functions for [`check_`](https://cmake.org/cmake/help/latest/module/CheckSymbolExists.html#command:check_symbol_exists) commands.

## Usage

To use this library, you can use CMake’s [`FetchContent`](https://cmake.org/cmake/help/latest/module/FetchContent.html#module:FetchContent) to import the project. All library
commands are available after including with a `toolbelt_` prefix:

<!-- x-release-please-start-version -->
```cmake
include(FetchContent)

# Fetch content from this repo.
FetchContent_Declare(
     toolbelt
     GIT_REPOSITORY https://github.com/mmalenic/cmake-toolbelt
     GIT_TAG v0.3.0
)
FetchContent_MakeAvailable(toolbelt)

# Allow cmake to find the src directory.
list(APPEND CMAKE_MODULE_PATH "${toolbelt_SOURCE_DIR}/src")
include(toolbelt)
```

<!-- x-release-please-end -->

Alternatively, copy and paste the code in the [src](https://github.com/mmalenic/cmake-toolbelt/tree/main/src) directory
and include the library using `include(toolbelt)`.

## Why does this project exist?

The motivation behind this project is to define a common set of CMake functions that I use for a variety of C++
projects.

There are countless CMake “helper”-style libraries. See a list of some of the [here](https://github.com/onqtam/awesome-cmake).
This project does not aim to replace these, however it does contain some code which existing libraries lack,
such as interactions with the CMake [`check_`](https://cmake.org/cmake/help/latest/module/CheckSymbolExists.html#command:check_symbol_exists) commands.

## Development

This project contains a set of unit tests for the `toolbelt` commands. These can be run using [pytest](https://docs.pytest.org/en/stable/) and
[poetry](https://python-poetry.org/). After initializing the poetry project, run the tests using pytest:

```shell
pytest
```

The documentation for this project (including this README) is made using [sphinx](https://www.sphinx-doc.org/en/master/), and published to github pages.
To generate documentation, run the following in the [docs](https://github.com/mmalenic/cmake-toolbelt/tree/main/docs) directory to create a static page:

```shell
make html
```

Run the following to update this `README.md`:

```shell
make readme
```

Contributions are welcome. Feel free to open any pull requests or issues.

## Licence

This project is licensed under the MIT [licence]().
