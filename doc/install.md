---
layout: doc
title: Installation
---

Osm2pgsql works on Linux, Windows, macOS, and other systems. We recommend you
always use the latest [released version]({% link releases/index.md %}),
currently {{ site.releases | sort: 'date' | map: "version" | last }}.

[![Packaging status](https://repology.org/badge/tiny-repos/osm2pgsql.svg)](https://repology.org/project/osm2pgsql/versions)
[![latest packaged version(s)](https://repology.org/badge/latest-versions/osm2pgsql.svg)](https://repology.org/project/osm2pgsql/versions)

<div class="install">
    <a href="{% link doc/install/linux.md %}">{% include img/logo-tux.svg %}Installing on Linux</a>
    <a href="{% link doc/install/windows.md %}">{% include img/logo-windows.svg %}Installing on Windows</a>
    <a href="{% link doc/install/macos.md %}">{% include img/logo-apple.svg %}Installing on macOS</a>
    <a href="{% link doc/install/freebsd.md %}">{% include img/logo-freebsd.svg %}Installing on FreeBSD</a>
    <a href="{% link doc/install/docker.md %}">{% include img/logo-docker.svg %}Installing with Docker</a>
    <a href="{% link doc/install/source.md %}">{% include img/from-source.svg %}Installing from Source</a>
</div>

## Upgrading an Existing Installation

Usually you can upgrade an existing installation of osm2pgsql to a new version
without worries. But sometimes the database format or something like it changes
and you have to re-import the OSM data, create a new index or so. Please read
the release information carefully. There is also an appendix in the manual with
[upgrading information](manual.html#upgrading).

