source properties.sh

# Install Docker
for node in "${all_nodes[@]}"
do 
  echo Installing docker on $node 
  echo ssh $node "yum -y install docker" 
done


# Setup docker storage

# cleanup 
for node in "${all_nodes[@]}"
do 
  echo Cleaning up Docker on $node ; \
  ssh $node "systemctl stop docker ; rm -rf /var/lib/docker/*"  ;
done


# TODO determine the volume group
cat <<EOF > /tmp/docker-storage-setup

EOF

# setup docker storage on all nodes
for node in "${all_nodes[@]}"
do 
  echo Configuring Docker Storage and rebooting $node
  scp /tmp/docker-storage-setup ${node}:/etc/sysconfig/docker-storage-setup
  ssh $node "
  	docker-storage-setup ;
        systemctl enable docker
        systemctl start docker"
done


# verify docker
echo "waiting for setup to end"
sleep 20
for node in "${all_nodes[@]}"
do 
  echo Checking docker status on $node
  sleep 2
  ssh $node "systemctl status docker | grep Active"
done


# Put basic docker images on app hosts
REGISTRY="registry.access.redhat.com";PTH="openshift3"
OSE_VERSION=$(yum info atomic-openshift | grep Version | awk '{print $3}')
for node in "${app_nodes[@]}"
do 
  ssh $node "
    docker pull $REGISTRY/$PTH/ose-deployer:v$OSE_VERSION ; \
    docker pull $REGISTRY/$PTH/ose-sti-builder:v$OSE_VERSION ; \
    docker pull $REGISTRY/$PTH/ose-pod:v$OSE_VERSION ; \
    docker pull $REGISTRY/$PTH/ose-keepalived-ipfailover:v$OSE_VERSION ; \
    docker pull $REGISTRY/$PTH/ruby-20-rhel7 ; \
    docker pull $REGISTRY/$PTH/mysql-55-rhel7 ; \
    docker pull openshift/hello-openshift:v1.2.1 ;
    "
done


# Only pull infrastructure images to appropriate nodes
REGISTRY="registry.access.redhat.com";PTH="openshift3"
OSE_VERSION=$(yum info atomic-openshift | grep Version | awk '{print $3}')
for node in "${infra_nodes[@]}"
do 
  ssh $node "
    docker pull $REGISTRY/$PTH/ose-haproxy-router:v$OSE_VERSION  ; \
    docker pull $REGISTRY/$PTH/ose-deployer:v$OSE_VERSION ; \
    docker pull $REGISTRY/$PTH/ose-pod:v$OSE_VERSION ; \
    docker pull $REGISTRY/$PTH/ose-docker-registry:v$OSE_VERSION ;
  "
done


# Examine docker on app nodes
for node in "${app_nodes[@]}"
do 
  ssh $node docker info
  ssh $node lvs
done

