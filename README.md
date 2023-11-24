# Samba Integration Test Environment

The purpose of this project is to provide a generic mechanism to set up a
clustered Samba test environment for different file systems.

Currently we are supporting filesystems such as cephfs, glusterfs and xfs.
We are working on integrating other clustered filesystems such as GPFS as well.

The mechanism is built on vagrant-libvirt and ansible, and it is able to
run on any host that has support for these pieces of software.

We are using latest packages of filesystems and latest upstream Samba codebase
for setting up the cluster.

This repo brings up the test environment and then runs the tests.
Various other resources are playing together inorder to enable the Samba Integration:

- [sit-test-cases](https://github.com/samba-in-kubernetes/sit-test-cases) - test suites that are run by ansible playbooks in [sit-environment](https://github.com/samba-in-kubernetes/sit-environment)
- [samba-build](https://github.com/samba-in-kubernetes/samba-build) - specfile and ansible automations to build nightly samba RPMs
- [CentOS CI](https://jenkins-samba.apps.ocp.cloud.ci.centos.org/) - jenkins server where we run our tests and builds
- [CentOS CI jobs](https://github.com/samba-in-kubernetes/samba-centosci) - centos-ci job configurations
- [nightly samba rpms repository](http://artifacts.ci.centos.org/samba/pkgs/) - packages and artifacts created by nightly samba rpm build jobs
