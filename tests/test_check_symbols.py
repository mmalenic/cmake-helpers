from subprocess import run
from tests.fixtures import check_symbols

def test_check_symbols(check_symbols, capfd):
    """Test that check symbols compiles an existing symbol."""
    run("cmake .".split(), check=True)
    out, _ = capfd.readouterr()
    assert "cmake-helpers: check_symbol - using check_cxx_symbol_exists" in out

    run("cmake --build .".split(), check=True)
    run("./check_symbols_test")
