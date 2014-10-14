
#!/bin/bash
#if [ "$(id -u)" != "0" ]; then
#   echo "This script must be run like: sudo ./install.sh" 1>&2
#   exit 1
#fi

echo "Starting Update…"
VERSION=$(cat /home/pi/pimame/version )
echo "current version:"
echo $VERSION

sudo apt-get -y install bc

if [ $(echo $VERSION '<' "8.7" | bc -l) == 1 ]; then
    sudo apt-get -y -f install
    wget -N http://sheasilverman.com/rpi/raspbian/installer/vice_2.3.21-1_armhf.deb
    sudo dpkg -i vice_2.3.21-1_armhf.deb
    sudo apt-get -y install python-requests python vsftpd xboxdrv stella python-pip python-requests python-levenshtein libsdl1.2-dev
fi

cd ~/pimame
if [ $(echo $VERSION '==' "8.7" | bc -l) == 1 ]; then
  git fetch --all
  git reset --hard origin/master
fi
git pull
git submodule update --recursive
cd pimame-menu
#version 8 beta 4.1
git checkout master
git config --global user.email "none@none.com"
git config --global user.name "none@none.com"
git stash
git pull
git stash pop
git config --global --unset user.email
git config --global --unset user.name
cd ~/pimame

if [ $(echo $VERSION '<=' "8.6" | bc -l) == 1 ]; then
###mednafen
echo "Removing old version of mednafen..."
rm -rf /home/pi/pimame/emulators/mednafen
echo "Cloning new version of mednafen..."
git clone https://github.com/ssilverm/mednafen-dispmanx-sdl /home/pi/pimame/emulators/mednafen

###NES
wget http://pimame.org/8files/fceux.zip
mkdir /home/pi/pimame/emulators/fceux
mv fceux.zip /home/pi/pimame/emulators/fceux
cd /home/pi/pimame/emulators/fceux
unzip -o fceux.zip
rm fceux.zip
cd /home/pi/pimame

###dgen
rm -rf /home/pi/pimame/emulators/dgen-sdl-1.32
git clone https://github.com/ssilverm/dgen-sdl /home/pi/pimame/emulators/dgen-sdl-1.32
fi


if [ $(echo $VERSION '<' "8.7" | bc -l) == 1 ]; then
#8.8 / 8.0 beta 6
cd /home/pi/pimame/emulators/gpsp
ln -s /home/pi/pimame/roms/gba/gba_bios.bin gba_bios.bin
fi

if [ $(echo $VERSION '<' "9" | bc -l) == 1 ]; then #START 9
#8.8 / 8.0 beta 6
echo "Updating to 0.8 Beta 7"
sudo apt-get update
sudo apt-get install gunicorn

if grep --quiet pimame-web-frontend /home/pi/.profile; then
        sed -i "s|sudo python /home/pi/pimame/pimame-web-frontend/app.py|cd /home/pi/pimame/pimame-web-frontend/; sudo gunicorn app:app -b 0.0.0.0:80|g" /home/pi/.profile
else
  echo "Did not change web frontend."
fi

fi #end 9


echo "You are now updated. Please restart to activate PiMAME :)"
