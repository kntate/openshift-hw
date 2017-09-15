source properties.sh

ssh-keygen -f /root/.ssh/id_rsa -N ''
cat /root/.ssh/id_rsa.pub >> /root/.ssh/authorized_keys
echo StrictHostKeyChecking no >> /etc/ssh/ssh_config

# many commands also from from master nodes, will prompt for password
for node in "${master_nodes[@]}"
do 
  ssh $node "echo StrictHostKeyChecking no >> /etc/ssh/ssh_config"
done


# add keys to all nodes, will prompt for password
for node in "${all_nodes[@]}"
do 
  ssh-copy-id root@$node
done

