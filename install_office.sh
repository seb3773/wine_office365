#!/bin/bash
echo;echo;echo "  =================================";echo "  == Office 365 (2019) for Linux =="
echo "  =================================";echo "                         by Seb3773";echo;echo
if [ "$EUID" -eq 0 ];then echo " > This script must not be run as root."
echo " > Please run it as normal user, elevated rights will be asked when needed. ";echo;echo " > exiting.";echo;exit;fi
echo " > This script will install Microsoft Office 365 (2019) on your computer."
echo " > It will use approximatively 3.4Gb of disk space."
echo " ? Proceed ? (y:yes/enter:quit) ?" && read x
if [ "$x" == "y" ] || [ "$x" == "Y" ]; then

if ! dpkg -l | grep -q winehq-stable; then
echo " > Installing wine and required components...";echo
sudo dpkg --add-architecture i386 >> ./setup.log 2>&1
sudo apt install -y gnupg2 software-properties-common wget cabextract >> ./setup.log 2>&1
sudo wget -O /etc/apt/keyrings/winehq-archive.key https://dl.winehq.org/wine-builds/winehq.key >> ./setup.log 2>&1
sudo wget -NP /etc/apt/sources.list.d/ https://dl.winehq.org/wine-builds/debian/dists/bookworm/winehq-bookworm.sources >> ./setup.log 2>&1
sudo apt update >> ./setup.log 2>&1
sudo apt install -y --install-recommends winehq-stable >> ./setup.log 2>&1
fi

echo " > Creating Microsoft_Office_365 prefix...";echo
mkdir -p "$HOME/Microsoft_Office_365"
WINEARCH=win32 WINEPREFIX="$HOME/Microsoft_Office_365" winecfg /v win7 >> ./setup.log 2>&1
while pgrep wine > /dev/null; do sleep 1; done
sleep 2

echo;echo " > Extracting archive, please wait...";echo
if [ -f "./files/Microsoft_Office_365.tar.xz" ]; then
tar -xf ./files/Microsoft_Office_365.tar.xz -C "$HOME/"
else
cat ./files/Microsoft_Office_365_part_* > ./files/Microsoft_Office_365.tar.xz
rm -f ./files/Microsoft_Office_365_part_*
tar -xf ./files/Microsoft_Office_365.tar.xz -C "$HOME/"
fi

cp -f ./files/hkeyuser.reg "$HOME/Microsoft_Office_365/drive_c"
sed -i 's/XXuserXX/'"$USER"'/g' "$HOME/Microsoft_Office_365/drive_c/hkeyuser.reg"
WINEPREFIX="$HOME/Microsoft_Office_365" regedit /S "$HOME/Microsoft_Office_365/drive_c/hkeyuser.reg"  >> ./setup.log 2>&1
while pgrep wine > /dev/null; do sleep 1; done
sleep 2
rm "$HOME/Microsoft_Office_365/drive_c/hkeyuser.reg"
rm -rf "$HOME/Microsoft_Office_365/drive_c/users/$USER"
mv "$HOME/Microsoft_Office_365/drive_c/users/XXuserXX" "$HOME/Microsoft_Office_365/drive_c/users/$USER"
cd  "$HOME/Microsoft_Office_365/drive_c/users/$USER"
ln -s $(xdg-user-dir DESKTOP) Desktop
ln -s $(xdg-user-dir DOWNLOAD) Downloads
ln -s $(xdg-user-dir DOCUMENTS) Documents
ln -s $(xdg-user-dir MUSIC) Music
ln -s $(xdg-user-dir PICTURES) Pictures
ln -s $(xdg-user-dir VIDEOS) Videos
cd -

echo;echo
sudo cp -f ./files/word.png /usr/share/icons/hicolor/128x128/apps
sudo cp -f ./files/excel.png /usr/share/icons/hicolor/128x128/apps
sudo cp -f ./files/powerpoint.png /usr/share/icons/hicolor/128x128/apps
sudo cp -f ./files/Word.desktop /usr/share/applications/
sudo cp -f ./files/Excel.desktop /usr/share/applications/
sudo cp -f ./files/PowerPoint.desktop /usr/share/applications/
echo;echo " > Microsoft Office 365 installation done.";echo
echo " > script finished.";echo;else echo " > Exited.";echo;fi
