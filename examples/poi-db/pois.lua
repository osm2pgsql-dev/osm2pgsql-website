
local pois = osm2pgsql.define_table({
    name = 'pois',
    ids = { type = 'any', type_column = 'osm_type', id_column = 'osm_id' },
    columns = {
        { column = 'name' },
        { column = 'class', not_null = true },
        { column = 'subclass' },
        { column = 'geom', type = 'point', not_null = true },
}})

function process_poi(object, geom)
    local a = {
        name = object.tags.name,
        geom = geom
    }

    if object.tags.amenity then
        a.class = 'amenity'
        a.subclass = object.tags.amenity
    elseif object.tags.shop then
        a.class = 'shop'
        a.subclass = object.tags.shop
    else
        return
    end

    pois:insert(a)
end

function osm2pgsql.process_node(object)
    process_poi(object, object:as_point())
end

function osm2pgsql.process_way(object)
    if object.is_closed and object.tags.building then
        process_poi(object, object:as_polygon():centroid())
    end
end

