---
title: Project CODA
---

# Project CODA: Reduce osm2pgsql resource usage

The amount of data in OSM is climbing continually, and therefore the memory and
disk requirements of osm2pgsql have risen as well. In this project we want to
reduce the memory and disk usage of osm2pgsql by implementing more efficient
storage formats, specifically for "intermediate" data used while processing,
often called the "middle". We are tentatively calling this CODA, the Compact
OpenStreetMap Data Archive.

This will not only help with resource consumption on the community-run OSM
servers, but also enable wider use of OSM data, even on planet-scale, in
low-resource environments available to small NGOs or to students.

## Project plan

The project starts in April/May 2026 and runs for about a year. We'll first
look at the requirements in detail, then research possible solutions using
existing libraries for embedded databases as well as "from scratch" approaches.
Based on the results of that research we'll decide on an implementation. We'll
verify the design with a prototype and then integrate everything into
osm2pgsql.

## Progress

*Here we'll document the progress of the project.*

## Funding

<div style="display: flex; flex-wrap: wrap; align-items: center; gap: 20px;">
    <img src="/img/nlnet.svg" width="200" style=""/>
    <img src="/img/ngi0.svg" width="200" style=""/>
</div>

[This project](https://nlnet.nl/project/Osm2pgsql/) is funded through the [NGI0
Commons Fund](https://nlnet.nl/commonsfund), a fund established by
[NLnet](https://nlnet.nl/) with financial support from the European
Commission's [Next Generation Internet](https://ngi.eu/) programme, under the
aegis of [DG Communications Networks, Content and
Technology](https://commission.europa.eu/about-european-commission/departments-and-executive-agencies/communications-networks-content-and-technology_en)
under grant agreement No
[101135429](https://cordis.europa.eu/project/id/101135429). Additional funding
is made available by the [Swiss State Secretariat for Education, Research and
Innovation](https://www.sbfi.admin.ch/sbfi/en/home.html) (SERI).

