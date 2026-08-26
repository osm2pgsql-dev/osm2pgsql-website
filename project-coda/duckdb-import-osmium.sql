
-- Import OSM data into DuckDB using "osmium" extension

SET VARIABLE osm_file = '...';

INSTALL spatial;
LOAD spatial;

INSTALL osmium FROM community;
LOAD osmium;

CREATE TABLE nodes (
    id int64 PRIMARY KEY,
    lat int32,
    lon int32,
    tags map(varchar, varchar)
);

CREATE TABLE ways (
    id int64 PRIMARY KEY,
    nodes int64[],
    tags map(varchar, varchar)
);

CREATE TABLE areas (
    id int64 PRIMARY KEY,
    nodes int64[],
    tags map(varchar, varchar)
);

CREATE TABLE relation_areas (
    id int64 PRIMARY KEY,
    member_types enum('node', 'way', 'relation')[],
    member_refs int64[],
    member_roles varchar[],
    tags map(varchar, varchar)
);

CREATE TABLE relations (
    id int64 PRIMARY KEY,
    member_types enum('node', 'way', 'relation')[],
    member_refs int64[],
    member_roles varchar[],
    tags map(varchar, varchar)
);

INSERT INTO nodes
    SELECT id, ST_Y(geometry) * 10000000, ST_X(geometry) * 10000000, tags FROM query_table(getvariable('osm_file'))
        WHERE type = 'node';

INSERT INTO ways
    SELECT id, refs, tags FROM query_table(getvariable('osm_file'))
        WHERE type = 'way' AND kind = 'line';

INSERT INTO areas
    SELECT id, refs, tags FROM query_table(getvariable('osm_file'))
        WHERE type = 'way' AND kind = 'area';

INSERT INTO relation_areas
    SELECT id, ref_types, refs, ref_roles, tags FROM query_table(getvariable('osm_file'))
        WHERE type = 'relation' AND kind = 'area';

INSERT INTO relations
    SELECT id, ref_types, refs, ref_roles, tags FROM query_table(getvariable('osm_file'))
        WHERE type = 'relation';

