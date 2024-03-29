---
layout: doc
title: Installation
---

Osm2pgsql works on Linux, Windows, macOS, and other systems. We recommend you
always use the latest [released version]({% link releases/index.md %}),
currently {{ site.data.releases | map: "version" | first }}.

[![Packaging status](https://repology.org/badge/tiny-repos/osm2pgsql.svg)](https://repology.org/project/osm2pgsql/versions)
[![latest packaged version(s)](https://repology.org/badge/latest-versions/osm2pgsql.svg)](https://repology.org/project/osm2pgsql/versions)

<div class="install">
    <a href="{% link doc/install/linux.md %}"><img alt="" src="{% link img/linux.png %}"/>Installing on Linux</a>
    <a href="{% link doc/install/windows.md %}"><img alt="" src="{% link img/windows.png %}"/>Installing on Windows</a>
    <a href="{% link doc/install/macos.md %}"><img alt="" src="{% link img/apple.png %}"/>Installing on macOS</a>
    <a href="{% link doc/install/freebsd.md %}"><img alt="" src="{% link img/freebsd.png %}"/>Installing on FreeBSD</a>
    <a href="{% link doc/install/docker.md %}"><img alt="" src="{% link img/docker.png %}"/>Installing with Docker</a>
    <a href="{% link doc/install/source.md %}"><img alt="" src="{% link img/source.png %}"/>Installing from Source</a>
</div>

## Upgrading an Existing Installation

Usually you can upgrade an existing installation of osm2pgsql to a new version
without worries. But sometimes the database format or something like it changes
and you have to re-import the OSM data, create a new index or so. Please read
the release information carefully. There is also an appendix in the manual with
[upgrading information](manual.html#upgrading).

