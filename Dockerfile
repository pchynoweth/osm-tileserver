FROM ubuntu:24.04

# Prevent tzdata prompts
ARG DEBIAN_FRONTEND=noninteractive

# Basic deps
RUN apt-get update && apt-get upgrade -y && apt-get install -y \
    libboost-all-dev git-core tar unzip wget bzip2 build-essential autoconf \
    libtool libxml2-dev libgeos-dev libgeos++-dev libpq-dev libbz2-dev \
    libproj-dev munin-node munin libprotobuf-c-dev protobuf-c-compiler \
    libfreetype6-dev libtiff5-dev libicu-dev libgdal-dev libcairo-dev \
    libcairomm-1.0-dev apache2 apache2-dev libagg-dev liblua5.2-dev \
    ttf-unifont lua5.1 liblua5.1-dev libgeotiff5 curl sudo make cmake g++ \
    libboost-dev libboost-system-dev libboost-filesystem-dev libexpat1-dev \
    zlib1g-dev libbz2-dev libpq-dev libgeos-dev libgeos++-dev libproj-dev \
    lua5.2 liblua5.2-dev build-essential ninja-build postgresql \
    postgresql-contrib postgis postgresql-12-postgis-3 \
    postgresql-12-postgis-3-scripts autoconf apache2-dev libtool libxml2-dev \
    libbz2-dev libgeos-dev libgeos++-dev libproj-dev gdal-bin libmapnik-dev \
    mapnik-utils python3-mapnik fonts-noto-cjk fonts-noto-hinted \
    fonts-noto-unhinted ttf-unifont npm nodejs

# node deps
RUN npm install -g carto

COPY 000-default.conf /etc/apache2/sites-available/000-default.conf

# Add render user
RUN useradd -m renderaccount && mkdir -p /data && \
    chown renderaccount:renderaccount /data

WORKDIR /root/build

# Postgis
COPY setup.sh .
RUN ./setup.sh

WORKDIR /data
RUN rm -rf /root/build

COPY entrypoint.sh .
ENTRYPOINT [ "./entrypoint.sh" ]
CMD [ "sleep", "infinity" ]
