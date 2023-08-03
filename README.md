# Samba-Gluster Integration Test Environment

The purpose of this project is to provide a generic mechanism to set up a
gluster-ctdb-samba cluster as a test environment. The mechanism is built on
vagrant-libvirt and ansible, and should be able to run on any host that has
support for these pieces of software. It is pulling the latest nightly RPM
builds from the upstream master branches of Gluster and Samba for setting
up the cluster.

In the future, we might support options for choosing to consume pre-built RPMS
or building from a given software branch.

This repo brings up the test environment and then runs the tests.
Various other resources are playing together inorder to enable the Samba Integration:

- [sit-test-cases](https://github.com/samba-in-kubernetes/sit-test-cases) - test suites that are run by ansible playbooks in [sit-environment](https://github.com/samba-in-kubernetes/sit-environment)
- [samba-build](https://github.com/samba-in-kubernetes/samba-build) - specfile and ansible automations to build nightly samba RPMs
- [CentOS CI](https://jenkins-samba.apps.ocp.cloud.ci.centos.org/) - jenkins server where we run our tests and builds
- [CentOS CI jobs](https://github.com/samba-in-kubernetes/samba-centosci) - centos-ci job configurations
- [nightly samba rpms repository](http://artifacts.ci.centos.org/samba/pkgs/) - packages and artifacts created by nightly samba rpm build jobs
- [nightly gluster rpms repository](http://artifacts.ci.centos.org/gluster/nightly/) - packages and artifacts created by nightly gluster rpm build jobs
