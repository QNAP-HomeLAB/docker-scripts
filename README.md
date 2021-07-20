# QNAP Docker HomeLAB Setup Instructions
    A guide for configuring Docker containers on QNAP devices with Container Station

<center><big><strong>WARNING: Unfinished Project</strong></big>
<br><br>
   <img src="https://i.imgur.com/dF9OEiS.png" align="center" width="200"/>
</center><br>

  This project is as yet unfinished, which means there can and will be issues.
  Getting this HomeLAB enviornment working in your QNAP will probably require tweaking and troubleshooting.
  I will help when and if I can, but I can not be held responsible for issues created while following this guide or performing any suggestions I make.

**WARNING:** This guide is incomplete, and as such ***will*** contain errors.

Please read the [disclaimer](#disclaimer) at the end of this document.

**PREREQUISITES:**
   - A QNAP device that supports the Container Station application. We have not yet figured out how to manually install Docker on a QNAP device, therefore must still rely on the default installation of Docker.
   - A desire to learn Docker and some basic Terminal commands.

Consider joining and contributing to the [QNAP Unofficial Discord](https://discord.gg/rnxUPMd), a community built around advice on everything QNAP. We have helpful members, FAQs, CI/CD, community Docker images, and cookies (well, maybe not cookies).

---
---

### Contents
- [QNAP Docker HomeLAB Setup Instructions](#qnap-docker-homelab-setup-instructions)
    - [Contents](#contents)
  - [1. QNAP GUI Steps](#1-qnap-gui-steps)
    - [1. Network Port Configuration](#1-network-port-configuration)
    - [2. Docker user account](#2-docker-user-account)
    - [3. Entware-std installation](#3-entware-std-installation)
    - [4. Container Station Setup](#4-container-station-setup)
  - [2. Terminal Steps](#2-terminal-steps)
    - [1. SSH Terminal Connection](#1-ssh-terminal-connection)
    - [2. Docker folder creation](#2-docker-folder-creation)
    - [3. Entware-std profile setup](#3-entware-std-profile-setup)
    - [4. Docker Scripts Reference](#4-docker-scripts-reference)
  - [3. Docker general config steps](#3-docker-general-config-steps)
    - [1. Environment Variables](#1-environment-variables)
    - [2. Docker Container Creation](#2-docker-container-creation)
- [Contributors](#contributors)
- [DISCLAIMER](#disclaimer)

---
---

## 1. QNAP GUI Steps
- All actions in this section will be performed in the QNAP QTS operating system web-portal GUI.

### 1. Network Port Configuration

1. **Ports 80, 443, and 8080 *must be _unused_ by your NAS.*** 
   - ***NOTE:*** This step may be unnecessary if you can get double port forwarding to work when getting Traefik to recognize your domain and register a certificate. YMMV.
   - By default, QTS assigns ports 8080 and 443 as the default HTTP and HTTPS ports for the QNAP Web Admin Console, and assigns 80 as the default HTTP port for the native "Web Server" application. Each of these must be updated to be successful with this guide.
1. Modify these ports as follows to ensure there will be no port conflicts with docker stacks:
   - ***Change* default *System* ports:** In QNAP Web GUI
      - `Control Panel >> System >> General Settings`
      - Change the default HTTP port to `8880`, and the default HTTPS port to `8443`.
      - **NOTE:** This *will* change the LAN address from which you access your QTS web-gui, requiring you to add the port at the end of your NAS LAN IP (e.g. https://192.168.1.100:8443)
   - ***Change* default *Web Application* ports:** In QNAP Web GUI
      - `Control Panel >> Applications >> Web Server`
      - Change the default HTTP port to `9880`, and the default HTTPS port to `9443`.
      - **TIP:** Unless currently in use, consider disabling the MySQL application in the QNAP GUI Settings.
      - **WARNING:** *DO NOT* disable the **Web Server** application, leave this active on the new port. There is a bug in QTS where the Web Server will re-acquire the default port if it is disabled.
1. **Ports 80 and 443 must be forwarded from your router to your NAS**. 
   - This is *possible* using UPNP in the QNAP GUI, but ***is not recommended!***
   - **Instead, disable UPNP at the router and manually forward ports 80 and 443 to your NAS.**
   - ***NOTE:*** There are too many possible routers to cover how to forward ports on each, but there are some good guides here if you don't know how to do it for your router: 
      - https://portforward.com/router.htm
      - https://www.howtogeek.com/66214/how-to-forward-ports-on-your-router

   **Ports Overview:**
   - QTS System ports should be:
      - HTTP : `8880`
      - HTTPS: `8443`
   <br>
   - QTS Web Server application ports should be:
      - HTTP : `9880`
      - HTTPS: `9443`

### 2. Docker user account

1. Create a new user called `dockeruser`

1. Create the following folder shares *using the QTS web-GUI* 
   - `ControlPanel >> Privilege >> Shared Folders` 
   - Give `dockeruser` Read/Write permissions for each of the below folders:
   - `/share/docker/`
     - This is the main "docker" folder inside which we will place swarm and compose config files, in their own subfolders. The remaining folders listed below should be created using the Terminal, when logged in using the default QTS `admin` account.
   - ***NOTE:*** The `swarm`, `compose`, `common`, and `secrets` folders (created using the terminal) can be added as shares in the QTS Control Panel, but that is entirely unnecessary as the `/share/docker/` parent folder is already shared out.

### 3. Entware-std installation

1. Install the `entware-std` package from the third-party QNAP Club repository appstore. This is necessary in order to setup the shortcuts/aliases used when controlling docker via command line by editing a permanent profile.
   - The preferred way to do this is to add the QNAP Club Repository to the App Center. Follow the [walkthrough instructions here](https://www.qnapclub.eu/en/howto/1). 
   - Note that I use the English translation of the QNAP Club website, but you may change languages (and urls) in the upper right language dropdown.
   - If you don't need the walkthrough, add the repository. (For English, go to App Center, Settings, App Repository, Add, `https://www.qnapclub.eu/en/repo.xml`).
   - If you **cannot** add the QNAP Club store to the App Center, you may manually download the qpkg file from that link and use it to manually install via the App Center, "Install Manually" button. This is **not preferred** as QNAP cannot check for and notify you of updates to the package.
   - Search for `entware-std` and install that package.
      - If you have trouble locating the correct package, the description begins with `entware-3x and entware-ng merged to become entware.` The working link (as of publication) is here: https://www.qnapclub.eu/en/qpkg/556. 

   - ***IMPORTANT:** DO NOT* CHOOSE either the `entware-ng` or `entware-3x-std` packages. These have merged and been superceded by `entware-std`.
### 4. Container Station Setup

1. Backup what you have running now (if you don't have anything running yet, skip to Step 3 or 5)

1. Shutdown and remove all Containers:
   - Open an SSH terminal session to your NAS and run: 
      - `docker system prune`
   - To ensure the network topography is reset, run:
      - `docker network prune`
   - To be sure you don't have a swarm left hanging around, run:
      - `docker swarm leave --force`

1. Remove Container Station:
      - In App Center, click the dropdown for Container Station and choose `Remove`
      - In Control Panel >> Shared Folders, check the box next to the `Container` shared folder and click "Remove" <p align="left"><img width="400" height="100" src="https://i.imgur.com/s1jXNNs.png"></p>
      - In the pop-up box, check "Also delete the data" and click "Yes" <p align="left"><img align="center" width="200" height="100" src="https://i.imgur.com/WXML3fl.png"></p>

1. Reboot the NAS <p align="left"><img align="center" width="100" height="150" src="https://i.imgur.com/voFkAt9.png"></p>

1. Install Container Station from the QNAP Appstore.
   - Launch CS once installed
   - Accept and create the `/Container` folder suggested when CS is launched for the first time.

---

## 2. Terminal Steps
- All actions in this section will be performed via SSH Terminal connection to your QNAP NAS.
### 1. SSH Terminal Connection

1. Open/Connect an SSH Terminal session to your QNAP NAS. 
   * You can use [PuTTY](https://putty.org/), the `Windows Subsystem for Linux`, or [Cmder](https://cmder.net/) or any command line utility with SSH.
   - **NOTE:** Alternatively you can use [BitVise](https://www.bitvise.com/ssh-client-download) because this also has an SFTP remote file browser interface.
   - **TIP:** I switched to using [WinSCP](https://winscp.net/eng/download.php) and [Cmder](https://cmder.net/) because they have dark themes. [Windows Terminal Preview](https://docs.microsoft.com/en-us/windows/terminal/get-started) is turning out to be a good Terminal as well.
   - **TIP:** Connecting to the NAS using SFTP allows me to edit the docker config files using `Notepad++` or `VSCodium` (open source Visual Studio Code clone).
   - **TIP:** I also map the `/share/docker/` folder as a Network drive on my Windows desktop, which makes viewing and editing Docker config files very easy.

2. Install nano or vi, whichever you are more comfortable with (only one needed)
   - **RUN:** `opkg install nano`
   - **RUN:** `opkg install vim`
   - ***NOTE:*** You must have installed the `entware-std` package as detailed in [Section 1.4](#4-container-station-setup) to be able to use the "opkg" installer.

### 2. Docker folder creation

1. This section is a continuation of the QNAP QTS folder creation steps from the previous section. Here we will create the sub-folders required for `scripts`, `swarm`, `compose`, and `secrets` files.

   - These folders should **all** be created using this example terminal command:
      ```bash
      mkdir -pm 600 /share/docker/scripts
      ```
      - `/share/docker/swarm` - this is the "docker swarm" config files folder
         - `/share/docker/swarm/appdata`
           - Here we will add folders named `< stack name >`. This is where your application files live... libraries, artifacts, internal application configuration, etc. Think of this directory much like a combination of `C:\Windows\Program Files` and `C:\Users\<UserName>\AppData` in Windows.
         - `/share/docker/swarm/configs`
           - Here we will also add folders named `< stack name >`. Inside this folder, we will keep our actual _stack_name.yml_ files and any other necessary config files used to configure the docker stacks and images we want to run. This folder makes an excellent GitHub repository.
           NOTE: Do not save sensitive information in your `.yml` files if you are sharing this folder as a git repository.
         - `/share/docker/swarm/runtime`
           - This is a shared folder on a volume that does not get backed up. It is where living DB files and transcode files reside, so it would appreciate running on the fastest storage group you have or in cache mode or in Qtier (if you use it). Think of this like the `C:\Temp\` in Windows.
         - `/share/docker/swarm/secrets`
           - This folder contains secret (sensitive) configuration data that should _NOT_ be shared publicly. This could be stored in a _PRIVATE_ Git repository, but should never be publicized or made available to anyone you don't implicitly trust with passwords, auth tokens, etc.
<br><br>
      - `/share/docker/compose`- this is the "docker-compose" config files folder
         - `/share/docker/compose/appdata`
           - Here we will add folders named `< stack name >`. This is where your application files live... libraries, artifacts, internal application configuration, etc. Think of this directory much like a combination of `C:\Windows\Program Files` and `C:\Users\<UserName>\AppData` in Windows.
         - `/share/docker/compose/configs`
           - Here we will also add folders named `< stack name >`. Inside this folder, we will keep our actual _stack_name.yml_ files and any other necessary config files used to configure the docker stacks and images we want to run. This folder makes an excellent GitHub repository.
           NOTE: Do not save sensitive information in your `.yml` files if you are sharing this folder as a git repository.
         - `/share/docker/compose/runtime`
           - This is a shared folder on a volume that does not get backed up. It is where living DB files and transcode files reside, so it would appreciate running on the fastest storage group you have or in cache mode or in Qtier (if you use it). Think of this like the `C:\Temp\` in Windows.
<br><br>
       - `/share/docker/secrets`
         - This folder contains secret (sensitive) configuration data that should _NOT_ be shared publicly. This could be stored in a _PRIVATE_ Git repository, but should never be publicized or made available to anyone you don't implicitly trust with passwords, auth tokens, etc.
<br><br>
      - `/share/docker/common` - This is where you can store general config files, or shared files both `compose` and `swarm` mode containers might use.
<br><br>
   - Once all required folders are created, you must update ownership and permissions so the `dockeruser` account has the proper access level for Docker operations:
      ```bash
      chown dockuser:dockgroup -cR /share/docker && chmod 600 -cR /share/docker
      ```
   - This is what your folder heirarchy should look like after creating the above folder structure:
   
      ![docker folder structure](https://i.imgur.com/dbm5fp9.png)

1. Next you need to download the custom *scripts* from the [QNAP HomeLAB Docker Scripts](https://gitlab.com/qnap-homelab/docker-scripts) repository to your `/share/docker/scripts/` directory.

   - ~~Alternatively, if you trust my installation script to run as root on your system, you can run this `curl` command that will automatically download and install the scripts for you:~~ This feature is not finished, please download and install the scripts manually.
   - ***TIP:*** Read through and understand what a script does before executing possibly malicious code on any device.
      ```bash
      # install the docker_scripts_setup.sh using wget without downloading the file
      wget -sO - https://raw.githubusercontent.com/QNAP-HomeLAB/Docker-Scripts/master/docker_scripts_setup.sh | sh
      ```
      ***OR***
      ```bash
      # download and install the docker_scripts_setup.sh using cURL
      curl -fsSL https://gitlab.com/qnap-homelab/docker-scripts/docker_scripts_setup.sh | sh
      ```

### 3. Entware-std profile setup

1. Type the below lines into the QNAP command line:
   ```bash
   printf "alias profile='source /opt/etc/profile" >> /opt/etc/profile
   ```
   ```bash
   printf "source /share/docker/scripts/docker_commands_list.sh -x" >> /opt/etc/profile
   ```
   - ***NOTE:*** Adding the above lines to your `profile` automates the loading of the custom helper-scripts in the `/share/docker/scripts/` sub-folder.
   - If you prefer to enter the text manually, this is the line that needs to go at the bottom of the `profile` file:
      ```bash
      source /share/docker/scripts/docker_commands_list.sh -x
      ```

1. ***OPTIONAL:*** The below steps accomplish the same thing as above, but add notification messages whenever you reload or log into the qnap cli.
   - ***NOTE:*** If you use a Windows client to save the profile (or the scripts below), they will be saved with the `CR LF` end of line sequence, and will error. **You MUST set the end of line sequence to UNIX `LF` in order for the profile and scripts to work correctly.** <p align="left"><figure><img align="center" width="400" src="https://i.imgur.com/oGWEvCO.png"><br><figcaption>VSCodium EOL Settings</figcaption></figure></p>

   - **EDIT** the `profile` file via `nano /opt/etc/profile` or `vi /opt/etc/profile`
   - **NOTE:** I prefer to use VSCodium to edit this file as it provides syntax highlighting.
      ```bash
      source /share/docker/scripts/docker_commands_list.sh -x && echo " >> '.../docker_commands_list.sh' successfully loaded" || echo " -- ERROR: could not import '.../docker_commands_list.sh'"
      ```
   - ***NOTE:*** You will need to restart your ssh terminal session, or execute the `profile` alias (a shortcut to reload `profile`), in order to make the changes effective.

### 4. Docker Scripts Reference

1. Once the `profile` and `/share/docker/scripts` are set up, use the below section as a reference for Docker shortcut commands.

   - In general, this is the scheme for how the shortcut acronyms are composed:

      - `dc...` refers to "**D**ocker **C**ompose" commands, for use outside of a swarm setup
      - `dl...` refers to "**D**ocker **L**ist" commands (i.e. docker processes, docker networks, etc)
      - `ds...` refers to "**D**ocker **S**tack" commands (groupls of containers in a swarm setup)
      - `dv...` refers to "**D**ocker ser**V**ice" commands (mostly error and logs related)
      - `dy...` refers to "**D**ocker s**Y**stem" commands for showing info and cleaning remnants
      - `dw...` refers to "**D**ocker s**W**arm" initialization/removal commands (the whole swarm)
   - ***NOTE:*** Individual script descriptions have been removed from this `readme.md`. 
     - Please refer to the [docker_commands_list.sh](https://github.com/QNAP-HomeLAB/Docker-Scripts/blob/master/docker_commands_list.sh) file for an updated list with descriptions.

## 3. Docker general config steps

### 1. Environment Variables

1. This setup relies on several environment variable files to properly configure and set up your Docker containers.
   - The `.script_vars.conf` file has variables used by both Swarm and Compose containers.
   - Ensure this file is located here: `/share/docker/scripts/.script_vars.conf`
   - Read through this file, and fill in ***YOUR* NETWORK, NAS, OR PERSONAL INFORMATION**.
   - Pay special attention to these variables, as they are ***REQUIRED:***
     - `var_nas_ip` - this is the Local Area Network IP address of your QNAP
     - `var_usr` - userid from command `id dockeruser`
     - `var_grp` - groupid from command `id dockeruser`
     - `var_tz` - time zone in standard `Region/City` format
     - `var_domain0` - main, or only, domain name used by Traefik
     - `var_dns_provider` - DNS provider (e.g. Cloudflare, Namecheap, etc)
     - `var_certresolver` - Certificate Resolver (e.g. Cloudflare, Namecheap, etc)

### 2. Docker Container Creation

1. You are now ready to customize the `Traefik` and other Docker app configuration files found in the repositories below. Your next step is to choose `Docker Compose` or `Docker Swarm` (or a combination of both!) and then download and modify the desired Docker container config files, or write your own. 
2. Example container configuration files from the QNAP HomeLAB repository:
   - [QNAP HomeLAB Docker Compose Configs](https://www.github.com/QNAP-HomeLAB/Docker-Compose)
   - [QNAP HomeLAB Docker Swarm Configs](https://www.github.com/QNAP-HomeLAB/Docker-Swarm)

If you have questions or issues, please join the community here: [QNAP Unofficial Discord](https://discord.gg/rnxUPMd).

---
---

# Contributors

* Thanks to the late `gkoerk` (RIP) for starting this community and project. Without his efforts, none of this would have been possible.
* Funky Penguin at funkypenguin.co.nz provided a lot of the inspiration and docker config examples which started this QNAP specific project.
* Several articles from smarthomebeginner.com were used as reference for the Traefik and Cloudflare configuration steps contained in this guide.
* Many helpers and members on the [QNAP Unofficial Discord](https://discord.gg/rnxUPMd) community.

# DISCLAIMER

  * **WARNING:** This guide is incomplete, and as such ***will*** probably contain errors.
  * **NOTE:** Effort has been made to provide accurate instructions tailored for QNAP NAS devices, but no guarantee can be made that this guide will work on your specific device.
  * **YOU** accept all liability for loss or damage or inconvenience arising from using the information contained in this guide.
  * **YOU** accept all responsibility and risk when following the steps in this guide.
