#!/usr/bin/env bash
set -e
set -o pipefail

# args: voltype, temp disk mount path
voltype=$1
mntpath=$2

# get my ip address
ipaddress=$(ip addr list eth0 | grep "inet " | cut -d' ' -f6 | cut -d/ -f1)

# if master, peer and create volume
if [ "$AZ_BATCH_IS_CURRENT_NODE_MASTER" == "true" ]; then
    # construct brick locations
    IFS=',' read -ra HOSTS <<< "$AZ_BATCH_HOST_LIST"
    bricks=
    for node in "${HOSTS[@]}"
    do
        bricks+=" $node:$mntpath/gluster/brick"
        # probe peer
        if [ "$node" != "$ipaddress" ]; then
            echo "probing $node"
            gluster peer probe "$node"
        fi
    done
    numnodes=${#HOSTS[@]}
    numpeers=$((numnodes - 1))
    echo "waiting for $numpeers peers to reach connected state..."
    # get peer info
    set +e
    while :
    do
        numready=$(gluster peer status | grep -c '^State: Peer in Cluster')
        if [ "$numready" == "$numpeers" ]; then
            break
        fi
        sleep 1
    done
    set -e
    echo "$numpeers nodes joined peering"
    # delay to wait for peers to connect
    sleep 5
    # create volume
    echo "creating gv0 (voltype: $voltype numnodes: $numnodes bricks:$bricks)"
    # shellcheck disable=SC2086
    gluster volume create gv0 "$voltype" "$numnodes" transport tcp${bricks} force
    # modify volume properties: the uid/gid mapping is UNDOCUMENTED behavior
    gluster volume set gv0 storage.owner-uid "$(id -u _azbatch)"
    gluster volume set gv0 storage.owner-gid "$(id -g _azbatch)"
    # start volume
    echo "starting gv0"
    gluster volume start gv0
fi

# poll for volume created
echo "waiting for gv0 volume..."
set +e
while :
do
    if gluster volume info gv0; then
        # delay to wait for subvolumes
        sleep 5
        break
    fi
    sleep 1
done
set -e

# add gv0 to /etc/fstab but do not auto-mount due to temp disk issues
mountpoint=$AZ_BATCH_NODE_ROOT_DIR/mounts/gluster_on_compute/gv0
mkdir -p "$mountpoint"
chmod 775 "$mountpoint"
echo "adding $mountpoint to fstab"
echo "$ipaddress:/gv0 $mountpoint glusterfs _netdev,noauto 0 0" >> /etc/fstab

# mount it
echo "mounting $mountpoint"
START=$(date -u +"%s")
set +e
while :
do
    if mount "$mountpoint"; then
        break
    else
        NOW=$(date -u +"%s")
        DIFF=$(((NOW-START)/60))
        # fail after 5 minutes of attempts
        if [ $DIFF -ge 5 ]; then
            echo "could not mount gluster volume: $mountpoint"
            exit 1
        fi
        sleep 1
    fi
done
set -e
chmod 775 "$mountpoint"

# touch file noting success
touch .glusterfs_success
