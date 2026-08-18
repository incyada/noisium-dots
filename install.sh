#!/bin/bash
# things to do:
# DONE:
# 1. backup all replaced files
# 2. update repos and check which package manager is on the system (paru, yay, dnf, or apt)
# 3. auto-check needed packages first, then install them (skipped apt for now, and would refactor fedora installs a bit)
# TODO NEXT TIME: switch to kwin install depending on what is being installed and only install file if it contain .plasmoid or .kwinscript in it

# NOT STARTED YET:
# 4. install extensions needed (do want to support the projects at hand, although, im not sure how easy it will be)
# 5. auto-create any folders that arent there for the installation
# # folders needed: ~/.local/share/icons/hicolor/512x512/app, ~/.local/share/aurorae/themes, ~/.local/share/kwin/scripts
# 6. replace instances of my name (incyada) to $USER
# 7. check if the device has battery, why? cause not everyone has a laptop (use ls /sys/class/power_supply/BAT* and see if it doesnt error out)
# 8. lots of manual copy-pasting

# solid intro
# made this a function for simplicity sake
# actually, this whole file is just functions
script_intro() {
    # not sure if multiple lines will slow things down for systems that are pretty slow
    echo "* * NOISIUM DOTS TUI INSTALLER * *"
    echo "Welcome to the Noisium dots TUI installer!"
    echo "This script will handle the manually parts of installing the noisium dots for you, so that all you have to do is sit back, relax, and enjoy the commands!"
    echo "Really quickly though: This script will not work if the distro of your choosing is based on, or are the following:"
    echo "- Debian/Ubuntu"
    echo "- Fedora (but not based on Fedora Atomic/Silverblue)"
    echo "- Arch Linux (but not SteamOS)"
    echo "If you are willing to add support for other distros (such as NixOS, Gentoo, Alpine, or openSUSE, feel free to open a pull request to this repository: https://github.com/incyada/noisium-dots/pulls"
    # allows asking for input, in this case, its just to press enter in order to continue
    read -p "Press enter to continue: " enter
    echo ""
    echo "Before proceding, some things to note first:"
    echo "- This script will modify some user files and configurations, but the script backs them up first incase you want to easily switch back."
    echo "- In some cases, sudo will appear in order to install certain packages for this theme. If you arent comfortable with that, you can exit right away (CTRL + C)."
    read -p "The next time you press enter, the script will create a backup of the most important files, and start installing itself. To accept and start, press enter: " enter
}

echo ""
echo "- alright then, lets begin!"
# backup user files and folders to another directory, incase something does goes wrong
data_backup() {
    echo "1. Backing up user data (for extra mesure)..."
    ""
    cp -r ~/.config ~./.config-backup
    cp -r ~/.local/share ~/.local/share-backup
}

# package check via package manager
# quite weird, but makes things less error prone
pkg_manager_check() {
    # basic if else chain that checks for the right package manager
    echo "2. Checking what distro this is through the package manager..."
    echo ""
    if command -v apt > /dev/null 2>&1; then
        echo "DISTRO BASE FOUND: DEBIAN"
        echo "Using apt as the package manager..."
        # you can replace strings by changing its value later down the line, just like python, thank god
        # although that is not whats happening here, it is a rule of thumb to remember
        # plus this is my script, i can write whatever i want
        pkg_manager="lbuntu"
    elif command -v dnf > /dev/null 2>&1; then
        echo "DISTRO BASE FOUND: FEDORA"
        echo "Using dnf as the package manager..."
        pkg_manager="redhatslop"
    # on arch, will have to check if yay or paru is installed rather than pacman... will have to install some AUR packages
    # there is acleaner way of doing this check, without another if statement, but i havent unlocked that yet
    elif command -v paru yay > /dev/null 2>&1; then
        # saving the aur helper that will be used
        if command -v paru > /dev/null 2>&1; then
            aur_helper=paru
        else
            aur_helper=yay
        fi
        echo "DISTRO BASE FOUND: ARCH"
        echo "Using pacman as the package manager..."
        echo "AUR Helper: $aur_helper"
        pkg_manager="rtfm"
    elif command -v pacman > /dev/null 2>&1; then
        echo "DISTRO BASE FOUND: ARCH"
        echo "...But not AUR wrapper was found..."
        echo "Please install either yay, or paru first before running this script, as some AUR packages will have to be installed."
        exit 1
    else
        echo "Odd... maybe the package manager isnt on the ones listed, or somehow doesnt exist... try checking if its there first before rerunning."
        exit 1
    fi
}

