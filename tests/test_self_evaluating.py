import unittest
from bel.runner import Runner

runner = Runner()

class SelfEvaluating(unittest.TestCase):
    def test_nil(self):
        output = runner.run("nil")
        self.assertEqual("nil", output)

    def test_t(self):
        output = runner.run("t")
        self.assertEqual("t", output)

    def test_o(self):
        output = runner.run("o")
        self.assertEqual("o", output)

    def test_apply(self):
        output = runner.run("apply")
        self.assertEqual("apply", output)
