# Backend support for Samba Integration Test Environment (SITE)

## Introduction

A backend represents the underlying filesystem that Samba uses to store the
data that will be accessible through the SMB protocol.

The SITE can be configured to easily use different backends to run the tests.
This will be very useful to identify:

  - Compatibility issues between Samba and the backend
  - Malfunction or unexpected behavior of the backend
  - Problems in Samba itself

## Configuration

The way to configure the backend is by assigning its name to the `backend`
option in the `EXTRA_VARS` environment variable before launching the `make`
command.

Some backends may be configured in different ways. This is known as "variants"
of the backend. Variants are specified by adding its name as a suffix of the
backend, separated by a dot (`.`). If no variant is added to the backend, the
default one is assumed.

   ```
   $ export EXTRA_VARS="backend=<backend>[.<variant>]"
   ```

The currently supported backends and its variants are:

  - glusterfs
    - default
  - xfs
    - default
  - cephfs
    - default (CephFS using a kernel mount point)
    - vfs (CephFS using the Samba VFS module)

## Creation of a new backend for SITE

### Organization

The structure of the playbooks, roles and tasks is such that backend and OS
specific information is split into different files. If any of the files you
need to create to define the new backend requires executing some tasks that
are dependent on the operating system, those tasks should be created as
separate files in the same directory as the main file.

The name of the file should be `<os>.yml`, where `<os>` should match one of the
names defined in the `os_includes` object in
`vagrant/roles/local.defaults/vars/main.yml`.

To include that file, you need to add the following snippet in the main yaml
file:

   ```yaml
   - name: Process OS specific tasks
     include_tasks: "{{ include_file }}"
     with_first_found:
       - files: "{{ config.os.includes }}"
     loop_control:
       loop_var: include_file
   ```

### Steps to create the new backend

#### Define the backend

Update `vagrant/roles/local.defaults/vars/main.yml` to add the following
information:

  - Create an environment for the new backend in `environments` object.

    You need to define how many machines are needed to run the tests, as well
    as the required resources and the roles they will perform. You can use an
    already existing environment as a reference, but you must be sure to assign
    the roles `admin`, `clients` and `cluster` to at least one of the machines.
    These roles are required to execute the ansible playbooks.

#### Install dependencies for installation

Create a new role `sit.<backend>` in `vagrant/roles` that will be responsible
to install any required packages needed to install the backend components in
the required machines. This commonly includes any extra ansible collections
that will help during the installation.

The tasks must be created in `tasks/setup/main.yml` under the role's main
directory.

#### Create the cluster configuration

The main set of parameters that define the behaviour of the backend as well as
the configuration of CTDB and Samba for this environment need to be created in
`vagrant/ansible/cluster-<backend>.yml`.

You can use the files from other backends as a reference when creating this
file.

#### Create the main backend role

This role contains all the steps required to install, configure, deploy and
make the backend accessible on a machine. Its name must be `sit.<backend>` and
it should be created inside `vagrant/ansible/roles`.

Several files are required to complete the installation on all machines:

  - `tasks/common/main.yml` should define the tasks required to prepare a node
    to use the backend, that are common to both servers and clients.

  - `tasks/server/main.yml` should define the tasks required to prepare a server
    to use the backend.

  - `tasks/client/main.yml` should define the tasks required to prepare a client
    to use the backend.

  - `tasks/main.yml` should define the tasks required to install the backend in
    a node and create the volume.

  - `tasks/new_volume.yml` should create a new volume and optionally mount it.

  - `tasks/new_share.yml` should create a new samba configuration file for a
    samba share.

#### Configure CTDB

A new file `vagrant/ansible/roles/ctdb.setup/tasks/<backend>/main.xml` must be
created to help configure the CTDB shared storage to store the locking file.

#### Configure Samba

Finally, the required configuration for samba must be created. It requires
creating a new file:

  - `vagrant/ansible/roles/samba.setup/tasks/<backend>/main.xml` must be created
    to help configure and mount the created volume for using it with samba.
