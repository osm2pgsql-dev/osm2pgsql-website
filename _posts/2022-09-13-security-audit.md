---
layout: post
title: Security audit for osm2pgsql
---

In the last couple of months the source code of osm2pgsql has gone through
a security audit. This was part of the [NGI Zero prject](https://nlnet.nl/project/Nominatim/)
for Nominatim which uses osm2pgsql for its data import. The audit was done
by the friendly people from
[RadicallyOpenSecurity](https://www.radicallyopensecurity.com/) (ROS).

Why do we need a security audit?
osm2pgsql processes arbitrary OSM data files, which may come from potentially
untrusted sources. This makes osm2pgsql a potential attack vector for someone
who wants
to take control of a machine through manipulated data files. ROS tested
the importer code through [fuzzing](https://en.wikipedia.org/wiki/Fuzzing) of the import formats `xml`, `pbf` and `o5m`.
In addition they ran a static code analysis to check for common issues and reviewed
our documentation.

The good news is that none of the tests revealed any severe security issues.
The fuzz testing was not able to crash osm2pgsql. While it does not mean
that the import code is bug free, an attack through manipulated data files
is less likely.

The static code check revealed two places in the code where it was possible
to inject bad SQL code through command-line parameters. These cases are
already fixed on the master branch
([#1753](https://github.com/openstreetmap/osm2pgsql/pull/1753),
[#1758](https://github.com/openstreetmap/osm2pgsql/pull/1758)).
The security risk for these issues is relatively low because an attacker
would still need access to the command line and credentials to the database to make use of them.

The largest security risk for `osm2pgsql` is not so much the code itself
but the fact that the tool relies on a properly set-up system environment.
To run osm2pgsql in a secure manner it is vital that it runs with minimal
access to the rest of the system and that PostgreSQL is set up properly.
We have amended the manual further to remind you
of the most important security practises, among them

* Set up secure authentication for PostgreSQL. Most installations have
  sane defaults but you should recheck the settings.
* Handle passwords to the database responsibly. Passwords on the command
  line are not secure. Use `pgpass` files instead.
* Give minimal rights to all files used by osm2pgsql: binaries, Lua scripts,
  config files.
* Only run Lua scripts from trusted sources.

As part of the project, ROS has taught us about the fuzzing techniques they
used. That means that regular fuzzing runs will now be part of our testing
strategy next to the growing set of unit and integration tests. For this our
new [test server]({% link _posts/2022-08-30-new-test-server.md %}) has come
in handy which now runs fuzzying tests when not needed otherwise.
