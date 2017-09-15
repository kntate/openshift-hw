declare -a master_nodes=(master1.example.com)

declare -a infra_nodes=(infranode1.example.com)

declare -a app_nodes=(node1.example.com \
        node2.example.com)

declare -a all_nodes=("${master_nodes[@]}" \
        "${infra_nodes[@]}" \
        "${app_nodes[@]}")

