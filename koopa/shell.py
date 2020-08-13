#!/usr/bin/env python3
"""
Provenance for running external commands, with logging.

Using recommended subprocess method from bcbio-nextgen.

String sanitization:
cmd.format(**locals())

See also:
- https://github.com/bcbio/bcbio-nextgen/blob/master/bcbio/provenance/do.py
"""

import collections
import os
import subprocess
import sys

import six

from koopa.log import logger, logger_stdout


def find_bash():
    """
    Find bash.
    Updated 2020-02-09.
    """
    for bash in [
        find_cmd("bash"),
        "/usr/local/bin/bash",
        "/usr/bin/bash",
        "/bin/bash",
    ]:
        if bash and os.path.exists(bash):
            return bash
    raise IOError("Could not find bash in any standard location.")


def find_cmd(cmd):
    """
    Find command.
    Updated 2020-02-09.
    """
    try:
        return subprocess.check_output(["which", cmd]).decode().strip()
    except subprocess.CalledProcessError:
        return None


def koopa_help():
    """
    Koopa help.
    Updated 2020-08-13.
    """
    cmd = sys.argv[0]
    pos_args = sys.argv[1:]
    if "-h" in pos_args or "--help" in pos_args:
        subprocess.call(["man", cmd])
        sys.exit()


def shell(cmd, log_stdout=False, env=None):
    """
    Run shell command in subprocess.
    Updated 2020-02-09.

    Perform running and check results, raising errors for issues.

    See also:
    https://docs.python.org/3/library/subprocess.html
    """
    cmd, shell_arg, executable_arg = _normalize_cmd_args(cmd)
    sub = subprocess.Popen(
        cmd,
        shell=shell_arg,
        executable=executable_arg,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        close_fds=True,
        env=env,
    )
    debug_stdout = collections.deque(maxlen=100)
    while 1:
        line = sub.stdout.readline().decode("utf-8", errors="replace")
        if line.rstrip():
            debug_stdout.append(line)
            if log_stdout:
                logger_stdout.debug(line.rstrip())
            else:
                logger.debug(line.rstrip())
        exitcode = sub.poll()
        if exitcode is not None:
            for line in sub.stdout:
                debug_stdout.append(line.decode("utf-8", errors="replace"))
            if exitcode is not None and exitcode != 0:
                error_msg = (
                    " ".join(cmd)
                    if not isinstance(cmd, six.string_types)
                    else cmd
                )
                error_msg += "\n"
                error_msg += "".join(debug_stdout)
                sub.communicate()
                sub.stdout.close()
                raise subprocess.CalledProcessError(exitcode, error_msg)
            break
    sub.communicate()
    sub.stdout.close()


def _normalize_cmd_args(cmd):
    """
    Normalize subprocess arguments to handle list commands, string and pipes.

    Piped commands set pipefail and require use of bash to help with debugging
    intermediate errors.

    Updated 2020-02-09.
    """
    if isinstance(cmd, six.string_types):
        # Check for standard or anonymous named pipes.
        if cmd.find(" | ") > 0 or cmd.find(">(") or cmd.find("<("):
            return "set -o pipefail; " + cmd, True, find_bash()
        return cmd, True, None
    return [str(x) for x in cmd], False, None
