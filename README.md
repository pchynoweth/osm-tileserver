# osm-tileserver

## Overview

Basic OSM tile server based on the instructions provided on [switch2osm.org](https://switch2osm.org).

## Starting the server

Copy an OSM pbf file from [geofabrik](http://download.geofabrik.de/) to the data directory.

### With docker-compose

```
docker-compose up
```

### With docker

```
docker run --rm -p 8080:80 -v $PWD/data:/import pchynoweth/osm-tileserver
```

### Viewing the data

A demo leafletjs application can be found in the demo directory.  Run the demo as follows:

```
npm install
npm start
```

This should start a basic http server locally.  You should then point your browser to [http://localhost:3000](http://localhost:3000).
