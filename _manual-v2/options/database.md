| Option                                     | Description |
| ------------------------------------------ | ----------- |
| -d, \--database=DB                         | Database name or PostgreSQL conninfo string. |
| -U, \--user=USERNAME                       | *Version < 2.2.0*{:.version} Database user. |
| -U, \--username=USERNAME, \--user=USERNAME | *Version >= 2.2.0*{:.version} Database user. |
| -W, \--password                            | Force password prompt. Do not put the password on the command line! |
| -H, \--host=HOST                           | Database server hostname or unix domain socket location. |
| -P, \--port=PORT                           | Database server port. |
| \--schema=SCHEMA                           | Default for various schema settings throughout osm2pgsql (default: `public`). The schema must exist in the database and be writable by the database user. |
{: .desc}
