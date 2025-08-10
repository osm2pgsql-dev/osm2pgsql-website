---
layout: doc
title: Installing on Linux
---

There are [packages of
osm2pgsql](https://repology.org/project/osm2pgsql/versions){:.extlink}
available for many different Linux distributions. Some of them are quite old,
though, and have known bugs. If the current release is not available for your
distribution, consider installing the current release from source.

### <img alt="" src="{% link img/ubuntu.png %}"/>Installing on Ubuntu

![Ubuntu 20.04 package](https://repology.org/badge/version-for-repo/ubuntu_20_04/osm2pgsql.svg)
![Ubuntu 22.04 package](https://repology.org/badge/version-for-repo/ubuntu_22_04/osm2pgsql.svg)
![Ubuntu 24.04 package](https://repology.org/badge/version-for-repo/ubuntu_24_04/osm2pgsql.svg)

For Ubuntu installation is usually as simple as

```sh
apt install osm2pgsql
```

### <img alt="" src="{% link img/debian.svg %}"/>Installing on Debian

![Debian 11 (Bullseye) package](https://repology.org/badge/version-for-repo/debian_11/osm2pgsql.svg)
![Debian 12 (Bookworm) package](https://repology.org/badge/version-for-repo/debian_12/osm2pgsql.svg)
![Debian 12 (Bookworm) Backports package](https://repology.org/badge/version-for-repo/debian_12_backports/osm2pgsql.svg)
![Debian 13 (Trixie) package](https://repology.org/badge/version-for-repo/debian_13/osm2pgsql.svg)

For Debian installation is usually as simple as

```sh
apt install osm2pgsql
```

If you are using Debian Stable, we recommend using the packages from
[backports](https://backports.debian.org/){:.extlink}. Debian maintainers are
really good at keeping these up-to-date.

### <img alt="" src="{% link img/fedora.svg %}"/>Installing on Fedora

![Fedora 41 package](https://repology.org/badge/version-for-repo/fedora_41/osm2pgsql.svg)
![Fedora 42 package](https://repology.org/badge/version-for-repo/fedora_42/osm2pgsql.svg)
![Fedora Rawhide package](https://repology.org/badge/version-for-repo/fedora_rawhide/osm2pgsql.svg)

Fedora has packages of osm2pgsql available. Install with

```sh
dnf install osm2pgsql
```

### <img alt="" src="{% link img/opensuse.svg %}"/>Installing on openSUSE

First add the "Geo" package repository (adapt URL to the openSUSE version you
use):

```sh
zypper ar https://download.opensuse.org/repositories/Application:/Geo/openSUSE_Leap_15.6/ "Geo"
zypper refresh
```

Then install osm2pgsql:

```sh
zypper install osm2pgsql
```

### <img alt="" src="{% link img/arch.svg %}"/>Installing on Arch Linux

![AUR package](https://repology.org/badge/version-for-repo/aur/osm2pgsql.svg)

Build the
[osm2pgsql-git](https://aur.archlinux.org/packages/osm2pgsql-git){:.extlink}
package from the
[AUR](https://wiki.archlinux.org/title/Arch_User_Repository){:.extlink}.
(Download the tarball and compile/install with `makepkg`, or use an AUR helper
such as `yaourt`.)

