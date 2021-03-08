<div align="center" class="tip" markdown="1" style>

![screenshot](https://user-images.githubusercontent.com/24478471/110273897-36213c80-7f93-11eb-847a-4b7b13e77d16.png)
![wine version](https://img.shields.io/badge/wine-6.0-red) ![winamp version](https://img.shields.io/badge/Winamp-5.8-orange) ![Tested on Ubuntu](https://img.shields.io/badge/Tested%20on-Ubuntu%2020.04%20LTS-orange)![rep size](https://img.shields.io/github/repo-size/samdisk11/WinampLinux)
</div>



# Winamp 5.80 installer for Linux
This bash script helps you install Winamp 5.8 and it's libraries on your Linux machine using WINE automatically.

## :lightning: Features
* Automatically downloads Winamp from offical website
* Installs prerequirements if needed
* works on any Linux distribution


## :warning: Requirements
1- use a 64 bit edition of your distro (optional but highly recommended)

2-make sure the following packages are already installed on your Linux distro
* `wine` (make sure it is up to date)
* `winetricks`
* `md5sum`


if they are not already installed you can install them using this example command for Ubuntu.
```
sudo apt-get install wine winetricks md5sum
``` 

4- make sure you have an internet connection and about 200 MB of disk space for Winamp (and its prerequisites)

## :computer: Installation
The installer script will create a new WINE virtual drive and will install to USERNAME/.WinampLinux

just click on Next on every prompt and do not check mark "Install Winamp Agent" 



most of the code based off of https://github.com/Gictorbit/photoshopCClinux/
