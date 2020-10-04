---------------------------------------

## 3. Docker helper-script installation

1. Open/Connect an SSH Terminal session to your QNAP NAS. 
   * You can use [PuTTY](https://putty.org/) or the `Windows Subsystem for Linux` feature in Windows 10.
   * **NOTE**: Alternatively you can use [BitVise](https://www.bitvise.com/ssh-client-download) because this also has an SFTP remote file browser interface.
   * **NOTE**: I switched to using [WinSCP](https://winscp.net/eng/download.php) and [Cmder](https://cmder.net/) because they have dark themes.
     - Connecting to the NAS using SFTP allows me to edit the docker config files using Notepad++ or Visual Studio Code.

1. Install nano or vi, whichever you are more comfortable with (only one needed)
   - **RUN**: `opkg install nano`
   - **RUN**: `opkg install vim`
   - ***NOTE***: You must have installed the `entware-std` package as detailed in Section-2 Step-8 to be able to use the "opkg" installer.

1. Type the below lines into the QNAP command line:
   ```bash
   printf "alias profile='source /opt/etc/profile" >> /opt/etc/profile
   ```
   ```bash
   printf "source /share/docker/scripts/docker_commands_list.sh -x" >> /opt/etc/profile
   ```
   - ***NOTE***: Adding the above lines to your `profile` file automates the loading of our custom helper-scripts in the `/share/docker/scripts/` sub-folder.

   1. ***OPTIONAL***: The below steps accomplish the same thing as above, but add notification messages whenever you reload or log into the qnap cli.
      - ***NOTE***: If you use a Windows client to save the profile (or the scripts below), they will be saved with CR LF and will error.
      - ***NOTE***: **You MUST set the end of line format to UNIX (LF) in order for the profile and scripts to work correctly.**
  
      1. **RUN**: `nano /opt/etc/profile` (or `vi /opt/etc/profile` if that is your thing)
   - If you prefer to enter the text manually, this is the line that needs to go at the bottom of the `profile` file.
   ```bash
   source /share/docker/scripts/docker_commands_list.sh -x
   ```
   - ***NOTE***: If you want to to be notified each time the scripts load, use this line of code instead:
   ```bash
   source /share/docker/scripts/docker_commands_list.sh -x && echo " >> '.../docker_commands_list.sh' successfully loaded" || echo " -- ERROR: could not import '.../docker_commands_list.sh'"
   ```
   - ***NOTE***: You will need to restart your ssh or cli session in order to make the profile changes effective.
