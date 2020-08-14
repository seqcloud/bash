#!/usr/bin/env python3
"""
Provenance for running external commands.

String sanitization:
cmd.format(**locals())

See also:
- https://github.com/bcbio/bcbio-nextgen/blob/master/bcbio/provenance/do.py
"""

from collections import deque
from subprocess import CalledProcessError, Popen, PIPE, STDOUT

from six import string_types

from koopa.system import find_bash


def _normalize_cmd_args(cmd):
    """
    Normalize subprocess arguments to handle list commands, string and pipes.

    Piped commands set pipefail and require use of bash to help with debugging
    intermediate errors.

    Updated 2020-02-09.
    """
    if isinstance(cmd, string_types):
        # Check for standard or anonymous named pipes.
        if cmd.find(" | ") > 0 or cmd.find(">(") or cmd.find("<("):
            return "set -o pipefail; " + cmd, True, find_bash()
        return cmd, True, None
    return [str(x) for x in cmd], False, None


def shell(cmd, env=None):
    """
    Run shell command in subprocess.
    Updated 2020-08-14.

    Using recommended subprocess method from bcbio-nextgen.

    See also:
    https://docs.python.org/3/library/subprocess.html
    """
    cmd, shell_arg, executable_arg = _normalize_cmd_args(cmd)
    sub = Popen(
        cmd,
        shell=shell_arg,
        executable=executable_arg,
        stdout=PIPE,
        stderr=STDOUT,
        close_fds=True,
        env=env,
    )
    debug_stdout = deque(maxlen=100)
    while 1:
        line = sub.stdout.readline().decode("utf-8", errors="replace")
        if line.rstrip():
            debug_stdout.append(line)
        exitcode = sub.poll()
        if exitcode is not None:
            for line in sub.stdout:
                debug_stdout.append(line.decode("utf-8", errors="replace"))
            if exitcode is not None and exitcode != 0:
                error_msg = (
                    " ".join(cmd) if not isinstance(cmd, string_types) else cmd
                )
                error_msg += "\n"
                error_msg += "".join(debug_stdout)
                sub.communicate()
                sub.stdout.close()
                raise CalledProcessError(exitcode, error_msg)
            break
    sub.communicate()
    sub.stdout.close()
