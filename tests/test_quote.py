import unittest
from bel.runner import Runner

runner = Runner()

class Quote(unittest.TestCase):
    def test_simple_quote(self):
        output = runner.run("'x")
        self.assertEqual("x", output)

    def test_longer_quote(self):
        output = runner.run("'bel")
        self.assertEqual("bel", output)

    def test_symbolic_quote(self):
        output = runner.run("'+")
        self.assertEqual("+", output)
