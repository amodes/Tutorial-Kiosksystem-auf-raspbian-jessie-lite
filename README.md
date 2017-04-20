
<h1> Installation eines Kiosksystems auf einem Raspberry Pi 3 Model B mit Rasbian Jessie Lite </h1>

<h3>1) Download und Installation des Betriebssystems</h3>



Auf einer Micro-SD-Karte mit mindestens 8GB Speicherkapazität soll die Lite-Version des Betriebssystems Raspbian Jessie installiert werden.<br>

> Download-Link (Torrent und ZIP): https://www.raspberrypi.org/downloads/raspbian/

<hr>

<h3>2) SSH und Login</h3>



Damit der SSH-Dienst nach erneutem Reboot automatisch startet muss auf der Root-Ebene des Datei-Systems eine leere Datei mit dem Titel "ssh" angelegt werden. Danach kann das System gestartet werden.<br>

Standardmäßig erfolgt der Login über die folgenden Daten:

> Username: pi<br>
> Password: raspberry

<hr>

<h3>3) Änderung des Passworts und des Tastatur-Layouts</h3>

Die Änderung des Passworts sowie des Tastatur-Layouts ist über das Konfigurations-Tool "raspi-config" möglich: 

```
sudo raspi-config
```

Die Änderung des Passwortes erfolgt über "passwd" (einfach den Anweisungen folgen):

```
passwd
```

Nach einem Reboot werden die Änderungen übernommen.

<hr>

<h3>4) WLAN-Konfiguration</h3>



Öffnen der Datei "wpa_supplicant.conf" in einem Texteditor (hier Nano):

```
sudo nano /etc/wpa_supplicant/wpa_supplicant.conf
```

Folgender Code soll hinzugefügt werden:

```
network={
	ssid="<Netzwerkname>"
    psk="<Netzwerkschlüssel>"
}
```

Nach einem Reboot sollte sich nun das System automatisch mit dem angegebenen Netzwerk verbinden.

```
sudo reboot now
```

<hr>

<h3>5) Statische IP Adresse</h3>

Da sich in einem Netzwerk die IP-Addresse des Geräts ändern kann, sollte eine statische IP-Adresse auf dem Raspberry Pi eingerichtet werden. Somit kann sichergestellt werden, dass ein Remotezugriff auf den Pi gewährleistet ist.

Anzeigen des Netzwerk-Interfaces:
```
cat /etc/network/interfaces 
```
> Die Zeile "iface eth0 inet dhcp" bzw "iface eth0 inet manual"
sagt aus, dass die IP Dynamische über den Router generiert wird.

Internet Informationen anzeigen:
```
ifconfig 
```
> Hier müssen die IP-Adresse (inet addr), die Broadcoast-Adresse (Bcast) und die Netzwerkmaske (MASK) notiert werden

```
netstat -nr
```
> Hier müssen die Destination-Addresse (Destination) und das Gateway notiert werden.

Nun wird der Netzwerk-Zugang konfiguriert:

```
sudo nano /etc/network/interfaces
```
> Hier muss die Zeile "iface eth0 inet manual" bzw. "iface eth0 inet dhcp" folgendermaßen geändert werden:
```
iface eth0 inet static
```
> Direkt nach dieser Zeile werden folgende Zeilen notiert und mit den oben notierten Informationen befüllt:
```
address <IP-Adresse>
netmask <Netzwerkmaske>
network <Destination Address>
broadcast <Broadcast>
gateway <Gateway>
```

Danach können die Änderungen gespeichert und das Skript geschlossen werden.
Von der Komandozeile muss nun folgender Befehl ausgeführt werden:
```
sudo rm /var/lib/dhcp/*
```
Nach einem Reboot erhält das System nun eine statische IP-Adresse
```
sudo reboot 
```

<hr>

<h3>6) Anpassung des Betriebssystems</h3>

Da die Lite-Version von Raspbian Jessie schon eine sehr abgespeckte Version darstellt, ist es nicht mehr nötig im großen Umfang nicht benötigte Pakete zu entfernen.
```
sudo apt-get remove vim-tiny
sudo apt-get autoremove
```

<hr>

<h3>7) Aktualisierung des Systems</h3>

Zum Neueinlesen und Aktualisierung der betriebssystemeigenen Paketlisten soll folgender Befehl ausgeführt werden:

```
sudo apt-get update && sudo apt-get upgrade
```

<hr>

<h3>8) Installation der Software-Komponenten</h3>

Der Window-Manager "matchbox", der Display Server "xorg" sowie die virtuelle Tastatur "matchbox-keyboard" werden über folgenden Befehl installiert:

```
sudo apt-get install -y matchbox xorg
```

Download und Installation der "kweb"-Suite (Web Browser):

```
wget http://steinerdatenbank.de/software/kweb-1.6.9.tar.gz
tar -xzf kweb-1.6.9.tar.gz
cd kweb-1.6.9
./debinstall
```

> Versionsnummern sowie unterstützte Paketversionen können sich im Laufe der Zeit ändern. Die mindeste stabile Version für Raspbian Jessie ist "kweb-1.6.9".
Während der Installation wird u.U. gefragt, ob einige zusätzliche Pakete mitinstalliert werden sollen. Je nach Bedarf kann dies akzeptiert oder abgelehnt werden, da der Browser auch ohne diese Pakete funktionieren wird. Weitere Informationen zu diesen zusätzlichen Programmen finden sich [hier](kweb-browser-konfiguration).<br>

