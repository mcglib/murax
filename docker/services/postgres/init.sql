CREATE USER fedora WITH ENCRYPTED PASSWORD 'fedora123';
CREATE DATABASE fcrepo;
GRANT ALL PRIVILEGES ON DATABASE fcrepo TO fedora;

CREATE DATABASE murax;
CREATE USER murax WITH ENCRYPTED PASSWORD 'murax123';
GRANT ALL PRIVILEGES ON DATABASE murax TO murax;
