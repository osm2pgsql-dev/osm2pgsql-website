| Short option | Long option                  | Description |
| ------------ | ---------------------------- | --- |
| -I           | \--disable-parallel-indexing | By default osm2pgsql initiates the index building on all tables in parallel to increase performance. This can be a disadvantage on slow disks, or if you don't have enough RAM for PostgreSQL to perform up to 7 parallel index building processes (e.g. because `maintenance_work_mem` is set high). |
|              | \--number-processes=THREADS  | Specifies the number of parallel threads used for certain operations. If disks are fast enough e.g. if you have an SSD, then this can greatly increase speed of the "going over pending ways" and "going over pending relations" stages on a multi-core server. |
{: .desc}
