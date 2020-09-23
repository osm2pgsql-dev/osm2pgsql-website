---
chapter: 2
title: System Requirements
---

### Operating System

Osm2pgsql works on Linux, Windows, and macOS. It is developed on Linux and most
of the developers don't have experience with running it on anything but Linux,
so it will probably works best there. This documentation is also somewhat
geared towards Linux users.

That being said, we strive to make the software work on Windows and macOS as
well.

Only 64bit systems are supported.

Look at the [installation instructions]({% link doc/install.md %}) for details.

### Memory Requirements

Memory requirements for your system will vary widely depending on the size of
your input file. Is it city-sized extract or the whole planet?

As a rule of thumb you need at least as much main memory as the PBF file with
the OSM data is large. So for a planet file you currently need at least 64 GB
RAM. Osm2pgsql will not work with less than 2 GB RAM.

More memory can be used as cache and speed up processing a lot.

### Disk Requirements

You are strongly encouraged to use a SSD (NVMe if possible) for your database.
This will be much faster than traditional hard disks.

Requirements for your system will vary widely depending on
* the amount of data you want to store (city-sized extract or the whole planet?)
* whether or not you want to update the data regularly

