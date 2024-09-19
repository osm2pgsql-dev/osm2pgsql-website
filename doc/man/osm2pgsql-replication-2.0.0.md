---
layout: doc
title: "Manual Page: osm2pgsql-replication(1)"
---

## Version 2.0.0

<a href="#NAME">NAME</a><br>
<a href="#SYNOPSIS">SYNOPSIS</a><br>
<a href="#DESCRIPTION">DESCRIPTION</a><br>
<a href="#OPTIONS">OPTIONS</a><br>
<a href="#OPTIONS &rsquo;osm2pgsql-replication init&rsquo;">OPTIONS &rsquo;osm2pgsql-replication init&rsquo;</a><br>
<a href="#OPTIONS &rsquo;osm2pgsql-replication update&rsquo;">OPTIONS &rsquo;osm2pgsql-replication update&rsquo;</a><br>
<a href="#OPTIONS &rsquo;osm2pgsql-replication status&rsquo;">OPTIONS &rsquo;osm2pgsql-replication status&rsquo;</a><br>
<a href="#SEE ALSO">SEE ALSO</a><br>

<hr>


<h2>NAME
<a name="NAME"></a>
</h2>



<p style="margin-left:11%; margin-top: 1em">osm2pgsql-replication
- osm2pgsql database updater</p>

<h2>SYNOPSIS
<a name="SYNOPSIS"></a>
</h2>



<p style="margin-left:11%; margin-top: 1em"><b>osm2pgsql-replication</b>
[-h] {init,update,status} ...</p>

<h2>DESCRIPTION
<a name="DESCRIPTION"></a>
</h2>


<p style="margin-left:11%; margin-top: 1em">Update an
osm2pgsql database with changes from a OSM replication
server.</p>

<p style="margin-left:11%; margin-top: 1em">This tool
initialises the updating process by looking at the import
file <br>
or the newest object in the database. The state is then
saved in a table <br>
in the database. Subsequent runs download newly available
data and apply <br>
it to the database.</p>

<p style="margin-left:11%; margin-top: 1em">See the help of
the &rsquo;init&rsquo; and &rsquo;update&rsquo; command for
more information on <br>
how to use osm2pgsql-replication.</p>

<h2>OPTIONS
<a name="OPTIONS"></a>
</h2>



<p style="margin-left:11%; margin-top: 1em"><b>Sub-commands
<br>
osm2pgsql-replication</b> <i>init</i></p>

<p style="margin-left:22%;">Initialise the replication
process.</p>

<p style="margin-left:11%;"><b>osm2pgsql-replication</b>
<i>update</i></p>

<p style="margin-left:22%;">Download newly available data
and apply it to the database.</p>

<p style="margin-left:11%;"><b>osm2pgsql-replication</b>
<i>status</i></p>

<p style="margin-left:22%;">Print information about the
current replication status, optionally as JSON.</p>

<h2>OPTIONS &rsquo;osm2pgsql-replication init&rsquo;
<a name="OPTIONS &rsquo;osm2pgsql-replication init&rsquo;"></a>
</h2>


<p style="margin-left:11%; margin-top: 1em">usage:
osm2pgsql-replication init [-h] [-q] [-v] [-d DB] [-U NAME]
[-H HOST] <br>
[-P PORT] [-p PREFIX] <br>
[--middle-schema SCHEMA] [--schema SCHEMA] <br>
[--osm-file FILE | --server URL] <br>
[--start-at TIME]</p>

<p style="margin-left:11%; margin-top: 1em">Initialise the
replication process.</p>

<p style="margin-left:11%; margin-top: 1em">This function
sets the replication service to use and determines from <br>
which date to apply updates. You must call this function at
least once <br>
to set up the replication process. It can safely be called
again later <br>
to change the replication servers or to roll back the update
process and <br>
reapply updates.</p>

<p style="margin-left:11%; margin-top: 1em">There are
different methods available for initialisation. When no <br>
additional parameters are given, the data is initialised
from the data <br>
in the database. If the data was imported from a file with
replication <br>
information and the properties table is available (for
osm2pgsql &gt;= 1.9) <br>
then the replication from the file is used. Otherwise the
minutely <br>
update service from openstreetmap.org is used as the default
replication <br>
service. The start date is either taken from the database
timestamp <br>
(for osm2pgsql &gt;= 1.9) or determined from the newest way
in the database <br>
by querying the OSM API about its creation date.</p>

