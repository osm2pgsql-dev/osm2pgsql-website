| Option                                  | Description |
| --------------------------------------- | ----------- |
| -e, \--expire-tiles=[MIN-ZOOM-]MAX-ZOOM | Create a tile expiry list for zoom level `MAX-ZOOM` or all zoom levels between `MIN-ZOOM` and `MAX-ZOOM` (default is `0` which means the feature is disabled) |
| -o, \--expire-output=FILENAME           | Output file name for expired tiles list (default: `dirty_tiles`) |
| \--expire-bbox-size=SIZE                | Max width and height for a polygon to expire the whole polygon, not just the boundary (default `20000`) |
{: .desc}
