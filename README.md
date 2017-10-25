# OpenSSH for Windows

[OpenSSH for Windows](https://www.mls-software.com/opensshd.html) is an [OpenSSH](https://openssh.com) installer package for Windows.


# Download

Download 


# Contents

This repository contains sources for the Installer package and Cygwin source files. to get the 32bit/64bit binaries, head to https://www.mls-software.com/opensshd.html or [Release page](https://github.com/cyfrost/OpenSSH-for-Windows/releases)


# Building the Installer

* Download [NSIS Script Compiler](http://nsis.sourceforge.net/Download) for compiling NSI scripts

before compiling the setupssh.nsi script, you'll need the following plugins installed:

* Download [Registry Plug-in](http://nsis.sourceforge.net/Registry_plug-in)

* Download [Services Plug-in](http://nsis.sourceforge.net/Services_plug-in)

* Download [User-Mgr Plug-in](http://nsis.sourceforge.net/UserMgr_plug-in)

Install (or) copy them to `<NSIS Installation Directory>\Plugins` and/or `<NSIS Installation Directory>\Include` folder(s).

Use the NSIS Script Compiler to build setup executable by dragging the "setupssh.nsi" file into the Compiler window.

# Disclaimer

All the resources provided in this repository are forked from [mls-software.com/opensshd.html](https://www.mls-software.com/opensshd.html), where they are actively updated and maintained (Intent is to reflect the same within this repository).


# Licensing

The licensing terms and conditions are inherent from [mls-software.com/opensshd.html](https://www.mls-software.com/opensshd.html).
