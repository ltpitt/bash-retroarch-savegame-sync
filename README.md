[![GitHub Issues](https://img.shields.io/github/issues-raw/ltpitt/bash-retroarch-savegame-sync)](https://github.com/ltpitt/bash-retroarch-savegame-sync/issues)
![Total Commits](https://img.shields.io/github/last-commit/ltpitt/bash-retroarch-savegame-sync)
![GitHub commit activity](https://img.shields.io/github/commit-activity/4w/ltpitt/bash-retroarch-savegame-sync?foo=bar)
[![License](https://img.shields.io/badge/license-GNU-blue.svg)](https://raw.githubusercontent.com/ltpitt/bash-retroarch-savegame-sync/master/LICENSE)
![Contributions welcome](https://img.shields.io/badge/contributions-welcome-orange.svg)

![Retroarch Savegame Sync Logo](https://github.com/ltpitt/bash-retroarch-savegame-sync/raw/main/logo/bash-retroarch-savegame-sync-logo.gif)  

# Retroarch Savegame Sync
This script allows to sync Retroarch's savestates and savefiles to between two or more Retroarch devices.  
It is able to work with three types of connections: local (simply using local filesystem, you can also plug SD cards or usb drives from handhelds or consoles to the computer running the script), SCP (e.g. pi@192.168.1.170:/home/pi) or FTP (e.g. ftp://192.168.1.171/sd/retroarch).  
The script gets the savestates and savefiles data from the specified source, copies it locally and makes a local backup. Then it merges all the savestates and savefiles in the local tmp folder (only keeping the most recently modified ones), and then copies the newest ones back to all the consoles.  
Please keep in mind that in order to have working savestates you should be using the same rom / iso and the same core (emulator) version and sometimes this still does not work between different platforms.  
Savefiles, on the other hand, are the original way to save game progression on physical cartridges or memory cards and those generally work just fine, even between different cores / platforms.  

## Pre-requisites
* Make sure that your RetroArch installs are saving all savefiles to the savefiles folder and all savestates to the savestates folder. This is now default but be sure to check it before starting. More info about the topic is available [here](https://docs.libretro.com/guides/change-directories/#savefile-and-savestate)
* Be sure that you can access your emulation machines via SCP or FTP  
* At the moment FTP is only implemented with anonymous connection (no user / pass)  
* In order to use SCP please setup a passwordless connection. Here's how to obtain such result: https://www.ssh.com/ssh/copy-id

## Installation and usage
* Clone the repository or simply download it as a zip file and unzip it in your home folder
* Customize the variables in the beginning of the script. It is mandatory to define **console name** and **path** customizing the example you will find in the **CONSOLES** variable. For other variables default values should be ok for most users. **For the moment being the script works ONLY using IP addresses**
* Make the script executable: `chmod +x bash-retroarch-savegame-sync.sh`
* Run it: `./bash-retroarch-savegame-sync.sh` or schedule it

## How to schedule automatic script execution
* https://www.howtogeek.com/101288/how-to-schedule-tasks-on-linux-an-introduction-to-crontab-files/

## Important notice
The script is just a quick hack and in beta version. It will make a complete backup of all the savegames in the folder specified among the variables.  Nonetheless this is not bullet proof and test it at your own risk.  More updates will come, have fun!

## FTP Software suggestions
Here's some list of software you can run on your consoles in order to let the script connect via FTP:
- PS Vita - [Ftp Everywhere](https://github.com/teakhanirons/ftpeverywhere/)
- PS Vita - [BGFTP](https://github.com/GrapheneCt/BGFTP)

### Contribution guidelines ###

* If you have any idea or suggestion contact directly the Repo Owner

### Who do I talk to? ###

* ltpitt: Repo Owner
