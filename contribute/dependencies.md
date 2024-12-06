---
repositories:
    - id: debian_13
      name: Debian Testing
      date: (2025)
      gs: groupstart
    - id: debian_12
      name: Debian 12 Bookworm
      date: 2023-06-10
    - id: debian_11
      name: Debian 11 Bullseye
      date: 2021-08-14
      eol: 2026
    - id: debian_10
      name: Debian 10 Buster
      date: 2019-07-06
      eol: 2024
    - id: ubuntu_24_04
      name: Ubuntu 24.04 (Noble)
      date: 2024-04-25
      eol: 2029-06
      gs: groupstart
    - id: ubuntu_22_04
      name: Ubuntu 22.04 (Jammy)
      date: 2022-04-21
      eol: 2027-04
    - id: ubuntu_20_04
      name: Ubuntu 20.04 (Focal)
      date: 2020-04-23
      eol: 2025-04
    - id: fedora_rawhide
      name: Fedora Rawhide
      gs: groupstart
    - id: fedora_41
      name: Fedora 41
      date: 2024-10-29
      eol: 2025-11-19
    - id: fedora_40
      name: Fedora 40
      date: 2024-04-23
      eol: 2025-05-13
    - id: fedora_39
      name: Fedora 39
      date: 2023-11-07
      eol: 2024-11-12
    - id: fedora_38
      name: Fedora 38
      date: 2023-04-18
      eol: 2024-05-14
    - id: centos_8
      name: CentOS 8
      date: 2019-09-24
      eol: 2029-05-31
      gs: groupstart
    - id: homebrew
      name: Homebrew
      gs: groupstart
packages:
    - osm2pgsql
    - postgresql
    - postgis
    - lua
    - cmake
    - gcc
    - llvm
    - python
    - boost
    - proj
    - geos
    - catch
    - fmt
    - libosmium
    - protozero
    - pyosmium
    - nlohmann-json
title: Dependencies
---

# Dependencies

This page shows which versions of software osm2pgsql depends on (or that are
otherwise related) are available on popular Linux distributions and macOS. It
sometimes helps maintainers decide what versions need to be supported.

*See the
[README](https://github.com/osm2pgsql-dev/osm2pgsql/blob/master/README.md) for
a list of actual dependencies.*

<table class="software-versions">
<thead>
    <tr>
        <th>Distribution</th>
        <th>Released</th>
        <th>End of life</th>
{%- for package in page.packages -%}
        <th><a href="https://repology.org/project/{{ package }}/versions">{{ package }}</a></th>
{%- endfor -%}
    </tr>
</thead>
<tbody>
{%- for repos in page.repositories -%}
    <tr class="{{ repos.gs }}">
        <td>{{ repos.name }}</td>
        <td>{{ repos.date }}</td>
        <td>{{ repos.eol }}</td>
{%- for package in page.packages -%}
        <td><img src="https://repology.org/badge/version-for-repo/{{ repos.id }}/{{ package }}.svg?header="/></td>
{%- endfor -%}
    </tr>
{%- endfor -%}

</tbody>
</table>

* C++14 should be fully supported from GCC 5, Clang 3.4. It is the default from GCC 6.1 to GCC 10 and since Clang 6.
* C++17 should be fully supported from GCC 7, Clang 5. It is the default from GCC 11.

See also:

* [C++ Standards Support in GCC](https://gcc.gnu.org/projects/cxx-status.html)
* [C++ Implementation Status in libstdc++](https://gcc.gnu.org/onlinedocs/libstdc++/manual/status.html)
* [C++ Support in Clang](https://clang.llvm.org/cxx_status.html)
* [C++ Support in libc++](https://libcxx.llvm.org/)

