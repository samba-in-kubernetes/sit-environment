INVENTORY := ./inventory

fix_ssh:
	@ansible-playbook -i ${INVENTORY} fix_ssh.yml

centos8_build_setup:
	@ansible-playbook -i ${INVENTORY} centos8_build_setup.yml

centos9_build_setup:
	@ansible-playbook -i ${INVENTORY} centos9_build_setup.yml

single_node_samba_cluster:
	@ansible-playbook -i ${INVENTORY} single_node_samba_cluster.yml