<p style="margin-left:11%; margin-top: 1em">The replication
service can be changed with the &rsquo;--server&rsquo;
parameter. <br>
To use a different start date, add &rsquo;--start-at&rsquo;
with an absolute <br>
ISO timestamp (e.g. 2007-08-20T12:21:53Z). When the program
determines the <br>
start date from the database timestamp or way creation date,
then it <br>
subtracts another 3 hours by default to ensure that all new
changes are <br>
available. To change this rollback period, use
&rsquo;--start-at&rsquo; with the <br>
number of minutes to rollback. This rollback mode can also
be used to <br>
force initialisation to use the database date and ignore the
date <br>
from the replication information in the file.</p>

<p style="margin-left:11%; margin-top: 1em">The
initialisation process can also use replication information
from <br>
an OSM file directly and ignore all other date information.
<br>
Use the command &rsquo;osm2pgsql-replication --osm-file
&lt;filename&gt;&rsquo; for this. <b><br>
-q</b>, <b>--quiet</b></p>

<p style="margin-left:22%;">Print only error messages</p>

<p style="margin-left:11%;"><b>-v</b>, <b>--verbose</b></p>

<p style="margin-left:22%;">Increase verboseness of
output</p>

<p style="margin-left:11%;"><b>-d</b> DB, <b>--database</b>
DB</p>

<p style="margin-left:22%;">Name of PostgreSQL database to
connect to or conninfo string</p>

<p style="margin-left:11%;"><b>-U</b> NAME,
<b>--username</b> NAME</p>

<p style="margin-left:22%;">PostgreSQL user name</p>

<p style="margin-left:11%;"><b>-H</b> HOST, <b>--host</b>
HOST</p>

<p style="margin-left:22%;">Database server host name or
socket location</p>

<p style="margin-left:11%;"><b>-P</b> PORT, <b>--port</b>
PORT</p>

<p style="margin-left:22%;">Database server port</p>

<p style="margin-left:11%;"><b>-p</b> PREFIX,
<b>--prefix</b> PREFIX</p>

<p style="margin-left:22%;">Prefix for table names (default
&rsquo;planet_osm&rsquo;)</p>

<p style="margin-left:11%;"><b>--middle-schema</b>
SCHEMA</p>

<p style="margin-left:22%;">Name of the schema to store the
table for the replication state in</p>

<p style="margin-left:11%;"><b>--schema</b> SCHEMA</p>

<p style="margin-left:22%;">Name of the schema for the
database</p>

<p style="margin-left:11%;"><b>--osm-file</b> FILE</p>

<p style="margin-left:22%;">Get replication information
from the given file.</p>

<p style="margin-left:11%;"><b>--server</b> URL</p>

<p style="margin-left:22%;">Use replication server at the
given URL</p>

<p style="margin-left:11%;"><b>--start-at</b> TIME</p>

<p style="margin-left:22%;">Time when to start replication.
When an absolute timestamp (in ISO format) is given, it will
be used. If a number is given, then replication starts the
number of minutes before the known date of the database.</p>

<h2>OPTIONS &rsquo;osm2pgsql-replication update&rsquo;
<a name="OPTIONS &rsquo;osm2pgsql-replication update&rsquo;"></a>
</h2>


<p style="margin-left:11%; margin-top: 1em">usage:
osm2pgsql-replication update update [options] [-- param
[param ...]]</p>

<p style="margin-left:11%; margin-top: 1em">Download newly
available data and apply it to the database.</p>

<p style="margin-left:11%; margin-top: 1em">The data is
downloaded in chunks of &rsquo;--max-diff-size&rsquo; MB.
Each chunk is <br>
saved in a temporary file and imported with osm2pgsql from
there. The <br>
temporary file is normally deleted afterwards unless you
state an explicit <br>
location with &rsquo;--diff-file&rsquo;. Once the database
is up to date with the <br>
replication source, the update process exits with 0.</p>

<p style="margin-left:11%; margin-top: 1em">Any additional
arguments to osm2pgsql need to be given after
&rsquo;--&rsquo;. Database <br>
and the prefix parameter are handed through to osm2pgsql.
They do not need <br>
to be repeated. &rsquo;--append&rsquo; and
&rsquo;--slim&rsquo; will always be added as well.</p>