# update repositories
repo_update_time() {
    echo "3. Updating repositories, but not updating packages"
    echo "[NOTE]: You will be asked to input your password here, as package list updates are ususally like that."
    echo ""
    # checks if a variable is a certain string
    if [ "${pkg_manager}" = "rtfm" ]; then
        echo "command executed: sudo pacman -Sy"
        sudo pacman -Sy
    elif [ "${pkg_manager}" = "redhatslop" ]; then
        echo "command executed: sudo dnf makecache"
        sudo dnf makecache
    # in here, i can just add the debian/ubuntu commands, since the script alrady killed itself when it was checking the distro
    else
        echo "command executed: sudo apt update"
        sudo apt update
    fi
}

# installing system packages
# i have an idea, and its just to turn all of these entries into functions, rather than hardcoded commands
# ill reserve this at the end of the script
packages_installation() {
    echo "4. Installing needed system packages"
    echo ""
    if [ "${pkg_manager}" = "redhatslop" ]; then
        # looks pretty unreadable, but i did my best to make it the opposite
        echo "Installing Darkly..."
        echo "command executed: sudo dnf copr enable deltacopy/darkly -y"
        sudo dnf copr enable deltacopy/darkly -y
        echo "command executed: sudo dnf install darkly -y"
        sudo dnf install darkly -y

        echo ""
        echo "Installing Rounded corners effect..."
        echo "command executed: sudo dnf copr enable matinlotfali/KDE-Rounded-Corners -y"
        sudo dnf copr enable matinlotfali/KDE-Rounded-Corners -y
        echo "command executed: sudo dnf install kwin-effect-roundcorners -y"
        sudo dnf install kwin-effect-roundcorners -y

        echo ""
        echo "Installing Better Blur DX..."
        echo "command executed: sudo dnf copr enable infinality/kwin-effects-better-blur-dx -y"
        sudo dnf copr enable infinality/kwin-effects-better-blur-dx -y
        echo "command executed: sudo dnf install kwin-effects-better-blur-dx -y"
        sudo dnf install kwin-effects-better-blur-dx -y

        echo ""
        echo "Installing Konsole (if its not there there)"
        echo "command executed: sudo dnf install konsole -y"
        sudo dnf install konsole -y

        echo ""
        echo "Cooking some fresh fish (if its not there there)"
        echo "If you dont want fish, then you can delete it after the dots are installing"
        echo "command executed: sudo dnf install fish -y"
        sudo dnf install fish -y
    elif [ "${pkg_manager}" = "rtfm" ]; then
        # arch is much simpler though, as coprs dont have to be added beforehand
        echo "Installing Darkly..."
        # as an arch user myself (well artix, to be exact), these flags just means that the package will be install if its not there and will not ask for confirmation, usually
        echo "command executed: sudo $aur_helper darkly-bin --needed --noconfirm"
        sudo $aur_helper darkly-bin --needed --noconfirm

        echo ""
        echo "Installing Rounded corners effect..."
        echo "command executed: sudo $aur_helper kwin-effect-rounded-corners --needed --noconfirm"
        sudo $aur_helper kwin-effect-rounded-corners --needed --noconfirm

        echo ""
        echo "Installing Better Blur DX..."
        echo "command executed: sudo $aur_helper kwin-effects-better-blur-dx --needed --noconfirm"
        sudo $aur_helper kwin-effects-better-blur-dx --needed --noconfirm

        echo ""
        echo "Installing Konsole (if its not there there)"
        echo "command executed: sudo pacman -S konsole --needed --noconfirm"
        sudo pacman -S konsole --needed --noconfirm

        echo ""
        echo "Cooking some fresh fish (if its not there there)"
        echo "If you dont want fish, then you can delete it after the dots are installing"
        echo "command executed: sudo pacman -S fish --needed --noconfirm"
        sudo pacman -S fish --needed --noconfirm
    else
        echo "Debian-based has been skipped for now as not all of the packages are available as ppa (plus i want to work with vanilla debian, so any of ubuntu conveniences will be skipped)"
        # this one is more complicated due to... well its debian, and its not known for being new
        # use curl instead, but will be once i get there: https://github.com/Bali10050/Darkly/releases/download/v0.5.38/darkly-0.5.38_debian14_amd64.deb
        # install the following packages first: sudo apt install -y git cmake g++ extra-cmake-modules qt6-tools-dev kwin-dev libkf6configwidgets-dev gettext libkf6crash-dev libkf6globalaccel-dev libkf6kio-dev libkf6service-dev libkf6notifications-dev libkf6kcmutils-dev libkdecorations3-dev libxcb-composite0-dev libxcb-randr0-dev libxcb-shm0-dev libxcb-res0-dev libxcb-sync-dev qt6-base-private-dev qt6-base-dev-tools libdrm-dev

        # build script for better-blur-dx (i dont know how to remove it though)
        # git clone https://github.com/xarblu/kwin-effects-better-blur-dx
        # cd kwin-effects-better-blur-dx
        # chmod +x build.sh
        # ./build.sh

        # build scipt for rounded corners (samw thing)
        # git clone https://github.com/matinlotfali/KDE-Rounded-Corners
        # cd KDE-Rounded-Corners
        # mkdir build
        # cd build
        # cmake ..
        # cmake --build . -j
        # sudo make install

        echo ""
        echo "Installing Konsole (if its not there there)"
        echo "command executed: sudo apt install konsole -y"
        sudo apt install konsole -y

        echo ""
        echo "Cooking some fresh fish (if its not there there)"
        echo "If you dont want fish, then you can delete it after the dots are installing"
        echo "command executed: sudo apt install fish -y"
        sudo apt install fish -y
    fi
}

