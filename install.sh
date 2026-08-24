#!/bin/bash

# solid intro
# made this a function for simplicity sake
# actually, this whole file is just functions

# tiny warning to say to the user DO NOT RUNT THIS AS ROOT, THE SCRIPT WILL DO IT ITSELF
if [[ $EUID -eq 0 ]]; then
   echo "[NOTE]: pls dont make me destroy your system pls (no sudo)";
   exit 1;
fi

script_intro() {
    # not sure if multiple lines will slow things down for systems that are pretty slow
    echo "* * NOISIUM DOTS TUI INSTALLER * *"
    echo "Welcome to the Noisium dots TUI installer!"
    echo "This script will handle the manually parts of installing the noisium dots for you, so that all you have to do is sit back, relax, and enjoy the commands!"
    echo "Really quickly though: This script will not work if the distro of your choosing is not based on, or aren't the following:"
    echo "- Debian/Ubuntu"
    echo "- Fedora (but not based on Fedora Atomic/Silverblue)"
    echo "- Arch Linux (but not SteamOS)"
    echo "If you are willing to add support for other distros (such as NixOS, Gentoo, Alpine, or openSUSE, feel free to open a pull request to this repository: https://github.com/incyada/noisium-dots/pulls"
    # allows asking for input, in this case, its just to press enter in order to continue
    read -p "Press enter to continue: " enter

    echo ""
    echo "Before proceding, some things to note first:"
    echo "- This script will modify some user files and configurations, but the script backs them up first incase you want to easily switch back."
    echo "- In some cases, sudo will appear in order to install certain packages for this theme, you will notice as it will be invoked when needed. If you arent comfortable with that, you can exit right away (CTRL + C)."
    read -p "The next time you press enter, the script will create a backup of the most important files, and start installing itself. To accept and start, press enter: " enter
}

# backup user files and folders to another directory, incase something does goes wrong
data_backup() {
    echo "1. Backing up user data (for extra mesure)..."
    echo "The script will only back up ~/.config and ~/.local/share, as they are used for the installation"
    echo "If you see this for a couple of minutes... i can fell your pain too"
    cp -rp $HOME/.config $HOME/.config-backup
    cp -rp $HOME/.local/share $HOME/.local/share-backup
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
    elif command -v yay paru > /dev/null 2>&1; then
        # saving the aur helper that will be used
        # basically "&&" is only ran if a command suceeds
        aur_helper=$(command -v paru >/dev/null 2>&1 && echo paru || echo yay)
        echo "DISTRO BASE FOUND: ARCH"
        echo "Using pacman and the installed AUR helper as the package manager..."
        echo "AUR Helper: $aur_helper"
        pkg_manager="rtfm"
    elif command -v pacman > /dev/null 2>&1; then
        echo "DISTRO BASE FOUND: ARCH"
        echo "...But not AUR wrapper was found..."
        echo "Please install either yay, or paru first before running this script, as some AUR packages will have to be installed."
        echo "If you are on Cachyos, or have the Cachyos repositories, you can install yay, or paru like you would with any other package."
        echo "If they arent there, here are the direct links to the main AUR wrappers:"
        echo "Paru: https://github.com/Morganamilo/paru#installation"
        echo "Yay: https://github.com/Jguer/yay#source"
        exit 1
    else
        echo "Odd... maybe the package manager isnt on the ones listed, or somehow doesnt exist... try checking if apt, dnf, or pacman is there first before rerunning."
        exit 1
    fi
}

