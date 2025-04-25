<div align="center">
  <img loading="lazy" src="https://raw.githubusercontent.com/StardustMod/build/refs/heads/main/assets/banner.png"/>
</div>

<h4 align="center">StardustKernel 💫 for Nokia 2.1 (Android 10).</h4>

# Features

- Based on CAF Kernel Tag ***LA.UM.8.6.r1-03400-89xx.0***
- Kernel Based on ***00WW_4_11I (August 1, 2021)***
- Upstream Kernel from ***3.18.124*** to ***3.18.140***
- Merge with CAF Kernel Tag ***LA.UM.8.6.r1-05300-89xx.0*** + ***Android Common Kernel*** + ***Linux Stable***
- KernelSU by [***@backslashxx***](https://github.com/backslashxx)
- A little overclock for GPU
- Overclock for Little, Mid and Big CPU
- CPU Input Boost
- HZ Tick Set at 25Hz
- Cortex A53 Optimizations
- WireGuard
- Klapse
- Boeffla Wakelock Blocker
- MSM Hotplug
- ThunderTweaks Support (You can get ThunderTweaks [here](https://github.com/StardustMod/build/raw/refs/heads/main/ThunderTweaks_v1.1.1.5.apk) to customize kernel features)

# How to Install

- Flash Zip file via `TWRP` recovery based (You can get TWRP [here](https://github.com/Dynamo8917/android_recovery_fih_E2M))
- Install `Kernel Addons` on `/sdcard/StardustKernel-Addons-Dynamo-[version].zip` via Magisk
- Install `KernelSU` from [Here](https://github.com/backslashxx/KernelSU/releases)

# Supported Devices

|       Name        |  Codename/Model  |
:------------------:|:----------------:|
|     Nokia 2.1     |       E2M        |
|     Nokia 2V      |       EVW        |

# Revert to Stock Kernel
- You can flash zip file [here](https://github.com/StardustMod/build/raw/refs/heads/main/StardustKernel-Uninstaller-Nokia_2.1-Dynamo.zip) to restore stock kernel.

# How to Build

1. Copy command below and paste on your terminal to install all necessary dependencies

```
sudo apt update && sudo apt upgrade -y && sudo apt install --no-install-recommends -y build-essential && wget http://security.ubuntu.com/ubuntu/pool/universe/p/python2.7/python2.7_2.7.18-13ubuntu1.5_amd64.deb http://security.ubuntu.com/ubuntu/pool/universe/p/python2.7/libpython2.7-stdlib_2.7.18-13ubuntu1.5_amd64.deb http://security.ubuntu.com/ubuntu/pool/universe/p/python2.7/python2.7-minimal_2.7.18-13ubuntu1.5_amd64.deb http://security.ubuntu.com/ubuntu/pool/universe/p/python2.7/libpython2.7-minimal_2.7.18-13ubuntu1.5_amd64.deb && sudo apt install -y ./libpython2.7-minimal_2.7.18-13ubuntu1.5_amd64.deb ./libpython2.7-stdlib_2.7.18-13ubuntu1.5_amd64.deb ./python2.7-minimal_2.7.18-13ubuntu1.5_amd64.deb ./python2.7_2.7.18-13ubuntu1.5_amd64.deb && rm -rf *.deb && sudo ln -sf /usr/bin/python2.7 /usr/bin/python2
```

2. Clone repository

```
git clone https://github.com/StardustMod/android_kernel_nokia_msm8917
```

3. Build it!

```
./build.sh
```

4. After build you can find the kernel zip file at the location below

```
build/export/StardustKernel-Unofficial-[yyyyMMdd]-Nokia2.1-Dynamo.zip
```

5. Flash using TWRP based recovery

6. Test it and enjoy!

# Credits

- [`Project Dynamo`](https://github.com/Dynamo8917) for [Kernel Source](https://github.com/Dynamo8917/android_kernel_nokia_msm8917)
- [`Batu33TR`](https://github.com/Batu33TR) for [ProjectMedusa Kernel](https://github.com/ProjectMedusaAndroid/android_kernel_samsung_msm8917_Q)
- [`Chococatpp`](https://github.com/Chococatpp) for [ProjectSoraki Kernel](https://github.com/Chococatpp/android_kernel_samsung_msm8917_Q)
- [`msm8917-dev`](https://github.com/msm8917-dev) for [LineageOS Kernel](https://github.com/msm8917-dev/android_kernel_samsung_msm8917)
- [`backslashxx`](https://github.com/backslashxx) for [KernelSU](https://github.com/backslashxx/KernelSU) and [Backport Guide](https://github.com/backslashxx/KernelSU/issues/20)
