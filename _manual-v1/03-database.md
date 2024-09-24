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
* [PostGIS install page](https://postgis.net/documentation/getting_started/){:.extlink}

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

This manual assumes that you have 'peer' authentication configured when using
a local database. That means a local user may connect to the database with its
own username without needing to type a password. This authentication method
is the default on Debian/Ubuntu-based distributions. Never configure 'trust'
authentication where all local users can connect as any user to the database.

Any osm2pgsql setup will need a database to work on. You should create this as
PostgreSQL superuser and change ownership (with `--owner` option on the
`createdb` command or an `OWNER=` clause on the `CREATE DATABASE` SQL command)
to the user osm2pgsql is using. This way the database user that osm2pgsql uses
doesn't need database creation privileges.

Typical osm2pgsql setups need the `postgis` and `hstore` extensions to be
enabled in the database. To install these you need superuser privileges in the
database. Enable them (with `CREATE EXTENSION`) as PostgreSQL superuser on the
database that osm2pgsql is using before you run osm2pgsql.

Of course osm2pgsql needs to be able to create tables and write to the
database. Usually it can do this as owner of the database created for it.
Using the data, on the other hand, doesn't need any of those rights. So the
map rendering software you are using, for instance, usually only needs to
read the data. It is recommended that you run these as a different database
user, distinct from the database user osm2pgsql is using and only give that
user `SELECT` rights (with the `GRANT` command).

*Version >= 1.4.0*{: .version} If you are using a security scheme based on
database schemas in your database you can use the `--schema`, `--middle-schema`
and `--output-pgsql-schema` options and the `schema` table option in the flex
output, respectively, to tell osm2pgsql to load data into specific schemas. You
have to create those schemas and give them the correct rights before running
osm2pgsql.

Before PostgreSQL 15 all database users could add objects (such as tables and
indexes) to the *public* schema by default. Since PostgreSQL 15, by default,
only the owner of the database is allowed to do this. If osm2pgsql is using a
database user that's not the owner of the database, you have to grant this user
`CREATE` rights on the *public* schema of the database, or you have to
configure osm2pgsql to use a different schema as described above. See the
[PostgreSQL
manual](https://www.postgresql.org/docs/current/ddl-schemas.html#DDL-SCHEMAS-PRIV){:.extlink}
for the details.
{:.note}

### Encoding

OpenStreetMap data is from all around the world, it always uses UTF-8 encoding.
Osm2pgsql will write the data as is into the database, so it has to be in UTF-8
encoding, too.

On any modern system the default encoding for new databases should be UTF-8,
but to make sure, you can use the `-E UTF8` or `--encoding=UTF8` options when
creating the database for osm2pgsql with `createdb`.

### Tuning the PostgreSQL Server

Usual installs of the PostgreSQL server come with a default configuration that
is not well tuned for large databases. You should change these settings in
`postgresql.conf` and restart PostgreSQL before running osm2pgsql, otherwise
your system will be much slower than necessary.

The following settings are geared towards a system with 64GB RAM and a fast
SSD. The values in the second column are suggestions to provide a good starting
point for a typical setup, you might have to adjust them for your use case. The
value in the third column is the default set by PostgreSQL 15.

| Config Option                                                                                                                    | Proposed Value  | Pg 15 Default | Remark |
| -------------------------------------------------------------------------------------------------------------------------------- | --------------- | ------------- | ------ |
| [shared_buffers](https://www.postgresql.org/docs/current/runtime-config-resource.html#GUC-SHARED-BUFFERS)                        | 1GB             | 128MB         | Lower than typical PostgreSQL recommendations to give osm2pgsql priority to RAM. |
| [work_mem](https://www.postgresql.org/docs/current/runtime-config-resource.html#GUC-WORK-MEM)                                    | 50MB            | 4MB           | |
| [maintenance_work_mem](https://www.postgresql.org/docs/current/runtime-config-resource.html#GUC-MAINTENANCE-WORK-MEM)            | 10GB            | 64MB          | Improves `CREATE INDEX` |
| [autovacuum_work_mem](https://www.postgresql.org/docs/current/runtime-config-resource.html#GUC-AUTOVACUUM-WORK-MEM)              | 2GB             | -1            | -1 uses `maintenance_work_mem` |
| [wal_level](https://www.postgresql.org/docs/current/runtime-config-wal.html#GUC-WAL-LEVEL)                                       | minimal         | replica       | Reduces WAL activity if replication is not required during data load.  Must also set `max_wal_senders=0`. |
| [checkpoint_timeout](https://www.postgresql.org/docs/current/runtime-config-wal.html#GUC-CHECKPOINT-TIMEOUT)                     | 60min           | 5min          | Increasing this value reduces time-based checkpoints and increases time to restore from PITR |
| [max_wal_size](https://www.postgresql.org/docs/current/runtime-config-wal.html#GUC-MAX-WAL-SIZE)                                 | 10GB            | 1GB           | PostgreSQL > 9.4 only. For PostgreSQL <= 9.4 set `checkpoint_segments = 100` or higher. |
| [checkpoint_completion_target](https://www.postgresql.org/docs/current/runtime-config-wal.html#GUC-CHECKPOINT-COMPLETION-TARGET) | 0.9             | 0.9           | Spreads out checkpoint I/O of more of the `checkpoint_timeout` time, reducing spikes of disk activity |
| [max_wal_senders](https://www.postgresql.org/docs/current/runtime-config-replication.html#GUC-MAX-WAL-SENDERS)                   | 0               | 10            | See `wal_level` |
| [random_page_cost](https://www.postgresql.org/docs/current/runtime-config-query.html#GUC-RANDOM-PAGE-COST)                       | 1.0             | 4.0           | Assuming fast SSDs  |
{: .desc}

Here are the proposed settings for copy-and-paste into a config file:

```
shared_buffers = 1GB
work_mem = 50MB
maintenance_work_mem = 10GB
autovacuum_work_mem = 2GB
wal_level = minimal
checkpoint_timeout = 60min
max_wal_size = 10GB
checkpoint_completion_target = 0.9
max_wal_senders = 0
random_page_cost = 1.0
```

Increasing values for `max_wal_size` and `checkpoint_timeout` means that
PostgreSQL needs to run checkpoints less often but it can require additional
space on your disk and increases time required for Point in Time Recovery
(PITR) restores.  Monitor the PostgreSQL logs for warnings indicating
checkpoints are occurring too frequently: `HINT:  Consider increasing the
configuration parameter "max_wal_size".`

Autovacuum must not be switched off because it ensures that the tables are
frequently analysed. If your machine has very little memory, you might consider
setting `autovacuum_max_workers = 1` and reduce `autovacuum_work_mem` even
further. This will reduce the amount of memory that autovacuum takes away from
the import process.

For additional details see the [Server Configuration
chapter](https://www.postgresql.org/docs/current/runtime-config.html){:.extlink}
and [Populating a Database in the Performance Tips chapter](
https://www.postgresql.org/docs/current/populate.html){:.extlink} in the
PostgreSQL documentation.


### Expert Tuning

The suggestions in this section are *potentially dangerous* and are not
suitable for all environments. These settings can cause crashes and/or
corruption.  Corruption in a PostgreSQL instance can lead to a "bricked"
instance affecting all databases in the instance.

| Config Option                | Proposed Value  | Pg 15 Default | Remark |
| ---------------------------- | --------------- | ------------- | ------ |
| full_page_writes             | off             | on            |  Warning: Risks data corruption.  Set back to `on` after import. |
| fsync                        | off             | on            |  Warning: Risks data corruption.  Set back to `on` after import. |
{: .desc}

Additional information is on the PostgreSQL wiki: [Tuning Your PostgreSQL
Server](https://wiki.postgresql.org/wiki/Tuning_Your_PostgreSQL_Server){:.extlink}.
The section titled `synchronous_commit` contains important information to the
`synchronous_commit` and `fsync` settings.


### Number of Connections

*Version < 1.11.0*{:.version} Osm2pgsql will open multiple connections to the
database to speed up the import. The number of connections will depend on the
number of tables that are configured and the number of threads used. This can
easily exceed the `max_connections` limit defined in the [PostgreSQL
config](https://www.postgresql.org/docs/current/runtime-config-connection.html){:.extlink}.

(Currently there are about `3 + number of tables` connections used on import
and `3 + (1 + number of threads) * number of tables` connections used on
update. But this might change from version to version of osm2pgsql.)

If you are hit by this, your options are to

* increase the `max_connections` settings in your database configuration, or
* reduce the number of threads with the `--number-processes=THREADS` command
  line option of osm2pgsql.

*Version >= 1.11.0*{:.version} The number of connections does not depend on the
number of tables any more. The default number of connections allowed in
PostgreSQL should be enough for most use cases.

### Using a Template Database

Databases are actually created in PostgreSQL by copying a *template database*.
If you don't specify a database to copy from, the `template1` database is used.
PostgreSQL allows you to change `template1` or to create additional template
databases. If you create a lot of databases for use with osm2pgsql, you can do
initializations like `CREATE EXTENSTION postgis;` once in a template database
and they will be available in any database you create from them.

See the [PostgreSQL
manual](https://www.postgresql.org/docs/current/manage-ag-templatedbs.html){:.extlink}
for details.

### Database Maintainance

PostgreSQL tables and indexes that change a lot tend to get larger and larger
over time. This can happen even with autovacuum running. This does not affect
you if you just import OSM data, but when you update it regularly, you have
to keep this in mind. You might want to occasionally re-import the database
from scratch.

This is not something specific to osm2pgsql, but a general PostgreSQL issue.
If you are running a production database, you should inform yourself about
possible issues and what to do about them in the PostgreSQL literature.

