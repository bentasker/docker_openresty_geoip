FROM openresty/openresty

#COPY geo_ip_license /tmp/
# export DOCKER_BUILDKIT=1
# docker build --secret id=maxmindsecret,src=geo_ip_license .

COPY src/maxmind_fetch.sh /

# Fetch sources for the relevant version and rebuild
#
# Based on the instructions here: https://www.electrosoftcloud.com/en/compile-geoip2-in-openresty-and-how-to-use-it/
RUN --mount=type=secret,id=maxmindsecret apt-get update \
&& apt-get install -y wget build-essential git libmaxminddb0 libmaxminddb-dev libpcre3 libpcre3-dev libssl-dev  zlib1g-dev\
&& mkdir /tmp/compile \
&& cd /tmp/compile \
&& export OPENRESTY_VER=$(openresty -v 2>&1|cut -d "/" -f2) \
&& wget https://openresty.org/download/openresty-${OPENRESTY_VER}.tar.gz \
&& tar xvf openresty-${OPENRESTY_VER}.tar.gz \
&& mkdir /tmp/compile/openresty-${OPENRESTY_VER}/modules \
&& cd /tmp/compile/openresty-${OPENRESTY_VER}/modules \
&& git clone https://github.com/leev/ngx_http_geoip2_module.git \
&& cd ../bundle/nginx-$(openresty -v 2>&1|cut -d "/" -f2| grep -oP '^[0-9]+\.[0-9]+\.[0-9]+') \
&& export LUAJIT_LIB="/usr/local/openresty/luajit/lib/" \
&& export LUAJIT_INC="../LuaJIT-*/src/" \
&& COMPILEOPTIONS=$(openresty -V 2>&1|grep -i "arguments"|cut -d ":" -f2-) \
&& eval ./configure $COMPILEOPTIONS --with-http_slice_module --add-dynamic-module=../../modules/ngx_http_geoip2_module \
&& make modules \
&& mkdir -p /usr/local/openresty/nginx/modules/ \
&& cp objs/ngx*geoip2_module*so /usr/local/openresty/nginx/modules/ \
&& mkdir -p /usr/local/openresty/nginx/maxmind/ \
&& chmod +x /maxmind_fetch.sh \
&& /maxmind_fetch.sh \
&& echo "load_module modules/ngx_http_geoip2_module.so;" > module_load \
&& cat module_load /usr/local/openresty/nginx/conf/nginx.conf | tee /usr/local/openresty/nginx/conf/nginx.conf \
&& rm -rf /tmp/compile /var/lib/apt/lists/*
COPY src/geoip2.conf /etc/nginx/conf.d



# TODO - slice won't currently be available because we've only built the custom module. Should do the full build and install.


          
