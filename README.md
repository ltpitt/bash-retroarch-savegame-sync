![Alt Text](https://github.com/ltpitt/bash-retroarch-savegame-sync/raw/main/logo/bash-retroarch-savegame-sync-logo.gif)  

# Retroarch Savegame Sync
This script allows to sync savegames to the newest one between two or more retroarch devices

## Usage
* Be sure that you can access your emulation machines via SCP or FTP. At the moment FTP is only implemented with anonymous connection (no user / pass). In order to use SCP please setup a passwordless connection. Here's how to obtain such result: https://www.ssh.com/ssh/copy-id
* Clone the repository or simply download it as a zip file and unzip it in your home folder
* Customize the variables in the beginnin of the script, if needed
* Run the script using /path/to/your/folder/bash-retroarch-savegame-sync.sh or schedule it

## How to schedule automatic script execution
* If you have Windows: https://technet.microsoft.com/en-us/library/cc748993(v=ws.11).aspx
* If you have Linux or Mac: https://www.howtogeek.com/101288/how-to-schedule-tasks-on-linux-an-introduction-to-crontab-files/

## Important notice
The script is just a quick hack and in beta version. It will make a complete backup of all the savegames in the folder specified among the variables.  Nonetheless this is not bullet proof and test it at your own risk.  More updates will come, have fun!

### Contribution guidelines ###

* If you have any idea or suggestion contact directly the Repo Owner

### Who do I talk to? ###

* ltpitt: Repo Owner
