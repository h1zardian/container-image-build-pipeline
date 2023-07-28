
tfm apply --auto-approve

tfm state list

tfm state show <jenkins_instance>

# copy the public_ip to ansible/inventory/group_vars/jenkins.yml

cd ansible

ansible-playbook -i inventory/hosts.ini playbooks/jenkins.yml