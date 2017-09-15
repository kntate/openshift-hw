source steps/properties.sh

./steps/setup-keys.sh

# setup the repos
./steps/setup-repos.sh

# setup dns
./steps/dns.sh

./steps/docker.sh

./steps/ose.sh

