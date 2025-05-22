# GPIB Setup Script for Raspberry Pi

This repository provides a simple script to set up GPIB communication with PyVISA and Linux-GPIB on a Raspberry Pi. It supports USB GPIB adapters such as the Agilent 82357A.

## Features

- Installs all required build tools and dependencies
- Builds and installs the Linux-GPIB kernel and user-space modules
- Configures USB permissions and GPIB device access
- Sets up Python virtual environment with PyVISA and related packages
- Supports Agilent 82357A USB GPIB adapter

## Requirements

- Raspberry Pi with Raspberry Pi OS (Debian-based)
- Internet connection
- USB GPIB adapter (e.g., Agilent 82357A)

## Installation

1. Clone this repository:

```bash
git clone https://github.com/abduznik/gpib-rpi.git
cd gpib-rpi
