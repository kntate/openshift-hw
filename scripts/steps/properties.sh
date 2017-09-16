declare -a master_nodes=(192.168.206.130)

declare -a infra_nodes=(192.168.206.128)

declare -a app_nodes=(192.168.206.132 \
        192.168.206.129)

declare -a all_nodes=("${master_nodes[@]}" \
        "${infra_nodes[@]}" \
        "${app_nodes[@]}")

export GUID="ABCD"
export guid="ABCD"