# update repositories
repo_update_time() {
    echo "3. Updating repositories, but not updating packages"
    echo "[NOTE]: You will be asked to input your password here, as package list updates are usually like that."
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
packages_installation() {
    echo "4. Installing needed system packages"
    echo ""
    if [ "${pkg_manager}" = "redhatslop" ]; then
        # looks pretty unreadable, but i did my best to make it the opposite
        local copper="sudo dnf copr enable -y"
        local install="sudo dnf install -y"
        # the $1 is there to save space on needlessly retyping it, by just providing this: user/repo
        # the number can also increment per argument added, as $2 was added
        # for dnf, $1 is the copr to enable, and $2 is the package
        package() {
            if [[ "$1" == *"/"* ]]; then
                echo "Installing $2..."
                echo "command executed: $copper $1"
                $copper $1
                echo "command executed: $install $2"
                $install $2
            else
                echo "Installing $1..."
                echo "command executed: $install $1"
                $install $1
            fi
        }

        package deltacopy/darkly darkly
        package matinlotfali/KDE-Rounded-Corners kwin-effect-roundcorners
        package infinality/kwin-effects-better-blur-dx kwin-effects-better-blur-dx
        package atim/starship starship
        package konsole
        package fish
    elif [ "${pkg_manager}" = "rtfm" ]; then
        # arch is much simpler though, as coprs dont have to be added beforehand
        # as an arch user myself (well artix, to be exact), these flags just means that the package will be install if its not there and will not ask for confirmation, usually
        local install="$aur_helper -S"
        local flags="--needed --noconfirm"
        package() {
            echo "Installing $1..."
            echo "command executed: $install $1 $flags"
            $install $1 $flags
        }

        package darkly-bin
        package kwin-effect-rounded-corners
        package kwin-effects-better-blur-dx
        # something interesting about aur helpers, atleast when it comes to paru, is that it checks the main installed repositories first before resorting to the aur
        # this means the install variable can be reused, and it still works, including with the chaotic aur (if an aur helper is installed for some reason)
        package starship
        sudo package konsole
        sudo package fish
    else
        # debian/ubuntu based installation looks weird, because i dont have ppas and darkly is the only one that is a package, so for the rest, its manual compilation time
        local install="sudo apt install -y"
        echo "Installing Darkly..."
        echo "curling first..."
        # also im not even sure if this would work on kubuntu aswell, but i refuse to use anything ubuntu based, unless its mint
        curl -L -O $(curl -s https://api.github.com/repos/Bali10050/Darkly/releases/latest | grep '"browser_download_url":' | grep .deb | grep -o 'https://[^"]*')
        # doesnt seem like apt needs another flag for installing local packages
        echo "now we install with this command: $install ./package.deb # package.deb is supposed to be darkly, but renamed incase any versions were to be added"
        # using willcard to always install deb file no matter what the name is
        $install ./*.deb
        rm -f ./*.deb
        echo ""
        echo "Hold on, ill need some dependencies first..."
        echo "command executed: sudo apt install -y [a lot of packages that are harmless]"
        $install git curl cmake g++ extra-cmake-modules qt6-tools-dev kwin-dev libkf6configwidgets-dev gettext libkf6crash-dev libkf6globalaccel-dev libkf6kio-dev libkf6service-dev libkf6notifications-dev libkf6kcmutils-dev libkdecorations3-dev libxcb-composite0-dev libxcb-randr0-dev libxcb-shm0-dev libxcb-res0-dev libxcb-sync-dev qt6-base-private-dev qt6-base-dev-tools libdrm-dev

        echo ""
        echo "Building, and installing kwin-effects-better-blur-dx..."
        git clone https://github.com/xarblu/kwin-effects-better-blur-dx
        cd kwin-effects-better-blur-dx
        chmod +x build.sh
        ./build.sh
        cd ../
        rm -rf kwin-effects-better-blur-dx

        echo ""
        echo "Building, and installing KDE-Rounded-Corners..."
        git clone https://github.com/matinlotfali/KDE-Rounded-Corners
        cd KDE-Rounded-Corners
        mkdir build
        cd build
        cmake ..
        cmake --build . -j
        sudo make install
        cd ../
        cd ../
        # some files are write protected, so sudo will be used here to properly delete it
        sudo rm -rf KDE-Rounded-Corners

        echo ""
        echo "Installing starship..."
        echo "command executed: $install starship"
        $install starship

        echo ""
        echo "Installing konsole..."
        echo "command executed: $install konsole"
        $install konsole

        echo ""
        echo "Installing fish..."
        echo "command executed: $install fish"
        $install fish
    fi
}

# installing other extensions through curl
# before that though... some functions will be defined first
dependers() {
    # ill install panel colorizer and kara first, as they have to be built first (well, one works without, but it is better with a compiled plugin)
    # dependencies first
    echo "Installing dependencies first..."
    echo "the list is long, so ill spare you the details"
    if [ "$pkg_manager" = "redhatslop" ]; then
        sudo dnf install -y git curl gcc-c++ cmake extra-cmake-modules libplasma-devel kf6-kcoreaddons-devel spectacle python3 python3-dbus python3-gobject gettext g++ qt6-qtdeclarative-devel kf6-ki18n-devel kf6-kservice-devel kf6-kwindowsystem-devel libplasma-devel plasma-activities-devel kwin-devel wayland-devel libepoxy-devel libdrm-devel plasma-workspace-devel kf6-kitemmodels-devel
    elif [ "$pkg_manager" = "rtfm" ]; then
        sudo pacman -S git curl gcc cmake extra-cmake-modules libplasma spectacle python python-dbus python-gobject gettext base-devel qt6-base qt6-declarative kwin plasma-activities plasma-workspace --needed --noconfirm
    else
        sudo apt install -y git curl build-essential cmake extra-cmake-modules libplasma-dev kde-spectacle python3 python3-dbus python3-gi gettext cmake build-essential qt6-declarative-dev extra-cmake-modules qt6-base-dev libkf6i18n-dev libkf6service-dev libkf6windowsystem-dev plasma-workspace-dev libplasmaactivities-dev kwin-dev pkg-config libdrm-dev
    fi
}

# function to make the tedious thing of manually installing github repos with install scripts in the root of the project
git_cloner_3000() {
    # $1 is user, $2 is repo name
    echo ""
    echo "Installing $1/$2..."
    git clone https://github.com/$1/$2
    cd $2
    ./install.sh $3 # this one is only for tela
    cd ../
    rm -rf $2
}

curveball() {
    echo ""
    echo "Installing $1..."
    # created a git fallback specifically for scripts that for some reason, dont have github releases on them
    if [ "$2" = "kwin" ]; then
        local mp3player=kwinscript
        local extension_install="kpackagetool6 -t KWin/Script --install extension"
    else
        local mp3player=plasmoid
        local extension_install="kpackagetool6 -t Plasma/Applet --install extension"
    fi
    if [ "$2" = "git_fallback" -o "$3" = "git_fallback" ]; then
        git clone https://github.com/$1.git fallback_extension
        cd fallback_extension
        if [ "$2" = "kwin" ]; then
            kpackagetool6 -t KWin/Script --install .
        else
            kpackagetool6 -t Plasma/Applet --install .
        fi
        cd ../
        rm -rf fallback_extension
    else
        # saves command as variable (all this does is extract the download url)
        local freemovies=$(curl -s https://api.github.com/repos/$1/releases/latest | grep '"browser_download_url":' | grep .$mp3player | grep -o 'https://[^"]*')
        # then it runs it
        # first, widget is renamed so that this is reusable
        curl -o extension -LO ${freemovies}
        # now we install it, then remove it
        $extension_install
        rm extension
    fi
}
# widget install
# the first 2 need compilation
winget2 () {
    git_cloner_3000 luisbocanegra plasma-panel-colorizer
    git_cloner_3000 dhruv8sh kara
    git_cloner_3000 kevinbudz quickclock
    curveball pnedyalkov91/advanced-weather-widget
    curveball itsKhangQBit/BetterBatteryWidget
    # will make a bit of a small exception and delete this
    rm com.itsKhang.betterbatterywidget_p5.plasmoid
    curveball zeroxoneafour/polonium kwin
    curveball maurges/dynamic_workspaces kwin git_fallback
    # im going to mostly wing the rest of them, as they are just edge case that dont necessarily need an entire function for it

    echo ""
    echo "Installing KDE Control Station..."
    git clone https://github.com/EliverLara/kde-control-station.git
    cd kde-control-station/package
    kpackagetool6 -t Plasma/Applet --install .
    cd ../
    cd ../
    rm -rf kde-control-station

    echo ""
    echo "Installing dynamic_padding..."
    kpackagetool6 -t KWin/Script --install kde/dynamic_padding.kwinscript

    git_cloner_3000 vinceliuice Tela-icon-theme -c

    echo ""
    echo "Installing Geometry change effect..."
    # there is a makefile on the repo, can use that
    git clone https://github.com/peterfajdiga/kwin4_effect_geometry_change.git
    cd kwin4_effect_geometry_change/
    make install
    cd ../
    rm -rf kwin4_effect_geometry_change/


    echo ""
    echo "Installing Pixelify Sans (user-wide)..."
    git clone https://github.com/eifetx/Pixelify-Sans.git
    mkdir -p $HOME/.local/share/fonts/p
    cp ./Pixelify-Sans/fonts/variable/PixelifySans[wght].ttf $HOME/.local/share/fonts/p/PixelifySans.ttf
    rm -rf Pixelify-Sans

    echo ""
    echo "Installing Monocraft (user-wide)..."
    # mini curveball
    local freegamesdotcom=$(curl -s https://api.github.com/repos/IdreesInc/Monocraft/releases/latest | grep '"browser_download_url":' | grep Monocraft-nerd-fonts-patched.ttc | grep -o 'https://[^"]*')
    curl -LO ${freegamesdotcom}
    # now we install it, then remove it
    cp Monocraft-nerd-fonts-patched.ttc $HOME/.local/share/fonts/p/Monocraft.ttc
    rm Monocraft-nerd-fonts-patched.ttc
}
# massive sidequest aside, here is the cleaner, final function
curvysphere() {
    echo "6. installing non-package files through curl and git"
    echo ""
    dependers
    winget2
}

# finally, another function: creating needed folders
# this step is quick, so its unnecessary to report the step to the terminal
fold() {
    mkdir -p $HOME/.local/share/$1
}

missinformation() {
    echo "5. creating missing needed folders (its just 2 lines)"
    echo ""
    fold icons/hicolor/512x512/apps
    fold aurorae/themes
}

# renaming all instances of my name (incyada), to the one of the user running the script
yourname() {
    echo "7. fixing filepaths to specify current user, instead of incyada"
    echo ""
    # make a temporary backup for good measure
    # will be worked on
    cp -r ./kde ./kde-backup
    local file=()
    # im gonna need to spilt each file cleanly, so this small loop should do it while replacing any instance of my name, with who is running the script
    while IFS= read -r file; do
        sed -i "s/incyada/$USER/g" "$file"
        echo "Overriden $file"
    done < <(grep -rl incyada kde-backup/* 2>/dev/null)
}

# most people have desktops, but i have a laptop, and since the battery widget is placed there for my usecase, ill have to detect whether or not someone has a battery on their laptop, and if its necessary to use the battery-less variant for this script
batterycheck() {
    echo "8. check if the device running the script isnt plugged 24/7"
    echo ""
    # null is nothing, who would have guessed
    # checks exit code of the command while running it
    if ls /sys/class/power_supply/BAT* >/dev/null 2>/dev/null; then
        echo "Device has a battery. layout will change accordingly"
    else
        echo "Device doesnt have a battery. layout will change accordingly"
        rm ./kde-backup/configs/plasma-org.kde.plasma.desktop-appletsrc
        mv ./kde-backup/configs/plasma-org.kde.plasma.desktop-appletsrc-nobattery kde-backup/configs/plasma-org.kde.plasma.desktop-appletsrc
    fi
}

# finally, with all of that being done, i can now manually, copy-paste everything
# well not quite, i will add some complexity as to not make this code hideous
# im tired and will explain this tomorrow
imclose() {
    local backup="./kde-backup"
    local data="$HOME/.local/share"
    # dry run avoids doing anything destructive, incase its needed
    local dry_run=0
    if [[ "$1" == "dry-run" ]]; then
        dry_run=1
        shift
    fi

    # declare is a fancier way of setting values to variables by adding attrubutes
    # in this case, each entries is an alias for a longer entry
    declare -A simple=(
        [plasma]="$data/plasma"
        [color-schemes]="$data/color-schemes"
        [wallpapers]="$data/wallpapers"
        [konsole]="$data/konsole"
    )

    # run dry run if declared
    _do() {
        if [[ $dry_run -eq 1 ]]; then
            echo "[dry-run] $*"
        else
            "$@"
        fi
    }

    # to be honest, i didnt write this, but i can explain it
    # this is needed for kwinrc, as to respect user defaults
    # what it does, is look through each entry, and only overriding any entries from the dotfiles, rather than the whole thing
    merge_ini() {
        local src="$1" dest="$2"
        mkdir -p "$(dirname "$dest")"
        touch "$dest"
        awk -v src="$src" '
        function flush_leftover(sec,    combined, parts) {
            for (combined in srcval) {
                split(combined, parts, SUBSEP)
                if (parts[1] == sec && !((sec, parts[2]) in done)) {
                    print parts[2] "=" srcval[sec, parts[2]]
                    done[sec, parts[2]] = 1
                }
            }
        }
        BEGIN {
            sec = ""
            while ((getline line < src) > 0) {
                if (line ~ /^\[.*\]$/) {
                    sec = line
                    if (!(sec in secSeen)) { secSeen[sec]=1; secOrder[++nsec]=sec }
                    continue
                }
                if (line !~ /^[;#]/ && (p = index(line, "=")) > 0)
                    srcval[sec, substr(line,1,p-1)] = substr(line,p+1)
            }
            close(src)
            cursec = ""
        }
        /^\[.*\]$/ {
            flush_leftover(cursec)
            cursec = $0
            destSeen[cursec] = 1
            print
            next
        }
        !/^[;#]/ && (p = index($0, "=")) > 0 {
            key = substr($0, 1, p-1)
            if ((cursec, key) in srcval) {
                print key "=" srcval[cursec, key]
                done[cursec, key] = 1
            } else print
            next
        }
        { print }
        END {
            flush_leftover(cursec)
            for (i=1; i<=nsec; i++) {
                s = secOrder[i]
                if (!(s in destSeen)) {
                    print s
                    flush_leftover(s)
                }
            }
        }
        ' "$dest" > "$dest.tmp" && mv "$dest.tmp" "$dest"
    }

    # copies any entry that have more unique filepaths
    # basically boils down to "if its this, run this-and honestly? thats extravagant."
    # how did i do my ai comment
    for item in "$@"; do
        if [[ -n "${simple[$item]}" ]]; then
            _do mkdir -p "${simple[$item]}"
            _do cp -r "$backup/$item/." "${simple[$item]}/"
        elif [[ "$item" == start-bloom ]]; then
            local myflower="$HOME/.local/share/icons/hicolor/512x512/apps"
            _do mkdir -p $myflower
            _do cp "$backup/Start Bloom.svg" "$myflower/"
        elif [[ "$item" == aurorae ]]; then
            local mynoise="$HOME/.local/share/aurorae/themes/"
            _do cp -rn "$backup/aurorae-themes/." "$mynoise"
        elif [[ "$item" == kwin ]]; then
            _do merge_ini "$backup/kwinrc" "$HOME/.config/kwinrc"
        elif [[ "$item" == configs ]]; then
            _do mkdir -p "$HOME/.config"
            _do cp -r "$backup/configs/." "$HOME/.config/"
        else
            echo "Unknown item: $item" >&2
        fi
    done
}

dotinstall() {
    echo "9. actually installing the dot files"
    echo ""
    # if you specify dry-run before everything else, it wont actually override your dotfiles before the script was ran
    imclose plasma color-schemes wallpapers konsole kwin start-bloom configs aurorae
    # if the theme doesnt get applied on the session, force it
    plasma-apply-lookandfeel -a "Blackberry Noisium"
}

# last thing before sendoff, changing the shell
newsoup() {
    echo "10. change shell to fish"
    echo ""
    echo "depending on if sudo didnt timeout, you will be asked for your password"
    # i didnt think this would be possible
    chsh -s "$(command -v fish)" "$USER"
}

# now i can have an outro
# been one of the longest couple of days
script_outro() {
    # you are not needed anymore
    rm -rf kde-backup
    echo ""
    echo "* * The dotfiles has been installed! * *"
    echo "Now that its done, some things last:"
    echo "1. make sure that anything that you consider important has been correctly backed up before the script installed the dotfiles potentionally destructive. they are on the following paths:"
    echo "- Configs: ~/.config, backed up to ~/.config-backup"
    echo "- App data: ~/.local/share, backed up to ~/.local/share-backup"
    echo "2. Log out to apply everything for the dotfiles, trust me, you should do this"
    echo "3. Check out the Polonium keybinds to change them, or familiarize with them. You can see the shortcuts on System Settings > Keyboard > Shortcuts > Window Management > Any keybind that starts with "Polonium:""
    echo "4. If you want a more WM-like feel, why not try the title-less variant of the theme's window decoration (yes, i made one)? You would find it ion the System Settings > Color and Themes > Window decorations"
    echo "5. Try out any wallpapers that you will like, rather than the default included in this theme. I made 5, 4 of which are Minecraft screenshots for different seasons."
    echo "6. Apply the Silent SDDM config for a more consistent look for the lookscreen. The files are in the silent-sddm folder, and you should be able to override the "silent" SDDM theme files (if they are there) with whats in there."
    echo "Remember: You can always return to before the script was ran via the backups if you want to return to your setup."
    echo ""
    echo "With all of that being said and done, there is nothing else for me, and i hope you enjoy the Noisium Dots!"
    read -p "Press enter to end: " enter
}
# i guess now we can call them
# they are also at the bottom, so that its faster to remove a step for debugging
script_intro

echo ""
echo "- alright then, lets begin!"

data_backup # step 1
pkg_manager_check # step 2
repo_update_time # step 3
packages_installation # step 4
missinformation # step 5
curvysphere # step 6
yourname # step 7
batterycheck # step 8
dotinstall # step 9
newsoup # step 10
script_outro
