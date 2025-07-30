#! /bin/bash

set -euxo pipefail


for dir in all_sizes_?? ; do
    mkdir -p "./filtered/${dir}"
    for file in ./${dir}/bridge_1_tables_* ; do
        cat "$file" | grep "table=1" > "./filtered/$file" || true
    done

    pushd "filtered"
    for i in {1..3} ; do
        if ! [[ -f "$dir/bridge_${i}_tables_mud_099.log" ]] ; then
            continue
        fi
        for file in $dir/bridge_${i}_tables_mud* ; do
            cat "$file" | wc -l >> "./${dir}/${dir}_bridge_${i}_mud_table_sizes.log"
        done

        for file in $dir/bridge_${i}_tables_base* ; do
            cat "$file" | wc -l >> "./${dir}/${dir}_bridge_${i}_base_table_sizes.log"
        done
    done
    popd
done
