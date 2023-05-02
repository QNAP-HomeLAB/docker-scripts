<div align="center">

# QNAP HomeLAB Using Docker Containers

#### A Guide for Docker Container management via SSH Terminal

</br><big><strong>WARNING: Unfinished Project</strong></big></br></br>
<img src="https://i.imgur.com/dF9OEiS.png" width="200"/>
</br>

Getting this HomeLAB enviornment working in your QNAP will probably require tweaking and troubleshooting.

Consider joining and contributing to the [QNAP Unofficial Discord](https://discord.gg/NaxEB4sz7G), a community built around advice on everything QNAP. We have helpful members, FAQs, community Docker images, and cookies (well, maybe not cookies).

I am quite active in the Discord, and will help when and if I can, but I can not be held responsible for issues created while following this guide or performing any suggestions I make.

**WARNING:** This guide is incomplete, and as such **will *probably*** contain errors.

Please read the [disclaimer](#disclaimer) at the end of this document.

##### PRE-REQUISITES

A desire to learn Docker and some basic Terminal commands.

A desktop with a Terminal application (e.g. Termius), and a text editor (e.g. VSCodium)

A QNAP device that supports the Container Station application and therefore Docker.

A Debian based Linux distribution with Docker installed via https://get.docker.com

Thanks for checking out this guide. If it ends up being useful for your setup, please consider donating!

<a href="https://ko-fi.com/W7W64AIOZ"><img src="https://ko-fi.com/img/githubbutton_sm.svg"></a>

</div>

---
---

### Contents
[QNAP HomeLAB Using Docker Containers](#qnap-homelab-using-docker-containers)

- [I. QNAP GUI Steps](#i-qnap-gui-steps)
   - [1. Network Port Configuration](#1-network-port-configuration)
   - [2. Docker user account](#2-docker-user-account)
   - [3. Entware-std installation](#3-entware-std-installation)
   - [4. Container Station Setup](#4-container-station-setup)
   - [5. Docker Shared Folder](#5-docker-shared-folder)
- [II. Terminal Steps](#ii-terminal-steps)
   - [1. SSH Terminal Connection](#1-ssh-terminal-connection)
   - [2. Docker folder creation](#2-docker-folder-creation)
   - [3. Entware-std profile setup](#3-entware-std-profile-setup)
   - [4. Docker Scripts Reference](#4-docker-scripts-reference)
- [III. Docker general config steps](#iii-docker-general-config-steps)
   - [1. Environment Variables](#1-environment-variables)
   - [2. Docker Container Creation](#2-docker-container-creation)
- [Contributors](#contributors)
- [DISCLAIMER](#disclaimer)

---
---
<center>

## QNAP GUI Steps
</center>

    All actions in this section will be performed in the QNAP QTS Web UI.

    If following this guide on a Debian based OS, QNAP specific steps are unnecessary.

### 1. Network Port Configuration

1. For ease of configuration, ports 80, 443, and 8080 **must be _unused_ by your NAS.**
   - ***NOTE:*** This step may be unnecessary if you can get 'chained' port-forwards to work when configuring Traefik to recognize your domain and register a certificate. YMMV.
   - **EXPLANATION:** QTS assigns ports 8080 and 443 as the default HTTP and HTTPS ports for the QNAP Web UI, and assigns 80 as the default HTTP port for the native "Web Server" application. A reverse proxy requires 80 and 443 in order to obtain certificates and properly route traffic. Unless you decide not to use a reverse proxy, these must be changed to successfully complete this guide.
   - **RECOMMENDATION:** Even if you do not use a reverse proxy, I ***HIGHLY*** recommend that you change the default ports for the Web UI, Web Server, and SSH connections to increase the security of your NAS. Also disable UPnP.

1. Modify the default ports as follows to ensure there will be no port conflicts with docker stacks:
   - **Change default *System* ports:** In QNAP Web GUI
      - `Control Panel >> System >> General Settings`
      - Change the default HTTP port to `8480`, and the default HTTPS port to `8443`.
      - **NOTE:** This *will* change the LAN address from which you access your QTS web-gui, requiring you to add the port at the end of your NAS LAN IP (e.g. https://192.168.1.100:8443)
   - **Change default *Web Application* ports:** In QNAP Web GUI
      - `Control Panel >> Applications >> Web Server`
      - Change the default HTTP port to `9480`, and the default HTTPS port to `9443`.
      - **TIP:** Unless currently in use, consider disabling the MySQL application in the QNAP GUI Settings.
      - **NOTE:** It used to be required to keep the **Web Server** application enabled with the modified ports, otherwise the QTS Web Server would re-acquire the default port when disabled. I have not verified this personally, but apparently this bug was fixed so you can now safely disable the built-in Web Server.
   - **Change default *SSH* port:** In QNAP Web UI
      - `Control Panel >> Network & File Services >> Telent / SSH`
      - Change the default to a random number somewhere between `49152 - 65535`.
      - See this [list of port numbers](https://en.wikipedia.org/wiki/List_of_TCP_and_UDP_port_numbers#Dynamic,_private_or_ephemeral_ports) to make sure the one you choose is not already assigned.

1. **Ports 80 and 443 must be forwarded from your router to your NAS**.
   - *Disable UPnP on you router and manually forward ports 80 and 443 to your NAS.*
   **NOTE:** There are too many possible routers to cover how to forward ports on each, but there are some good guides here if you don't know how to do it for your router:

      - https://www.howtogeek.com/66214/how-to-forward-ports-on-your-router

      - https://portforward.com/router.htm
         - **WARNING:** Do not purchase the port-forwarding program offered from this website, it will not work for this and is a waste of money.

      ##### New Ports Settings Overview

      **QTS System UI**
      `HTTP: 8480 | HTTPS: 8443`

      **Web Server**
      `HTTP: 9480 | HTTPS: 9443`

      **SSH Terminal**
      `example: 54545`

### 2. Docker User Account Creation

   - **TIP:** During QTS initialization, if the first user created is the `dockeruser` user account, all the container configs shared here will be pre-configured to use the correct `UID: 1000` and `GID: 1000`.

   - **NOTE:** If you do not create the `docker` user as the first user account, you will need to update each container config to reflect your particular `UID` and `GID`, obtained by the terminal command: `id dockeruser`.

1. Ensure the `docker` user account is created.
   - `Control Panel >> Privilege >> Users`
   - Click the `Create` dropdown button and select `Create User`.
   **TIP:** Create the user with all lowercase letters so Linux case sensitivity is never an issue.

1. Create a new group called `docker`.
   **NOTE:** This step can be performed after creation of the `/docker` Shared Folder below in the `5. Docker Folder Creation` section.
   - `Control Panel >> Privilege >> User Groups`
   - Click the `Create` button and type in the `docker` name.
      **TIP:** Create the user with all lowercase letters so Linux case sensitivity is never an issue.
   - Assign the `docker` user account to this group by clicking the `Edit` button on the right.
   - If the `/docker` Shared Folder has been created, assign `read/write` folder permissions for this group to the folder.

### 3. Entware-std Installation

1. Install the `entware-std` package from the third-party QNAP Club repository appstore. This is necessary in order to set up the shortcuts/aliases used when controlling docker via command line by editing a permanent profile.

   - The preferred way to do this is to add the QNAP Club Repository to the App Center. Follow the [walkthrough instructions here](https://www.qnapclub.eu/en/howto/1).

      Note, I use the English translation of the QNAP Club website, but you may change languages (and urls) in the upper right language dropdown.

   - If you don't need the walkthrough, add the repository.
      For English, go to App Center, Settings, App Repository, paste in
      `https://www.qnapclub.eu/en/repo.xml`.

   - If you **cannot** add the QNAP Club store to the App Center, you may manually download the qpkg file from that link and use it to manually install via the App Center, "Install Manually" button. This is **not preferred** as QNAP cannot check for and notify you of updates to the package.

   - Search for `entware-std` and install the package.

      **TIP:** If you have trouble locating the correct package, the description begins with
      `entware-3x and entware-ng merged to become entware.`
      The working link (as of publication) is here: https://www.qnapclub.eu/en/qpkg/556.

   - **IMPORTANT:** ***DO NOT*** install the `entware-ng` or `entware-3x-std` packages. These have merged and been superceded by `entware-std`.

### 4. Container Station Setup

1. Backup what you have running now (if you don't have anything running yet, skip to Step 3. If you have also never used Container Station, skip to Step 5).

1. Shutdown and remove all docker containers and networks. This can be accomplished using Container Station, but connecting via SSH terminal allows you to complete this quickly with only three commands.

   - Stop all running containers:
      ```bash
      docker stop $(docker container ls --all --quiet)
      ```

   - Remove all stopped containers, unused networks, images, and build cache:
      ```bash
      docker system prune
      ```

   - Ensure you are not a part of a Docker Swarm:
      ```bash
      docker swarm leave --force
      ```

1. Remove Container Station:
      - In App Center, click the dropdown for Container Station and choose `Remove`.
      - In `Control Panel >> Shared Folders`, check the box next to the `container` shared folder and click "Remove"
         <p align="left"><img width="400" height="100" src="https://i.imgur.com/s1jXNNs.png"></p>
      - In the pop-up box, check "Also delete the data" and click "Yes"
         <p align="left"><img width="200" height="100" src="https://i.imgur.com/WXML3fl.png"></p></br>

1. Reboot the NAS
   <p align="left"><img width="150" height="200" src="https://i.imgur.com/voFkAt9.png"></p></br>

1. Once the reboot is complete, install Container Station from the QNAP Appstore.
   - Launch CS after installed.
   - Create the `container/` folder when prompted during the first launch of CS.

### 5. Docker Shared Folder

1. Create the `docker/` folder share **using the QTS Web UI**

   - `ControlPanel >> Privilege >> Shared Folders`

   - Click the 'Create' dropdown button and select `Shared Folder`.

   - Name the folder `docker` using **all lowercase letters**.

      ***WARNING:*** An all lowercase `docker` folder is required so the helper scripts work correctly.

   - Give `dockeruser` Read/Write permissions for the newly created `/docker` shared folder:

   - **INFO:** This is the main "docker" folder inside which we will place swarm and compose config files in their own subfolders, as well as helper scripts and secrets. The remaining folders listed below should be created using the Terminal while logged in using the default QTS `admin` account.

   - **NOTE:** The `appdata`, `compose`, `secrets`, and `swarm` sub-folders can be created using QTS File Station, but that is entirely unnecessary considering you can create them all with a single terminal command shown below. They should *not* be created as Shared Folders in the same way as the parent `docker/` folder.

---
<center>

## Terminal Steps
</center>

    All actions in this section will be accomplished via SSH terminal connection to your QNAP NAS.

### 1. SSH Terminal Connection

1. Open/Connect an SSH terminal session to your QNAP NAS.
   * You can use [PuTTY](https://putty.org/), the `Windows Subsystem for Linux`, [Cmder](https://cmder.net/) or any terminal utility with SSH.
   - **NOTE:** Alternatively you can use [BitVise](https://www.bitvise.com/ssh-client-download) because this also has an SFTP remote file browser interface.
   - **TIP:** I switched to using [WinSCP](https://winscp.net/eng/download.php) and [Cmder](https://cmder.net/) because they have dark themes. [Windows Terminal Preview](https://docs.microsoft.com/en-us/windows/terminal/get-started) is turning out to be a good Terminal as well.
   - **TIP:** Connecting to the NAS using SFTP allows me to edit the docker config files using `Notepad++` or `VSCodium` (open source Visual Studio Code clone).
   - **TIP:** I also map the `/share/docker/` folder as a Network drive on my Windows desktop, which makes viewing and editing Docker config files very easy.

2. Install `nano` so you can edit text files in the terminal:
      ***NOTE:*** You must have installed `entware-std` as detailed in [Section 1.4](#4-container-station-setup) and rebooted to be able to use the "opkg" installer command.
   - **RUN:** `opkg install nano`

### 2. Docker folder creation

   1. This section is a continuation of the QNAP QTS folder creation steps from the previous section. Here we will create required sub-folders in the `docker/` Shared Folder.

   1. Before creating the folders, these descriptions will familiarize you with the structure.

      `/share/docker/appdata`
         - This is where `application` data and internal config files will reside.
         - Each docker `container` will have its own named subfolder.

      `/share/docker/compose`
         - This is where `Docker stack` files will be stored using the docker compose format.
         - Each `compose` file can have multiple apps or containers included in the stack.
         - A git repository can provide versioning and backup for this folder.
         - **Do not save sensitive data** in compose.yml files if this is a git repository.

      `/share/docker/runtime`
         - OPTIONAL. `Temporary` DB files and `transcode` files will go here.
         - This folder should reside on a volume that does not get backed up.
         - Link this folder to a fast storage volume or Qtier cache if possible.
         - If used, create with `ln -s /target/volume/path /share/docker/runtime`

      `/share/docker/scripts`
         - Docker helper scripts for convenient container management are stored here.
         - Read and update the `.vars_docker.conf` file with your configuration info.
         - These scripts are why folder paths and compose files have strict naming requirements.

      `/share/docker/secrets`
         - This folder contains `secret` or `sensitive` configuration data such as passwords.
         - Do **not** store this folder in a public git repository.
         - Non-sensitive, `common` configuration settings can also be stored here.

      `/share/docker/swarm`
         - This is where `Swarm stack` files will be stored using the docker compose format.
         - Each `compose` file can have *multiple* apps or containers included in the stack.
         - A git repository can provide versioning and backup for this folder.
         - **Do not save sensitive data** in compose.yml files if this is a git repository.

   1. The required subfolders should be created using this terminal command:
      - QNAP ONLY: A link from `/opt/docker` to `/share/docker` is required for script operations.
         ```bash
         ln -s /share/docker /opt/docker
         ```

      **TIP:** Change `-o 1000` to your docker user `UID` and `-g 1000` to your docker group `GUID`.
         ```bash
         install -o 1000 -g 1000 -m 755 -d /share/docker/{appdata,compose,scripts,secrets,swarm}
         ```

      - Once required folders are created, make sure all files and sub-folders inside `docker/` are owned by the `dockeruser` and have the proper permissions:
         ```bash
         chown dockeruser:dockergroup -cR /opt/docker && chmod 755 -cR /opt/docker
         ```

         - This is what your folder heirarchy should show after creating the required folders:
            ```bash
            # Docker folder heirarchy
            /share
               └── docker
                  ├── appdata
                  │   ├── appname
                  │   └── ...
                  ├── compose
                  │   ├── appname
                  │   └── ...
                  ├── runtime
                  ├── scripts
                  ├── secrets
                  └── swarm
                     ├── appname
                     └── ...
            ```
         - Viewed through WinSCP, which shows the volume designation:
            <div align="left"><img src="https://i.imgur.com/Z3Q3NXn.png">
            <small><figcaption align="left">The `CECACHEDEV2_DATA` volume tag may be different on your NAS.</figcaption></small></div></br>

1. Next you need to download the `docker helper scripts` from this [QNAP HomeLAB Docker Scripts](https://gitlab.com/qnap-homelab/docker-scripts) repository to your `/share/docker/scripts/` directory.

<div align="center">

   **WARNING:**
   The automatic install script is not working, please download and install the scripts manually.

</div>

   - ~~Alternatively, if you trust my installation script to run as root on your system, you can run this `curl` command that will automatically download and install the scripts for you:~~

   - ***TIP:*** Read through and understand what a script does before executing possibly malicious code on any device.

      ```bash
      # install the docker_scripts_setup.sh using wget without downloading the file
      wget -qO - https://raw.githubusercontent.com/qnap-homelab/docker-scripts/master/docker_scripts_setup.sh | sh
      ```

      ***OR***
      ```bash
      # download and install the docker_scripts_setup.sh using cURL
      curl -fs https://gitlab.com/qnap-homelab/docker-scripts/docker_scripts_setup.sh | sh
      ```

### 3. Entware-std profile setup

1. Type the below lines into the QNAP command line. These commands will add a shortcut to reload the `profile` and make the docker scripts load each time you connect via SSH terminal.
   ```bash
   printf "\nalias profile='source /opt/etc/profile'" >> /opt/etc/profile
   ```
   ```bash
   printf "\nsource /opt/docker/scripts/docker_commands_list.sh -c" >> /opt/etc/profile
   ```
   - ***NOTE:*** If you prefer to enter the text manually, these are the lines that need to go at the bottom of the `profile` file:
      ```bash
      alias profile='source /opt/etc/profile'
      source /opt/docker/scripts/docker_commands_list.sh -c
      ```

   - ***OPTIONAL:*** The below steps accomplish the same thing as above, but add notification messages whenever you reload or log into the qnap cli.

   - **EDIT** the `profile` file via `nano /opt/etc/profile` or `vi /opt/etc/profile`
   - **NOTE:** I prefer to use VSCodium to edit this file as it provides syntax highlighting.
      ```bash
      source /opt/docker/scripts/docker_commands_list.sh -c && echo " >> '.../docker_commands_list.sh' successfully loaded" || echo " -- ERROR: could not import '.../docker_commands_list.sh'"
      ```
   - ***NOTE:*** You will need to restart your ssh terminal session, or execute the `profile` alias (a shortcut to reload `profile`), in order to make the changes effective.
   </br>

<div align="center">

   **WARNING:**
   If you use a Windows client to save the profile (or the scripts below),
   by default the files will be saved with the `CR LF` end of line sequence,
   and will error when executed.

**You MUST set the end of line sequence to UNIX `LF`.**
**Windows `CR LF` style EoL will result in failed scripts with no error.**</strong>

<small><figcaption>VSCodium EoL Settings</figcaption></small>
<img width="400" src="https://i.imgur.com/oGWEvCO.png">
<small><figcaption>(click on the "CRLF" text on the right of the bottom status bar)</figcaption></small>

</div>

### 4. Docker Scripts Reference

1. Once the `profile` and `/share/docker/scripts` are set up, use the below section as a reference for Docker shortcut commands.

   - In general, this is the scheme for how the shortcut acronyms are composed:

      - `dc...` refers to "**D**ocker **C**ompose" commands, for use outside of a swarm setup
      - `dl...` refers to "**D**ocker **L**ist" commands (i.e. docker processes, docker networks, etc)
      - `ds...` refers to "**D**ocker **S**tack" commands (groups of containers in a swarm setup)
      - `dv...` refers to "**D**ocker ser**V**ice" commands (mostly error and logs related)
      - `dw...` refers to "**D**ocker s**W**arm" initialization/removal commands (the whole swarm)
      - `dy...` refers to "**D**ocker s**Y**stem" commands for showing info and cleaning remnants
</br>

   - ***NOTE:*** Individual script descriptions have been removed from this `readme.md`. Please refer to the [docker_commands_list.sh](https://github.com/QNAP-HomeLAB/Docker-Scripts/blob/master/docker_commands_list.sh) file for an updated list with descriptions.

---
<center>

## Docker general config steps
</center>

    All instructions in this section will apply to your chosen Docker environment.

### 1. Environment Variables

1. The Docker helper scripts require several environment variable to be properly configured.

   - The `.vars_docker.conf` file has variables used by both Swarm and Compose containers.

   - Ensure this file is located here: `/share/docker/scripts/.vars_docker.conf`

   - Read through this file, and fill in ***YOUR* NETWORK, NAS, OR PERSONAL INFORMATION**.

   - Pay special attention to these variables, as they are ***REQUIRED:***

     - `var_nas_ip` - this is the Local Area Network IP address of your QNAP

     - `var_usr` - userid from command `id dockeruser`

     - `var_grp` - groupid from command `id dockeruser`

     - `var_tz` - time zone in standard `Region/City` format

     - `var_domain0` - main, or only, domain name used by Traefik

     - `var_dns_provider` - DNS provider (e.g. Cloudflare, Namecheap, etc)

     - `var_certresolver` - Certificate Resolver (e.g. Cloudflare, Namecheap, etc)

   - There are many more variables, but not all will be used for each new container created.

### 2. Docker Container Creation

1. The basic setup is now complete. Continue in one of the two (or a combination of both!) linked repositories below to further customize your Docker environment.

   I recommend the `Docker Swarm` setup, as it is considered a production environment. Docker Compose files can still be used in a Docker Swarm, but not all features of a Swarm can be used in the basic Compose setup.

   Once these environment specific steps are completed, you will be ready to customize `Traefik` and other Docker container configuration files also found in the repositories below.

   Download and modify the desired Docker container config files, or write your own.
</br>

2. Final required steps and example application configuration files from QNAP HomeLAB:
   - [QNAP HomeLAB Docker Compose Configs](https://www.github.com/QNAP-HomeLAB/Docker-Compose) - No further system configuration required. `docker-compose.yml` files can be used to immediately run containerized applications.
   - [QNAP HomeLAB Docker Swarm Configs](https://www.github.com/QNAP-HomeLAB/Docker-Swarm) - Several more system configuration steps are required before you can run containerized applications using a Swarm setup.

If you have questions or issues, please join the community here: [QNAP Unofficial Discord](https://discord.gg/NaxEB4sz7G).

---
---

# Contributors

* Thanks to the late `gkoerk` (RIP) for starting this community and project. Without his efforts, none of this would have been possible.
* Funky Penguin at funkypenguin.co.nz provided a lot of the inspiration and docker config examples which started this QNAP specific project.
* Several articles from smarthomebeginner.com were used as reference for the Traefik and Cloudflare configuration steps contained in the next two sections of this guide.
* The many helpers and members in the [QNAP Unofficial Discord](https://discord.gg/NaxEB4sz7G) community.

---

# DISCLAIMER

   - **WARNING:** This guide is incomplete, and as such ***will probably contain errors***.

   * **NOTE:** Effort has been made to provide accurate instructions tailored for QNAP NAS devices, but no guarantee can be made that this guide will work on your specific device.

   - I find it unfortunate that I have to say this, but you must accept all liability for any loss or damage or inconvenience resulting from your use of the information contained in these guides.

      - All responsibility and risk for properly verifying the validity of anything written in this guide lies with the user.

      - Contributors have composed the steps contained herin to the best of their ability, but nobody is infallible nor can all situations be accounted for.

      - If you have questions or concerns, please join us on the [QNAP Unofficial Discord](https://discord.gg/NaxEB4sz7G) community and request help.
