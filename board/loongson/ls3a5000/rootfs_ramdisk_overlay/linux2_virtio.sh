# check whether /dev/hvisor exists, if not, run /install.sh
if [ ! -e /dev/hvisor ]; then
    echo "hvisor not installed, installing..."
    /install.sh
fi

echo "Starting linux2 with virtio..."
# hvisor zone start /tool/linux2.json

cd tool
nohup ./hvisor virtio start virtio_cfg.json &

sudo poweroff