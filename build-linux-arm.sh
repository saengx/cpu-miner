#!/bin/bash

# Linux build, optimised for ARM devices

N=$(echo -en '\033[0m')
RD=$(echo -en '\033[07;31m') # tulisan diberi blok
RED=$(echo -en '\033[00;31m')
GR=$(echo -en '\033[07;32m') # tulisan diberi blok
GRN=$(echo -en '\033[00;32m')
YLW=$(echo -en '\033[00;33m')
BLUE=$(echo -en '\033[00;34m')
MTA=$(echo -en '\033[00;35m')
LMA=$(echo -en '\033[20;36m')
PURP=$(echo -en '\033[00;35m')
CYAN=$(echo -en '\033[00;36m')
LGRAY=$(echo -en '\033[00;38m')
LRD=$(echo -en '\033[07;31m')
LRED=$(echo -en '\033[01;31m')
LGR=$(echo -en '\033[01;32m')
LYL=$(echo -en '\033[01;33m')
LYLO=$(echo -en '\033[07;33m') # tulisan diberi blok
LBL=$(echo -en '\033[01;34m')
LBLU=$(echo -en '\033[07;34m')
LMA=$(echo -en '\033[01;35m')
LPPLE=$(echo -en '\033[01;35m')
LCY=$(echo -en '\033[01;36m')
LCYN=$(echo -en '\033[07;36m')
WHT=$(echo -en '\033[01;37m')
clear
if [ ! -e configure ]; then
	echo "🛠🛠${YLW}เริ่มต้นสร้าง การกำหนดค่าต่างๆ อาจใช้เวลาค่อนข้างมาก${N}😅"
	rm -rf autom4te.cache
	rm -f Makefile.in aclocal.m4 autom4te.cache compat/Makefile.in
	rm -f compile config.guess config.sub config.status configure
	rm -f cpuminer-config.h.in depcomp install-sh missing
	if ./autogen.sh; then
		echo "  => done."
	else
		exit 1
	fi
fi

if [ -e Makefile ]; then
	echo "Cleaning previous build..."
	make distclean
	echo "  => done."
fi

echo "Configuring..."

# --disable-assembly: some ASM code doesn't build on ARM
# Note: we don't enable -flto, it doesn't bring anything here but slows down
# the build a lot. If needed, just add -flto to the CFLAGS string.
# normal build.
./configure --with-crypto --with-curl --disable-assembly CC=gcc CXX=g++ CFLAGS="-Ofast -fuse-linker-plugin -ftree-loop-if-convert-stores -march=native" LDFLAGS="-march=native"

# debug build
#./configure --with-crypto --with-curl --disable-assembly CC=gcc CXX=g++ CFLAGS="-O0 -g3 -fuse-linker-plugin -ftree-loop-if-convert-stores -march=native" LDFLAGS="-g3 -march=native"

[ $? = 0 ] || exit $?
echo "  => done."

if [ -z "$NPROC" ]; then
	NPROC=$(nproc 2>/dev/null)
	NPROC=${NPROC:-1}
fi

echo "Compiling on $NPROC processes..."

make install -j $NPROC

if [ $? != 0 ]; then
	echo "Compilation failed (make=$?)".
	echo "Common causes: missing libjansson-dev libcurl4-openssl-dev libssl-dev"
	echo "If you pulled updates into this directory, remove configure and try again."
	exit 1
fi
echo "🛠${GRN}สร้างการกำหนดค่าต่างๆ สำเร็จ${N}🎉"

echo '$ ls -l cpuminer'
ls -l cpuminer

echo "Stripping..."

strip -s cpuminer

[ $? = 0 ] || exit $?
echo " ⚡${LCYN}พร้อมทำงาน โปรดตั้งค่าต่างๆเพื่อเริ่มขุด${N}⚡"
