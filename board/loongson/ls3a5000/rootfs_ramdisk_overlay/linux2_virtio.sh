# check whether /dev/hvisor exists, if not, run /install.sh
if [ ! -e /dev/hvisor ]; then
    echo "hvisor not installed, installing..."
    /install.sh
fi

echo "booting zone linux2 with virtio..."

hvisor zone start /tool/linux2.json

sleep 1
echo "connecting to nonroot hvc console at /dev/pts/0"
screen /dev/pts/0