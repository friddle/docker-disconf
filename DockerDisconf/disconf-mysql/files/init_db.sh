#!/bin/bash

# Initialize MySQL database.
# ADD this file into the container via Dockerfile.
# Assuming you specify a VOLUME ["/var/lib/mysql"] or `-v /var/lib/mysql` on the `docker run` command��
# Once built, do e.g. `docker run your_image /path/to/docker-mysql-initialize.sh`
# Again, make sure MySQL is persisting data outside the container for this to have any effect.

set -e
set -x

# mysql_install_db

# Start the MySQL daemon in the background.
/usr/sbin/mysqld &
mysql_pid=$!

until mysqladmin ping &>/dev/null; do
  echo -n "."; sleep 0.2
done

# Permit root login without password from outside container.
# mysql -e "GRANT ALL ON *.* TO root@'%' IDENTIFIED BY '' WITH GRANT OPTION"

# create the default database from the ADDed file.
mysql < /tmp/sql/1-init_table.sql
mysql < /tmp/sql/2-data.sql
mysql < /tmp/sql/20141201/disconf.sql
mysql < /tmp/sql/20141226/disconf.sql
mysql < /tmp/sql/20150101/disconf.sql
mysql < /tmp/sql/20150320/disconf.sql

# Tell the MySQL daemon to shutdown.
mysqladmin shutdown

# Wait for the MySQL daemon to exit.
wait $mysql_pid

# create a tar file with the database as it currently exists
tar czvf default_mysql.tar.gz /var/lib/mysql

# the tarfile contains the initialized state of the database.
# when the container is started, if the database is empty (/var/lib/mysql)
# then it is unpacked from default_mysql.tar.gz from
# the ENTRYPOINT /tmp/run_db script