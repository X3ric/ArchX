#!/usr/bin/env bash
#github-action genshdoc
#
# @file User
# @brief User customizations and AUR package installation.
clear
echo -nE "
     _____                    __       ____ ___                       
    /  _  \  _______   ____  |  |__   |    |   \ ______  ____  _______ 
   /  /_\  \ \_  __ \_/ ___\ |  |  \  |    |   //  ___/_/ __ \ \_  __ \ 
  /    |    \ |  | \/\  \___ |   Y  \ |    |  / \___ \ \  ___/  |  | \/
  \____|__  / |__|    \___  >|___|  / |______/ /____  > \___  > |__|   
          \/              \/      \/                \/      \/       
                  _____________________________________
                  \  Automated Arch Linux Installer   /
                   \    SCRIPTHOME:      ArchX       /
                    \_______________________________/

                        Installing AUR Softwares

"
source $HOME/ArchX/configs/setup.conf
cd ~
mkdir "/home/$USERNAME/.cache"
touch "/home/$USERNAME/.cache/zshhistory"
cp -r "/home/$USERNAME/ArchX/configs/usr/.zshrc" "/home/$USERNAME"
cp -r "/home/$USERNAME/ArchX/configs/usr/.aliasrc" "/home/$USERNAME"

sed -n '/'$INSTALL_TYPE'/q;p' ~/ArchX/pkg-files/${DESKTOP_ENV}.txt | while read line
do
  if [[ ${line} == '--END OF MINIMAL INSTALL--' ]]
  then
    # If selected installation type is FULL, skip the --END OF THE MINIMAL INSTALLATION-- line
    continue
  fi
  echo "INSTALLING: ${line}"
  sudo pacman -S --noconfirm --needed ${line}
done

if [[ ! $AUR_HELPER == none ]]; then
  cd ~
  git clone "https://aur.archlinux.org/$AUR_HELPER.git"
  cd ~/$AUR_HELPER
  makepkg -si --noconfirm
  # sed $INSTALL_TYPE is using install type to check for MINIMAL installation, if it's true, stop
  # stop the script and move on, not installing any more packages below that line
  sed -n '/'$INSTALL_TYPE'/q;p' ~/ArchX/pkg-files/aur-pkgs.txt | while read line
  do
    if [[ ${line} == '--END OF MINIMAL INSTALL--' ]]; then
      # If selected installation type is FULL, skip the --END OF THE MINIMAL INSTALLATION-- line
      continue
    fi
    echo "INSTALLING: ${line}"
    $AUR_HELPER -S --noconfirm --needed ${line}
  done
fi

export PATH=$PATH:~/.local/bin

#switch to zsh
sudo chsh $USERNAME -s /bin/zsh

if [[ $INSTALL_TYPE == "FULL" ]]; then
  if [[ $DESKTOP_ENV == "awesome" ]]; then
    cp -r -a ~/ArchX/configs/usr/. ~/
    cp -r ~/ArchX/pkg-files/${DESKTOP_ENV}.sh ~/
  fi
fi

echo -ne "
__________________________________________________________
                    SYSTEM READY FOR 3-post-setup.sh     /
________________________________________________________/

"
exit