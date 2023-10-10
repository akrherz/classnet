# Iowa State University Classnet

This is class management system written by Pete Boysen of Iowa State University
back in the 1990s / early 2000s.  No implicit nor express warranties are
provided with this code.

## Setup

The codebase assumes it is running within the root directory of an apache
vhost.  The system requires `/usr/bin/perl` and a writable `data` folder by
the apache user.  Some opinionated setup details.

- mkdir /local
- cd /local
- git clone https://github.com/akrherz/classnet.git
- cd classnet
- mkdir data
- chown apache:apache data
- copy /local/classnet/conf/apache-vhost.conf into /etc/httpd/conf.d and edit
accordingly.
- edit `cgi-bin/admin/.htaccess` to reflect your local environment / admin user.
