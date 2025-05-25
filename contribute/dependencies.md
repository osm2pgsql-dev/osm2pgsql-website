---
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
{%- for package in site.data.dependencies.packages -%}
        <th><a href="https://repology.org/project/{{ package }}/versions">{{ package }}</a></th>
{%- endfor -%}
    </tr>
</thead>
<tbody>
{%- for repos in site.data.dependencies.repositories -%}
    <tr class="{{ repos.gs }}">
        <td>{{ repos.name }}</td>
        <td>{{ repos.date }}</td>
        <td>{{ repos.eol }}</td>
{%- for package in site.data.dependencies.packages -%}
        <td><span class="repology-version-badge" id="pkg-version-{{ package }}-{{ repos.id }}">-</span></td>
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

<script>
var packages = {{ site.data.dependencies.packages | jsonify }};
for (var pkg of packages) {
    const pkgname = pkg;
    fetch(`https://osm2pgsql.org/repology-package-info/${pkg}.json`)
      .then((response) => {
        if (response.ok) {
            return response.json();
        }
        return {};
       })
      .then((infolist) => {
          for (var info of infolist) {
            const span = document.getElementById(`pkg-version-${pkgname}-${info.repo}`);
            if (span !== null && info.status !== 'rolling') {
                span.innerHTML = info.version;
            }
          }
      });
}
</script>
