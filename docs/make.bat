@ECHO OFF

pushd %~dp0

REM Command file for Sphinx documentation

if "%SPHINXBUILD%" == "" (
	set SPHINXBUILD=poetry run sphinx-build
)
set SOURCEDIR=.
set BUILDDIR=_build

%SPHINXBUILD% >NUL 2>NUL
if errorlevel 9009 (
	echo.
	echo.The 'sphinx-build' command was not found. Make sure you have Sphinx
	echo.installed, then set the SPHINXBUILD environment variable to point
	echo.to the full path of the 'sphinx-build' executable. Alternatively you
	echo.may add the Sphinx directory to PATH.
	echo.
	echo.If you don't have Sphinx installed, grab it from
	echo.https://www.sphinx-doc.org/
	exit /b 1
)

if "%1" == "html-versioned" goto html-versioned
if "%1" == "readme" goto readme
if "%1" == "" goto help

%SPHINXBUILD% -M %1 %SOURCEDIR% %BUILDDIR% %SPHINXOPTS% %O%
goto end

:html-versioned
poetry run sphinx-multiversion %SOURCEDIR% %BUILDDIR% %SPHINXOPTS% %O% && ^
copy %SOURCEDIR%\_static\index.html %BUILDDIR%
goto end

:readme
%SPHINXBUILD% -M markdown %SOURCEDIR% %BUILDDIR% %SPHINXOPTS% %O% readme.rst && ^
move %BUILDDIR%\markdown\readme.md ..\README.md
goto end

:help
%SPHINXBUILD% -M help %SOURCEDIR% %BUILDDIR% %SPHINXOPTS% %O%

:end
popd
