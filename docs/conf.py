from pathlib import Path
from shutil import copy

project = "cmake-toolbelt"
copyright = "2024, Marko Malenic"
author = "Marko Malenic"
release = "0.1.0"

extensions = [
    "sphinxcontrib.moderncmakedomain",
    "sphinx.ext.intersphinx",
    "sphinx_multiversion",
]

intersphinx_mapping = {"cmake": ("https://cmake.org/cmake/help/latest", None)}
exclude_patterns = ["**/_build/*"]

templates_path = [
    "_templates",
]

html_theme = "sphinx_book_theme"
html_static_path = ["_static"]
html_css_files = ["custom.css"]
html_theme_options = {
    "logo": {
        "image_dark": "_static/logo_light.svg",
        "image_light": "_static/logo_dark.svg",
    },
    "icon_links": [
        {
            "name": "MIT Licensed",
            "url": "https://github.com/mmalenic/cmake-toolbelt/blob/main/LICENSE",
            "icon": "https://img.shields.io/badge/license-MIT-blue.svg",
            "type": "url",
        },
        {
            "name": "Build status",
            "url": "https://github.com/mmalenic/cmake-toolbelt/actions?query=workflow%3Atest+branch%3Amain",
            "icon": "https://github.com/mmalenic/cmake-toolbelt/actions/workflows/test.yaml/badge.svg",
            "type": "url",
        },
        {
            "name": "GitHub",
            "url": "https://github.com/mmalenic/cmake-toolbelt",
            "icon": "fa-brands fa-github",
        },
    ]
}
html_sidebars = {
    "**": [
        "navbar-logo.html",
        "icon-links.html",
        "search-button-field.html",
        "sbt-sidebar-nav.html",
        "versioning.html",
    ],
}


def copy_index_html(app, exception):
    """
    Copy the index.html from _static into the _build directory.
    """
    if exception is None:
        confdir = Path(app.confdir)
        copy(confdir / "_static/index.html", confdir / "_build")


def setup(app):
    app.connect("build-finished", copy_index_html)
