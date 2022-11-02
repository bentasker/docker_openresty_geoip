

### Building

The GeoIP module relies on Maxmind's Free GeoIP2 database - however, a little while back Maxmind changed things so that you need to have registered in order to download the database.

The build includes a script to download a database, but you need to provide your own Maxmind license key.

Edit `geo_ip_license` and set your license key

    GEO_IP_LICENSE="<maxmind license>"

Docker's buildkit can then be told to expose it as a secret

    export DOCKER_BUILDKIT=1
    docker build --secret id=maxmindsecret,src=geo_ip_license .

