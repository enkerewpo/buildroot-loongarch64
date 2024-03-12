workdir=`pwd`

DEST=$workdir/../output/host

PATH=$DEST/bin:$PATH

#QMAKESPEC=$DEST/mkspecs/linux-g++/ 
QMAKESPEC=$DEST/mkspecs/linux-mips64el-g++/ 

QTDIR=$DEST/mips64el-buildroot-linux-gnu/sysroot/usr

LD_LIBRARY_PATH=$DEST/mips64el-buildroot-linux-gnu/sysroot/usr/lib

export PATH QMAKESPEC QTDIR LD_LIBARY_PATH 

