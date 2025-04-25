#!/bin/bash

separator ()
{
  echo "---------------------------------------------------------"
}

quotes ()
{
  echo "-- $1..."
}

noquotes ()
{
  echo "-- $1"
}

clean ()
{
    separator
    quotes "Cleaning Up Build Files"

    rm -rf o* .w* build/AIK/*.c* build/AIK/s* build/*.p* build/*er* && git restore arch/arm/configs/$KERNEL_DEFCONFIG

    if [[ "$CLEAN" == "y" ]]; then
        separator
        quotes "Revert all Change to Latest Commit (All Uncommit Change will Lost!)"
        separator
        rm -rf K* toolc* build/A* build/m* build/s* build/u* && git clean -df && git reset --hard HEAD
    fi
}

abort ()
{
    cd -

    if [[ "$CLEAN" == "y" ]]; then
        clean
    fi

    separator
    quotes "Failed to Compile Kernel! Exiting"
    separator

    exit -1
}

check ()
{
    if [ $? -eq 0 ]; then
        echo "-- Setup $1 Done!"
    else
        quotes "Failed! Cancel the Script"
        abort
    fi
}

submodule ()
{
    separator
    quotes "Fetch all Submodules Update"

    git submodule update -f -q --init --recursive > /dev/null
    check "Submodules"
}

usage ()
{
    cat << EOF
Usage: $(basename "$0") [options]
Options:
    -k, --ksu [y/N]        Include KernelSU Next (default: y)
    -h, --help             List all Build Script Command
    -c, --clean [y/N]      Reset all Change to Latest Commit [!! Your Uncommit Change will Lost !!] (default: n)
EOF
}

nosudo ()
{
    clean
    noquotes "You Need to Run Script with \"sudo\" (sudo ./build.sh) to Install all Dependencies"
    separator

    exit -1
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --ksu|-k)
            KSU_OPTION="$2"
            shift 2
            ;;
        --ver|-v)
            KERNEL_VERSION="$2"
            shift 2
            ;;
        --rel|-r)
            RELEASE="$2" # Use when Run on GitHub Actions (y: Release - n: CI)
            shift 2
            ;;
        --help|-h)
            usage
            exit 1
            ;;
        --clean|-c)
            CLEAN="$2"
            shift 2
            ;;
        *)\
            exit 1
            ;;
    esac
done

detect_env ()
{
    # Set Build Variable
    separator

    DATE=`date +"%Y%m%d"`
    REPO_URL="https://raw.githubusercontent.com/StardustMod/build/refs/heads/dynamo/"
    export KBUILD_BUILD_USER=oItsMineZ
    export KBUILD_BUILD_HOST=StardustKernel

    KERNEL_DEFCONFIG=stardust-E2M-perf_defconfig
    DEVICE="Nokia 2.1"
    MODEL=Dynamo
    SOC="Snapdragon 425 (MSM8917)"

    if [ ! -z $RELEASE ]; then
        quotes "Running on GitHub Actions"
        echo BUILD_DEVICE=${DEVICE// /_} >> $GITHUB_ENV
        echo BUILD_MODEL=$MODEL >> $GITHUB_ENV
    else
        quotes "Running on Local Machine"
        LOCAL=y
    fi

    if [ -z $KERNEL_VERSION ]; then
        KERNEL_VERSION=Unofficial
    fi

    if [ -z $KSU ]; then
        KSU=y
    fi

    if [ -z $CLEAN ]; then
        CLEAN=n
    fi

    separator

    if test -f "/usr/bin/python2.7" && test -f "/usr/bin/python2"; then
        quotes "Python 2.7 Directory Found!"
    else
        quotes "Python 2.7 Not Found! Starting the Installer"
        if [[ $EUID -ne 0 ]]; then
            nosudo
        else
            quotes "Installing Python 2.7"
            separator

            wget http://security.ubuntu.com/ubuntu/pool/universe/p/python2.7/python2.7_2.7.18-13ubuntu1.5_amd64.deb http://security.ubuntu.com/ubuntu/pool/universe/p/python2.7/libpython2.7-stdlib_2.7.18-13ubuntu1.5_amd64.deb http://security.ubuntu.com/ubuntu/pool/universe/p/python2.7/python2.7-minimal_2.7.18-13ubuntu1.5_amd64.deb http://security.ubuntu.com/ubuntu/pool/universe/p/python2.7/libpython2.7-minimal_2.7.18-13ubuntu1.5_amd64.deb
            sudo apt install -y ./libpython2.7-minimal_2.7.18-13ubuntu1.5_amd64.deb ./libpython2.7-stdlib_2.7.18-13ubuntu1.5_amd64.deb ./python2.7-minimal_2.7.18-13ubuntu1.5_amd64.deb ./python2.7_2.7.18-13ubuntu1.5_amd64.deb
            rm -rf *.deb

            if test -f "/usr/bin/python2"; then
                rm -rf /usr/bin/python2
            fi

            sudo ln -sf /usr/bin/python2.7 /usr/bin/python2
            check "Python 2.7"
        fi
    fi

    if test -d "build/AIK"; then
        quotes "Android Image Kitchen Directory Found!"
    else
        quotes "Add Android Image Kitchen as Submodule"
        git submodule add -b image -f -q https://github.com/StardustMod/build build/AIK > /dev/null && chmod +x build/AIK/mk*
        check "Android Image Kitchen Directory"
    fi

    if ! test -f "build/AIK/ramdisk/init"; then
        quotes "Getting Ramdisk Binary"

        if ! test -d "build/AIK/ramdisk"; then
            mkdir -p build/AIK/ramdisk
        fi

        curl -LSs "${REPO_URL}init" -o build/AIK/ramdisk/init && chmod +x build/AIK/ramdisk/i*
        check "Ramdisk Binary"
    fi

    if ! test -f "build/module-binary"; then
        quotes "Getting Module Binary"
        curl -LSs "https://raw.githubusercontent.com/Zackptg5/MMT-Extended/refs/heads/master/META-INF/com/google/android/update-binary" -o build/module-binary
        check "Module Binary"
    fi

    quotes "Getting Module Props"
    curl -LOSs "${REPO_URL}module.prop" && curl -LOSs "${REPO_URL}system.prop" && mv *.p* build
    check "Module Props"

    if ! test -f "build/update-binary"; then
        quotes "Getting Kernel Binary"
        curl -LOSs "${REPO_URL}update-binary"
        check "Kernel Binary"
    fi

    quotes "Getting Kernel Script"
    curl -LOSs "${REPO_URL}updater-script" && mv up* build
    check "Kernel Script"

    check "Build Environment"
}

toolchain ()
{
    separator

    if test -d "toolchain"; then
        quotes "arm-linux-androideabi-4.9 Directory Found!"
    else
        quotes "Add arm-linux-androideabi-4.9 as Submodule"
        git submodule add -f -q https://github.com/arter97/arm-linux-androideabi-4.9 toolchain/arm-linux-androideabi-4.9 > /dev/null
        check "arm-linux-androideabi-4.9"
    fi

    GCC=$PWD/toolchain/arm-linux-androideabi-4.9/bin/
    ARGS="
        ARCH=arm O=out \
        KCFLAGS=-mno-android \
        CROSS_COMPILE=${GCC}arm-linux-androideabi- \
    "
}

kernelsu ()
{
    separator

    if ! test -d "drivers/kernelsu"; then
        quotes "Add KernelSU as Submodule"
        separator

        if test -d "KernelSU"; then
            rm -rf Ke*
        fi

        git submodule add -f -q https://github.com/backslashxx/KernelSU > /dev/null
        bash <(curl -LSs "https://raw.githubusercontent.com/backslashxx/KernelSU/master/kernel/setup.sh") master
        separator
        check "KernelSU"
    fi
}

kernel ()
{
    # Build Kernel Image
    separator
    noquotes "Fetch Kernel Info"
    separator
    noquotes "Device: $DEVICE ("$MODEL")"
    noquotes "SOC: $SOC"
    noquotes "Defconfig: $KERNEL_DEFCONFIG"
    noquotes "Kernel Version: $KERNEL_VERSION"
    noquotes "Build Date: `date +"%Y-%m-%d"`"

    if [ -z $KSU ]; then
        noquotes "KernelSU: Not Include"
    else
        noquotes "KernelSU: Include"
    fi

    sed -i "s/CONFIG_LOCALVERSION=\"-perf\"/CONFIG_LOCALVERSION=\"-Stardust-$KERNEL_VERSION-$DEVICE-$MODEL\"/" arch/arm/configs/$KERNEL_DEFCONFIG

    separator
    noquotes "Building Kernel Using $KERNEL_DEFCONFIG"
    quotes "Generating Configuration Files"
    separator

    make -j$(nproc --all) $ARGS $KERNEL_DEFCONFIG || abort

    separator
    quotes "Building Kernel"
    separator

    make -j$(nproc --all) $ARGS || abort

    separator
    quotes "Finished Kernel Build!"

    rm -rf build/out/$MODEL
    mkdir -p build/out/$MODEL
}

ramdisk ()
{
    # Build Ramdisk
    separator
    quotes "Building Ramdisk"
    separator

    rm -f build/AIK/s*
    mkdir -p build/AIK/split_img
    pushd build/AIK/split_img > /dev/null
    mv ../../../out/arch/arm/boot/zImage-dtb boot.img-kernel
    echo -e "0x80000000" > boot.img-base
    echo -e "" > boot.img-board
    echo -e "console=ttyHSL0,115200,n8 androidboot.console=ttyHSL0 androidboot.hardware=qcom androidboot.memcg=true user_debug=30 msm_rtb.filter=0x237 ehci-hcd.park=3 androidboot.bootdevice=7824900.sdhci lpm_levels.sleep_disabled=1 earlycon=msm_hsl_uart,0x78B0000 loop.max_part=7 loglevel=0 loglevel=0 buildvariant=user veritykeyid=id:8f56f02c61394639f13af4e8cfe02d087e41b936" > boot.img-cmdline
    echo -e "sha1" > boot.img-hashtype
    echo -e "0" > boot.img-header_version
    echo -e "AOSP" > boot.img-imgtype
    echo -e "0x00008000" > boot.img-kernel_offset
    echo -e "16777216" > boot.img-origsize
    echo -e "2021-08" > boot.img-os_patch_level
    echo -e "10.0.0" > boot.img-os_version
    echo -e "2048" > boot.img-pagesize
    echo -e "0x01000000" > boot.img-ramdisk_offset
    echo -e "gzip" > boot.img-ramdiskcomp
    echo -e "0x00f00000" > boot.img-second_offset
    echo -e "0x00000100" > boot.img-tags_offset
    popd > /dev/null

    # Create Boot Image
    quotes "Calling Android Image Kitchen"
    pushd build/AIK > /dev/null

    ./mkimg
    popd > /dev/null
}

build_zip ()
{
    # Build Zip
    separator
    quotes "Building Zip"
    if [[ "$LOCAL" == "y" ]] || [[ "$RELEASE" == "y" ]]; then
        separator
    fi

    pushd build > /dev/null
    rm -rf out/$MODEL/zip
    mkdir -p export
    mkdir -p out/$MODEL/zip/module/common/
    mkdir -p out/$MODEL/zip/module/META-INF/com/google/android
    mkdir -p out/$MODEL/zip/META-INF/com/google/android
    mv AIK/image-new.img out/$MODEL/boot-patched.img
    mv ../out/drivers/staging/prima/wlan.ko out/$MODEL/zip/pronto_wlan.ko

    cp out/$MODEL/boot-patched.img out/$MODEL/zip/boot.img
    cp update-binary out/$MODEL/zip/META-INF/com/google/android/
    mv updater-script out/$MODEL/zip/META-INF/com/google/android/

    mv module.prop out/$MODEL/zip/module/
    mv system.prop out/$MODEL/zip/module/common/
    cp module-binary out/$MODEL/zip/module/META-INF/com/google/android/update-binary
    echo -e "#MAGISK" > out/$MODEL/zip/module/META-INF/com/google/android/updater-script

    cd out/$MODEL/zip/module
    zip -r ../module.zip .
    rm -rf out/$MODEL/zip/module

    popd > /dev/null
    sed -i "s/ui_print(\" Kernel Version: \");/ui_print(\" Kernel Version: $KERNEL_VERSION\");/" build/out/$MODEL/zip/META-INF/com/google/android/updater-script
    sed -i "s/ui_print(\" Kernel Device: \");/ui_print(\" Kernel Device: $DEVICE ($MODEL)\");/" build/out/$MODEL/zip/META-INF/com/google/android/updater-script
    sed -i "s/ui_print(\" Kernel Toolchain: \");/ui_print(\" Kernel Toolchain: arm-linux-androideabi-4.9\");/" build/out/$MODEL/zip/META-INF/com/google/android/updater-script

    if [[ "$LOCAL" == "y" ]] || [[ "$RELEASE" == "y" ]]; then
        sed -i "s/CONFIG_LOCALVERSION=\"-Stardust-$KERNEL_VERSION-$DEVICE-$MODEL\"/CONFIG_LOCALVERSION=\"-StardustKernel-$KERNEL_VERSION-$DATE-$DEVICE-$MODEL\"/" arch/arm/configs/$KERNEL_DEFCONFIG
        NAME=$(grep -o 'CONFIG_LOCALVERSION="[^"]*"' arch/arm/configs/$KERNEL_DEFCONFIG | cut -d '"' -f 2)
        NAME=${NAME:1} && NAME=${NAME// /_}.zip
        pushd build/out/$MODEL/zip > /dev/null
        zip -r ../"$NAME" .
        popd > /dev/null
        pushd build/out > /dev/null
        rm -rf $MODEL/zip
        mv $MODEL/"$NAME" ../export/"$NAME"
        popd > /dev/null
    fi
}

# Main Function
rm -rf ./build.log
(
    START=`date +%s`

    separator
    quotes "Preparing the Build Environment"

    detect_env
    toolchain
    pushd $(dirname "$0") > /dev/null

    if [[ "$LOCAL" == "y" ]]; then
        submodule
    fi

    if [[ "$KSU" == "y" ]]; then
        echo "# CONFIG_KSU_LSM_SECURITY_HOOKS is not set" >> arch/arm/configs/$KERNEL_DEFCONFIG
        kernelsu
    fi

    kernel
    ramdisk
    build_zip

    if [[ "$LOCAL" == "y" ]]; then
        clean
        separator
    fi

    END=`date +%s`

    let "ELAPSED=$END-$START"

    quotes "Total Compile Time was $(($ELAPSED / 60)) Minutes and $(($ELAPSED % 60)) Seconds"
    separator
) 2>&1	| tee -a ./build.log
