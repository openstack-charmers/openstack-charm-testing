#!/bin/bash -ex
# Wait for all instances to become ACTIVE
#
# Even when using --wait with `openstack server create`, that command
# has been shown to return 0 before instances are in an ACTIVE state.
#
# One should still use --wait when creating instances in automation
# but additional wait logic is necessary to avoid races (as of Ocata).

retry_command_expect_fail() {
    command=$@
    i=0
    attempts=3
    while [ $i -lt $attempts ]; do
        $command || break
        let "i+=1"
        sleep 10
    done
    if [ $i -ge $attempts ]; then
        exit 1
    fi
}


show_non_active_instances() {
    openstack server list | grep -v ACTIVE | grep private
}

retry_command_expect_fail show_non_active_instances