<p style="margin-left:11%; margin-top: 1em">Use the
&rsquo;--post-processing&rsquo; parameter to execute a
script after osm2pgsql has <br>
run successfully. If the updates consists of multiple runs
because the <br>
maximum size of downloaded data was reached, then the script
is executed <br>
each time that osm2pgsql has run. When the post-processing
fails, then <br>
the entire update run is considered a failure and the
replication information <br>
is not updated. That means that when &rsquo;update&rsquo; is
run the next time it will <br>
recommence with downloading the diffs again and reapplying
them to the <br>
database. This is usually safe. The script receives two
parameters: <br>
the sequence ID and timestamp of the last successful run.
The timestamp <br>
may be missing in the rare case that the replication service
stops responding <br>
after the updates have been downloaded.</p>

<table width="100%" border="0" rules="none" frame="void"
       cellspacing="0" cellpadding="0">
<tr valign="top" align="left">
<td width="11%"></td>
<td width="7%">


<p><b>param</b></p></td>
<td width="4%"></td>
<td width="63%">


<p>Extra parameters to hand in to osm2pgsql.</p></td>
<td width="15%">
</td></tr>
</table>

<p style="margin-left:11%;"><b>--diff-file</b> FILE</p>

<p style="margin-left:22%;">File to save changes before
they are applied to osm2pgsql.</p>

<p style="margin-left:11%;"><b>--max-diff-size</b>
<i>MAX_DIFF_SIZE</i></p>

<p style="margin-left:22%;">Maximum data to load in MB
(default: 500MB)</p>

<p style="margin-left:11%;"><b>--osm2pgsql-cmd</b>
<i>OSM2PGSQL_CMD</i></p>

<p style="margin-left:22%;">Path to osm2pgsql command</p>

<table width="100%" border="0" rules="none" frame="void"
       cellspacing="0" cellpadding="0">
<tr valign="top" align="left">
<td width="11%"></td>
<td width="9%">


<p><b>--once</b></p></td>
<td width="2%"></td>
<td width="78%">


<p>Run updates only once, even when more data is
available.</p> </td></tr>
</table>

<p style="margin-left:11%;"><b>--post-processing</b>
SCRIPT</p>

<p style="margin-left:22%;">Post-processing script to run
after each execution of osm2pgsql.</p>

<p style="margin-left:11%;"><b>-q</b>, <b>--quiet</b></p>

<p style="margin-left:22%;">Print only error messages</p>

<p style="margin-left:11%;"><b>-v</b>, <b>--verbose</b></p>

<p style="margin-left:22%;">Increase verboseness of
output</p>

<p style="margin-left:11%;"><b>-d</b> DB, <b>--database</b>
DB</p>

<p style="margin-left:22%;">Name of PostgreSQL database to
connect to or conninfo string</p>

<p style="margin-left:11%;"><b>-U</b> NAME,
<b>--username</b> NAME</p>

<p style="margin-left:22%;">PostgreSQL user name</p>

<p style="margin-left:11%;"><b>-H</b> HOST, <b>--host</b>
HOST</p>

<p style="margin-left:22%;">Database server host name or
socket location</p>

<p style="margin-left:11%;"><b>-P</b> PORT, <b>--port</b>
PORT</p>

<p style="margin-left:22%;">Database server port</p>

<p style="margin-left:11%;"><b>-p</b> PREFIX,
<b>--prefix</b> PREFIX</p>

<p style="margin-left:22%;">Prefix for table names (default
&rsquo;planet_osm&rsquo;)</p>

<p style="margin-left:11%;"><b>--middle-schema</b>
SCHEMA</p>

<p style="margin-left:22%;">Name of the schema to store the
table for the replication state in</p>

<p style="margin-left:11%;"><b>--schema</b> SCHEMA</p>

<p style="margin-left:22%;">Name of the schema for the
database</p>

<h2>OPTIONS &rsquo;osm2pgsql-replication status&rsquo;
<a name="OPTIONS &rsquo;osm2pgsql-replication status&rsquo;"></a>
</h2>


<p style="margin-left:11%; margin-top: 1em">usage:
osm2pgsql-replication status [-h] [-q] [-v] [-d DB] [-U
NAME] [-H HOST] <br>
[-P PORT] [-p PREFIX] <br>
[--middle-schema SCHEMA] [--schema SCHEMA] <br>
[--json]</p>

<p style="margin-left:11%; margin-top: 1em">Print
information about the current replication status, optionally
as JSON.</p>

<p style="margin-left:11%; margin-top: 1em">Sample
output:</p>

