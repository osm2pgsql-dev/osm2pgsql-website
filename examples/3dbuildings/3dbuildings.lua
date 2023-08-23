
local buildings = osm2pgsql.define_area_table('buildings', {
    -- Define an autoincrementing id column, QGIS likes a unique id on the table
    { column = 'id', sql_type = 'serial', create_only = true },
    { column = 'height', type = 'real', not_null = true },
    { column = 'geom', type = 'polygon', not_null = true },
})

-- calculate the height of the building from the tags
function calc_height(tags)
    -- if an explicit 'height' tag is available use that
    -- could be extended to also allow height in feet
    if tags.height then
        local h = tonumber(tags.height)
        if h and h > 0 and h < 900 then
            return h
        end
    end

    -- use 'building:levels' tag and assume each level is 4 meters high
    local levels = tags['building:levels']
    if levels then
        local l = tonumber(levels)
        if l and l > 0 and l < 200 then
            return l * 4
        end
    end

    -- fall back to default height if we can't find any useful tags
    return 12
end

function add_building(tags, geom)
    buildings:insert({
        height = calc_height(tags),
        geom = geom
    })
end

function osm2pgsql.process_way(object)
    if object.is_closed and object.tags.building then
        add_building(object.tags, object:as_polygon())
    end
end

function osm2pgsql.process_relation(object)
    if object.tags.type == 'multipolygon' and object.tags.building then
        geom = object:as_multipolygon()
        for g in geom:geometries() do
            add_building(object.tags, g)
        end
    end
end

