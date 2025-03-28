This folder contains ansible playbooks which are useful when manual access to the test machines are required. These are not run during automated testing.

The Makefile targets are as follows

##centos8_build_setup:
Install the required packages needed to setup a samba build environment on the storage* hosts. This is useful when instrumenting samba on these machines to check for a root cause for test failures