<p style="margin-left:11%; margin-top: 1em">2021-08-17
15:20:28 [INFO]: Using replication service
&rsquo;https://planet.openstreetmap.org/replication/minute&rsquo;,
which is at sequence 4675115 ( 2021-08-17T13:19:43Z ) <br>
2021-08-17 15:20:28 [INFO]: Replication server&rsquo;s most
recent data is &lt;1 minute old <br>
2021-08-17 15:20:28 [INFO]: Local database is 8288 sequences
behind the server, i.e. 5 day(s) 20 hour(s) 58 minute(s)
<br>
2021-08-17 15:20:28 [INFO]: Local database&rsquo;s most
recent data is 5 day(s) 20 hour(s) 59 minute(s) old</p>

<p style="margin-left:11%; margin-top: 1em">With the
&rsquo;--json&rsquo; option, the status is printed as a json
object.</p>

<p style="margin-left:11%; margin-top: 1em">{ <br>
&quot;server&quot;: { <br>
&quot;base_url&quot;:
&quot;https://planet.openstreetmap.org/replication/minute&quot;,
<br>
&quot;sequence&quot;: 4675116, <br>
&quot;timestamp&quot;: &quot;2021-08-17T13:20:43Z&quot;,
<br>
&quot;age_sec&quot;: 27 <br>
}, <br>
&quot;local&quot;: { <br>
&quot;sequence&quot;: 4666827, <br>
&quot;timestamp&quot;: &quot;2021-08-11T16:21:09Z&quot;,
<br>
&quot;age_sec&quot;: 507601 <br>
}, <br>
&quot;status&quot;: 0 <br>
}</p>


<p style="margin-left:11%; margin-top: 1em">&rsquo;status&rsquo;
is 0 if there were no problems getting the status. 1 &amp; 2
for <br>
improperly set up replication. 3 for network issues. If
status &acirc;&nbsp; 0, then <br>
the &rsquo;error&rsquo; key is an error message (as string).
&rsquo;status&rsquo; is used as the <br>
exit code.</p>


<p style="margin-left:11%; margin-top: 1em">&rsquo;server&rsquo;
is the replication server&rsquo;s current status.
&rsquo;sequence&rsquo; is it&rsquo;s <br>
sequence number, &rsquo;timestamp&rsquo; the time of that,
and &rsquo;age_sec&rsquo; the age of the <br>
data in seconds.</p>


<p style="margin-left:11%; margin-top: 1em">&rsquo;local&rsquo;
is the status of your server.</p>

<table width="100%" border="0" rules="none" frame="void"
       cellspacing="0" cellpadding="0">
<tr valign="top" align="left">
<td width="11%"></td>
<td width="9%">


<p><b>--json</b></p></td>
<td width="2%"></td>
<td width="33%">


<p>Output status as json.</p></td>
<td width="45%">
</td></tr>
</table>

<p style="margin-left:11%;"><b>-q</b>, <b>--quiet</b></p>

<p style="margin-left:22%;">Print only error messages</p>

<p style="margin-left:11%;"><b>-v</b>, <b>--verbose</b></p>

<p style="margin-left:22%;">Increase verboseness of
output</p>

<p style="margin-left:11%;"><b>-d</b> DB, <b>--database</b>
DB</p>

<p style="margin-left:22%;">Name of PostgreSQL database to
connect to or conninfo string</p>

<p style="margin-left:11%;"><b>-U</b> NAME,
<b>--username</b> NAME</p>

<p style="margin-left:22%;">PostgreSQL user name</p>

<p style="margin-left:11%;"><b>-H</b> HOST, <b>--host</b>
HOST</p>

<p style="margin-left:22%;">Database server host name or
socket location</p>

<p style="margin-left:11%;"><b>-P</b> PORT, <b>--port</b>
PORT</p>

<p style="margin-left:22%;">Database server port</p>

<p style="margin-left:11%;"><b>-p</b> PREFIX,
<b>--prefix</b> PREFIX</p>

<p style="margin-left:22%;">Prefix for table names (default
&rsquo;planet_osm&rsquo;)</p>

<p style="margin-left:11%;"><b>--middle-schema</b>
SCHEMA</p>

<p style="margin-left:22%;">Name of the schema to store the
table for the replication state in</p>

<p style="margin-left:11%;"><b>--schema</b> SCHEMA</p>

<p style="margin-left:22%;">Name of the schema for the
database</p>

<h2>SEE ALSO
<a name="SEE ALSO"></a>
</h2>


<p style="margin-left:11%; margin-top: 1em">* osm2pgsql
website (https://osm2pgsql.org) <br>
* osm2pgsql manual
(https://osm2pgsql.org/doc/manual.html)</p>
