#!/usr/bin/env bash

service postgresql start
service renderd start
service apache2 start

function first_pbf {
    for pbf in $(ls /import); do
        echo $pbf
        break
    done
}

PBF=$(first_pbf)

cat << EOF | sudo -u renderaccount -i
osm2pgsql -d gis --create --slim  -G --hstore --tag-transform-script ~/src/openstreetmap-carto/openstreetmap-carto.lua -C 2500 --number-processes ${NUM_CORES:=4} -S ~/src/openstreetmap-carto/openstreetmap-carto.style /import/$PBF
EOF

service renderd restart
service apache2 restart

$@
