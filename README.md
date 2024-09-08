<!-- This README.md is generated from docs/readme.rst. -->![image](https://img.shields.io/badge/license-MIT-blue.svgtarget:https://github.com/mmalenic/cmake-toolbelt/blob/main/LICENSEalt:MITlicensed)![image](https://github.com/mmalenic/cmake-toolbelt/actions/workflows/test.yaml/badge.svgtarget:https://github.com/mmalenic/cmake-toolbelt/actions?query=workflow%3Atest+branch%3Amainalt:Buildstatus)![image](https://github.com/mmalenic/cmake-toolbelt/actions/workflows/pages/pages-build-deployment/badge.svgtarget:https://github.com/mmalenic/cmake-toolbelt/actions/workflows/pages/pages-build-deploymentalt:Docs)

# cmake-toolbelt

A small collection of CMake build code which adds some missing functionality and reduces repetitive build
configurations.

This repository contains a C23 [#embed](https://en.cppreference.com/w/c/preprocessor/embed) replacement, functions for better dependency management, utilities for
defining required args and enums, and combinator functions for [`check_`](https://cmake.org/cmake/help/latest/module/CheckSymbolExists.html#command:check_symbol_exists) commands.

## Usage

To use this library, you can use CMake’s [`FetchContent`](https://cmake.org/cmake/help/latest/module/FetchContent.html#module:FetchContent) to import the project. All library
commands are available after including with a `toolbelt_` prefix:

```cmake
include(FetchContent)

# Fetch content from this repo.
FetchContent_Declare(
     toolbelt
     GIT_REPOSITORY https://github.com/mmalenic/cmake-toolbelt
     GIT_TAG 0.1.0
)
FetchContent_MakeAvailable(toolbelt)

# Allow cmake to find the src directory.
list(APPEND CMAKE_MODULE_PATH "${toolbelt_SOURCE_DIR}/src")
include(toolbelt)
```

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
