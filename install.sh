#!/bin/bash
# things to do:
# 1. backup all replaced files
# 2. update repos and check which package manager is on the system (paru, yay, dnf, or apt)
# 3. auto-check needed packages first
# 4. install extensions needed ( do want to support the projects at hand, although, im not sure how easy it will be)
# 5. auto-create any folders that arent there for the installation
# # folders needed: ~/.local/share/icons/hicolor/512x512/app, ~/.local/share/aurorae/themes, ~/.local/share/kwin/scripts
# 6. replace instances of my name (incyada) to $USER
# 7. check if the device has battery, why? cause not everyone has a laptop (use ls /sys/class/power_supply/BAT* and see if it doesnt error out)
# 8. lots of manual copy-pasting

# you can replace strings by changing its value later down the line, just like python, thank god
# solid intro
# # not sure if multiple lines will slow things down for systems that are pretty slow
echo "* * NOISIUM DOTS TUI INSTALLER * *"
echo "Welcome to the Noisium dots TUI installer!"
echo "This script will handle the manually parts of installing the noisium dots for you, so that all you ahve to do is sit back, relax, and enjoy the commands!"
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

echo ""
echo "- alright then, lets begin!"
# backup user files and folders to another directory, incase something does goes wrong
function data-backup() {
    echo "1. Backing up user data (for extra mesure)..."
    cp -r ~/.config ~./.config-backup
    cp -r ~/.local/share ~/.local/share-backup
}
# i guess now we can call it
data-backup
