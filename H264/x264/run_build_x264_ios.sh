#!/bin/sh

CONFIGURE_FLAGS="--enable-static --enable-pic --disable-cli"

ARCHS="arm64 x86_64 i386 armv7 armv7s"

# directories
SOURCE="x264"
FAT="x264-iOS"

SCRATCH="scratch-x264"
# must be an absolute path
THIN=`pwd`/"thin-x264"

X264Repos="http://git.videolan.org/git/x264.git"

# the one included in x264 does not work; specify full path to working one
GAS_PREPROCESSOR=/usr/local/bin/gas-preprocessor.pl
GASRepos="https://github.com/libav/gas-preprocessor.git"

#check GAS script
if [ ! -r $GAS_PREPROCESSOR ];then
    echo 'gas-preprocessor.pl not found. Trying to install...'
    rm -rf gas-preprocessor
    git clone ${GASRepos}
    cp  gas-preprocessor/gas-preprocessor.pl ${GAS_PREPROCESSOR}
    chmod u+x ${GAS_PREPROCESSOR}
fi

#check x264
if [ ! -r ${SOURCE} ]; then
    echo 'x264 source not found. Trying to download...'
    git clone ${X264Repos}
fi

COMPILE="y"
LIPO="y"

if [ "$*" ]
then
	if [ "$*" = "lipo" ]
	then
		# skip compile
		COMPILE=
	else
		ARCHS="$*"
		if [ $# -eq 1 ]
		then
			# skip lipo
			LIPO=
		fi
	fi
fi

if [ "$COMPILE" ]
then
	CWD=`pwd`
	for ARCH in $ARCHS
	do
		echo "building $ARCH..."
		mkdir -p "$SCRATCH/$ARCH"
		cd "$SCRATCH/$ARCH"
		CFLAGS="-arch $ARCH"
                ASFLAGS=

		if [ "$ARCH" = "i386" -o "$ARCH" = "x86_64" ]
		then
		    PLATFORM="iPhoneSimulator"
		    CPU=
		    if [ "$ARCH" = "x86_64" ]
		    then
		    	CFLAGS="$CFLAGS -mios-simulator-version-min=7.0"
		    	HOST=
		    else
		    	CFLAGS="$CFLAGS -mios-simulator-version-min=5.0"
			HOST="--host=i386-apple-darwin"
		    fi
		else
		    PLATFORM="iPhoneOS"
		    if [ $ARCH = "arm64" ]
		    then
		        HOST="--host=aarch64-apple-darwin"
			XARCH="-arch aarch64"
		    else
		        HOST="--host=arm-apple-darwin"
			XARCH="-arch arm"
		    fi
                    CFLAGS="$CFLAGS -fembed-bitcode -mios-version-min=7.0"
                    ASFLAGS="$CFLAGS"
		fi

		XCRUN_SDK=`echo $PLATFORM | tr '[:upper:]' '[:lower:]'`
		CC="xcrun -sdk $XCRUN_SDK clang"
		if [ $PLATFORM = "iPhoneOS" ]
		then
		    export AS="gas-preprocessor.pl $XARCH -- $CC"
		else
		    export -n AS
		fi

		CXXFLAGS="$CFLAGS"
		LDFLAGS="$CFLAGS"

        cd  $CWD/$SOURCE
		CC=$CC $CWD/$SOURCE/configure \
		    $CONFIGURE_FLAGS \
		    $HOST \
		    --extra-cflags="$CFLAGS" \
		    --extra-asflags="$ASFLAGS" \
		    --extra-ldflags="$LDFLAGS" \
		    --prefix="$THIN/$ARCH" || exit 1
		mkdir extras
		ln -s $GAS_PREPROCESSOR extras

		make -j3 install || exit 1
		cd $CWD
	done
fi

if [ "$LIPO" ]
then
	echo "building fat binaries..."
	mkdir -p $FAT/lib
	set - $ARCHS
	CWD=`pwd`
	cd $THIN/$1/lib
	for LIB in *.a
	do
		cd $CWD
		lipo -create `find $THIN -name $LIB` -output $FAT/lib/$LIB
	done

	cd $CWD
	cp -rf $THIN/$1/include $FAT
fi

