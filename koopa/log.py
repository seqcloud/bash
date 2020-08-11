#!/usr/bin/env python3
"""
Logging utilites.
"""

import logbook

LOG_NAME = "koopa"
DEFAULT_LOG_DIR = "log"

# pylint: disable=invalid-name
logger = logbook.Logger(LOG_NAME)
logger_cl = logbook.Logger(LOG_NAME + "-commands")
logger_stdout = logbook.Logger(LOG_NAME + "-stdout")
# pylint: enable=invalid-name


def get_log_dir(config):
    """
    Get log directory.
    Updated 2020-02-09.
    """
    log_dir = config.get("log_dir", DEFAULT_LOG_DIR)
    return log_dir
