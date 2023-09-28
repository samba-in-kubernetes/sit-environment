# Creation of a new test for SITE

The Samba Integration Test Environment (SITE) can run different tests on top of
the built environment.

Each test is defined as a new role created under vagrant/ansible/roles. It must
contain the following files:

  - prepare/main.yml

    This file must contain the tasks required to install the needed packages,
    and to prepare the environment for the test, like mounting samba shares or
    any other operations.

  - main.yml

    This file contains the tasks required to run the test itself.

  - recover/main.yml

    This file contains tasks to recover the system from a failed executuon of
    the test. This may be required in some cases to be sure that processes or
    other resources that normally are only released after completing tests
    successfully are correctly released.

  - cleanup/main.yml

    This file contains tasks to stop services, processes or other resources so
    that the environment is left in a state similar to that before running the
    tasks in prepare/main.yml.
