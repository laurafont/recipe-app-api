"""
Tests for the Django admin modifications.
"""

# to mock the behaviour of the database
from unittest.mock import patch

# one of the operational errors that can be raised by the database
from psycopg2 import OperationalError as Psycopg2Error

# to be able to call the command that we want to test
from django.core.management import call_command
# another operational error that can be raised by the database
from django.db.utils import OperationalError
# to be able to test the command
from django.test import SimpleTestCase


# this is the command we are mocking
@patch('core.management.commands.wait_for_db.Command.check')
class CommandTests(SimpleTestCase):
    """Test commands."""

    def test_wait_for_db_ready(self, patched_check):
        """Test waiting for database if database is ready."""
        # we need to simulate the check method of the database to return True
        patched_check.return_value = True

        # call the command to test
        call_command('wait_for_db')

        # we need to check if the check method was called with the correct
        # arguments
        patched_check.assert_called_once_with(databases=['default'])

    # we need to mock the time.sleep function to wait for some seconds
    # before calling the check method again so that it is not called
    # too many times
    @patch('time.sleep')
    def test_wait_for_db_delay(self, patched_sleep, patched_check):
        """Test waiting for database when getting OperationalError.
        The first 2 times we get a Psycopg2Error.
        The next 3 times we get an OperationalError.
        The sixth time we get a True. (all are random numbers)
        """
        patched_check.side_effect = [Psycopg2Error] * 2 + \
            [OperationalError] * 3 + [True]

        call_command('wait_for_db')

        # we need to call it 6 time to check for all exceptions and the
        # final True
        self.assertEqual(patched_check.call_count, 6)

        # we need to check if the check method was called with the correct
        # arguments (called many times)
        patched_check.assert_called_with(databases=['default'])
