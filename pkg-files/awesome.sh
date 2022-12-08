#!/bin/bash
user="${USER}"
if [[ "$EUID" -ne 0 ]]; then
echo -nE "
___________________________
  Awesome post install    /
_________________________/

"
    echo "Cange password for root to login with su root"
    sudo passwd root
    timeout 0.1 tmux && tmux source-file ~/.config/awesome/configs/tmux.config
    sudo ./awesome.sh
else
echo -nE "
___________________________
  Awesome final install   /
_________________________/  

"
    read -p "What is your user?: " choice

    read -p 'Lang us,it: ' pos
    localectl set-keymap --no-ask-password $pos
    localectl set-x11-keymap --no-ask-password $pos

    read -p 'Is laptop. true/false: ' lp
    if [[ $lp == "true" ]]; then
    pacman -S --needed --noconfirm tlp
    systemctl enable tlp.service
    fi

    read -p 'Samba sharing on local host. true/false: ' sm
    if [[ $sm == "true" ]]; then
        systemctl enable smb.service
        systemctl enable nmb.service
        echo "Cange password samba"
        smbpasswd -a $choice
    fi

    read -p 'Printers drivers. true/false: ' pr
    if [[ $pr == "true" ]]; then
        pacman -S --needed --noconfirm cups
        pacman -S --needed --noconfirm cups-pdf
        pacman -S --needed --noconfirm ghostscript
        pacman -S --needed --noconfirm gsfonts
        pacman -S --needed --noconfirm gutenprint
        pacman -S --needed --noconfirm gtk3-print-backends
        pacman -S --needed --noconfirm libcups
        pacman -S --needed --noconfirm system-config-printer
        systemctl enable cups.service
    fi

    read -p 'Change screen size. true/false: ' wm
    if [[ $wm == "true" ]]; then
        read -p 'Screen size XxY: ' screensize
        sed -i "/run xrandr/c\run xrandr --output Virtual1 --primary --mode $screensize --pos 0x0 --rotate normal" /home/$choice/.config/awesome/configs/autostart.sh
        pkill conky
        #echo "awesome.restart()" | awesome-client
    fi

    echo "XDG_CURRENT_DESKTOP=Unity" >> /etc/environment 
    echo "QT_QPA_PLATFORMTHEME=gtk2" >> /etc/environment 
    papirus-folders -C violet --theme ePapirus-Dark
    echo "reboot to apply"
    #remove to start and delete
    sed -i '/awesome.sh/d' /home/$choice/.zshrc && rm -R /home/$choice/awesome.sh 
fi