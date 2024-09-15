# Minimal makefile for Sphinx documentation
#

# You can set these variables from the command line, and also
# from the environment for the first two.
SPHINXOPTS    ?=
SPHINXBUILD   ?= poetry run sphinx-build
SOURCEDIR     = .
BUILDDIR      = _build

# Put it first so that "make" without argument is like "make help".
help:
	@$(SPHINXBUILD) -M help "$(SOURCEDIR)" "$(BUILDDIR)" $(SPHINXOPTS) $(O)

.PHONY: help Makefile

# Generate the README.md.
readme:
	@$(SPHINXBUILD) -M markdown "$(SOURCEDIR)" "$(BUILDDIR)" $(SPHINXOPTS) $(O) readme.rst && \
	 mv "$(BUILDDIR)"/markdown/readme.md ../README.md

# Generate versioned html
html-versioned:
	@poetry run sphinx-multiversion "$(SOURCEDIR)" "$(BUILDDIR)" $(SPHINXOPTS) $(O) && \
	 cp "$(SOURCEDIR)/_static/index.html" "$(BUILDDIR)"

# Catch-all target: route all unknown targets to Sphinx using the new
# "make mode" option.  $(O) is meant as a shortcut for $(SPHINXOPTS).
%: Makefile
	@$(SPHINXBUILD) -M $@ "$(SOURCEDIR)" "$(BUILDDIR)" $(SPHINXOPTS) $(O)
