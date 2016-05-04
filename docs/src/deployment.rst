
Installation
============

This page explains how to deploy Varapp on a new, empty server.

Varapp is a standard web application with decoupled backend (Python)
and frontend (Javascript).

The installation has been tested only on CentOS and Mac OSX.
In this example we will suppose that the OS is CentOS 6/7.


Dependencies
------------

* Python3
* Apache (-devel)
* MySQL (MariaDb)
* SMTP server (telnet)
* Redis cache

See below how to install them in a way that is guaranteed to work.

The backend uses Django with mod_wsgi. It makes use of Cython to build C extensions.


Host setup
----------

Install Python 3
................

The app has been developped and tested under Python 3.4/3.5.

* Install necessary tools::

    yum -y update
    yum groupinstall -y development   # a bunch of dev tools
    yum install -y zlib-dev openssl-devel sqlite-devel bzip2-devel

* Get the latest version::

    wget https://www.python.org/ftp/python/3.4.3/Python-3.4.3.tar.xz
    xz -d Python-3.4.3.tar.xz
    tar -xvf Python-3.4.3.tar

* Add ``/usr/local/lib`` to the system's ``ld.so.conf.d/`` and re-run ``ldconfig`` :
  
  Edit ``/etc/ld.so.conf`` or create a new file::

    touch /etc/ld.so.conf.d/usrlocal.conf

  and put only the line "/usr/local/lib" inside. Then run as root::

    ldconfig -v

  Alternatively, add this to the .bashrc::

    export PATH=$PATH:/usr/local/lib
    export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/lib

* Compilation:

  It must be compiled with `sqlite-devel` (just install `sqlite-devel` before compiling, as above).
  The `--enable-shared` option must be supplied to the "configure" script.
  Do not override an already existing version, in case some other local libs need it, so use
  `altinstall` instead of `install`::

    ./configure --enable-shared
    make && make altinstall

* Install the following Python libraries globally::

    pip3 install virtualenv         # virtual environments
    sudo yum install ncurses-devel  # for readline, see below
    pip3 install readline           # to avoid strange characters when arrows are pushed

  `pip` is shipped with Python3. Like for python, the command can be `pip`, `pip3` or `pip3.4`.

* The following aliases solve problems of sudo/non-sudo users, and make it shorter::

    ln -s /usr/local/bin/pip3.4 /usr/bin/pip3
    ln -s /usr/local/bin/python3.4 /usr/bin/python3
    ln -s /usr/local/bin/pyvenv-3.4 /usr/bin/pyvenv


Apache - MySQL - SMTP - Redis
.............................

* Install Apache (-devel so that we have `apxs`) and start the service::
    
    yum install httpd-devel
    service httpd start

  We install the -devel version to have `apxs`, the plugins installer.
  We need it for `mod_wsgi`, so that Apache can serve Python files.


* Install MySQL:
  
  In CentOS7, MySQL is now called MariaDB::

    yum install mariadb-devel mariadb-server mariadb-client

  Start/autostart the service::

    systemctl start/enable mariadb.service
    /usr/bin/mysql_secure_installation

  In order for python drivers to work, we need the devel version, hence the 
  `mariadb-devel`. For the classic mysql, it is::

    yum install mysql-community-devel


* Set up an SMTP server::

    yum install telnet

  Test that it works::

    telnet localhost 25


* Install Redis::

    wget http://download.redis.io/redis-stable.tar.gz
    tar xvzf redis-stable.tar.gz
    cd redis-stable
    make

  Launch the server::

    src/redis-server &

  For more details, see the `Redis docs <http://redis.io/documentation>`_.


.. _backend_deployment:

Backend deployment
------------------

We describe here how to serve the Python backend with Apache and mod_wsgi,
but nothing prevents from using another web server instead.

The Python backend can be found in `Github <https://github.com/varapp/varapp-backend-py>`_.
Clone or download the archive and unarchive it.

Let's suppose that we want to place the source in this folder::

    SOURCE_DIR=/home/varapp/backend 

* Build the app::

    python setup.py sdist

  Copy ``dist/django-varapp-<version>.tar.gz`` into a destination folder,
  in our example case ``$SOURCE_DIR``, and extract.
  It is advised to keep the source here even after installation.

* Create a Python virtual environment at ``$venv``
  (``$venv`` is a path, e.g. ``venv=~/.virtualenvs/varapp``)::

     mkdir -p $venv
     pyvenv $venv
     source $venv/bin/activate

* Install these python libraries in the virtualenv::

    pip3 install mod_wsgi           # Apache mod for Python
    pip3 install numpy              # necessary for Cython setup
    pip3 install cython             # necessary to build C extensions
    pip3 install mysqlclient        # MySQL driver

* Install:

  Enter the app's source folder (``${SOURCE_DIR}/django-varapp-<version>``).
  There should be a file ``setup.py`` in the current directory.

  Build C extensions::

    rm varapp/filters/apply_bitwise.c    # clean up - it will be regenerated properly
    python3 setup.py build_ext --inplace

  Install the app::

    python3 setup.py install --record install_log.txt

  That should install all required Python dependencies and the
  application itself inside the ``$venv`` directory.

