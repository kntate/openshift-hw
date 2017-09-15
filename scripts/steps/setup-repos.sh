source properties.sh

# Add repos
export OWN_REPO_PATH=https://admin.shared.example.opentlc.com/repos/ocp/3.5
cat << EOF > /etc/yum.repos.d/open.repo
[rhel-7-server-rpms]
name=Red Hat Enterprise Linux 7
baseurl=${OWN_REPO_PATH}/rhel-7-server-rpms
enabled=1
gpgcheck=0

[rhel-7-server-rh-common-rpms]
name=Red Hat Enterprise Linux 7 Common
baseurl=${OWN_REPO_PATH}/rhel-7-server-rh-common-rpms
enabled=1
gpgcheck=0

[rhel-7-server-extras-rpms]
name=Red Hat Enterprise Linux 7 Extras
baseurl=${OWN_REPO_PATH}/rhel-7-server-extras-rpms
enabled=1
gpgcheck=0

[rhel-7-server-optional-rpms]
name=Red Hat Enterprise Linux 7 Optional
baseurl=${OWN_REPO_PATH}/rhel-7-server-optional-rpms
enabled=1
gpgcheck=0

[rhel-7-fast-datapath-rpms]
name=Red Hat Enterprise Linux 7 Fast Datapath
baseurl=${OWN_REPO_PATH}/rhel-7-fast-datapath-rpms
enabled=1
gpgcheck=0
EOF

# Add the OpenShift Container Platform repository mirror
cat << EOF >> /etc/yum.repos.d/open.repo

[rhel-7-server-ose-3.5-rpms]
name=Red Hat Enterprise Linux 7 OSE 3.5
baseurl=${OWN_REPO_PATH}/rhel-7-server-ose-3.5-rpms
enabled=1
gpgcheck=0
EOF

# Clean up repos
yum clean all ; yum repolist


# loop through all nodes
for node in "${all_nodes[@]}"
do
          echo Copying open repos to $node
          scp /etc/yum.repos.d/open.repo ${node}:/etc/yum.repos.d/open.repo
          ssh ${node} 'mv /etc/yum.repos.d/redhat.{repo,disabled}'
          ssh ${node} yum clean all
          ssh ${node} yum repolist
done

