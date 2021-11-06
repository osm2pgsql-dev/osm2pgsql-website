---
repositories:
    - id: debian_12
      name: Debian Testing
      date: (2023)
      gs: groupstart
    - id: debian_11
      name: Debian 11 Bullseye
      date: 2021-08-14
      eol: 2026
    - id: debian_10
      name: Debian 10 Buster
      date: 2019-07-06
      eol: 2024
    - id: ubuntu_21_04
      name: Ubuntu 21.4 (Hirsute)
      date: 2021-04-22
      eol: 2022-01
      gs: groupstart
    - id: ubuntu_20_04
      name: Ubuntu 20.4 (Focal)
      date: 2020-04-23
      eol: 2025-04
    - id: ubuntu_18_04
      name: Ubuntu 18.4 (Bionic)
      date: 2018-04-26
      eol: 2023-04
    - id: ubuntu_16_04
      name: Ubuntu 16.4 (Xenial)
      date: 2016-04-21
      eol: 2021-04
    - id: fedora_rawhide
      name: Fedora Rawhide
      date: (April 2021)
      gs: groupstart
    - id: fedora_35
      name: Fedora 35
      date: 2021-11-02
    - id: fedora_34
      name: Fedora 34
      date: 2021-04-27
    - id: fedora_33
      name: Fedora 33
      date: 2020-10-07
    - id: centos_8
      name: CentOS 8
      date: 2019-09-24
      eol: 2029-05-31
      gs: groupstart
    - id: centos_7
      name: CentOS 7
      date: 2014-07-07
      eol: 2024-06-30
    - id: homebrew
      name: Homebrew
      gs: groupstart
packages:
    - postgresql
    - postgis
    - lua
    - cmake
    - gcc
    - llvm
    - python
    - boost
title: Dependencies
---

# Dependencies

This page shows which versions of software osm2pgsql depends on are available
on popular Linux distributions and macOS. It sometimes helps maintainers
decide what versions need to be supported.

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
* [C++ Support in Clang](https://clang.llvm.org/cxx_status.html)

