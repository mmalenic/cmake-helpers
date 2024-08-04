project = 'cmake-helpers'
copyright = '2024, Marko Malenic'
author = 'Marko Malenic'
release = '0.1.0'

extensions = [
    'sphinxcontrib.moderncmakedomain',
    'sphinx.ext.intersphinx'
]

intersphinx_mapping = {'cmake': ('https://cmake.org/cmake/help/latest', None)}
exclude_patterns = ['**/_build/*']

html_theme = 'sphinx_book_theme'

html_static_path = ['_static']
html_css_files = [
    'custom.css',
]