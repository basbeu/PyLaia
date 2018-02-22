from __future__ import absolute_import
from __future__ import division

from laia.meters.sequence_error_meter import SequenceErrorMeter

import unittest


class SequenceErrorMeterTest(unittest.TestCase):
    def testSingleString(self):
        err = SequenceErrorMeter()
        ref = ['home']
        hyp = ['house']
        err.add(ref, hyp)
        self.assertEqual(err.value, 0.5)

    def testSingleList(self):
        err = SequenceErrorMeter()
        ref = [[1, 2, 3, 4]]
        hyp = [[1, 2, 5, 6, 4]]
        err.add(ref, hyp)
        self.assertEqual(err.value, 0.5)

    def testMultiple(self):
        err = SequenceErrorMeter()
        ref = [['the', 'house', 'is', 'blue'],
               ['my', 'dog', 'is', 'black']]
        hyp = [['the', 'home', 'is', 'white'],
               ['my', 'dog', 'is', 'not', 'black']]
        err.add(ref, hyp)
        self.assertEqual(err.value, (2 + 1) / (4 + 4))

    def testMultipleCalls(self):
        err = SequenceErrorMeter()
        ref = [['the', 'house', 'is', 'blue'],
               ['my', 'dog', 'is', 'black']]
        hyp = [['the', 'home', 'is', 'white'],
               ['my', 'dog', 'is', 'not', 'black']]
        err.add(ref, hyp)
        err.add(['home'], ['house'])
        self.assertEqual(err.value, (2 + 1 + 2) / (4 + 4 + 4))


if __name__ == '__main__':
    unittest.main()