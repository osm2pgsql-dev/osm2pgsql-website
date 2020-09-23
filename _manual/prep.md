---
chapter: 3
title: Preparing the Database
---

Before you can import any OSM data into a database, you need a database.

### Installing PostgreSQL/PostGIS

You need the [PostgreSQL](https://www.postgresql.org/) database software and
the [PostGIS](https://postgis.net/) plugin for the database. Please read the
respective documentation on how to install it. On Linux this can almost always
be done with the package manager of your distribution.

* [PostgreSQL download page](https://www.postgresql.org/download/)
* [PostGIS download page](https://postgis.net/install/)

### Supported Releases

Osm2pgsql aims to support all PostgreSQL and PostGIS versions that are
currently supported by their respective maintainers.

Currently PostgreSQL 9.6 and above is supported.

### Creating a Database

To create a database that can be used by osm2pgsql follow these steps:

1. Create a database user that osm2pgsql will use. This user doesn't need
   any special rights. We'll use `osmuser` here.
2. Create a database that osm2pgsql will use belonging to the user you just
   created. We'll use `osm` as a name here.
3. Enable the `postgis` and `hstore` extensions in the newly created database.

On a typical Linux system you'll have a system user called `postgres` which
has admin privileges for the database system. We'll use that user for these
steps.

Here are typical commands used:

```
sudo -u postgres
sudo -u postgres createdb -E UTF8 -O osmuser osm
sudo -u postgres psql osm -c 'CREATE EXTENSION postgis;'
sudo -u postgres psql osm -c 'CREATE EXTENSION hstore;'
```

### Tuning the PostgreSQL Server

Usual installs of the PostgreSQL server come with a default configuration
that isn't well tuned for large databases. You **will** have to change those
settings and restart PostgreSQL before running osm2pgsql, otherwise your system
will be much slower than needed.

You should tune the following parameters in your `postgresql.conf` file:

```
shared_buffers = 2GB
maintenance_work_mem = (10GB)
autovacuum_work_mem = 2GB
work_mem = (50MB)
effective_cache_size = (24GB)
synchronous_commit = off
checkpoint_segments = 100 # only for postgresql <= 9.4
max_wal_size = 1GB # postgresql > 9.4
checkpoint_timeout = 10min
checkpoint_completion_target = 0.9
```

See more in docs on https://nominatim.org/release-docs/latest/admin/Installation/

For details see also the [Resource Consumption section in the Server
Configuration
chapter](https://www.postgresql.org/docs/current/runtime-config-resource.html)
in the PostgreSQL documentation.

