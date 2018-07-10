#基本镜像
FROM alpine:3.8

#上传安装文件
COPY libmcrypt-2.5.8.tar.gz /root/libmcrypt-2.5.8.tar.gz
COPY mcrypt-2.6.8.tar.gz /root/mcrypt-2.6.8.tar.gz
COPY mhash-0.9.9.9.tar.gz /root/mhash-0.9.9.9.tar.gz
COPY php-7.2.7.tar.gz /root/php-7.2.7.tar.gz
COPY phpredis-4.0.2.tar.gz /root/phpredis-4.0.2.tar.gz

#使用阿里云镜像
RUN echo "https://mirrors.aliyun.com/alpine/v3.8/main/" > /etc/apk/repositories && \
echo "https://mirrors.aliyun.com/alpine/v3.8/community/" >> /etc/apk/repositories && \

#更新
apk update && \
apk upgrade && \

#安装工具及依赖
apk add file gcc g++ make autoconf automake libtool libxml2-dev re2c bison bzip2-dev curl-dev libjpeg-turbo-dev libpng-dev readline-dev freetype freetype-dev libmcrypt-dev libressl-dev gettext-dev gd gd-dev pcre pcre-dev zlib zlib-dev libmcrypt && \
apk add postgresql-contrib postgresql-dev libpq && \

#过入home目录
cd /root/ && \

#编译mhash
#下载安装mhash
#https://master.dl.sourceforge.net/project/mhash/OldFiles/python-mhash-1.4.tar.gz
tar zxf mhash-0.9.9.9.tar.gz && \
cd mhash-0.9.9.9 && \
./configure && \
make && \
make install && \
cd /root/ && \

#编译mcrypt
#https://sourceforge.net/projects/mcrypt/files/MCrypt/2.6.8/mcrypt-2.6.8.tar.gz/download
tar zxf mcrypt-2.6.8.tar.gz && \
cd mcrypt-2.6.8 && \
./configure && \
make && \
make install && \
cd /root/ && \

#编译libmcrypt
#https://sourceforge.net/projects/mcrypt/files/Libmcrypt/2.5.8/libmcrypt-2.5.8.tar.gz/download
tar zxf libmcrypt-2.5.8.tar.gz && \
cd libmcrypt-2.5.8 && \
./configure && \
make && \
make install && \
cd /root/ && \

#编译php
tar zxf php-7.2.7.tar.gz && \
cd php-7.2.7 && \
./configure --prefix=/usr/local/php --disable-cli --enable-fpm --with-config-file-path=/usr/local/php/etc --disable-ipv6 --with-mhash --enable-mbstring --with-mysqli=mysqlnd --with-mysql-sock=/tmp/mysql.sock --enable-pcntl --with-pdo-mysql=mysqlnd --with-pdo-pgsql --enable-mysqlnd --without-pear --with-pcre-dir=/usr/include --with-mcrypt --with-zlib && \
make && \
make install && \
#安装gd扩展
cd ext && \
cd gd && \
/usr/local/php/bin/phpize && \
./configure --enable-gd-native-ttf --with-freetype-dir=/usr/include/freetype2 --with-jpeg-dir=/usr/local/lib --with-php-config=/usr/local/php/bin/php-config && \
make && \
make install && \
cd .. && \
#安装curl扩展
cd curl && \
/usr/local/php/bin/phpize && \
./configure --with-php-config=/usr/local/php/bin/php-config && \
make && \
make install && \
cd .. && \
#安装openssl扩展
cd openssl && \
cp config0.m4 config.m4 && \
/usr/local/php/bin/phpize && \
./configure --with-php-config=/usr/local/php/bin/php-config && \
make && \
make install && \
cd .. && \
#安装phpredis扩展
cd /root/ && \
tar zxf phpredis-4.0.2.tar.gz && \
cd phpredis-4.0.2 && \
/usr/local/php/bin/phpize && \
./configure --with-php-config=/usr/local/php/bin/php-config && \
make && \
make install && \
cd .. && \
#创建php.ini文件
cp /root/php-7.2.7/php.ini-production /usr/local/php/etc/php.ini && \
cp /usr/local/php/etc/php-fpm.conf.default /usr/local/php/etc/php-fpm.conf && \
cp /usr/local/php/etc/php-fpm.d/www.conf.default /usr/local/php/etc/php-fpm.d/www.conf && \


#清理安装文件
rm -rf /root/libmcrypt-2.5.8.tar.gz && \
rm -rf /root/libmcrypt-2.5.8 && \
rm -rf /root/mcrypt-2.6.8.tar.gz && \
rm -rf /root/mcrypt-2.6.8 && \
rm -rf /root/mhash-0.9.9.9.tar.gz && \
rm -rf /root/mhash-0.9.9.9 && \
rm -rf /root/phpredis-4.0.2.tar.gz && \
rm -rf /root/phpredis-4.0.2 && \
apk del gcc g++ make autoconf imagemagick-dev

#暴露端口
EXPOSE 9000

#挂载点
VOLUME ["/usr/local/php/etc"]

#启动php-fpm
CMD ["/usr/local/php/sbin/php-fpm", "-F", "-c", "/usr/local/php/etc/php.ini"]




#安装pdo_pgsql扩展
#apk add postgresql-contrib postgresql-dev libpq
#./configure --with-php-config=/usr/local/php/bin/php-config --with-pdo-pgsql

