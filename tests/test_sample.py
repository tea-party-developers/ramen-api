import pytest

from ramen.sample import add


@pytest.mark.parametrize(("x", "y", "expected"), [(1, 2, 3), (3, 4, 7), (5, 6, 11)])
def test_add(x: int, y: int, expected: int) -> None:
    assert add(x, y) == expected
