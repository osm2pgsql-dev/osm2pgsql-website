
local restaurants = osm2pgsql.define_table({
    name = 'restaurants',
    ids = { type = 'any', id_column = 'osm_id' },
    columns = {
        { column = 'name',    type = 'text' },
        { column = 'cuisine', type = 'text' },
        { column = 'geom',    type = 'point', projection = 4326, not_null = true }
    }
})

function osm2pgsql.process_node(object)
    if object.tags.amenity == 'restaurant' then
        restaurants:insert(
            {
                name = object.tags.name,
                cuisine = object.tags.cuisine,
                geom = object:as_point()
            }
        )
    end
end

function osm2pgsql.process_way(object)
    if object.tags.amenity == 'restaurant' and object.is_closed then
        restaurants:insert(
            {
                name = object.tags.name,
                cuisine = object.tags.cuisine,
                geom = object:as_polygon():centroid()
            }
        )
    end
end

function osm2pgsql.process_relation(object)
    if object.tags.amenity == 'restaurant' and object.tags.type == 'multipolygon' then
        restaurants:insert(
            {
                name = object.tags.name,
                cuisine = object.tags.cuisine,
                geom = object:as_multipolygon():centroid()
            }
        )
    end
end
