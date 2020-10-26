---
repositories:
    - id: debian_testing
      name: Deb Testing
    - id: debian_stable
      name: Deb Stable (Buster)
    - id: debian_oldstable
      name: Deb Oldstable (Stretch)
    - id: ubuntu_20_04
      name: Ubuntu 20.4 (Focal)
    - id: ubuntu_18_04
      name: Ubuntu 18.4 (Bionic)
    - id: fedora_rawhide
      name: Fedora Rawhide
    - id: fedora_32
      name: Fedora 32
    - id: centos_8
      name: CentOS 8
    - id: centos_7
      name: CentOS 7
    - id: homebrew
      name: Homebrew
packages:
    - postgresql
    - postgis
    - lua
    - cmake
    - gcc
    - clang
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
        <th>Software</th>
{%- for repos in page.repositories -%}
        <th>{{ repos.name }}</th>
{%- endfor -%}
    </tr>
</thead>
<tbody>
{%- for package in page.packages -%}
    <tr>
        <td><a href="https://repology.org/project/{{ package }}/versions">{{ package }}</a></td>
{%- for repos in page.repositories -%}
        <td><img src="https://repology.org/badge/version-for-repo/{{ repos.id }}/{{ package }}.svg?header="/></td>
{%- endfor -%}
    </tr>
{%- endfor -%}
</tbody>
</table>

