# aaw-kubeflow-containers tests

These directories control what tests each image undergoes.
The `general` directory contains a set of tests that are used for every image.
The remaining directories each reference a specific image,
and are only used to test that specific image.

The tests are performed by pytest,
and can be run locally after building the image.
See [the general development workflow in the main README.md](../README.md##General-Development-Workflow) for additional info

Python functions that begin with `test_` are marked as a test case by pytest.
All other functions are used by these test cases to perform the tests.

## General tests

### test_notebook.py

This test file contains one test, `test_server_alive`.
It checks if `localhost:8888` is behaving as expected.
It does this by checking if a specific web element is loading properly.

### test_packages.py

This test file contains two test cases,
one check all the python packages (`test_python_packages`),
the other checks all the r packages (`test_r_packages`).

Both these tests check if that imported packages have been installed properly.
It can also detect if packages are incompatable with each other.
It only checks packages specifically installed by `conda install`,
and not any of the dependancies.
The tests are performed by `CondaPackageHelper`,
in the `helpers.py` file.

There is a list of excluded packages that cannot be tested in a standard way.

**helpers.py**

This is a collection of all the helper functions used by the other test packages.
No tests should be found inside this file.

## Specific tests

If the image name mtches one of the specifc test directories,
then the included tests will be appened to the tests in the general folder.
Then all the contained tests will be performed.

### jupyterlab-cpu

This test directory contains 3 testfiles that test additional programs installed on the container.
It tests if julia, matplotlib, and pandas are all installed and working properly.
Most of these use a decorator to pass multiple test inputs to the same test.

### jupyterlab-pytorch

This test directory contains a single test that runs some pytorch commands inside the container to see if it is working as intended.
This function uses a decorator for pytest that lets it run multiple test inputs to the same test function.

### jupyterlab-tensorflow

This test directory contains a single test that runs some TensorFlow commands inside the container to see if it is working as intended.
This function uses a decorator for pytest that lets it run multiple test inputs to the same test function.
