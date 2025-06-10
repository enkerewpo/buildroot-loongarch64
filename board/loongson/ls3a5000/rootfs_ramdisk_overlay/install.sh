cd tool
insmod ./hvisor.ko
# check whether this hvisor is executable
if [ -x ./hvisor ]; then
    cp ./hvisor /bin
    echo "successfully installed hvisor, copied /bin/hvisor to /bin/hvisor and you can use it in your shell"
else
    echo "/tool/hvisor is not executable, please check the permission!"
fi