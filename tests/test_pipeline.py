"""Tests hello world printers methods."""

import unittest

import pandas as pd

from bci_analysis.pipeline import pipeline_align


class PipeLineAlignTest(unittest.TestCase):
    """Tests pipeline_align methods."""

    def test_collapse_dlc_data(self):
        """Tests collapse_dlc_data."""
        mocked_data = pd.DataFrame()
        expected_df = pd.DataFrame()
        output_df = pipeline_align.collapse_dlc_data(mocked_data)

        self.assertEqual(expected_df, output_df)


if __name__ == "__main__":
    unittest.main()