# installing other extensions through curl
# before that though...
notwaybar() {
    # ill install panel colorizer and kara first, as they have to be built first (well, one works without, but it is better with a compiled plugin)
    # dependencies first
    echo "Installing dependencies first..."
    echo "the list is long, so ill spare you the details"
    if [ "$pkg_manager" = "redhatslop" ]; then
        sudo dnf install -y git gcc-c++ cmake extra-cmake-modules libplasma-devel kf6-kcoreaddons-devel spectacle python3 python3-dbus python3-gobject gettext g++ qt6-qtbase-dev qt6-qtdeclarative-devel kf6-ki18n-devel kf6-kservice-devel kf6-kwindowsystem-devel libplasma-devel plasma-activities-devel kwin-devel wayland-devel libepoxy-devel libdrm-devel plasma-workspace-devel kf6-kitemmodels-devel
    elif [ "$pkg_manager" = "rtfm" ]; then
        sudo pacman -S git gcc cmake extra-cmake-modules libplasma spectacle python python-dbus python-gobject gettext base-devel qt6-base qt6-declarative kwin plasma-activities plasma-workspace --needed --noconfirm
    else
        sudo apt install -y git build-essential cmake extra-cmake-modules libplasma-dev kde-spectacle python3 python3-dbus python3-gi gettext cmake build-essential qt6-declarative-dev extra-cmake-modules qt6-base-dev libkf6i18n-dev libkf6service-dev libkf6windowsystem-dev plasma-workspace-dev libplasmaactivities-dev kwin-dev pkg-config libdrm-dev
    fi
    # compile widgets
    git clone https://github.com/luisbocanegra/plasma-panel-colorizer
    cd plasma-panel-colorizer
    ./install.sh
    cd ../
    rm -rf plasma-panel-colorizer
    git clone https://github.com/dhruv8sh/kara.git
    cd kara
    ./install.sh
    cd ../
    rm -rf kara
}

curveball() {
    # saves command as variable (all this does is extract the download url)
    # the $1 is also there to save space on needlessly retyping it, by just providing this: user/repo
    # the number can also increment per argument added
    freemovies=$(curl -s https://api.github.com/repos/$1/releases/latest | grep '"browser_download_url":' | grep .plasmoid | grep -o 'https://[^"]*')
    # then it runs it
    # first, widget is renamed so that this is reusable
    curl -o widget -L -O ${freemovies}
    # now we install it, then remove it
    kpackagetool6 -t Plasma/Applet --install widget
    # kpackagetool6 -t Plasma/Applet and
    rm widget
}
# widget install
# these dont need compilation, however
winget2 () {
    # installing quickclock, through git
    # git clone https://github.com/kevinbudz/quickclock.git
    # cd quickclock
    # ./install.sh
    # cd ../
    # rm -rf quickclock
    curveball pnedyalkov91/advanced-weather-widget
    curveball itsKhangQBit/BetterBatteryWidget
    # will make a but of a small exception and delete this
    rm com.itsKhang.betterbatterywidget_p5.plasmoid
    # curveball zeroxoneafour/polonium this one is a bit more complicated...
}
# anyways
curvysphere() {
    echo "5. installing non-package files through curl and git"
    echo ""
    # notwaybar
    winget2
}

# i guess now we can call it
# oh, also i have to do this each time i finish writing a function
# they are also at the bottom, so that its faster to remove a step for debugging
script_intro
# this one is disabled, as on my system, it would have to copy OVER 100GBs of content, so this makes developing the script faster, for now anyway
# data_backup
# pkg_manager_check
# repo_update_time
# packages_installation
curvysphere
