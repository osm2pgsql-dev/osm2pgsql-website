---
title: 'Tutorial: Switching from add_row() to insert()'
---

[↖ All Tutorials]({% link doc/tutorials/index.md %})

# Switching from `add_row()` to `insert()`

In 1.7.0 we introduced a new way of doing geometry transformations in flex
config files. Instead of declaring a geometry transformation in the `add_row()`
function (or using the default one) you have to explicitly say how to transform
the geometry and then use that like any normal value in the `insert()`
function. This is a tiny bit more work, but it make is much more obvious what's
happening. And it gives you more options, allowing you to do transformations
which weren't possible before.

This document described how to change flex config files which are using the
old `add_row()` method to the new way of doing things with `insert()`.

The `add_row()` function is deprecated now and will be removed in a future
version of osm2pgsql.

## For Point Layers

For Point layers it is easy to switch. Lets say you have a table that should
get all names and locations of restaurants. Change the `add_row` to `insert`
and the `{ create = 'point' }` to `object.as_point()`. Because `{ create =
'point' }` is the default, you might not have that line at all. But you still
need the new one.

<pre>
local restaurants = osm2pgsql.define_node_table('restaurants', {
    { column = 'name', type = 'text' },
    { column = 'geom', type = 'point' }
})

function osm2pgsql.process_node(object)
    if object.tags.amenity == 'restaurant' then
