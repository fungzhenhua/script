#! /bin/sh
#
# Program  : stirling.sh
# Date     : 2024-12-04 21:40
# Version  : V1.0
# Author   : fengzhenhua
# Email    : fengzhenhua@outlook.com
# CopyRight: Copyright (C) 2024 FengZhenhua(冯振华)
# License  : Distributed under terms of the MIT license.
#
STR_EXE="/usr/local/bin/stirling"
STR_DESKTOP="/usr/share/applications/Stirling-PDF.desktop"
pacman -Q stirling-pdf-bin &> /dev/null
if [[ $? != 0 ]]; then
    paru -S stirling-pdf-bin
    git clone https://github.com/Stirling-Tools/Stirling-PDF.git
    sudo cp -r ./Stirling-PDF/docs /usr/share/icons/stirling
fi
if [[ ! -e  $STR_EXE ]]; then
    sudo touch  $STR_EXE
    sudo chmod +x $STR_EXE
sudo sh -c "cat > $STR_EXE" <<EOA
#! /bin/sh
nohup java -jar /usr/share/java/stirling-pdf.jar &> /dev/null
xdg-open http://localhost:8080
EOA
fi
if [[ ! -e  $STR_DESKTOP ]]; then
    sudo touch  $STR_DESKTOP
sudo sh -c "cat > $STR_DESKTOP" <<EOB
[Desktop Entry]
Type=Application
Name=Stirling PDF
GenericName=Launch StirlingPDF and open its WebGUI
Categories=Office
Exec=stirling
Icon=/usr/share/icons/stirling/stirling-transparent.svg
Keywords=pdf
Type=Application
NoDisplay=false
Terminal=fals
EOB
fi
