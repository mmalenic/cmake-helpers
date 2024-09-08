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
html_extra_path = ["_static/index.html"]
html_css_files = ["custom.css"]
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
