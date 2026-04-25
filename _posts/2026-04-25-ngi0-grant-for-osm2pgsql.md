---
layout: post
title: NGI0 grant for osm2pgsql
---

The amount of data in OSM is climbing continually, and therefore the memory and
disk requirements of osm2pgsql have risen as well. To address this issue we
have [applied for and won a grant from the NGI0 Commons
Fund](https://nlnet.nl/project/Osm2pgsql/). In this project we want to reduce
the memory and disk usage of osm2pgsql by implementing more efficient storage
formats, specifically for “intermediate” data used while processing, often
called the “middle”. We are tentatively calling this CODA, the Compact
OpenStreetMap Data Archive. This will not only help with resource consumption
on the community-run OSM servers, but also enable wider use of OSM data, even
on planet-scale, in low-resource environments available to small NGOs or to
students.

Long-time osm2pgsql developer Jochen Topf will be funded to work on this
project for the next year or so. Progress and all the details will be published
on the [project's webpage](https://osm2pgsql.org/project-coda/).

<div style="display: flex; flex-wrap: wrap; align-items: center; gap: 20px;">
    <img src="https://osm2pgsql.org/img/nlnet.svg" width="200" style="float: left; padding: 0 40px 40px 0;"/>
    <img src="https://osm2pgsql.org/img/ngi0.svg" width="200" style="float: left; padding: 0 40px 40px 0;"/>
</div>

This project is funded through the [NGI0 Commons
Fund](https://nlnet.nl/commonsfund), a fund established by
[NLnet](https://nlnet.nl/) with financial support from the European
Commission's [Next Generation Internet](https://ngi.eu/) programme, under the
aegis of [DG Communications Networks, Content and
Technology](https://commission.europa.eu/about-european-commission/departments-and-executive-agencies/communications-networks-content-and-technology_en)
under grant agreement No
[101135429](https://cordis.europa.eu/project/id/101135429). Additional funding
is made available by the [Swiss State Secretariat for Education, Research and
Innovation](https://www.sbfi.admin.ch/sbfi/en/home.html) (SERI).
