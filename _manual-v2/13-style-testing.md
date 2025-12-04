---
chapter: 13
title: Style Testing
---

osm2pgsql flex styles can become complex very quickly. Style testing can
help ensure that there are no bugs in the lua style and the database tables
contain the desired data. osm2pgsql comes with a osm2pgsql-test-style that
allows you to write integration tests using
[BDD-style testing](https://behave.readthedocs.io/en/latest/philosophy/){:.extlink}.


### Prerequisites

osm2pgsql-test-style uses [behave](https://behave.readthedocs.io){:.extlink}
under the hood together with [psycopg](https://www.psycopg.org/psycopg3/)
for connecting to the database. Make sure you have both Python packages installed.

On Debian/Ubuntu-like systems, this can be installed from apt:

    sudo apt-get install python3-behave python3-psycopg

On other systems, get it directly from pypi:

    virtualenv behave-env
    ./behave-env/bin/pip install behave psycopg

Don't forget to enter the virtual environment when behave is installed inside
one:

    . behave-env/bin/activate

You also need to have PostgreSQL installed and the user running tests needs
database rights to create, configure and delete databases. When on
Debian/Ubuntu-like systems you can also run the tests inside a
[pg_virtualenv](https://manpages.debian.org/testing/postgresql-common/pg_virtualenv.1.en.html).

### Getting Started

BDD tests are organised in _feature files_. Each file collects a set of
_scenarios_, each describing expected behaviour. Here is a simple feature
file:

```gherkin
Feature: Test import of trees

Scenario: An OSM tree node will be imported
    Given the OSM data
        """
        n12 Tnatural=tree,name=Old%20%Oak x34.6 y56.374
        n20 Thighway=bus_stop x34.66 y56.377
        """
    Given the lua style
        """
        local trees = osm2pgsql.define_node_table('trees', {
            { column = 'name', type = 'text' },
            { column = 'geom', type = 'point', srid=4326 })

        function osm2pgsql.process_node(object)
          if object.tags.natural == 'tree' then
            trees:insert{
              name = tags.name,
              geom = geom:as_point()
            }
          end
        end
        """
    When running osm2pgsql flex
    Then table trees contains exactly
        | node_id | name    |
        | 12      | Old Oak |
```


Each scenario consists of _steps_ of the _given_, _when_ or _then_ kind.
In osm2pgsql-test-style, the steps of a scenario contain:

* a description of the input data (_"Given the OSM data"_)
* instructions on how osm2pgsql should be executed
  (_"Given the lua style"_, _"When running osm2pgsql"_)
* the expected database content after osm2pgsql has been run
  (_"Then table trees contains exactly"_)

Save the feature definition above in a file `trees.feature` and then run
the tests with:

    osm2pgsql-test-style trees.feature

Or, if you prefer using pg_virtualenv, then run:

    pg_virtualenv osm2pgsql-test-style trees.feature

This is already it. osm2pgsql-test-style runs behave under the hood which
will now for each scenario:

* set up a new PostgreSQL test database
* run osm2pgsql using the given input and the test database
* execute the necessary SQL commands to retrieve the database content and
  check that it corresponds to the expected output

To learn more about the feature file syntax, read about the
[Gherkin Feature Testing Language](https://behave.readthedocs.io/en/latest/gherkin/#docid-gherkiGn){:.extlink}
in the behave documentation. The remainder of the chapter assumes that
you understand the basic syntax and explains the different step definitions
that are available for testing your styles.

### Defining Data Input

Test data for the test cases can either be placed in external files or
defined inline as part of the scenario definition.

#### Using external test files

```gherkin
Given the input file '<file name>'
```

Use this step to define an external test file. You can use any file format
here that will be understood by osm2pgsql. The test file will be searched
relative to the feature file in which the scenario is defined. If you have
a separate directory containing all your test data, then you can use the
`--test-data-dir` command line option and osm2pgsql will search the test
data relative to the given directory.

A test can only be run against a single input file. If you define the
step for a second time in the same scenario, the new input file will be used
instead of the original one.

#### Defining input data inline

```gherkin
Given the OSM data
    """
    n1 Tamenity=cafe x34.6 y-56.1222
    w1 Tbuilding=yes Nn100,n102,n103,n100
    """
```

You can also include the input data directly in your scenario. The data needs
to be given in [OPL file format](https://osmcode.org/opl-file-format/){:.extlink}.
OPL is a simple text format for OSM data. Each line defines the property
of exactly one node, way or relation.

Using the step multiple times will add to the data already defined.
osm2pgsql-test-style will sort the data as required by osm2pgsql before giving
it to osm2pgsql.

Defining the latitude and longitude of each node can be a bit tedious. If you
don't really care where a node lands, for example when testing tag processing
only, you can just omit the `x` and `y` values and osm2pgsql-test-style will
assign a random value before giving the input data to osm2pgsql. For more
complex geometries, you can define a node grid

#### Node grids

```gherkin
Given the grid
    | 1 |   | 2 |    |
    |   |   |   | 10 |
    | 3 |   | 4 |    |
```

The grid step allows you to define the location of nodes relative to each
other. This makes it easy to visually express situations like "I have a
building with a node inside" or "There are two roads intersecting with
each other". A node grid is defined as a simple table where each cell
can contain a single number, the ID of the node to put there.

All nodes that you define in the grid, will be directly added to the
input OSM data as untagged nodes. That way, it won't be necessary to define
them later explicitly in your input data. If you do want to add tags or
extra information to one of the nodes, then simply add the OPL definition
of the node with the extra data. Leave out the x/y coordinates. They will
be automatically added from the information from the grid.

The origin of the grid is defined to be in the lower left corner. It is set
to 20.0, 20.0 by default. The default distance between cells is 0.01. You
can change the origin and step width like that:

```gherkin
Given the 0.05 grid with origin -4.34 69.1
    | 1 |   | 2 |
```

Grids are not accumulative. Using the grid step another time in the same
scenario will replace the grid data completely.

### Defining Style Files

The other important ingredient for an osm2pgsql run is the style file. Like
with the data, you may refer to an external style file for your test or
define the style code inline.

#### Using external style files

```gherkin
Given the style file '<file name>'
```

Use this step to set the style file option to the given file. If the
`--style-data-dir` is given on the command line, then the file will be
searched relative to this directory. Without a style directory present,
the test data directory is used. If that is not set either, the style file
will be searched relative to the feature file.

If your style requires additional modules, set `LUA_PATH` environment
variable accordingly. If it needs a custom themepark style, set the
environment variable `THEMEPARK_PATH`.

Using the step again in a scenario will change the style file used.

#### Defining lua style code inline

```gherkin
Given the lua style
    """
    <your code>
    """
```

This lua-style step allows to define the style code directly in the scenario.
As with external code, you may include further lua modules here but need to
make sure they can be found by setting the appropriate `LUA_PATH`
environment variable.

### Running osm2pgsql

```gherkin
When running osm2pgsql <output>
```

This line executes osm2pgsql with the previously configured data. '<output>'
is a shortcut for what you would put in the '-O' parameter of osm2pgsql,
one of 'flex', 'pgsql' or 'null'. The step contains a short-cut here because
the parameter is so frequently needed.

Next to the output parameter '-O', osm2pgsql-test-style also automatically
sets the name of the style file, the database name and the input data.

If you want to add more parameters for the execution, you can add a table
to the step like this:

```gherkin
When running osm2pgsql flex with parameters
   | --slim | --create |
   | -E     | 4326     |
```

Tha parameters will be added in the usual reading order: left to right and
top to bottom.

#### Checking the output

You can check that osm2pgsql has run successfully with the step:

```gherkin
Then execution is successful
```

However, in most cases you can skip this step. All steps that check the
database content implicitly check that osm2pgsql has been run successfully.

You can also check that osm2pgsql failed:

```gherkin
Then execution fails with return code <N>
```

If you don't care about the exact return code, the "with return code" part
can be left out.

To inspect the output of osm2pgsql more closely, use:

```gherkin
Then <error|standard> output contains
    """
    some message
    another message
    """
```

The step is successful if each line of the step text is contained somewhere
in the error message or standard output of osm2pgsql. Be aware that order
doesn't matter. Do not use the step to ensure that code is executed in a
fixed order.

### Checking Database Contents

The final set of steps can be used to check that database content is as
expected. All these steps will only run, when osm2pgsql has been
executed without any errors.

#### Table presence

To check if one or more tables have been created, use:

```gherkin
Then there are tables <table1>,<table2>,...
```

Conversely, to make sure that a table is absent:

```gherkin
Then there are no tables <table1>,<table2>,...
```

You will rarely need to do this explicitly. Instead you can directly proceed
to checking the content of the table. This will implicitly check that the
table exists.


#### Checking the content of a table

To compare the content of a table, use the step:

```gherkin
Then table <tablename> contains
    | col_foo   | col_bar |
    | something | 3.41    |
```

The heading of the table selects the columns of the table that should be
compared against the expected context. You may use any SQL expression here
that can be used for columns in a SELECT statement as long as it doesn't
contain an exclamation mark or a pipe character.

The rows of the table contain the expected content. Each row must be present
in the table at least once. To check a cell for a NULL value, use the
literal `NULL`.

You can also require that the table contains
only the content given by adding the word 'exactly' to your step:

```gherkin
Then table <tablename> contains exactly
    | id | name |
    | 1  | Lonely Node |
```

This is particularly useful, when you want to ensure that some content wasn't 
entered into the table.

You can also explicitly formulate a step stating that a given row doesn't
appear in the table:

```gherkin
Then table <tablename> doesn't contain
    | id | name |
    | 1  | Lonely Node |
```

Use this construct sparingly. Negative tests like this will not fail when
you have a typo in them or the data changes in unexpected ways. A wrongly
typed value is still simply a missing row in the table.

#### Checking aggregated content

You can use the containment check against aggregate SQL functions to
reason over your entire table:

```gherkin
Then table <tablename> contains
    | count(*) | every(name is not null) |
    | 144      | True                    |
```

Once again be warned to use aggregate testing as little as possible. It is
difficult in case of an error to find the exact culprit.

For convenience there is a shortcut step to check for the number of rows
in a table:

```gherkin
Then table <tablename> has <N> rows
```

This is the same as checking the contents of `count(*)`.

#### Creating complex content checks using SQL statements

For many cases, a simple content check of the table will be sufficient but
there are some situations where more complex SQL queries are needed to
properly describe the state of your database. For example, you might want
to join multiple tables or group the content of your tables.

To check the results of a complex SQL query, you need to first define the
SQL statement like this:

```gherkin
Given the SQL statment query-table-grouped-by-id
    """
    SELECT osm_id, count(*)
    FROM simple_polygon_table
    GROUP BY osm_id
    """
```

Then you can run the SQL and check the results of the query in a separate step:

```gherkin
Then statement query-table-grouped-by-id returns
    | osm_id | count |
    | 23     | 1     |
    | 42     | 4     |
```

The table describing the expected rows works exactly like the one for
checking for table contents. That means you can check for column contents
as well as SQL expressions and aggregations.

This statement check can be used multiple times. In particular, you can add
a SQL statement definition to the
[Background section](https://behave.readthedocs.io/en/latest/gherkin/#background){:.extlink}
of your feature file. This way you can define arbitrarily complex custom checks
to be used with a simple one-liner in the different scenarios of the file.

#### Value matchers

By default, cell content is compared as follows:

* If the value returned by PostgreSQL is a floating-point or fixed-point
  number, then the expected value is converted to float and compared with
  a small tolerance.
* In all other cases, the value returned is converted into a string using
  Python's [str()](https://docs.python.org/3/library/stdtypes.html#str){:.extlink}
  function and expected to match the cell content exactly.

You can change the comparison algorithm by adding a value matcher to the
column heading. To do so, add an exclamation mark after the SQL expression
in the header followed by the matcher expression.

##### !i - case-insensitive match

```gherkin
Then table foo contains
    | name!i |
    | abc    |
```

The `i` matcher converts the PostgreSQL result into a string and compares
this with the expected value in an case-insensitive way.

##### !re - regular-expression matching

```gherkin
Then table foo contains
    | name!re       |
    | .*[A-Z][0-9]* |
```

The `re` matcher converts the PostgreSQL result into a string and
then uses the expected value as a regular expression to match against.
The match will only be successful if the result string matches in its full
length.

##### !substr - partial matching

```gherkin
Then table foo contains
    | name!substr   |
    | Mid           |
```

The `substr` matcher converts the PostgreSQL result into a string and
then checks that the expected value is contained in the result string.
Matching is case-sensitive.

##### !json - matching json expressions

```gherkin
Then table foo contains
    | names!json                         |
    | {"de": "Deutsch", "en": "English"} |
```

The `json` matcher can be used to match hstore and json values
without requiring a specific order of the elements in the dictionary.
The expected value must be valid json.
The result must match exactly except for order of the elements in
json objects.

##### !geo - matching geometries

You can test for geometry correctness by converting results to WKT using
PostGIS' `AsText()` function and stating the expected WKT in the table.
This approach has two disadvantages: matching would be against exact values
not taking into account rounding issues for floats and WKT is rather
verbose making result tables rather large.

The `geo` matcher allows to compare geometries against a compact WKT-like
format which also allows to reference fields from a previously defined
node grid.

A _point_ in the geo format can either be a pair of floats separated by
spaces, just like in the WKT format. Or a point can be a single integer,
in which case it refers to the coordinates of a node in the node grid.

The follow tests are all equivalent:

```gherkin
Given the 0.1 grid with origin 10.4 -34.5
    | 3 |
Then table foo contains
    | ST_AsText(centroid) | centroid!geo | centroid!geo |
    | POINT(10.4 -34.5)   | 10.4 -34.5   | 3            |
```

A _linestring_ is a comma-separated list of points. Again, the points
may be expressed as coordinates or node references.

```gherkin
Given the 0.1 grid with origin 1.0 1.0
    | 3 |  | 4 |
Then table foo contains
    | way!geo          | way!geo |
    | 1.0 1.0, 1.2 1.0 | 3, 4    |
```

A _polygon_ is written as a comma-separated list of points in round brackets.
As with WKT, the first and last point of the list must be exactly the same.
If the polygon has inner rings, then add multiple bracket terms, separated
by comma.

```gherkin
Given the grid
    | 1 |    |    | 2 |
    |   | 10 | 11 |   |
    |   | 13 | 12 |   |
    | 4 |    |    | 3 |
Then table foo contains
    | poly!geo                     |
    | (1,2,3,4,1),(10,11,12,13,10) |
```

Polygons are matched with a bit of tolerance: winding order may be different
as well as the point on which the ring begins. This can come in handy when
the imported data is further transformed with PostGIS functions. The order
in which they produce the coordinates are not always consistent.

To create a _multipoint_, _multilinestring_ or _multipolygon_ join the
elements of the multi geometry with semicolon and surround them by
square brackets.

```gherkin
Given the 0.1 grid with origin 1.0 1.0
    | 3 |  | 4 |
    |   |  | 10|
Then table foo contains
    | multiline!geo |
    | [ 3, 4; 4, 10 ] |
```

A _geometrycollection_ also joins its elements with semicolon but is
surrounded by curly brackets.

```gherkin
Given the 0.1 grid with origin 1.0 1.0
    | 3 |  | 4 |
    |   |  | 10|
Then table foo contains
    | collection!geo |
    | { 3, 4; 10 } |
```

##### !~ - approximate float matching

Floating-point and decimal numbers are already matched with a certain
tolerance. If you need more control over the tolerance, then use the
`~` matcher followed by the required tolerance. If the tolerance
is a raw number, then it is considered an absolute tolerance: the result
may not deviate more than the given value from the expected value.

```gherkin
Then table foo contains
    | fuzzy_float!~0.1 |
    | 3.0              |
```

If the tolerance value is a percent value, then it is computed relative to
the expected value. This can be useful when expected values have a vastly
different order of magnitude.

```gherkin
Then table foo contains
    | fuzzy_float!~0.1% |
    | 3.0               |
    | 1000000.0         |
```

##### !: - advanced formatting

The ':' matcher allows to transform the returned value in any way
that is supported by the
[Python formatter language](https://docs.python.org/3/library/string.html#format-specification-mini-language)

```gherkin
Then table foo contains
    | hexhex!:X |
    | 14EB34FF  |
```


### Database Manipulation

If your style expects to run under a specific schema, you can cause a
schema to be created in the test database with:

```gherkin
Given the database schema <schemaname>
```

To remove an existing table, use:

```gherkin
When deleting table <tablename>
```

### Advanced Step Usage

osm2pgsql-test-style defines a few additional steps, which are mostly used
for its internal testing. These steps may be changed or removed without
advance warning.

#### Testing osm2pgsql-replication

These steps are mainly used to test the osm2pgsql-replication script itself.
You won't need them to test user-side lua scripts. If you want to test
updating of your database, simply execute osm2pgsql twice in your scenario:
first with `-c` to fill up the database with test data and then with `-a`
to test the actual update.
{:.note}

A fake replication service for the osm2pgsql-replication script can be
set up with:

```gherkin
Given the replication service at <url>
    | sequence | timestamp            |
    | 9999999  | 2013-08-03T19:00:02Z |
```

This creates a mock which responds to replication requests for the given
URL. Optionally some sequences can be defined with a timestamp. The mock
will return a state file with the configured timestamp.

To mock further URL calls, use:

```gherkin
Given the URL <full URL>
    """
    some content
    """
```

Only after a replication service has been chosen, osm2pgsql replication
can be executed with:

```gherkin
When running osm2pgsql-replication
```

The osm2pgsql-replication is always expected to reside in the same location
as the osm2pgsql-test-style script. If it cannot be found, then replication
tests will be skipped.

Parameters may be supplied in the same way as when osm2pgsql is run. You
may also use the steps for checking successful execution and matching standard
output and error afterwards.

### osm2pgsql-test-style Parameters

Use `osm2pgsql-test-style -h` to get an overview of the available runtime
parameters. This section describes the most frequently used ones.

#### Changing the osm2pgsql Binary

By default the style tester will run the `osm2pgsql` binary found in the
current path. You can set an explicit binary using the `--osm2pgsql-binary`
parameter.

#### Search Paths for Test Data

Additional test data like lua files or input data is expected to reside next
to the feature file. If you prefer to keep test data in a separate place,
then set the test data directory with `--test-data-dir`.

If the lua styles under test are in another directory then the feature files
or test data, set a separate search directory for them with `--style-data-dir`.
Note that the style files will still be searched in the test directory as
well, when they are not found in the style directory.

Note that osm2pgsql inherit any environment variables you may have set.
That means that you can hand in other information like `LUA_PATH` and
`THEMEPARK_PATH` as usual. Setting PostgreSQL environment variables to
configure the database connection will also work except for the database name.

#### Keeping Test Databases around for Debugging

The style tester creates a separate database for each test and cleans it up
immediately after the test is done. If you want the database to be kept
around, for example when you are debugging a test failure, use the
`--keep-test-db` parameter. Note that the database is dropped latest,
when the next test is executed. Thus there is no danger of an infinite
number of databases accumulating in your system when using this parameter.

When running under pg_virtualenv, don't forget to keep the virtual environment
as well. You can use the handy `-s` switch:

```sh
pg_virtualenv -s osm2pgsql-test-style --keep-test-db trees.feature:71
```

It drops you into a shell when the behave test fails, where you can use
psql to look at the database. Or start a shell in the virtual environment
with `pg_virtualenv bash` and run behave from there.

### Examples

osm2pgsql uses the style tester for all its integration tests. You can
find a wide range of examples of feature files in the test directory
[tests/bdd/flex](https://github.com/osm2pgsql-dev/osm2pgsql/tree/master/tests/bdd/flex).