<span class="change-bef">       restaurants:<span class="char-bef">add_row</span>({</span>
<span class="change-aft">       restaurants:<span class="char-aft">insert</span>({</span>
            name = object.tags.name,
<span class="change-bef">            geom = <span class="char-bef">{ create = 'point' }</span></span>
<span class="change-aft">            geom = <span class="char-aft">object.as_point()</span></span>
        })
    end
end
</pre>

## For (Multi)LineString Layers

For LineString geometries from ways, you have to use the: `as_linestring()`
function. Because `{ create = 'linestring' }` is the default for LineString
geometries, you might not have that line at all. But you still need the new
one.

<pre>
local railroads = osm2pgsql.define_way_table('railroads', {
    { column = 'geom', type = 'linestring' }
})

function osm2pgsql.process_way(object)
    if object.tags.railway == 'rail' then
<span class="change-bef">        railroads:<span class="char-bef">add_row</span>({ geom = <span class="char-bef">{ create = 'line' }</span> })</span>
<span class="change-aft">        railroads:<span class="char-aft">insert</span>({ geom = <span class="char-aft">object.as_linestring()</span> })</span>
    end
end
</pre>

If you were using `split_at` to split LineStrings into shorter ones, you'd
magically get multiple rows added to your database for long LineStrings.

With the `insert()` function this is no longer the case. You explicitly have to
call `segmentize()` now and then iterate over the results. Note that geometries
are in 4326 (lat/lon) coordinates, so you have to convert them to 3857
(WebMercator) coordinates first, before calling `segmentize()` to achieve the
same result as before.

<pre>
local railroads = osm2pgsql.define_way_table('railroads', {
    { column = 'geom', type = 'linestring' }
})

function osm2pgsql.process_way(object)
    if object.tags.railway == 'rail' then
<span class="change-bef">        railroads:<span class="char-bef">add_row</span>({</span>
<span class="change-bef">            <span class="char-bef">geom = { create = 'line', split_at = 100 }</span></span>
<span class="change-bef">        })</span>
<span class="change-aft">        <span class="char-aft">local mgeom = object.as_linestring():transform(3857):segmentize(100)</span></span>
<span class="change-aft">        <span class="char-aft">for sgeom in mgeom:geometries() do</span></span>
<span class="change-aft">            railroads:<span class="char-aft">insert({ geom = sgeom })</span></span>
<span class="change-aft">        <span class="char-aft">end</span></span>
    end
end
</pre>

If you have a MultiLineString geometry you can feed it the split geometry
directly:

<pre>
local railroads = osm2pgsql.define_way_table('railroads', {
    { column = 'geom', type = 'multilinestring' }
})

function osm2pgsql.process_way(object)
    if object.tags.railway == 'rail' then
<span class="change-bef">        railroads:<span class="char-bef">add_row</span>({ geom = <span class="char-bef">{ create = 'line', split_at = 100 }</span> })</span>
<span class="change-aft">        railroads:<span class="char-aft">insert</span>({ geom = <span class="char-aft">object.as_linestring():transform(3857):segmentize(100)</span> })</span>
    end
end
</pre>

## For Polygon Layers

If the (closed) way should be interpreted as a Polygon, the `{ create = 'area'
}` has to be replaced by a call to `as_polygon()`. Because `{ create = 'area'
}` is the default for Polygon geometries, you might not have that line at all.
But you still need the new one.

<pre>
local forests = osm2pgsql.define_way_table('forests', {
    { column = 'geom', type = 'polygon' }
})

function osm2pgsql.process_way(object)
    if object.is_closed and object.tags.natural == 'wood' then
<span class="change-bef">        forests:<span class="char-bef">add_row</span>({ geom = <span class="char-bef">{ create = 'area' }</span> })</span>
<span class="change-aft">        forests:<span class="char-aft">insert</span>({ geom = <span class="char-aft">object.as_polygon()</span> })</span>
    end
end
</pre>

If you are creating (Multi)Polygons from relations, you had to set `{ create =
'area' }` explicitly. This is now replaced by a call to `as_multipolygon()`.

<pre>
local forests = osm2pgsql.define_area_table('forests', {
    { column = 'geom', type = 'multipolygon' }
})

function osm2pgsql.process_relation(object)
    if object.tags.type == 'multipolygon' and object.tags.natural == 'wood' then
<span class="change-bef">         forests:<span class="char-bef">add_row</span>({ geom = <span class="char-bef">{ create = 'area' }</span> })</span>
<span class="change-aft">         forests:<span class="char-aft">insert</span>({ geom = <span class="char-aft">object.as_multipolygon()</span> })</span>
    end
end
</pre>

If you were using `split_at = 'multi'`, do the split explicitly now by
iterating over the polygons in the multipolygon:

<pre>
local forests = osm2pgsql.define_area_table('forests', {
    { column = 'geom', type = 'polygon' }
})

function osm2pgsql.process_relation(object)
    if object.tags.type == 'multipolygon' and object.tags.natural == 'wood' then
<span class="change-bef">        forests:<span class="char-bef">add_row</span>({</span>
<span class="change-bef">            <span class="char-bef">geom = { create = 'area', split_at = 'multi' }</span></span>
<span class="change-bef">        })</span>
<span class="change-aft">        <span class="char-aft">local mgeom = object.as_multipolygon()</span></span>
<span class="change-aft">        <span class="char-aft">for sgeom in mgeom:geometries() do</span></span>
<span class="change-aft">            forests:<span class="char-aft">insert({ geom = sgeom })</span></span>
<span class="change-aft">        <span class="char-aft">end</span></span>
    end
end
</pre>

## The "Magic" Area Data Type

Sometimes you want a column with the area of a polygon. In the old way of doing
things you used a special column of type `area` for this and osm2pgsql would
magically fill in the area of the corresponding polygon. For the new way you
have to use a normal column type, probably `real` and explicitly call the
`area()` function on the polygon object to calculate the area.

<pre>
local forests = osm2pgsql.define_way_table('forests', {
    { column = 'geom', type = 'polygon' },
<span class="change-bef">    { column = 'area', type = <span class="char-bef">'area' }</span></span>
<span class="change-aft">    { column = 'area', type = <span class="char-aft">'real' }</span></span>
})

function osm2pgsql.process_way(object)
    if object.is_closed and  object.tags.natural == 'wood' then
<span class="change-bef">        forests:<span class="char-bef">add_row</span>({ geom = <span class="char-bef">{ create = 'area' }</span> })</span>
<span class="change-aft">        <span class="char-aft">local poly = object.as_polygon():transform(3857)</span></span>
<span class="change-aft">        forests:<span class="char-aft">insert</span>({ geom = <span class="char-aft">poly, area = poly:area()</span> })</span>
    end
end
</pre>

Note that we need to transform the geometry into WebMercator (3857) coordinates
before calculating the area to get the same effect as before. We store the
transformed geometry in a local variable so we don't have to do the creation
and transformation of the polygon geometry twice.

Because the area calculation is now explicit, you can decide how to calculate
the area. If you want to have it in lat/lon coordinates instead, remove the
`transform()`. Or you can use the `spherical_area()` function (available in
osm2pgsql 1.9.0 or greater) instead.

<pre>
local forests = osm2pgsql.define_way_table('forests', {
    { column = 'geom', type = 'polygon' },
    { column = 'area', type = 'real' }
})

function osm2pgsql.process_way(object)
    if object.is_closed and  object.tags.natural == 'wood' then
        local poly = object.as_polygon()
        forests:insert({ geom = poly, area = poly:spherical_area() })
    end
end
</pre>

If you are splitting a multipolygon into its constituent polygons, you can
calculate the area on the whole or on the parts:

<pre>
local forests = osm2pgsql.define_area_table('forests', {
    { column = 'geom', type = 'polygon' },
    { column = 'marea', type = 'real' },
    { column = 'sarea', type = 'real' }
})

function osm2pgsql.process_relation(object)
    if object.tags.type == 'multipolygon' and object.tags.natural == 'wood' then
        local mgeom = object.as_multipolygon():transform(3857)
        local marea = mgeom:area()
        for sgeom in mgeom:geometries() do
            forests:insert({ geom = sgeom, marea = marea, sarea = sgeom:area() })
        end
    end
end
</pre>

