# install ansible
yum -y install ansible


cat << EOF > /etc/ansible/hosts
[masters]
#master1.example.com

[nodes]
#master1.example.com

# infra node
#infranode1.example.com
192.168.206.128

#node1.example.com
#node2.example.com
EOF


#TODO replace loop with actual nodes
#for node in   master1.example.com \
#	infranode1.example.com \
#	node1.example.com \
#	node2.example.com; \
#do \
#  echo installing NetworkManager on $node ; \
#  ssh $node "yum -y install NetworkManager"
#done


yum -y install wget git net-tools bind-utils iptables-services bridge-utils
yum -y install bash-completion

# TODO replace with master
#ssh master1.example.com yum -y install bash-completion


# TODO run yum update on all nodes
#for node in master1.example.com \
#	infranode1.example.com \
#	node1.example.com \
#	node2.example.com; \
#do \
#  echo Running yum update on $node ; \
#  ssh $node "yum -y update " ; \
#done

