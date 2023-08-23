
local tables = {}

tables.places = osm2pgsql.define_node_table('places', {
    { column = 'tags', type = 'jsonb' },
    { column = 'place', type = 'text' },
    { column = 'name', type = 'text' },
    { column = 'geom', type = 'point', projection = 3031 },
})

tables.coastlines = osm2pgsql.define_way_table('coastlines', {
    { column = 'geom', type = 'linestring', projection = 3031 },
})

tables.ice_shelves = osm2pgsql.define_way_table('ice_shelves', {
    { column = 'geom', type = 'linestring', projection = 3031 },
})

-- These are the value of the "place" tag we are interested in.
local check_place = osm2pgsql.make_check_values_func({ 'hamlet', 'isolated_dwelling', 'locality', 'town', 'village' })

function osm2pgsql.process_node(object)
    local place = object.tags.place

    if check_place(place) then
        tables.places:insert({
            tags = object.tags,
            place = place,
            name = object.tags.name,
            geom = object:as_point()
        })
    end
end

function osm2pgsql.process_way(object)
    -- For historical reasons OSM has ways tagged "natural=coastline" inside
    -- Antarctica that are not coastlines. Those have the additional tag
    -- "coastline=bogus", which allows us to make an exception for them.
    if object.tags.natural == 'coastline' and object.tags.coastline ~= 'bogus' then
        tables.coastlines:insert({ geom = object:as_linestring() })
    end
    if object.tags['glacier:edge'] == 'grounding_line' then
        tables.ice_shelves:insert({ geom = object:as_linestring() })
    end
end

