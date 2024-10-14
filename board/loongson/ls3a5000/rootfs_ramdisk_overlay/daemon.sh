# check whether /dev/hvisor exists, if not, run /install.sh
if [ ! -e /dev/hvisor ]; then
    echo "hvisor not installed, installing..."
    /install.sh
fi

mkdir -p /dev/pts
mount -t devpts devpts /dev/pts

nohup hvisor virtio start /tool/virtio_cfg.json &

# spawn a process to monitor nohup.out
# /mon.sh &