import unittest
from bel.runner import Runner

runner = Runner()

class EmptyInput(unittest.TestCase):
    def test_empty_input(self):
        output = runner.run("")
        self.assertEqual(None, output)
