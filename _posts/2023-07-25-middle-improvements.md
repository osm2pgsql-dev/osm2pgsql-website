---
layout: post
title: Middle improvements
---

In osm2pgsql there is that code that stores the raw data it gets from the input
files and makes it available to other parts of osm2pgsql for further
processing. This code is called, in osm2pgsql-speak, the "middle". Over the
last months we worked on some huge improvements to that code which not only
makes it much faster but also adds some functionality and will allow even more
processing options down the line. You can read about all the details of this
project in [this blog post by Jochen Topf](https://blog.jochentopf.com/2023-07-25-improving-the-middle-of-osm2pgsql.html).

