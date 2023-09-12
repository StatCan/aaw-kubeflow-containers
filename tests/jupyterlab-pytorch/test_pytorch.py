# Copyright (c) Jupyter Development Team.
# Distributed under the terms of the Modified BSD License.
import logging

import pytest

LOGGER = logging.getLogger(__name__)


@pytest.mark.parametrize(
    "name,command",
    [
        (
            "print version",
            "import torch;print(torch.__version__)",
        ),
        (
            "Create tensor with random values",
            "import torch;x = torch.rand(5, 3);print(x)",   
        ),
    ],
)
def test_pytorch(container, name, command):
    """Basic pytorch tests"""
    LOGGER.info(f"Testing pytorch: {name} ...")
    c = container.run(tty=True, command=["start.sh", "conda", "run", "-n", "torch", "python", "-c", command])
    rv = c.wait(timeout=30)
    assert rv == 0 or rv["StatusCode"] == 0, f"Command {command} failed"
    logs = c.logs(stdout=True).decode("utf-8")
    LOGGER.debug(logs)
