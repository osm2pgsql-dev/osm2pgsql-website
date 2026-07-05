---
layout: doc
title: "Manual Page: osm2pgsql-test-style(1)"
---

# Version 2.3.1

<a href="#NAME">NAME</a><br>
<a href="#SYNOPSIS">SYNOPSIS</a><br>
<a href="#DESCRIPTION">DESCRIPTION</a><br>
<a href="#OPTIONS">OPTIONS</a><br>
<a href="#SEE ALSO">SEE ALSO</a><br>

<hr>


<h2>NAME
<a name="NAME"></a>
</h2>



<p style="margin-left:9%; margin-top: 1em">osm2pgsql-test-style
- osm2pgsql style testing</p>

<h2>SYNOPSIS
<a name="SYNOPSIS"></a>
</h2>



<p style="margin-left:9%; margin-top: 1em"><b>osm2pgsql-test-style</b>
[-h] [--osm2pgsql-binary OSM2PGSQL_BINARY] [--test-data-dir
TEST_DATA_DIR] [--style-data-dir STYLE_DATA_DIR] [--test-db
TEST_DB] [--template-test-db TEMPLATE_TEST_DB]
[--keep-test-db] [--test-tablespace {yes,no,auto}]
[--test-proj {yes,no,auto}] features [features ...]</p>

<h2>DESCRIPTION
<a name="DESCRIPTION"></a>
</h2>


<p style="margin-left:9%; margin-top: 1em">Test runner for
BDD-style integration tests.</p>

<p style="margin-left:9%; margin-top: 1em">See osm2pgsql
manual for more information on osm2pgsql style testing.
<b><br>
features</b></p>

<p style="margin-left:18%;">Feature files or paths</p>

<h2>OPTIONS
<a name="OPTIONS"></a>
</h2>



<p style="margin-left:9%; margin-top: 1em"><b>--osm2pgsql-binary</b>
<i>OSM2PGSQL_BINARY</i></p>

<p style="margin-left:18%;">osm2pgsql binary to use for
testing (default: osm2pgsql)</p>

<p style="margin-left:9%;"><b>--test-data-dir</b>
<i>TEST_DATA_DIR</i></p>

<p style="margin-left:18%;">(optional) directory to search
for test data</p>

<p style="margin-left:9%;"><b>--style-data-dir</b>
<i>STYLE_DATA_DIR</i></p>

<p style="margin-left:18%;">(optional) directory to search
for style files</p>

<p style="margin-left:9%;"><b>--test-db</b>
<i>TEST_DB</i></p>

<p style="margin-left:18%;">Name of database to use for
testing (default: osm2pgsql-test)</p>

<p style="margin-left:9%;"><b>--template-test-db</b>
<i>TEMPLATE_TEST_DB</i></p>

<p style="margin-left:18%;">Name of database to use for
creating the template db (default:
osm2pgsql-test-template)</p>

<p style="margin-left:9%;"><b>--keep-test-db</b></p>

<p style="margin-left:18%;">Keep the test database around
after tests are done</p>

<p style="margin-left:9%;"><b>--test-tablespace</b>
<i>{yes,no,auto}</i></p>

<p style="margin-left:18%;">Include tests requiring a
tablespace</p>

<p style="margin-left:9%;"><b>--test-proj</b>
<i>{yes,no,auto}</i></p>

<p style="margin-left:18%;">Include tests requiring the
proj library</p>

<h2>SEE ALSO
<a name="SEE ALSO"></a>
</h2>


<p style="margin-left:9%; margin-top: 1em">* osm2pgsql
website (https://osm2pgsql.org) * osm2pgsql manual
(https://osm2pgsql.org/doc/manual.html)</p>
