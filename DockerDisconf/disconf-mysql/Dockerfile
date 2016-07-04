FROM mysql
ENV  MYSQL_ROOT_PASSWORD=passw0rd
COPY files/sql /docker-entrypoint-initdb.d
VOLUME ["data","/var/lib/mysql"]
