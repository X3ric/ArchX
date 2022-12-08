#!/usr/bin/env bash
#github-action genshdoc
#
# @file Post-Setup
# @brief Finalizing installation configurations and cleaning up after script.
clear
echo -ne "
       _________                          __                        
      /   _____/   ____  _______  ___  __|__| _____  ____   ______
      \_____  \   / __ \ \_  __ \ \  \/ /|  |/  ___\/ __ \ /  ___/
      /        \ \  ___/  |  | \/  \   / |  |\  \___\  __/ \___ \ 
     /_______  /  \___  > |__|      \_/  |__| \___  >\___  >/___  >
             \/       \/                          \/     \/     \/ 
                  _____________________________________
                  \  Automated Arch Linux Installer   /
                   \    SCRIPTHOME:     ArchX        /
                    \_______________________________/

                     Final Setup and Configurations
                   GRUB EFI Bootloader Install & Check

"
source ${HOME}/ArchX/configs/setup.conf

if [[ -d "/sys/firmware/efi" ]]; then
    grub-install --efi-directory=/boot ${DISK}
fi

echo -ne "
___________________________________________________________
                      Creating Grub Boot Menu Themed      /
_________________________________________________________/

"
# set kernel parameter for decrypting the drive
if [[ "${FS}" == "luks" ]]; then
sed -i "s%GRUB_CMDLINE_LINUX_DEFAULT=\"%GRUB_CMDLINE_LINUX_DEFAULT=\"cryptdevice=UUID=${ENCRYPTED_PARTITION_UUID}:ROOT root=/dev/mapper/ROOT %g" /etc/default/grub
fi
# set kernel parameter for adding splash screen
sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="[^"]*/& splash /' /etc/default/grub
echo -e "Installing PolyDark Grub theme..."
THEME_DIR="/boot/grub/themes"
THEME_NAME="PolyDark"
echo -e "Creating the theme directory..."
mkdir -p "${THEME_DIR}/${THEME_NAME}"
echo -e "Copying the theme..."
cd ${HOME}/ArchX
cp -a configs${THEME_DIR}/${THEME_NAME}/* ${THEME_DIR}/${THEME_NAME}
echo -e "Backing up Grub config..."
cp -an /etc/default/grub /etc/default/grub.bak
echo -e "Setting the theme as the default..."
grep "GRUB_THEME=" /etc/default/grub 2>&1 >/dev/null && sed -i '/GRUB_THEME=/d' /etc/default/grub
echo "GRUB_THEME=\"${THEME_DIR}/${THEME_NAME}/theme.txt\"" >> /etc/default/grub
echo -e "Updating grub..."
grub-mkconfig -o /boot/grub/grub.cfg
echo -e "All set!"

#echo -ne "
#_______________________________________________________________
#                      Enabling Login Display Manager          /
#_____________________________________________________________/
#
#"
#if [[ ! "${DESKTOP_ENV}" == "arch"  ]]; then
#git clone --recurse-submodules https://github.com/fairyglade/ly
#cd ly
#make
#make install installsystemd
#cd ..
##sed -i 's/^#tty = 2/tty = 1/' /etc/ly/config.ini
#sudo systemctl enable ly.service
#systemctl disable getty@tty2.service
#fi
#
echo -ne "
______________________________________________________
                      Enabling Essential Services    /
____________________________________________________/

"
systemctl enable cups.service
echo "  Cups enabled"
ntpd -qg
systemctl enable ntpd.service
echo "  NTP enabled"
systemctl disable dhcpcd.service
echo "  DHCP disabled"
systemctl stop dhcpcd.service
echo "  DHCP stopped"
systemctl enable NetworkManager.service
echo "  NetworkManager enabled"
systemctl enable bluetooth
echo "  Bluetooth enabled"
systemctl enable avahi-daemon.service
echo "  Avahi enabled"

if [[ "${FS}" == "luks" || "${FS}" == "btrfs" ]]; then
echo -ne "
____________________________________________________
                      Creating Snapper Config      /
__________________________________________________/

"

SNAPPER_CONF="$HOME/ArchX/configs/etc/snapper/configs/root"
mkdir -p /etc/snapper/configs/
cp -rfv ${SNAPPER_CONF} /etc/snapper/configs/

SNAPPER_CONF_D="$HOME/ArchX/configs/etc/conf.d/snapper"
mkdir -p /etc/conf.d/
cp -rfv ${SNAPPER_CONF_D} /etc/conf.d/

fi

echo -ne "
____________________________________________________
                          Setting samba            /
__________________________________________________/

"
cp -rfv "$HOME/ArchX/configs/etc/samba" /etc/

echo -ne "
________________________________________
                             Cleaning  /
______________________________________/

"
# Remove no password sudo rights
sed -i 's/^%wheel ALL=(ALL) NOPASSWD: ALL/# %wheel ALL=(ALL) NOPASSWD: ALL/' /etc/sudoers
sed -i 's/^%wheel ALL=(ALL:ALL) NOPASSWD: ALL/# %wheel ALL=(ALL:ALL) NOPASSWD: ALL/' /etc/sudoers
# Add sudo rights
sed -i 's/^# %wheel ALL=(ALL) ALL/%wheel ALL=(ALL) ALL/' /etc/sudoers
sed -i 's/^# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers

rm -r $HOME/ArchX
rm -r /home/$USERNAME/ArchX
rm -r /home/$USERNAME/yay

# Replace in the same state
cd $pwd
