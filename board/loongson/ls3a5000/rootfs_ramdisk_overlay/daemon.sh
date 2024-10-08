# check whether /dev/hvisor exists, if not, run /install.sh
if [ ! -e /dev/hvisor ]; then
    echo "hvisor not installed, installing..."
    /install.sh
fi

nohup hvisor virtio start /tool/virtio_cfg.json &

# spawn a process to monitor nohup.out
# /mon.sh &