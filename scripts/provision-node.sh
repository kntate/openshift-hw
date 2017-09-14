ssh-keygen -f /root/.ssh/id_rsa -N ''
cat /root/.ssh/id_rsa.pub >> /root/.ssh/authorized_keys
echo StrictHostKeyChecking no >> /etc/ssh/ssh_config

# TODO insert loop for ssh-copy-id to all nodes

# setup the repos
./steps/setup-repos.sh

# setup dns
./steps/dns.sh

./steps/docker.sh
