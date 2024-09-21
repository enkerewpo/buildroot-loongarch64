# check whether /dev/hvisor exists, if not, run /install.sh
if [ ! -e /dev/hvisor ]; then
    echo "hvisor not installed, installing..."
    /install.sh
fi

echo "booting zone linux2..."
hvisor zone start /tool/linux2.json
sudo poweroff