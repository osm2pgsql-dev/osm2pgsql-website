---
layout: doc
title: Installing with Docker
---

Docker images for the latest and many earlier versions of osm2pgsql are available from
[Dockerhub](https://hub.docker.com/r/iboates/osm2pgsql)

```sh
docker pull iboates/osm2pgsql:latest
```

You can then generally run the image by passing the same arguments to the `docker run iboates/osm2pgsql` as you would to
`osm2pgsql` itself. It is a little bit more subtle than that (especially regarding `osm2pgsql-replication`, see the
[readme](https://github.com/iboates/osm-utilities-docker/tree/master/osm2pgsql#usel) for more info.

Note that these docker images are maintained externally. If you have any questions or bug reports [contact the
maintainer](https://github.com/iboates/osm-utilities-docker/issues).
