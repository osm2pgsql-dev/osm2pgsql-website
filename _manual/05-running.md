---
chapter: 5
title: Running osm2pgsql
---

### Basic command line operation

Osm2pgsql can work in one of two ways: *Import only* or *Import and Update*.

If you are new to osm2pgsql we recommend you try the *import only* approach
first and use a small extract of the OSM data.
{: .note}

#### Import Only

OSM data is imported once into the database and will not change afterwards. If
you want to update the data, you have to delete it and do a full re-import.
This approach is used when updates aren't needed or only happen rarely. It is
also sometimes the only option, for instance when you are using extracts for
which change files are not available. This is also a possible approach if disk
space is tight, because you don't need to store data needed only for updates.

In this mode osm2pgsql is used with the `-c, --create` command line option.
This is also the default mode. The following command lines are equivalent:

```sh
osm2pgsql -c OSMFILE
osm2pgsql --create OSMFILE
osm2pgsql OSMFILE
```

In case the system doesn't have much main memory, you can add the `-s, --slim`
and `--drop` options. In this case less main memory is used, instead more data
is stored in the database. This makes the import much slower, though. See
chapter XXX for details on these options.

#### Import and Update

In this approach OSM data is imported once and afterwards updated more or less
regularly from OSM change files. OSM offers minutely, hourly, and daily change
files. This mode is used when regular updates are desired and change files are
available.

In this mode osm2pgsql is used the first time with the `-c, --create` command
line option (this is also the default mode) and, additionally the `-s, --slim`
options. The following command lines are equivalent:

```sh
osm2pgsql -c -s OSMFILE
osm2pgsql --create --slim OSMFILE
osm2pgsql --slim OSMFILE
```

For the update runs the `-a, --append` and `-s, --slim` options must be used.
The following command lines are equivalent:

```sh
osm2pgsql -a -s OSMFILE
osm2pgsql --append --slim OSMFILE
```

This approach needs more disk space for your database, because all the
information necessary for the updates must be stored somewhere.

#### Getting Help or Version

To get help or the program version run with the following options:

{% include_relative options/help-version.md %}

### Database Connection

In create and append mode you have to tell osm2pgsql which database to access.
If left unset, it will attempt to connect to the default database (usually the
username) using a unix domain socket. Most usage only requires setting
`-d, --database`.

{% include_relative options/database.md %}

*Version >= 1.4.0*{: .version} Instead of specifying a database name with the
`-d, --database` option you can also specify a connection string in the form of
a keyword/value connection string (something like `host=localhost port=5432
dbname=mydb`) or a URI
(`postgresql://[user[:password]@][netloc][:port][,...][/dbname][?param1=value1&...]`)
See the [PostgreSQL
documentation](https://www.postgresql.org/docs/current/libpq-connect.html#LIBPQ-CONNSTRING){:.extlink}
for details.

### Processing the OSM Data

<img alt="Diagram showing overview of osm2pgsql data processing from OSM data to Input, then Middle, then Output and the Database" src="{% link img/osm2pgsql-overview.svg %}" width="350" style="float: right;"/>

Osm2pgsql processing can be separated into multiple steps:

1. The *Input* reads the OSM data from the OSM file.
2. The *Middle* stores all objects and keeps track of relationships between
   objects.
3. The *Output* transforms the data and loads it into the database.

This is, of course, a somewhat simplified view, but it is enough to understand
the operation of the program. The following sections will describe each of the
steps in more detail.

### The Input

Depending on the operational mode your input file is either

* an OSM data file (in *create* mode), or
* an OSM change file (in *append* mode)

Usually osm2pgsql will autodetect the file format, but see the `-r,
--input-reader` option below. Osm2pgsql can not work with OSM history files.

See the [Appendix C](#getting-an-preparing-osm-data) for more information on
how to get and prepare OSM data for use with osm2pgsql.

{% include_relative options/input.md %}

Use of the `-b, --bbox` option is not recommended; it is a crude way of
limiting the amount of data loaded into the database and it will not always do
what you expect it to do, especially at the boundaries of the bounding box. If
you use it, choose a bounding box that is larger than your actual area of
interest. A better option is to create an extract of the data *before* using
osm2pgsql. See [Appendix C](#getting-an-preparing-osm-data) for options.

### The Middle

The middle keeps track of all OSM objects read by osm2pgsql and the
relationships between those objects. It knows, for instance, which ways are
used by which nodes, or which members a relation has. It also keeps track of
all node locations. This information is necessary to build way geometries from
way nodes and relation geometries from members and it is necessary when
updating data, because OSM change files only contain changes objects themselves
and not all the related objects needed for creating an objects geometry.

More details are in its own [chapter](#middle).

### The Outputs

Osm2pgsql imports OSM data into a PostgreSQL database. *How* it does this
is governed by the *output* (sometimes called a *backend*). Several outputs
for different use cases are available:

The *flex* Output *Version >= 1.3.0*{: .version}

: This is the most modern and most flexible output
  option. If you are starting a new project, use this output. Many future
  improvements to osm2pgsql will only be available in this output.

: Unlike all the other output options there is almost no limit to how the OSM
  data can be imported into the database. You can decide which OSM objects
  should be written to which columns in which database tables. And you can
  define any transformations to the data you need, for instance to unify a
  complex tagging schema into a simpler schema if that's enough for your use
  case.

: This output is described in detail in [its own chapter](#the-flex-output).

The *pgsql* Output

: The *pgsql* output is the original output and the one that most people who
  have been using osm2pgsql know about. Many tutorials you find on the Internet
  only describe this output. It is quite limited in how the data can be
  written to the database, but many setups still use it.

: This output comes in two "flavours": With the original "C transformation"
  and with the somewhat newer "Lua transformation" which allows some changes
  to the data before it is imported.

: This output is described in detail in [its own chapter](#the-pgsql-output).

The *gazetteer* Output

: The *gazetteer* output is a specialized output used for
  [Nominatim](https://nominatim.org/){:.extlink} only. There is no information
  in this manual about its use, see the Nominatim documentation for details.

The *multi* Output

: The *multi* output is deprecated, it will be removed in a future version of
  osm2pgsql. If you are using it, switch to the flex output as soon as possible.

The *null* Output

: The *null* output doesn't write the data anywhere. It is used for testing and
  benchmarking, not for normal operation. If `--slim` is used with the null
  output, the middle tables are still generated.

Here are the command line options pertaining to the outputs (see later chapters
for command line options only used for specific outputs):

{% include_relative options/output.md %}

