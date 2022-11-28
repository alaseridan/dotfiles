## Install chocolatey
Run powershell as admin and run the commands:

```
Set-ExecutionPolicy Unrestricted -Force
System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
```

You may need to restart powershell so it refreshes the env

## Install Boxstarter
Run `choco install Boxstarter` to install box starter

## Running the install script
It may be easiest to open the Boxstarter shell, since it imports all of the boxstarter libraries and sets the correct permissions

Download `workmachine.ps1` and cd to the download location. Run the script with 

```
.\workmachine.ps1
```

Sit back while everything downloads
