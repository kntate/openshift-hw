source properties.sh

export OSE_VERSION=3.5
export GUID="ABCD"

cat << EOF > /etc/ansible/hosts
[OSEv3:children]
masters
nodes
nfs

[OSEv3:vars]
ansible_user=root

# enable ntp on masters to ensure proper failover
openshift_clock_enabled=true

deployment_type=openshift-enterprise
openshift_release=v$OSE_VERSION

openshift_master_cluster_method=native
openshift_master_cluster_hostname=192.168.206.130
openshift_master_cluster_public_hostname=master1-${GUID}.oslab.opentlc.com

os_sdn_network_plugin_name='redhat/openshift-ovs-multitenant'

openshift_master_identity_providers=[{'name': 'htpasswd_auth', 'login': 'true', 'challenge': 'true', 'kind': 'HTPasswdPasswordIdentityProvider', 'filename': '/etc/origin/master/htpasswd'}]
#openshift_master_htpasswd_users={'andrew': '\$apr1\$cHkRDw5u\$eU/ENgeCdo/ADmHF7SZhP/', 'marina': '\$apr1\$cHkRDw5u\$eU/ENgeCdo/ADmHF7SZhP/'

# default project node selector
osm_default_node_selector='region=primary'
openshift_hosted_router_selector='region=infra'
openshift_hosted_router_replicas=1
#openshift_hosted_router_certificate={"certfile": "/path/to/router.crt", "keyfile": "/path/to/router.key", "cafile": "/path/to/router-ca.crt"}
openshift_hosted_registry_selector='region=infra'
openshift_hosted_registry_replicas=1

openshift_master_default_subdomain=cloudapps-${GUID}.oslab.opentlc.com

#openshift_use_dnsmasq=False
#openshift_node_dnsmasq_additional_config_file=/home/bob/ose-dnsmasq.conf

openshift_hosted_registry_storage_kind=nfs
openshift_hosted_registry_storage_access_modes=['ReadWriteMany']
openshift_hosted_registry_storage_host=192.168.206.131
openshift_hosted_registry_storage_nfs_directory=/exports
openshift_hosted_registry_storage_volume_name=registry
openshift_hosted_registry_storage_volume_size=5Gi

[nfs]
192.168.206.131

[masters]
192.168.206.130 openshift_hostname=192.168.206.130 openshift_public_hostname=master1-${GUID}.oslab.opentlc.com

[nodes]
192.168.206.130 openshift_hostname=192.168.206.130 openshift_public_hostname=master1-${GUID}.oslab.opentlc.com openshift_node_labels="{'region': 'infra'}"
192.168.206.128 openshift_hostname=192.168.206.128 openshift_public_hostname=infranode1-${GUID}.oslab.opentlc.com openshift_node_labels="{'region': 'infra', 'zone': 'infranodes'}"
192.168.206.132 openshift_hostname=192.168.206.132 openshift_public_hostname=node1-${GUID}.oslab.opentlc.com openshift_node_labels="{'region': 'primary', 'zone': 'east'}"
192.168.206.129 openshift_hostname=192.168.206.129 openshift_public_hostname=node2-${GUID}.oslab.opentlc.com openshift_node_labels="{'region': 'primary', 'zone': 'west'}"
EOF
