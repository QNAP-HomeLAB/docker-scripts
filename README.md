# QNAP Docker HomeLAB Setup Instructions
    A guide for configuring Docker containers on QNAP devices with Container Station

**WARNING**: This guide is incomplete, and as such ***will*** contain errors.

Please read the [disclaimer](#disclaimer) at the end of this document.

Consider joining and contributing to the [QNAP Unofficial Discord](https://discord.gg/rnxUPMd), a community built around advice on everything QNAP. We have helpful members, FAQs, CI/CD, Community Docker images, and cookies.

---------------------------------------

## 1. Preparation

1. **Ports 80, 443, and 8080 *must be _unused_ by your NAS.*** 
   - By default, QTS assigns ports 8080 and 443 as the default HTTP and HTTPS ports for the QNAP Web Admin Console, and assigns 80 as the default HTTP port for the native "Web Server" application. Each of these must be updated to be successful with this guide.
1. Modify these ports as follows to ensure there will be no port conflicts with docker stacks:
   - ***Change* default *System* ports**: In QNAP Web GUI
      - `Control Panel >> System >> General Settings`
      - Change the default HTTP port to `8880`, and the default HTTPS port to `8443`.
      - **NOTE**: This *will* change the LAN address from which you access your QTS web-gui, requiring you to add the port at the end of your NAS LAN IP (e.g. https://192.168.1.100:8443)
   - ***Change* default *Web Application* ports**: In QNAP Web GUI
      - `Control Panel >> Applications >> Web Server`
      - Change the default HTTP port to `9880`, and the default HTTPS port to `9443`.
   - *DO NOT* disable the **Web Server** application, leave this active on the new port.
   - Unless currently in use, consider disabling the **MySQL** application in the QNAP GUI Settings.
1. **Ports 80 and 443 must be forwarded from your router to your NAS**. 
   - This is *possible* using UPNP in the QNAP GUI, but ***is not recommended!***
   - **Instead, disable UPNP at the router and manually forward ports 80 and 443 to your NAS.**
   - ***NOTE***: There are too many possible routers to cover how to forward ports on each, but there are some good guides here if you don't know how to do it for your router: 
      - https://portforward.com/router.htm
      - https://www.howtogeek.com/66214/how-to-forward-ports-on-your-router

**Ports Overview**:
- QTS **System** ports should be:
   - HTTP : 8880
   - HTTPS: 8443

- QTS **Web Server** application ports should be:
   - HTTP : 9880
   - HTTPS: 9443

---------------------------------------

## 2. Container Station Steps

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

1. Create a new user called `dockeruser`

1. Create the following folder shares *using the QTS web-GUI* 
   - `ControlPanel >> Privilege >> Shared Folders` 
   - Give `dockeruser` Read/Write permissions for each of the below folders:
   - `/share/swarm/appdata`
      - Here we will add folders named `< stack name >`. This is where your application files live... libraries, artifacts, internal application configuration, etc. Think of this directory much like a combination of `C:\Windows\Program Files` and `C:\Users\<UserName>\AppData` in Windows.
   - `/share/swarm/configs`
      - Here we will also add folders named `< stack name >`. Inside this structure, we will keep our actual _stack_name.yml_ files and any other necessary config files used to configure the docker stacks and images we want to run. This folder makes an excellent GitHub repository for this reason.
   - `/share/swarm/runtime`
      - This is a shared folder on a volume that does not get backed up. It is where living DB files and transcode files reside, so it would appreciate running on the fastest storage group you have or in cache mode or in Qtier (if you use it). Think of this like the `C:\Temp\` in Windows.
   - `/share/swarm/secrets`
      - This folder contains secret (sensitive) configuration data that should _NOT_ be shared publicly. This could be stored in a _PRIVATE_ Git repository, but should never be publicized or made available to anyone you don't implicitly trust with passwords, auth tokens, etc.

1. Install the `entware-std` package from the third-party QNAP Club repository appstore. This is necessary in order to setup the shortcuts/aliases used when controlling docker via command line by editing a permanent profile.
   - The preferred way to do this is to add the QNAP Club Repository to the App Center. Follow the [walkthrough instructions here](https://www.qnapclub.eu/en/howto/1). 
   - Note that I use the English translation of the QNAP Club website, but you may change languages (and urls) in the upper right language dropdown.
   - If you don't need the walkthrough, add the repository. (For English, go to App Center, Settings, App Repository, Add, `https://www.qnapclub.eu/en/repo.xml`).
   - If you have trouble locating the correct package below, the correct description begins `entware-3x and entware-ng merged to become entware.` The working link (as of publication) is here: https://www.qnapclub.eu/en/qpkg/556. 
   - If you **cannot** add the QNAP Club store to the App Center, you may manually download the qpkg file from that link and use it to manually install via the App Center, "Install Manually" button. This is **not preferred** as QNAP cannot check for and notify you of updates to the package.
   - Search for `entware-std` and install that package.

   - **Important**: *DO NOT* CHOOSE either the `entware-ng` or `entware-3x-std` packages. These have merged and been superceded by `entware-std`.


---------------------------------------

## 3. Docker helper-scripts installation

1. Open/Connect an SSH Terminal session to your QNAP NAS. 
   * You can use [PuTTY](https://putty.org/), the `Windows Subsystem for Linux`, or [Cmder](https://cmder.net/) or any command line utility with SSH.
   - **NOTE**: Alternatively you can use [BitVise](https://www.bitvise.com/ssh-client-download) because this also has an SFTP remote file browser interface.
   - **NOTE**: I switched to using [WinSCP](https://winscp.net/eng/download.php) and [Cmder](https://cmder.net/) because they have dark themes.
     - Connecting to the NAS using SFTP allows me to edit the docker config files using Notepad++ or VSCodium (open source Visual Studio Code clone).

1. Install nano or vi, whichever you are more comfortable with (only one needed)
   - **RUN**: `opkg install nano`
   - **RUN**: `opkg install vim`
   - ***NOTE***: You must have installed the `entware-std` package as detailed [in Section 2, Step 8](#2-container-station-steps) to be able to use the "opkg" installer.

1. Type the below lines into the QNAP command line:
   ```bash
   printf "alias profile='source /opt/etc/profile" >> /opt/etc/profile
   ```
   ```bash
   printf "source /share/docker/scripts/docker_commands_list.sh -x" >> /opt/etc/profile
   ```
   - ***NOTE***: Adding the above lines to your `profile` automates the loading of the custom helper-scripts in the `/share/docker/scripts/` sub-folder.

1. ***OPTIONAL***: The below steps accomplish the same thing as above, but add notification messages whenever you reload or log into the qnap cli.
   - **EDIT** the `profile` via `nano /opt/etc/profile` or `vi /opt/etc/profile`
   - **NOTE** I prefer to use VSCodium to edit this file as it provides syntax highlighting.
   - ***NOTE***: If you use a Windows text editor to save the profile (or the scripts below), they will be saved with CR LF and will error. ***You MUST set the end of line format to UNIX (LF) in order for `profile` and scripts to work correctly.*** <p align="left"><figure><img align="center" width="400" src="https://i.imgur.com/oGWEvCO.png"></p><figcaption>VSCodium EOL Settings</figcaption></figure>
   - If you prefer to enter the text manually, this is the line that needs to go at the bottom of the `profile` file.
      ```bash
      source /share/docker/scripts/docker_commands_list.sh -x
      ```
   - ***NOTE***: If you want to to be notified each time the scripts load, use this line of code instead:
      ```bash
      source /share/docker/scripts/docker_commands_list.sh -x && echo " >> '.../docker_commands_list.sh' successfully loaded" || echo " -- ERROR: could not import '.../docker_commands_list.sh'"
      ```
   - ***NOTE***: You will need to restart your ssh / cli session, or *execute* the `profile` alias created earlier (a shortcut to the docker commands file), in order to make the profile changes effective.

1. Next you will need to download the `script` files in this repository and place them in the `/share/docker/scripts` folder path on your QNAP. This can be accomplished several ways, but my preferred method is outlined here. 
   - Connect to your QNAP using [WinSCP](https://winscp.net/eng/download.php). <p align="left"><img align="center" width="400" src="https://i.imgur.com/3LaKSMB.png"></p>
   - You can then directly download the scripts from the [QNAP-HomeLAB/Docker-Scripts](https://github.com/QNAP-HomeLAB/Docker-Scripts/archive/master.zip) repository.
   - Once the `.zip` is downloaded, extract the files and copy them to the QNAP at this folder path: `/share/docker/scripts/`
   - This is the docker folder hierarchy and the scripts folder with scripts populated:  <p align="left"><img align="center" width="400" src="https://i.imgur.com/2VA8Jgw.png"></p>

2. Once the `profile` and `/share/docker/scripts` are set up, use the below section as a reference for Docker shortcut commands.

   - In general, this is the scheme for how the shortcut acronyms are composed:
      - `dc...` refers to `Docker Compose` commands, for use outside of a swarm setup
      - `dl...` refers to `Docker List` commands (i.e. docker processes, docker networks, etc)
      - `ds...` refers to `Docker Stack` commands (groups of containers in a swarm setup)
      - `dv...` refers to `Docker serVice` commands (mostly error and logs related)
      - `dy...` refers to `Docker sYstem` commands for showing info and cleaning remnants
      - `dw...` refers to `Docker sWarm` initialization/removal commands (the whole swarm)

   - **NOTE**: Individual script descriptions have been removed from this `readme.md`. 
   - Please refer to the [docker_commands_list.sh](https://github.com/QNAP-HomeLAB/Docker-Scripts/blob/master/docker_commands_list.sh) file for an updated list with descriptions.

## 4. Docker general config steps

1. This setup relies on several environment variable files to properly configure and set up your Docker containers.
   - The `.script_vars.conf` file has variables used by both Swarm and Compose containers.
   - Ensure this file is located here: `/share/docker/scripts/.script_vars.conf`
   - Read through this file, and fill in ***YOUR* NETWORK, NAS, OR PERSONAL INFORMATION**.
   - Pay special attention to these variables, as they are ***REQUIRED***:
     - `var_nas_ip` - this is the Local Area Network IP address of your QNAP
     - `var_usr` - userid from command `id dockeruser`
     - `var_grp` - groupid from command `id dockeruser`
     - `var_tz` - time zone in standard `Region/City` format
     - `var_domain0` - main, or only, domain name used by Traefik
     - `var_dns_provider` - DNS provider (e.g. Cloudflare, Namecheap, etc)
     - `var_certresolver` - Certificate Resolver (e.g. Cloudflare, Namecheap, etc)

3. **TYPE**: `docker network ls` (`dln`)The networks shown should match the following (except the generated NETWORK ID):
   ```
   [~] # docker network ls
   NETWORK ID          NAME                DRIVER              SCOPE
   XXXXXXXXXXXX        bridge              bridge              local
   XXXXXXXXXXXX        host                host                local
   XXXXXXXXXXXX        none                null                local
   ```

4. If you successfully edited the bash `profile` above, *AND* saved the scripts from the git repository to `/share/docker/scripts`, you can use the shortcut command `dwup` instead of manually performing the steps below.
   - **TYPE**: `dwup`
   - **WARNING**: It is very important to compare the network listing below with your system, and make sure the proper networks ***were created***.

5. **TYPE**: `docker swarm init --advertise-addr <YOUR NAS IP HERE>` - Use ***YOUR*** nas internal LAN IP address

6. **CHECKPOINT**: Run `docker network ls`. Does the list of networks contain one named `docker_gwbridge`?
   - The networks should match the following (except the generated NETWORK ID):
   ```
   [~] # docker network ls
   NETWORK ID          NAME                   DRIVER              SCOPE
   XXXXXXXXXXXX        bridge                 bridge              local
   XXXXXXXXXXXX        docker_gwbridge        bridge              local
   XXXXXXXXXXXX        host                   host                local
   XXXXXXXXXXXX        ingress                overlay             swarm
   XXXXXXXXXXXX        none                   null                local
   ```

   - **IMPORTANT: If your configuration is lacking the `docker_gwbridge` network, or differs from this list**, please contact someone on the [QNAP Unofficial Discord](https://discord.gg/rnxUPMd) (ideally in the [#docker-stack channel](https://discord.gg/MzTNQkV)). Do not proceed beyond this point unless your configuration matches the one above, unless you embrace pain and failure and love very complicated problems that could be QNAP's fault.

7. Create the traefik overlay network:
   - **NOTE**: This step is performed via script if you already installed the bash scripts above.
   - **TYPE**: `docker network create --driver=overlay --subnet=172.1.1.0/22 --attachable traefik_public`

8. You are now ready to customize the `Traefik` (and other Docker app) configuration files found in the repositories below. 
   - [Swarm Configs repository](https://github.com/QNAP-HomeLAB/Docker-Swarm-Configs)
   - [Compose Configs repository](https://github.com/QNAP-HomeLAB/Docker-Compose-Configs)

---------------------------------------

# DISCLAIMER

  * **WARNING**: This guide is incomplete, and as such ***will*** contain errors.
  * **YOU** accept all liability for losses or damages arising from using the information contained in this guide.
  * **NOTE** Effort has been made to provide accurate instructions tailored for QNAP NAS devices, but no guarantee can be made that this guide will work on your specific device.
  * **YOU** accept all responsibility and risk when following the steps in this guide.
