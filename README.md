# Autocord
Autocord is a tool to easily install and update Discord on your system.

## Prerequisites
Autocord requires the following tools to work correctly:

- **jq**          : A lightweight and flexible command-line JSON processor.
- **curl**        : For transferring data with URLs.
- **tar**         : To extract archived files.
- **gzip**        : For file compression and decompression.
- **pv**          : For monitoring the progress of data through a pipeline.
- **notify-send** : To be notified if Autocord detect/install a new version of Discord

Make sure these tools are installed on your system. For example, on Ubuntu/Debian-based systems, you can install them with:
```bash
sudo apt update
sudo apt install jq curl tar gzip pv libnotify-bin
```

## Installation
To install Autocord, run the following commands:
```bash
git clone https://github.com/Xdavius/autocord.git
cd autocord
./install.sh
```
This will clone the repository, navigate to the directory, and execute the installation script to set up Autocord.

## Optionnal
You can install the `fontconfig/local.conf` to ~/.config if you use Emoji and a DE where Emoji's are not displayed on the Window Title Bar
```bash
cp fontconfig/local.conf ~/.config/fontconfig/local.conf
```

You will need to manualy uninstall this file is you don't want it 
```bash
rm ~/.config/fontconfig/local.conf
```

## Usage
To install or update Discord, simply run:
```bash
autocord install
```

To uninstall Discord AND Autocord, simply run:
```bash
autocord uninstall
```


