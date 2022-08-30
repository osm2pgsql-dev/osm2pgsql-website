---
layout: post
title: New test server
---

Any software needs a lot of testing and osm2pgsql is no different. For
development we have automated unit, integration and regression tests, but they
only run on tiny amounts of data. To figure out where performance bottlenecks
are, how different configurations of osm2pgsql or the PostgreSQL database
affect performance, or wether a planet import still works after some major
changes, we need something else.

Thanks to [FOSSGIS e.V.](https://www.fossgis.de/), the German OSM chapter, we
have a new machine for development and testing now. With an AMD Ryzen 9 3900
12-Core Processor, 128 GByte RAM, and two 1.9 TByte NVME SSDs the machine is
easily capable enough to run a planet database. This will allow us to do lots
more, larger, and longer running tests in the future. It will also help with
giving users better advice in the manual how to set up their system for
specific use cases. Thank you, FOSSGIS!

