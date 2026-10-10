# nanoKONTROL-Config

[![Build](https://github.com/cheetahdotcat/nanoKONTROL-Config/actions/workflows/build.yml/badge.svg)](https://github.com/cheetahdotcat/nanoKONTROL-Config/actions/workflows/build.yml)
[![Release](https://img.shields.io/github/v/release/cheetahdotcat/nanoKONTROL-Config)](https://github.com/cheetahdotcat/nanoKONTROL-Config/releases/latest)
[![License: GPL-3.0](https://img.shields.io/badge/license-GPL--3.0-blue)](LICENSE)

Configuration tool for Korg nanoKONTROL written in Python.

This is a fork of [riban-bw/nanoKONTROL-Config](https://github.com/riban-bw/nanoKONTROL-Config) adding MIDI input fixes, loading of Korg Kontrol Editor scene files, native MIDI on Windows and macOS, uv packaging and prebuilt AppImages, Windows executables and macOS apps.

Supports nanoKONTROL1
![image](https://user-images.githubusercontent.com/3158323/176915252-a606ced7-62b2-42ef-b5da-ecca2c2c3b12.png)

Supports nanoKONTROL2
![image](https://user-images.githubusercontent.com/3158323/176915182-ca7fba06-30f5-4f93-bd36-8c0c3331ee31.png)

This tool provides a graphical user interface allowing configuration of Korg nanoKONTROL1 and nanoKONTROL2 devices. Functionality is broadly similar to Korg's own configuration tool (which I have never seen!). This tool is cross platform and open source.

On Linux MIDI connection is via JACK or ALSA (or both) hence a working JACK service and/or ALSA driver must be running before starting the application. On Windows and macOS the native MIDI system is used (WinMM / CoreMIDI, via python-rtmidi) and JACK is used as well if running. New MIDI ports are detected so the device may be connected after starting the application.

# Installation

## AppImage (Linux)

Prebuilt AppImages for x86_64 and aarch64 are attached to each [release](https://github.com/cheetahdotcat/nanoKONTROL-Config/releases). No Python installation is required. Download the file for your architecture, then:

```
chmod +x nanoKONTROL-Config-*.AppImage
./nanoKONTROL-Config-*.AppImage
```

ALSA (and optionally JACK) libraries are used from the host system. To build an AppImage locally run `make appimage`; the result is written to `dist/`.

## Windows

Download `nanoKONTROL-Config-*-windows-x86_64.exe` from the [releases](https://github.com/cheetahdotcat/nanoKONTROL-Config/releases) page and run it. The executable is not signed so SmartScreen may warn on first start ("More info" → "Run anyway").

## macOS

Download `nanoKONTROL-Config-*-macos-arm64.zip` (Apple Silicon) or `-macos-x86_64.zip` (Intel) from the [releases](https://github.com/cheetahdotcat/nanoKONTROL-Config/releases) page, unzip and move `nanoKONTROL-Config.app` to Applications. The app is not notarized, so clear the quarantine flag before first start:

```
xattr -cr /Applications/nanoKONTROL-Config.app
```

To build the Windows executable or macOS app locally run `make pyinstaller` (on Windows from Git Bash); the result is written to `dist/`.

## From source

Clone this repository, e.g. `git clone https://github.com/cheetahdotcat/nanoKONTROL-Config.git` or download and extract the zip.

## Run with uv

The simplest way to run the application is with [uv](https://docs.astral.sh/uv/), which installs Python and the Python dependencies automatically:

```
uv run nanoKONTROL.py
```

or `make run`. JACK and/or ALSA libraries must still be installed on the system.

## Install dependencies manually

The application is written in Python3 and tested on GNU/Linux. It should run on any platform that can meet the following dependencies:

- jack (for JACK MIDI interface)
- alsa-midi (for ALSA MIDI interface)
- tkinter
- PIL
- PIL Image

On a DEBIAN based system the following may install the required Python modules:

`sudo apt install python3-jack-client python3-tk python3-pil python3-pil.imagetk`

To install alsa-midi:

```
sudo apt install python3-pip
sudo pip3 install alsa-midi
```

On Windows and macOS install Pillow and python-rtmidi (`pip3 install Pillow python-rtmidi`); `uv run nanoKONTROL.py` does this automatically.

# Usage

To start the application, run the AppImage, Windows executable or macOS app, `uv run nanoKONTROL.py`, or `python3 nanoKONTROL.py` if dependencies were installed manually.

After starting the application, select the MIDI ports to which the nanoKONTROL is connected using the drop-down lists near the top, labelled "MIDI input" and "MIDI output". This is likely to be "nanoKONTROL" or "nanoKONTROL2" unless the device is connected to another machine and MIDI routed. The application tries to connect automatically when a nanoKONTROL is plugged in. The picture of the device should change to indicate the device detected.

Click the ![image](https://user-images.githubusercontent.com/3158323/176854990-1b05b67f-5ee8-4033-aa6b-4a9b08500a56.png) download button to retrieve a scene from the device.

Click on a button, slider or knob on the image and adjust its parameters using the editor on the right hand side.

Click the ![image](https://user-images.githubusercontent.com/3158323/176855266-c99b60f7-1762-4368-a889-5da36618160e.png) upload button to upload to the nanoKONTROL.

Click the ![image](https://user-images.githubusercontent.com/3158323/176855361-4ea75e8b-cff0-47c8-bb37-3cf351f40b1d.png) save button to save the scene to the nanoKONTROL's internal persistent memory.

Click the ![image](https://user-images.githubusercontent.com/3158323/176915479-baf8d65f-2365-489f-a51e-11723717cd29.png) restore button to restore the last downloaded scene. This restores locally in the application. To revert the device to its previous state you must then press the upload button.

Click the **Load...** button to open a scene file saved by Korg Kontrol Editor (`.nktrl_data` for nanoKONTROL1, `.nktrl2_data` for nanoKONTROL2). The scene is loaded into the editor only; press the upload button to send it to the device.

# Credits and Licensing

Released under the [GPL 3.0 software licensing](https://www.gnu.org/licenses/gpl-3.0.en.html). You may use and distribute this software free of charge. It may not be used within a closed source project. There is no liability protection of its use.

[Core code](https://github.com/riban-bw/nanoKONTROL-Config) written by [Brian Walton](http://riban.co.uk)

[Tooltips](https://github.com/PedroHenriques/Tkinter_ToolTips) provided by [Pedro Henriques](http://www.pedrojhenriques.com)

Icons from [freeicons](https://freeicons.io)

![image](https://user-images.githubusercontent.com/3158323/176854990-1b05b67f-5ee8-4033-aa6b-4a9b08500a56.png) ![image](https://user-images.githubusercontent.com/3158323/176855361-4ea75e8b-cff0-47c8-bb37-3cf351f40b1d.png) [ColourCreatype](https://freeicons.io/profile/5790)

![image](https://user-images.githubusercontent.com/3158323/176917301-d15296fb-79ab-421e-9d40-bc22f057394b.png) [MD Badsha Meah](https://freeicons.io/profile/3335)

![image](https://user-images.githubusercontent.com/3158323/176915479-baf8d65f-2365-489f-a51e-11723717cd29.png) [Anu Rocks](https://freeicons.io/profile/730)

![image](https://user-images.githubusercontent.com/3158323/178100762-9c3db76a-64b7-431c-8df6-ba40e2395564.png) [Reda](https://freeicons.io/profile/6156)

![led_red](https://user-images.githubusercontent.com/3158323/178287278-5d2e337b-b793-47f9-8261-42bb8ce27e64.png) [freesvg.org](https://freesvg.org)

