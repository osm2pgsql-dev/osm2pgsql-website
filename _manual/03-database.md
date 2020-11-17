---
chapter: 3
title: Preparing the Database
---

Before you can import any OSM data into a database, you need a database.

### Installing PostgreSQL/PostGIS

You need the [PostgreSQL](https://www.postgresql.org/){:.extlink} database
software and the [PostGIS](https://postgis.net/){:.extlink} plugin for the
database. Please read the respective documentation on how to install it. On
Linux this can almost always be done with the package manager of your
distribution.

* [PostgreSQL download page](https://www.postgresql.org/download/){:.extlink}
* [PostGIS download page](https://postgis.net/install/){:.extlink}

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

```sh
sudo -u postgres createuser osmuser
sudo -u postgres createdb --encoding=UTF8 --owner=osmuser osm
sudo -u postgres psql osm --command='CREATE EXTENSION postgis;'
sudo -u postgres psql osm --command='CREATE EXTENSION hstore;'
```

### Security Considerations

Osm2pgsql does not need any special database rights, it doesn't need superuser
status and doesn't need to create databases or roles. You should create a
database user for the specific use by osm2pgsql which should not have any
special PostgreSQL privileges.

Any osm2pgsql setup will need a database to work on. You should create this as
PostgreSQL superuser and change ownership (with `--owner` option on the
`createdb` command or an `OWNER=` clause on the `CREATE DATABASE` SQL command)
to the user osm2pgsql is using. This way the database user that osm2pgsql uses
doesn't need database creation privileges.

Typical osm2pgsql setups need the `postgis` and `hstore` extensions to be
enabled in the database. To install these you need superuser privileges in the
database. Enable them (with `CREATE EXTENSION`) as PostgreSQL superuser on the
database that osm2pgql is using before you run osm2pgsql.

Of course osm2pgsql needs to be able to create tables and write to the
database. Usually it can do this as owner of the database created for it.
Using the data, on the other hand, doesn't need any of those rights. So the
map rendering software you are using, for instance, usually only needs to
read the data. It is recommended that you run these as a different database
user, distinct from the database user osm2pgsql is using and only give that
user `SELECT` rights (with the `GRANT` command).

*Version >= 1.4.0*{: .version} If you are using a security scheme based on
database schemas in your database you can use the `--middle-schema` and
`--output-pgsql-schema` options and the `schema` table option in the flex
output, respectively, to tell osm2pgsql to load data into specific schemas. You
have to create those schemas and give them the correct rights before running
osm2pgsql.

### Encoding

OpenStreetMap data is from all around the world, it always uses UTF-8 encoding.
osm2pgsql will write the data as is into the database, so it has to be in UTF-8
encoding, too.

On any modern system the default encoding for new databases should be UTF-8,
but to make sure, you can use the `-E UTF8` or `--encoding=UTF8` options when
creating the database for osm2pgsql with `createdb`.


### Tuning the PostgreSQL Server

Usual installs of the PostgreSQL server come with a default configuration
that isn't well tuned for large databases. You **will** have to change those
settings and restart PostgreSQL before running osm2pgsql, otherwise your system
will be much slower than necessary.

You should tune the following parameters in your `postgresql.conf` file. The
values in the second column are suggestions and good starting point for a
typical setup, you might have to adjust them for your use case. The settings
are somewhat geared towards a system with 64GB RAM and a fast SSD.

| Config Option                | Proposed Value  |
| ---------------------------- | ------ |
| shared_buffers               | 2GB    |
| maintenance_work_mem         | 10GB   |
| autovacuum_work_mem          | 2GB    |
| work_mem                     | 50MB   |
| effective_cache_size         | 24GB   |
| synchronous_commit           | off    |
| max_wal_size                 | 1GB    |
| checkpoint_timeout           | 10min  |
| checkpoint_completion_target | 0.9    |
{: .desc}

A higher number for `max_wal_size` means that PostgreSQL needs to run
checkpoints less often but it does require the additional space on your disk.

Autovacuum must not be switched off because it ensures that the tables are
frequently analysed. If your machine has very little memory, you might consider
setting `autovacuum_max_workers = 1` and reduce `autovacuum_work_mem` even
further. This will reduce the amount of memory that autovacuum takes away from
the import process.

For the initial import, you should also set:

```
fsync = off
full_page_writes = off
```

Don't forget to reenable them after the initial import or you risk database
corruption!

For details see also the [Resource Consumption section in the Server
Configuration chapter](https://www.postgresql.org/docs/current/runtime-config-resource.html){:.extlink}
in the PostgreSQL documentation. Some information is also on the PostgreSQL
wiki: [Tuning Your PostgreSQL
Server](https://wiki.postgresql.org/wiki/Tuning_Your_PostgreSQL_Server){:.extlink}.