* Edit the settings file to fit your environment:

  The app needs a file with various settings (typically called ``settings.py``),
  a template of which is already present in the distribution inside
  ``varmed/settings/``.

  Typically the settings file should be written and stored externally, 
  then copied into the module inside ``varmed/settings/``. 
  
* Create the database:

  Log in to MySQL using the MYSQL_USER and MYSQL_PWD defined in settings.py::

    mysql -u<MYSQL_USER> -p<MYSQL_PWD>

  Create and empty database called "users_db" (or any other USERS_DB in settings.py)::

    CREATE DATABASE users_db DEFAULT CHARACTER SET utf8 DEFAULT COLLATE utf8_general_ci;

  Generate the database schema (from models)::

    python manage.py migrate

  At this point, trying to log in the app will probably tell you "User does not exist".
  You need to edit the database to add new users, variants dbs, and accesses of one to the other.
  For convenience, some sample data has already been prepared and can be loaded for each table like this::

    python manage.py loaddata resources/dumps/init/data_people.json
    python manage.py loaddata resources/dumps/init/data_users.json
    python manage.py loaddata resources/dumps/init/data_variantsdb.json
    python manage.py loaddata resources/dumps/init/data_dbaccess.json
    python manage.py loaddata resources/dumps/init/data_roles.json

  This will create a new user "admin" with password "admin", the role of "superuser",
  and initial access to a database called "mydb.db" (which does not exist yet).

* Apache configuration (httpd.conf)

  There is one .conf file specific to the user/virtual machine,
  and one created by `mod_wsgi`.
  The latter should never be edited direcly (that would get overwritten).
  We are interested in the user/machine specific one.

  Here is our development config (shortened), given as example::

    <VirtualHost *:80>
      ServerAdmin  ...
      DocumentRoot .../htdocs
      ServerName   varapp.vital-it.ch

      ProxyPass         /backend  http://localhost:8887/varapp
      ProxyPassReverse  /backend  http://localhost:8887/varapp

      <Directory ".../htdocs">
        AllowOverride All
        Options FollowSymLinks
        Order allow,deny
        Allow from all
      </Directory>
    </VirtualHost>

  Configure, then restart the server::

    sudo /etc/init.d/httpd restart

  or it might be::

    /sbin/service httpd restart


* Configure and run the Apache proxy (`mod_wsgi`)::
  
    mod_wsgi-express start-server varmed/wsgi.py \
        --port=8887 \
        --user varapp \
        --server-root=${SOURCE_DIR}/mod_wsgi-server \
        --processes 2 --threads 5 \
        --queue-timeout 60 --request-timeout 90 \
        --server-status

  ``varmed/wsgi.py`` contains the configuration for this step, and tells the app where to find
  the settings file. If it is not in ``varmed/settings`` or is not called ``settings.py``,
  you must edit ``varmed/wsgi.py`` accordingly.

  It sets up a proxy Apache server, hence the ProxyPass and ProxyPassReverse
  lines in the Apache config above.
  The ProxyPasslines will redirect :8000/backend queries to read at :8887/varapp.

  One is free to change the port number, processes and threads, or timeouts
  specified in the command above.

* Test that it works::

    curl http://127.0.0.1:8000/backend/

  (with the trailing slash) should respond "Hello World !".


Advanced
........

* For more control, one can set up the server configuration with::

    mod_wsgi-express setup-server varmed/wsgi.py [options]

  The result is a folder ``mod_wsgi_server`` in ``$SOURCE_DIR``
  with Apache config files and executables inside.

  Then one can call Apache binaries directly, for instance to restart the app::

    ${SOURCE_DIR}/mod_wsgi-server/apachectl restart

* Useful development options ::

    --reload-on-changes: restart the server everytime a change is made to the source files.
    --log-to-terminal: print log to standard out instead of Apache's error_log.

  For more options, see::

    mod_wsgi-express -h
    mod_wsgi-express start-server -h

* One can also use the app's ``manage.py`` to run `mod_wsgi`::

    python manage.py runmodwsgi --port 8887 [options]

.. An environment variable `DJANGO_SETTINGS_MODULE` is set automatically by Django when
the app is started to indicate where the settings are to be taken from.
But if one wants to run some part of the library in a script,
e.g. unit tests, one needs to specify it::
export DJANGO_SETTINGS_MODULE="varmed.settings.settings_example"
This makes references to the file
``$venv/lib/python3.4/site-packages/varmed/settings/settings_example.py``.


Frontend deployment
-------------------

The Javascript frontend can be found in `Github <https://github.com/varapp/varapp-frontend-react>`_.
Clone or download the archive and unarchive it.

Install `npm` (with the `node.js` installer, for instance)::

    yum -y install nodejs
    sudo npm install npm -g

The installation has been successfully tested with node v4.2.0 and npm 2.14.7.

Configuration parameters must be set in ``app/conf/conf.js``.
In particular, depending on whether you decided to protect the backend by using
the HTTPS protocol, you will need to set the `USE_HTTPS` variable.

Build the app::

    npm install
    bower install
    gulp build
    gulp targz

This will create a .tar.gz file in ``build/``.

Copy that archive into a destination folder that can be read by Apache, 
typically some ``htdocs/`` or ``/var/www/html/``, and extract. 
The destination folder is the one indicated by ``DocumentRoot`` in the Apache configuration.

