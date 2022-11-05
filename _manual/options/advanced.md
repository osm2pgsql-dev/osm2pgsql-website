| Option                            | Description |
| --------------------------------- | ----------- |
| -I, \--disable-parallel-indexing  | Disable parallel clustering and index building on all tables, build one index after the other. |
| \--number-processes=THREADS       | Specifies the number of parallel threads used for certain operations. The default is to set this between 1 and 4 depending on the number of CPUs you have. Values up to 32 are possible but probably not useful. Note that each thread opens multiple connections to the database and you will probably reach the limit of allowed database connections. |
| \--with-forward-dependencies=BOOL | *Version >= 1.4.0*{:.version} Propagate changes from nodes to ways and node/way members to relations (Default: `true`). When this is set to `false` on import, any updates need to be run with `false`, too. |
{: .desc}
