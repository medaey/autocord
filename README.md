# Autocord
Autocord is a tool to easily install and update Discord on your system.

## Installation
To install Autocord, run the following commands:
```bash
git clone https://github.com/Xdavius/autocord.git
cd autocord
./install.sh
```
This will clone the repository, navigate to the directory, and execute the installation script to set up Autocord.

## Usage
To install or update Discord, simply run:
```bash
autocord install
```

To uninstall Discord AND Autocord, simply run:
```bash
autocord uninstall
```

## Prerequisites
Autocord requires the following tools to work correctly:

- **jq**: A lightweight and flexible command-line JSON processor.
- **curl**: For transferring data with URLs.
- **tar**: To extract archived files.
- **gzip**: For file compression and decompression.
- **pv**: For monitoring the progress of data through a pipeline.

Make sure these tools are installed on your system. For example, on Ubuntu/Debian-based systems, you can install them with:
```bash
sudo apt update
sudo apt install jq curl tar gzip pv
```
