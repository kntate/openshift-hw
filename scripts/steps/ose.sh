source properties.sh

yum -y install atomic-openshift-utils
yum -y install bash-completion
for node in "${master_nodes[@]}"
do 
  ssh $node "yum -y install atomic-openshift-utils"
  ssh $node "yum -y install bash-completion"
done

# Create ansible file
export GUID=`hostname|awk -F. '{print $2}'`
echo $GUID
cat << EOF > /etc/ansible/hosts
[OSEv3:vars]

###########################################################################
### Ansible Vars
###########################################################################
timeout=60
ansible_become=yes
ansible_ssh_user=ec2-user

###########################################################################
### OpenShift Basic Vars
###########################################################################

deployment_type=openshift-enterprise
# openshift_image_tag=v3.5
# openshift_release=v3.5.5.5
# docker_version='1.12.5'

# default project node selector
osm_default_node_selector='env=app'

###########################################################################
### OpenShift Optional Vars
###########################################################################

# Enable cockpit
osm_use_cockpit=true
osm_cockpit_plugins=['cockpit-kubernetes']

###########################################################################
### OpenShift Master Vars
###########################################################################

openshift_master_api_port=443
openshift_master_console_port=443

openshift_master_cluster_method=native
openshift_master_cluster_hostname=loadbalancer1.${GUID}.internal
openshift_master_cluster_public_hostname=loadbalancer.${GUID}.example.opentlc.com
openshift_master_default_subdomain=apps.${GUID}.example.opentlc.com
#openshift_master_overwrite_named_certificates=false
openshift_set_hostname=true

###########################################################################
### OpenShift Network Vars
###########################################################################

osm_cluster_network_cidr=10.1.0.0/16
openshift_portal_net=172.30.0.0/16

#os_sdn_network_plugin_name='redhat/openshift-ovs-multitenant'
os_sdn_network_plugin_name='redhat/openshift-ovs-subnet'


###########################################################################
### OpenShift Authentication Vars
###########################################################################

# openshift_master_identity_providers=[{'name': 'ldap', 'challenge': 'true', 'login': 'true', 'kind': 'LDAPPasswordIdentityProvider','attributes': {'id': ['dn'], 'email': ['mail'], 'name': ['cn'], 'preferredUsername': ['uid']}, 'bindDN': 'uid=admin,cn=users,cn=accounts,dc=shared,dc=example,dc=opentlc,dc=com', 'bindPassword': '<BIND_PASSWORD - ASK INSTRUCTOR>', 'ca': '/etc/origin/master/ipa-ca.crt','insecure': 'false', 'url': 'ldaps://ipa.shared.example.opentlc.com:636/cn=users,cn=accounts,dc=shared,dc=example,dc=opentlc,dc=com?uid?sub?(memberOf=cn=ocp-users,cn=groups,cn=accounts,dc=shared,dc=example,dc=opentlc,dc=com)'}]
# openshift_master_ldap_ca_file=/root/ipa-ca.crt

#openshift_master_identity_providers=[{'name': 'allow_all', 'login': 'true', 'challenge': 'true', 'kind': 'AllowAllPasswordIdentityProvider'}]

# htpasswd auth
openshift_master_identity_providers=[{'name': 'htpasswd_auth', 'login': 'true', 'challenge': 'true', 'kind': 'HTPasswdPasswordIdentityProvider', 'filename': '/etc/origin/master/htpasswd'}]
# Defining htpasswd users
#openshift_master_htpasswd_users={'user1': '<pre-hashed password>', 'user2': '<pre-hashed password>'}
# or
openshift_master_htpasswd_file=/root/htpasswd.openshift

############################################################################
### OpenShift Metrics Vars
###########################################################################

openshift_hosted_metrics_deploy=true

openshift_hosted_metrics_storage_kind=nfs
openshift_hosted_metrics_storage_access_modes=['ReadWriteOnce']
openshift_hosted_metrics_storage_nfs_directory=/srv/nfs
openshift_hosted_metrics_storage_nfs_options='*(rw,root_squash)'
openshift_hosted_metrics_storage_volume_name=metrics
openshift_hosted_metrics_storage_volume_size=10Gi

openshift_hosted_metrics_public_url=https://hawkular-metrics.apps.${GUID}.example.opentlc.com/hawkular/metrics

###########################################################################
### OpenShift Logging Vars
###########################################################################

openshift_hosted_logging_deploy=true

openshift_hosted_logging_storage_kind=nfs
openshift_hosted_logging_storage_access_modes=['ReadWriteOnce']
openshift_hosted_logging_storage_nfs_directory=/srv/nfs
openshift_hosted_logging_storage_nfs_options='*(rw,root_squash)'
openshift_hosted_logging_storage_volume_name=logging
openshift_hosted_logging_storage_volume_size=10Gi

openshift_hosted_logging_hostname=kibana.apps.${GUID}.example.opentlc.com
openshift_hosted_logging_elasticsearch_cluster_size=1
openshift_master_logging_public_url=https://kibana.apps.${GUID}.example.opentlc.com


###########################################################################
### OpenShift Router and Registry Vars
###########################################################################

openshift_hosted_router_selector='env=infra'
openshift_hosted_router_replicas=2
#openshift_hosted_router_certificate={"certfile": "/path/to/router.crt", "keyfile": "/path/to/router.key", "cafile": "/path/to/router-ca.crt"}

openshift_hosted_registry_selector='env=infra'
openshift_hosted_registry_replicas=2

openshift_hosted_registry_storage_kind=nfs
openshift_hosted_registry_storage_access_modes=['ReadWriteMany']
openshift_hosted_registry_storage_nfs_directory=/srv/nfs
openshift_hosted_registry_storage_volume_name=registry
openshift_hosted_registry_storage_volume_size=10Gi

###########################################################################
### OpenShift Host Vars
###########################################################################

[OSEv3:children]
masters
nodes
etcd
lb
nfs

[nfs]
support1.${GUID}.internal

# host group for masters
[masters]
master1.${GUID}.internal
master2.${GUID}.internal
master3.${GUID}.internal

# host group for etcd
[etcd]
master1.${GUID}.internal
master2.${GUID}.internal
master3.${GUID}.internal

# Specify load balancer host
[lb]
loadbalancer1.${GUID}.internal

# host group for nodes, includes region info
[nodes]
master1.${GUID}.internal openshift_hostname=master1.${GUID}.internal
master2.${GUID}.internal openshift_hostname=master2.${GUID}.internal
master3.${GUID}.internal openshift_hostname=master3.${GUID}.internal

infranode1.${GUID}.internal openshift_node_labels="{'env': 'infra', 'zone': 'THX-1138'}" openshift_hostname=infranode1.${GUID}.internal
infranode2.${GUID}.internal openshift_node_labels="{'env': 'infra', 'zone': 'THX-1139'}" openshift_hostname=infranode2.${GUID}.internal
node1.${GUID}.internal openshift_node_labels="{'env': 'app', 'zone': 'THX-1138'}" openshift_hostname=node1.${GUID}.internal
node2.${GUID}.internal openshift_node_labels="{'env': 'app', 'zone': 'THX-1138'}" openshift_hostname=node2.${GUID}.internal

EOF



# Run the ansible file, '-f' means 20 concurrent tasks
ansible-playbook -f 20 /usr/share/ansible/openshift-ansible/playbooks/byo/config.yml

