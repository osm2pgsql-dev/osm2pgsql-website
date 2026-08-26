
-- Import OSM data into DuckDB using "spatial" extension

SET VARIABLE osm_file = '...';

INSTALL spatial;
LOAD spatial;

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

CREATE TABLE way_nodes (
    node_id int64 PRIMARY KEY,
    way_ids int64[]
);

CREATE TABLE relations (
    id int64 PRIMARY KEY,
    member_types enum('node', 'way', 'relation')[],
    member_refs int64[],
    member_roles varchar[],
    tags map(varchar, varchar)
);

INSERT INTO nodes
    SELECT id, lat * 10000000, lon * 10000000, tags FROM ST_ReadOsm(getvariable('osm_file'))
        WHERE kind = 'node' AND tags IS NOT NULL;

INSERT INTO ways
    SELECT id, refs, tags FROM ST_ReadOsm(getvariable('osm_file'))
        WHERE kind = 'way';

INSERT INTO way_nodes
    WITH up AS (
        SELECT id AS way_id, unnest(refs) AS node_id FROM ST_ReadOsm(getvariable('osm_file'))
            WHERE kind = 'way'
    ) SELECT node_id, list(way_id) FROM up GROUP BY node_id;

INSERT INTO relations
    SELECT id, ref_types, refs, ref_roles, tags FROM ST_ReadOsm(getvariable('osm_file'))
        WHERE kind = 'relation';

