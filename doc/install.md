---
layout: doc
title: Installation
---

Osm2pgsql works on Linux, Windows, macOS, and other systems. We recommend you
always use the latest [released version]({% link releases/index.md %}),
currently {{ site.data.releases | map: "version" | first }}.

[![Packaging status](https://repology.org/badge/tiny-repos/osm2pgsql.svg)](https://repology.org/project/osm2pgsql/versions)
[![latest packaged version(s)](https://repology.org/badge/latest-versions/osm2pgsql.svg)](https://repology.org/project/osm2pgsql/versions)

<ul>
    <li><a href="#installing-on-linux">Installing on Linux</a></li>
    <li><a href="#installing-on-windows">Installing on Windows</a></li>
    <li><a href="#installing-on-macos">Installing on macOS</a></li>
    <li><a href="#installing-on-freebsd">Installing on FreeBSD</a></li>
    <li><a href="#upgrading-an-existing-installation">Upgrading an Existing Installation</a></li>
</ul>

<section markdown="1">

## <img alt="" src="{% link img/linux.png %}"/>Installing on Linux

There are [packages of
osm2pgsql](https://repology.org/project/osm2pgsql/versions){:.extlink}
available for many different Linux distributions. Some of them are quite old,
though, and have known bugs. If the current release is not available for your
distribution, consider installing the current release from source.

### <img alt="" src="{% link img/ubuntu.png %}"/>Installing on Ubuntu

![Ubuntu 18.04 package](https://repology.org/badge/version-for-repo/ubuntu_18_04/osm2pgsql.svg)
![Ubuntu 20.04 package](https://repology.org/badge/version-for-repo/ubuntu_20_04/osm2pgsql.svg)
![Ubuntu 22.04 package](https://repology.org/badge/version-for-repo/ubuntu_22_04/osm2pgsql.svg)

For Ubuntu installation is usually as simple as

```sh
apt install osm2pgsql
```

### <img alt="" src="{% link img/debian.svg %}"/>Installing on Debian

![Debian 10 (Buster) package](https://repology.org/badge/version-for-repo/debian_10/osm2pgsql.svg)
![Debian 10 (Buster) Backports package](https://repology.org/badge/version-for-repo/debian_10_backports/osm2pgsql.svg)
![Debian 11 (Bullseye) package](https://repology.org/badge/version-for-repo/debian_11/osm2pgsql.svg)
![Debian 11 (Bullseye) Backports package](https://repology.org/badge/version-for-repo/debian_11_backports/osm2pgsql.svg)
![Debian Testing package](https://repology.org/badge/version-for-repo/debian_12/osm2pgsql.svg)

For Debian installation is usually as simple as

```sh
apt install osm2pgsql
```

If you are using Debian Stable, we recommend using the packages from
[backports](https://backports.debian.org/){:.extlink}. Debian maintainers are
really good at keeping these up-to-date.

### <img alt="" src="{% link img/fedora.svg %}"/>Installing on Fedora

![Fedora 33 package](https://repology.org/badge/version-for-repo/fedora_33/osm2pgsql.svg)
![Fedora 34 package](https://repology.org/badge/version-for-repo/fedora_34/osm2pgsql.svg)
![Fedora 35 package](https://repology.org/badge/version-for-repo/fedora_35/osm2pgsql.svg)
![Fedora Rawhide package](https://repology.org/badge/version-for-repo/fedora_rawhide/osm2pgsql.svg)

Fedora has packages of osm2pgsql available. Install with

```sh
dnf install osm2pgsql
```

### <img alt="" src="{% link img/opensuse.svg %}"/>Installing on openSUSE

First add the "Geo" package repository (adapt URL to the openSUSE version you
use):

```sh
zypper ar https://download.opensuse.org/repositories/Application:/Geo/openSUSE_Leap_15.2/ "Geo"
zypper refresh
```

Then install osm2pgsql:

```sh
zypper install osm2pgsql
```

### <img alt="" src="{% link img/arch.svg %}"/>Installing on Arch Linux

![AUR package](https://repology.org/badge/version-for-repo/aur/osm2pgsql.svg)

Build the
[osm2pgsql-git](https://aur.archlinux.org/packages/osm2pgsql-git/){:.extlink}
package from the
[AUR](https://wiki.archlinux.org/title/Arch_User_Repository){:.extlink}.
(Download the tarball and compile/install with `makepkg`, or use an AUR helper
such as `yaourt`.)

### Installing from Source / Git

If you can't use the packaged version of osm2pgsql for your distribution, you
can always install from source.

* To install the latest release, download the
  [latest release](https://github.com/openstreetmap/osm2pgsql/releases/latest)
  as `tar.gz` or `zip` file and unpack it.
* To install a version from git, get it with `git clone
  https://github.com/openstreetmap/osm2pgsql`.

See the *Building* section in the
[`README.md`](https://github.com/openstreetmap/osm2pgsql/blob/master/README.md)
for a list of dependencies and build instructions.

</section>
<section markdown="1">

## <img alt="" src="{% link img/windows.png %}"/>Installing on Windows

### Using prebuild binaries

You can [download prebuild binaries](/download/windows/). Unpack the ZIP file
and you can immediately use osm2pgsql.

### Compiling from source

For native Windows compilation you need a C++14-compatible compiler. Follow the
usual steps for compiling CMake projects.

</section>
<section markdown="1">

## <img alt="" src="{% link img/apple.png %}"/>Installing on macOS

![Homebrew package](https://repology.org/badge/version-for-repo/homebrew/osm2pgsql.svg)

Osm2pgsql is [available on
Homebrew](https://formulae.brew.sh/formula/osm2pgsql){:.extlink}. Install with

```sh
brew install osm2pgsql
```

</section>
<section markdown="1">

## <img alt="" src="{% link img/freebsd.png %}"/>Installing on FreeBSD

![FreeBSD port](https://repology.org/badge/version-for-repo/freebsd/osm2pgsql.svg)

Osm2pgsql is available in [FreeBSD
Ports](https://www.freebsd.org/cgi/ports.cgi?query=osm2pgsql){:.extlink}.
Install with:

```sh
pkg install converters/osm2pgsql
```

</section>
<section markdown="1">

## Upgrading an Existing Installation

Usually you can upgrade an existing installation of osm2pgsql to a new version
without worries. But sometimes the database format or something like it changes
and you have to re-import the OSM data, create a new index or so. Please read
the release information carefully. There is also an appendix in the manual with
[upgrading information](manual.html#upgrading).

</section>
