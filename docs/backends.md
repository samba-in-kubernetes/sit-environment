# Creation of a new backend for SITE

## Organization

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

## Steps to create the new backend

### Define the backend

Update `vagrant/roles/local.defaults/vars/main.yml` to add the following
information:

  - Add the internal name in `be_names` object.

    This entry maps the user-provided backend name into a name that will be
    used internally to locate files related to that backend.

    Example:
      ```yaml
      be_names:
        glusterfs: glusterfs
      ```

  - Create an environment for the new backend in `environments` object.

    You need to define how many machines are needed to run the tests, as well
    as the required resources and the roles they will perform. You can use an
    already existing environment as a reference, but you must be sure to assign
    the roles `admin`, `clients` and `cluster` to at least one of the machines.
    These roles are required to execute the ansible playbooks.

### Install dependencies for installation

Create a new role `sit.<backend>` in `vagrant/roles` that will be responsible
to install any required packages needed to install the backend components in
the required machines. This commonly includes any extra ansible collections
that will help during the installation.

> Note: the name of the `<backend>` must be the internal one defined in the
>       `be_names` object in the previous step.

The tasks must be created in `tasks/setup/main.yml` under the role's main
directory.

### Create the cluster configuration

The main set of parameters that define the behaviour of the backend as well as
the configuration of CTDB and Samba for this environment need to be created in
`vagrant/ansible/cluster-<backend>.yml`.

You can use the files from other backends as a reference when creating this
file.

### Create the main backend role

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

### Configure CTDB

A new file `vagrant/ansible/roles/ctdb.setup/tasks/<backend>/main.xml` must be
created to help configure the CTDB shared storage to store the locking file.

### Configure Samba

Finally, the required configuration for samba must be created. It requires
creating two new files:

  - `vagrant/ansible/roles/samba.setup/tasks/<backend>/main.xml` must be created
    to help configure and mount the created volume for using it with samba.

  - `vagrant/ansible/roles/samba.setup/templates/<backend>/smb_share.conf.j2`
    should be a share configuration template that defines how to export the
    volume through samba.
