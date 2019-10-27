#!/usr/bin/env bash

set -xe

/etc/init.d/postgresql start

# initialise postgres
cat << EOF | sudo -u postgres -i
createuser renderaccount # answer yes for superuser (although this isn't strictly necessary)
createdb -E UTF8 -O renderaccount gis
EOF

cat << EOF | sudo -u postgres psql
\c gis
CREATE EXTENSION postgis;
CREATE EXTENSION hstore;
ALTER TABLE geometry_columns OWNER TO renderaccount;
ALTER TABLE spatial_ref_sys OWNER TO renderaccount;
\q
EOF

# osm2pgsql
git clone git://github.com/openstreetmap/osm2pgsql.git
(cd osm2pgsql
mkdir build
cd build
cmake .. -G Ninja
ninja
ninja install)

# mod_tile
git clone -b switch2osm git://github.com/SomeoneElseOSM/mod_tile.git
(cd mod_tile
./autogen.sh
./configure
make
make install
make install-mod_tile
ldconfig)

# carto
cat << EOF | sudo -u renderaccount -i
mkdir -p ~/src
cd ~/src
git clone git://github.com/gravitystorm/openstreetmap-carto.git
cd openstreetmap-carto
carto -v
carto project.mml > mapnik.xml
~/src/openstreetmap-carto/scripts/get-shapefiles.py
EOF

# Web Server
mkdir /var/lib/mod_tile
chown renderaccount /var/lib/mod_tile

mkdir /var/run/renderd
chown renderaccount /var/run/renderd

echo "LoadModule tile_module /usr/lib/apache2/modules/mod_tile.so" >> /etc/apache2/conf-available/mod_tile.conf
a2enconf mod_tile

mv ~/build/mod_tile/debian/renderd.init /etc/init.d/renderd
chmod u+x /etc/init.d/renderd
mv ~/build/mod_tile/debian/renderd.service /lib/systemd/system/
