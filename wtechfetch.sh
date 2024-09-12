#!/bin/bash
#Author https://github.com/withersky
CRESET='\033[0m'
BLUE='\033[0;34m'
LBLUE='\033[1;34m'
MAGENTA='\033[0;35m'
LMAGENTA='\033[1;35m'
YELLOW='\033[0;33m'
SELECT=$1
#===Specs func==============================================================================================================
specs() {
    if [ -f "/etc/os-release" ]; then
        . /etc/os-release
    else
        PRETTY_NAME=$(uname -o)
    fi
    ARCH=$(uname -m)
    KERNEL=$(uname -r)
    if command -v duptime -p &>/dev/null; then
        UPTIME=$(uptime -p | sed 's/^.\{3\}//')
    else
        UPTIME="${MAGENTA}Incorrect format!${CRESET}"
    fi
    if command -v dpkg &>/dev/null; then
        PACKAGES_DPKG=$(dpkg -l | wc -l)
        PACKAGES_DPKG=" ${PACKAGES_DPKG} (dpkg)"
    fi
    if command -v rpm &>/dev/null; then
        PACKAGES_RPM=$(rpm -qa | wc -l)
        PACKAGES_RPM=" ${PACKAGES_RPM} (rpm)"
    fi
    if command -v snap &>/dev/null; then
        PACKAGES_SNAP=$(snap list | wc -l)
        PACKAGES_SNAP=" ${PACKAGES_SNAP} (snap)"
    fi
    if command -v flatpak &>/dev/null; then
        PACKAGES_FLATPAK=$(flatpak list | grep -v ^'Ref' | wc -l)
        PACKAGES_FLATPAK=" ${PACKAGES_FLATPAK} (flatpak)"
    fi
    if [[ "$ARCH" == "mips" ]]; then
        CPU=$(cat /proc/cpuinfo | grep 'cpu model'| uniq | sed 's/.*: //')
    else
        CPU=$(cat /proc/cpuinfo | grep 'model name' | uniq | sed 's/.*: //')
    fi
    if command -v lspci &>/dev/null; then
        GPU=$(lspci | grep -i vga | sed 's/.*: //; s/ (rev [0-9]*)$//')
    else
        GPU="${MAGENTA}Unknown${CRESET}"
    fi
    MEM=$(free -b | awk -F ':' 'NR==2{print $2}' | awk '{print $1"-"$6}')
    USEDMEM=$((MEM / 1024 / 1024))
    TOTALMEM=$((${MEM//-*} / 1024 / 1024))
    TOTALSWAP=$(awk '$3=="kB"{$2=int($2/1024);$3="MB"} 1' /proc/meminfo | grep SwapTotal | sed 's/^.\{11\}\(.*\).\{3\}$/\1/')
    FREESWAP=$(awk '$3=="kB"{$2=int($2/1024);$3="MB"} 1' /proc/meminfo | grep SwapFree | sed 's/^.\{10\}\(.*\).\{3\}$/\1/')
    USEDSWAP=$((TOTALSWAP - FREESWAP))
    SWAP="${USEDSWAP} MB / ${TOTALSWAP} MB"
    if [[ "${TOTALSWAP}" == "0" ]]; then
        SWAP="${MAGENTA}Not used${CRESET}"
    fi
    if command -v journalctl &>/dev/null; then
        JERRORS=$(journalctl --since "7 days ago" | grep -i error | wc -l)
    else
        JERRORS=${MAGENTA}Not use journalctl${CRESET}
    fi
    
}
#===Display part============================================================================================================
logo() {
    echo -en "${BLUE}__        ___ _   _                   _           ${CRESET}\n"
    echo -en "${BLUE}\ \      / (_) |_| |__   ___ _ __ ___| | ___   _  ${CRESET}\n"
    echo -en "${BLUE} \ \ /\ / /| | __| '_ \ / _ \ '__/ __| |/ / | | | ${CRESET}\n"
    echo -en "${BLUE}  \ V  V / | | |_| | | |  __/ |  \__ \   <| |_| | ${CRESET}\n"
    echo -en "${BLUE}   \_/\_/  |_|\__|_| |_|\___|_|  |___/_|\_\\__,  |${CRESET}\n"
    echo -en "${BLUE}  _____         _       _____    _       _ |___/  ${CRESET}\n"
    echo -en "${BLUE} |_   _|__  ___| |__   |  ___|__| |_ ___| |__     ${CRESET}\n"
    echo -en "${BLUE}   | |/ _ \/ __| '_ \  | |_ / _ \ __/ __| '_ \    ${CRESET}\n"
    echo -en "${BLUE}   | |  __/ (__| | | | |  _|  __/ || (__| | | |   ${CRESET}\n"
    echo -en "${BLUE}   |_|\___|\___|_| |_| |_|  \___|\__\___|_| |_|   ${CRESET}\n"
}

default() {
    echo -en "${BLUE}__        ___ _   _                   _           ${CRESET}| ${LMAGENTA}${USER}${CRESET}@${LMAGENTA}${HOSTNAME}\n"
    echo -en "${BLUE}\ \      / (_) |_| |__   ___ _ __ ___| | ___   _  ${CRESET}| -----------------------\n"
    echo -en "${BLUE} \ \ /\ / /| | __| '_ \ / _ \ '__/ __| |/ / | | | ${CRESET}| ${LBLUE}OS${CRESET}: ${PRETTY_NAME} ${YELLOW}${ARCH}${CRESET}\n"
    echo -en "${BLUE}  \ V  V / | | |_| | | |  __/ |  \__ \   <| |_| | ${CRESET}| ${LBLUE}Kernel${CRESET}: ${KERNEL}\n"
    echo -en "${BLUE}   \_/\_/  |_|\__|_| |_|\___|_|  |___/_|\_\\__,  | ${CRESET}| ${LBLUE}Uptime${CRESET}: ${UPTIME}\n"
    echo -en "${BLUE}                                           |___/  ${CRESET}| ${LBLUE}Packages${CRESET}:${PACKAGES_DPKG}${PACKAGES_RPM}${PACKAGES_SNAP}${PACKAGES_FLATPAK}\n"
    echo -en "${BLUE}  _____         _       _____    _       _        ${CRESET}| ${LBLUE}CPU${CRESET}: ${CPU}\n"
    echo -en "${BLUE} |_   _|__  ___| |__   |  ___|__| |_ ___| |__     ${CRESET}| ${LBLUE}GPU${CRESET}: ${GPU}\n"
    echo -en "${BLUE}   | |/ _ \/ __| '_ \  | |_ / _ \ __/ __| '_ \    ${CRESET}| ${LBLUE}Memory${CRESET}: ${USEDMEM} MB / ${TOTALMEM} MB\n"
    echo -en "${BLUE}   | |  __/ (__| | | | |  _|  __/ || (__| | | |   ${CRESET}| ${LBLUE}Swap${CRESET}: ${SWAP}\n"
    echo -en "${BLUE}   |_|\___|\___|_| |_| |_|  \___|\__\___|_| |_|   ${CRESET}| ${LBLUE}Journalctl errors in the last 7 days${CRESET}: ${JERRORS}\n"
}
#===Help====================================================================================================================
help() {
    echo -en "${LBLUE}wtechfetch${CRESET}:\n"
    echo -en "  ${YELLOW}--logo${CRESET} - display wtechgetch logo\n"
    echo -en "  ${YELLOW}--install${CRESET} - install wtechfetch to /opt/wtechfetch\n"
    echo -en "  ${YELLOW}--uninstall${CRESET} - uninstall wtechfetch\n"
    echo -en "  ${YELLOW}without option${CRESET} - display info about PC\n"
    exit 0
}
#===Install=================================================================================================================
install() {
    if command -v wtechfetch &>/dev/null; then
        echo -e "${MAGENTA}It was installed earlier!${CRESET}"
        exit 1
    else
        sudo mkdir /opt/wtechfetch
        sudo cp ./wtechfetch.sh /opt/wtechfetch
        sudo chown -R $SUDO_USER /opt/wtechfetch
        sudo ln -s /opt/wtechfetch/wtechfetch.sh /usr/bin/wtechfetch
        echo -e "${LBLUE}For run script type 'wtechfetch'. For uninstall 'sudo wtechfetch --uninstall'${CRESET}"
        exit 0
    fi
}
#===Uninstall===============================================================================================================
uninstall() {
    if command -v wtechfetch &>/dev/null; then
        sudo rm -rf /opt/wtechfetch
        sudo rm -rf /usr/bin/wtechfetch
        echo -e "${LBLUE}Uninstall successfully!${CRESET}"
        exit 0
    else
        echo -e "${MAGENTA}Not installed!${CRESET}"
        exit 1
    fi
}
#===Are you root?===========================================================================================================
check_user() {
if [[ `whoami` != "root" ]]
then
        echo -e "\033[31mYou must be root!\033[0m"
        exit 1
fi
}
#===Main====================================================================================================================
if [[ "$SELECT" == "-h" || "$SELECT" == "--help" ]]; then
    help
    exit 0
fi

if [[ "$SELECT" == "--logo" ]]; then
    logo
    exit 0
fi

if [[ "$SELECT" == "" ]]; then
    specs
    default
    exit 0
fi

if [[ "$SELECT" == "--install" ]]; then
    check_user
    install
    exit 0
fi

if [[ "$SELECT" == "--uninstall" ]]; then
    check_user
    uninstall
    exit 0
fi
