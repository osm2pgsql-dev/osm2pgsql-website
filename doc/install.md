---
layout: doc
title: Installation
---

Osm2pgsql works on Linux, Windows, macOS, and other systems. We recommend you
always use the latest released version, currently
{{ site.osm2pgsql.latest_version }}.

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

### Installing on Debian/Ubuntu

For Debian/Ubuntu installation is usually as simple as

```sh
apt install osm2pgsql
```

If you are using Debian Stable, we recommend using the packages from
[backports](https://backports.debian.org/){:.extlink}. Debian maintainers are
really good at keeping these up-to-date.

### Installing on Fedora

Fedora has packages of osm2pgsql available. Install with

```sh
dnf install osm2pgsql
```

### Installing on openSUSE

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

### Installing on Arch Linux

Build the
[osm2pgsql-git](https://aur.archlinux.org/packages/osm2pgsql-git/){:.extlink}
package from the
[AUR](https://wiki.archlinux.org/index.php/Arch_User_Repository){:.extlink}.
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

You can [download prebuild
binaries](https://lonvia.dev.openstreetmap.org/osm2pgsql-winbuild/releases/).
Unpack the ZIP file and you can immediately use osm2pgsql.

### Compiling from source

For native Windows compilation you need a C++11-compatible compiler. Visual
Studio 2017 & 2015 are known to work. Follow the usual steps for compiling
CMake projects.

</section>
<section markdown="1">

## <img alt="" src="{% link img/apple.png %}"/>Installing on macOS

Osm2pgsql is [available on
Homebrew](https://formulae.brew.sh/formula/osm2pgsql){:.extlink}. Install with

```sh
brew install osm2pgsql
```

</section>
<section markdown="1">

## <img alt="" src="{% link img/freebsd.png %}"/>Installing on FreeBSD

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
