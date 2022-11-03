# OpenResty with GeoIP in Docker
==================================

This repo contains build materials to take the latest [OpenResty](https://openresty.org/en/) image from [Docker Hub](https://hub.docker.com/r/openresty/openresty/) and add the [GeoIP2 Module](https://github.com/leev/ngx_http_geoip2_module.git) to it so that things like geo-blocking can be done.

----

### Building

The GeoIP module relies on Maxmind's Free GeoIP2 database - however, a little while back Maxmind changed things so that you need to have registered in order to [download the database](https://dev.maxmind.com/geoip/geolite2-free-geolocation-data).

The build includes a script to download a database, but you need to provide your own Maxmind license key for use during image build

Edit `geo_ip_license` and set your license key

    GEO_IP_LICENSE="<maxmind license>"

Docker's buildkit can then be told to expose it as a secret

    export DOCKER_BUILDKIT=1
    docker build --secret id=maxmindsecret,src=geo_ip_license -t openresty_geoip .
    


