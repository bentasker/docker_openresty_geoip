# OpenResty with GeoIP in Docker
==================================

This repo contains build materials to take the latest [OpenResty](https://openresty.org/en/) image from [Docker Hub](https://hub.docker.com/r/openresty/openresty/) and add the [GeoIP2 Module](https://github.com/leev/ngx_http_geoip2_module.git) to it so that things like geo-blocking can be done.

The build is based upon the post at [https://www.electrosoftcloud.com/en/compile-geoip2-in-openresty-and-how-to-use-it/](https://www.electrosoftcloud.com/en/compile-geoip2-in-openresty-and-how-to-use-it/), with a few small tweaks.


----

### Building

The GeoIP module relies on Maxmind's Free GeoIP2 database - however, a little while back Maxmind changed things so that you need to have registered in order to [download the database](https://dev.maxmind.com/geoip/geolite2-free-geolocation-data).

The build includes a script to download a database, but you need to provide your own Maxmind license key for use during image build

Edit `geo_ip_license` and set your license key

    GEO_IP_LICENSE="<maxmind license>"

Docker's buildkit can then be told to expose it as a secret

    export DOCKER_BUILDKIT=1
    docker build --secret id=maxmindsecret,src=geo_ip_license -t openresty_geoip .
    


----

## Auth Rules

### Variables

The configuration defined in `geoip2.conf` will lead the the following variables being available for use within your Nginx configuration (or resulting LUA calls)

* `$geoip2_metadata_country_build` : Information about the database itself
* `$geoip2_data_country_code`: The country's ISO code (e.g. `GB` for the UK)
* `$geoip2_data_country_name`: The country's name (e.g. `United Kingdom`)

Note: If you want to use a different language for country names (or change variable names etc), you can create your own `geoip2.conf` and export it to `/etc/nginx/conf.d/geoip2.conf` when invoking the container:

```nginx
# Usa nombres en español
geoip2 /usr/local/openresty/nginx/maxmind/GeoLite2-Country.mmdb {
    auto_reload 30m;
    $geoip2_metadata_country_build metadata build_epoch;
    $geoip2_data_country_code default=NK source=$remote_addr country iso_code;
    $geoip2_data_country_name country names es;
}
```

See the [`ngx_http_geopip2_module`](https://github.com/leev/ngx_http_geoip2_module.git) for details of other supported usage.


----

### Simple Country Whitelisting

If you simply want to whitelist a specific country, you can do something like
```nginx

if ($geoip2_data_country_code != "GB"){
     return 403;
}
```

----

### Subnet Whitelisting

If you want to be able to whitelist IP ranges (such as a LAN subnet) you can do so by using nginx's `geo` to map a range to a value.

Add the following to a file in `conf.d`
```nginx
geo $whitelist_ip {
  default 0;
  192.168.3.0/24 1;
}
```

And then, within the Nginx `server` blocks where you want to apply your ruleset, add something like the following
```
access_by_lua_block {
    if (ngx.var.whitelist_ip == "0" and ngx.var.geoip2_data_country_code ~= "GB")
    then
       ngx.exit(403)
    end
}
```

(You can, of course, also do more advanced things like define a table of allowed countries and test where that table [contains the necessary value](https://snippets.bentasker.co.uk/page-2106050929-Check-if-value-exists-in-table-LUA.html).


