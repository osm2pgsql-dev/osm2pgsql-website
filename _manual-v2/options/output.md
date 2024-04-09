| Option               | Description |
| -------------------- | ----------- |
| -O, \--output=OUTPUT | Select the output. Available outputs are: **flex**, **pgsql** (default), and **null**. You don’t need to add this option in append mode, because osm2pgsql will remember it from the import. |
| -S, \--style=STYLE   | The style file. This specifies how the data is imported into the database, its format depends on the output. (For the **pgsql** output, the default is `/usr/share/osm2pgsql/default.style`, for other outputs there is no default.) You don’t need to add this option in append mode, because osm2pgsql will remember it from the import. If you set it in append mode anyway, it will use the new setting for this and future updates. |
{: .desc}