Sollte es Probleme bei der Installation geben, sollte dieser Befehl ausgeführt werden. Hierdurch werden fehlende Abhängigkeiten nachinstalliert und kaputte Pakete eventuell deinstalliert.

```
sudo apt-get -f install
```

<hr>

<h3>9) Erstellung des Shell-Skriptes</h3>

Nun wird mit Nano ein neues Shell-Script im Home-Ordner des Systems erstellt:

```
sudo nano startKiosk.sh
```

In dem Skript wird die Logik zum (korrekten) Aufruf des Window-Managers und Browsers verfasst:

```
#!/bin/sh
xset -dpms
xset s off 
xset s noblank
matchbox-window-manager &
matchbox-keyboard --daemon &
while true; do
	kweb -KHJ http://www.google.com &
    wait $!
    sleep 10
done
exit
```

> Eine kleine Erklärung zu den Konfigurations-Möglichkeiten des Browsers und der Tastatur gibt es am Ende dieses Tutorials unter 13) kweb-browser-konfiguration. <br> Zudem finden Sie die Skript-Datei im Repository.

Das Skript muss nun ausführbar gemacht werden:
```
sudo chmod +x startKiosk.sh
```

Zum Test des Skriptes kann folgender Befehl ausgeführt werden:

```
sudo xinit /home/pi/startKiosk.sh
```

> Es ist möglich den Browser mit der Tastenkombination STRG + ALT + F1  und danach STRG + C zu beenden.

<hr>

<h3>10) Ausführung des Shell-Skriptes beim Start</h3>

Damit das Skript beim Start des Raspberry auszuführen, muss die Datei "rc.local" in einem Text-Editor (hier Nano) geöffnet werden:

```
sudo nano /etc/rc.local
```

Vor "exit 0" wird folgende Zeile eingefügt:

```
sudo xinit /home/pi/startKiosk.sh &
```

<hr>

<h3>11) Auto-Login beim System-Boot</h3>

Zum automatischen Login beim Start des Systems muss zuerst folgende Datei in einem Text-Editor (hier Nano) aufgerufen werden:

```
sudo nano /etc/systemd/system/getty.target.wants/getty@tty1.service
```

In der "[Service]" Sektion muss die Zeile "ExecStart=..." folgendermaßen geändert werden:

```
ExecStart=-/sbin/agetty -a <Benutzername> %I $TERM
```

Nun muss noch sichergestellt werden, dass das System in die Konsole (TTY) bootet:

```
systemctl set-default multi-user.target
```

<hr>

<h3>12) Neustart des Systems</h3>

Im letzten Schritt wird der Raspberry neu gestartet:

```
sudo reboot now
```

Das System müsste nun den Browser automatisch anzeigen.

<hr>

<h3>13) kweb Browser: Shortcuts und Konfiguration</h3>

Hier ist eine mögliche Konfiguration des Browsers abgebildet:
```
...
kweb -KHJ http://www.google.com &
...
```
- Link zur kweb-Dokumentation: http://steinerdatenbank.de/software/kweb_manual.pdf<br>

- Shortcuts:<br>
Kleinbuchstaben und bestimmte Sonderzeichen stehen für Shortcuts die durch das Einbeziehen in den Browser-String entweder ein- oder ausgeschaltet werden können. Auf Seite 71 der Dokumentation befindet sich eine Liste mit den möglichen Shortcut-Konfigurationen

- Konfiguration:<br>
Die Groß-Buchstaben im Browser-String stehen je für eine Einstellung im Browser. Im Folgenden werden die im Beispiel verwendeten Funktionen aufgelistet. Eine vollständige Liste der Konfigurations-Möglichkeiten findet sich unter Punkt 9. Absatz a) der kweb-Dokumentation
<br>
> J = Javascript ist eingeschaltet<br>
> H = benutze URL, wenn vorhanden, als Home-Page anstatt der Default Home-Page. Diese kann entweder mit “file://...” oder “http://...” beginnen<br>
> K = der Browser wird im Kiosk-Modus gestartet

<b>kweb Browser: Zusätzliche Pakete</b>

- youtube-dl:
  - Beschreibung: Kommandozeilen-Programm zum Download von Youtube-Videos
  - Link: https://rg3.github.io/youtube-dl/
- omxplayer:
  - Beschreibung: Kommandozeilen-Video-Player
  - Link: http://www.raspberry-projects.com/pi/software_utilities/media-players/omxplayer
- xpdf:
  - Beschreibung: PDF-Betrachter, -Wandler, -Reader
  - Link: http://www.foolabs.com/xpdf/
- leafpad:
  - Beschreibung: Einfacher Text-Editor
  - Link: http://tarot.freeshell.org/leafpad/
- lxterminal:
  - Beschreibung: Terminalemulator
  - Link: https://www.raspberrypi.org/documentation/usage/terminal/

<hr>

<h3>Virtuelle Tastatur</h3>

- Erklärung: Die virtuelle Tastatur "matchbox-keyboard" ist im Paket des matchbox-Window-Managers standardmäßig enthalten und kann individuell angepasst werden. Eine kleine Anleitung zur Konfiguration findet sich unter folgendem Link.
- Link: http://wiki.openmoko.org/wiki/Change_matchbox_keyboard_layout


<h3>Impressum</h3>

- Autoren: Alexander Modes und Alexander Schober<br>
- Projektarbeit im FWP Betriebssysteme<br>
- Technische Hochschule Deggendorf
