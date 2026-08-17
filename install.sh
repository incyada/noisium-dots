#!/bin/bash
# things to do:
# DONE:
# 1. backup all replaced files
# 2. update repos and check which package manager is on the system (paru, yay, dnf, or apt)
# NOT STARTED YET:
# 3. auto-check needed packages first, then install them
# 4. install extensions needed (do want to support the projects at hand, although, im not sure how easy it will be)
# 5. auto-create any folders that arent there for the installation
# # folders needed: ~/.local/share/icons/hicolor/512x512/app, ~/.local/share/aurorae/themes, ~/.local/share/kwin/scripts
# 6. replace instances of my name (incyada) to $USER
# 7. check if the device has battery, why? cause not everyone has a laptop (use ls /sys/class/power_supply/BAT* and see if it doesnt error out)
# 8. lots of manual copy-pasting

# solid intro
# made this a function for simplicity sake
function script_intro() {
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
# i guess now we can call it
# oh, also i have to do this each time i finish writing a function
script_intro

echo ""
echo "- alright then, lets begin!"
# backup user files and folders to another directory, incase something does goes wrong
function data_backup() {
    echo "1. Backing up user data (for extra mesure)..."
    ""
    cp -r ~/.config ~./.config-backup
    cp -r ~/.local/share ~/.local/share-backup
}
# this one is disabled, as on my system, it would have to copy OVER 100GBs of content, so this makes developing the script faster, for now anyway
# data_backup

# package check via package manager
# quite weird, but makes things less error prone
function pkg_manager_check() {
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
        echo "DISTRO BASE FOUND: ARCH"
        echo "Using pacman as the package manager..."
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
pkg_manager_check

# update repositories
function repo_update_time() {
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
repo_update_time
