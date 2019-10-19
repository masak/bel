import unittest
from bel.runner import Runner, BelEvalError

runner = Runner()

class Quote(unittest.TestCase):
    def test_bel(self):
        output = runner.run("\\bel")
        self.assertEqual("\\bel", output)

    def test_tab(self):
        output = runner.run("\\tab")
        self.assertEqual("\\tab", output)

    def test_lf(self):
        output = runner.run("\\lf")
        self.assertEqual("\\lf", output)

    def test_cr(self):
        output = runner.run("\\cr")
        self.assertEqual("\\cr", output)

    def test_sp(self):
        output = runner.run("\\sp")
        self.assertEqual("\\sp", output)

    def test_unknown_character(self):
        self.assertRaises(BelEvalError, lambda: runner.run("\\turqois"))

    def test_character_h(self):
        output = runner.run("\\h")
        self.assertEqual("\\h", output)

    def test_character_e(self):
        output = runner.run("\\e")
        self.assertEqual("\\e", output)

