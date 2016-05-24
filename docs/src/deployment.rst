
.. Non-breaking white space, to fill empty divs
.. |nbsp| unicode:: 0xA0
   :trim:

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


* Set up an SMTP server (emails)::

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

The Python backend can be found in `Github <https://github.com/varapp/varapp-backend-py>`_.

* Clone or download the archive::

    git clone https://github.com/varapp/varapp-backend-py.git

* Create a Python virtual environment::

    venv=~/.virtualenvs/varapp     # Or any other location of your choice
    mkdir -p $venv
    pyvenv $venv
    source $venv/bin/activate

  This makes every python library you install from now on, including Varapp, exist only in this directory.
  So you have a clean environment, with no versions clashes or namespace problems.
  Another consequence is that uninstall varapp, you only need to ``rm -rf $venv``.

* Install these python libraries in the virtualenv::

    pip3 install --upgrade pip
    pip3 install 'mod_wsgi>=4.5.2'            # Apache mod for Python 
    pip3 install 'mod_wsgi-httpd>=2.4.12.6'   # Local, latest httpd version (can take a couple of minutes)
    pip3 install 'numpy>=1.10.0'              # necessary for Cython setup
    pip3 install 'cython>=0.23.4'             # necessary to build C extensions
    pip3 install 'mysqlclient>=1.3.7'         # MySQL driver

* Edit the settings file to fit your environment:

  The app needs a file with various settings (typically called ``settings.py``),
  a template of which is already present in the distribution inside
  ``varmed/settings/settings.py``. Edit this file according to your environment, in particular

  * ``GEMINI_DB_PATH``: the directory under which you will store the variants data.
  * ``DB_USERS``: the name of the MySQL database that stores users, db accesses etc.
  * Your MySQL connection settings.
  * Your SMTP (email server) settings.
  * Once in production, turn off ``DEBUG`` and change the ``SECRET_KEY``.

  Typically, the settings file should be written and stored externally, 
  then copied into the module to overwrite the above. 

  Common settings are in ``varmed/settings/base.py`` and can be overwritten
  in ``settings.py``, although usually you won't need to change anything there.

* Install:

  Enter the app's source folder.
  There should be a file ``setup.py`` in the current directory.

  Build C extensions::

    python3 setup.py build_ext --inplace

  Install the app::

    python3 setup.py install --record install_log.txt

  That should install all required Python dependencies and the
  application itself inside the ``$venv`` directory.

* Create the database:

  Log in to MySQL using the ``MYSQL_USER`` and ``MYSQL_PWD`` defined in settings.py,
  and create an empty database called "users_db" (or any other USERS_DB in settings.py)::

    mysql -u<MYSQL_USER> -p<MYSQL_PWD> --execute \
    "CREATE DATABASE users_db DEFAULT CHARACTER SET utf8 DEFAULT COLLATE utf8_general_ci;"

  Generate the database schema (from models)::

    python3 manage.py migrate

  You should see lines like::

    Operations to perform:
    Apply all migrations: contenttypes, sessions, auth, admin, varapp
    Running migrations:
    Rendering model states... DONE
    Applying contenttypes.0001_initial... OK
    Applying auth.0001_initial... OK
    Applying admin.0001_initial... OK
    ...

  At this point, you need to edit the database to add new users, variants dbs, and accesses of one to the other.
  For convenience, some sample data has already been prepared and can be loaded for each table like this::

    python3 manage.py loaddata resources/dumps/init/data_people.json
    python3 manage.py loaddata resources/dumps/init/data_roles.json
    python3 manage.py loaddata resources/dumps/init/data_users.json
    python3 manage.py loaddata resources/dumps/init/data_variantsdb.json
    python3 manage.py loaddata resources/dumps/init/data_dbaccess.json

  This will create a new user "admin" with password "admin", the role of "superuser",
  with access to a sample database "demo_mini".
  This user will be able to manage available databases from the frontend Admin page.

* Test with the local dev server:

  This will start a simple web server (to not use in production)::

    python3 manage.py runserver

  Now you can enter ``http://127.0.0.1:8000/varapp`` in your browser's address bar 
  and it should answer "Hello World!". 

* Configure and run the Apache proxy (`mod_wsgi`):
  
  The above looks nice already, but is not suitable for production. 
  We describe here how to serve the Python backend with Apache and mod_wsgi
  (but nothing prevents from using another web server instead)::

    mod_wsgi-express start-server varmed/wsgi.py \
        --port=8887 \
        --user <USERNAME> \
        --server-root=./mod_wsgi-server \
        --processes 2 --threads 5 \
        --queue-timeout 60 --request-timeout 90

  ``varmed/wsgi.py`` contains the configuration for this step, and tells the app where to find
  the settings file. If it is not in ``varmed/settings/`` or is not called ``settings.py``,
  you must edit ``varmed/wsgi.py`` accordingly.

  Do not forget to replace ``<USERNAME>`` by your own user name.
  One is free to change the port number, processes and threads, or timeouts
  specified in the command above.

  ``server-root`` is the directory where the wsgi/httpd configuration will be written,
  along with Apache control executables.

* Test that it works:

  You can enter ``http://127.0.0.1:8887/varapp`` in your browser's address bar 
  and it should answer "Hello World!". 
  This is the URL that the frontend will call to fetch data from the server.

* Add more data:

  Now you can add Gemini databases to the directory defined by ``GEMINI_DB_PATH`` in the settings.
  When the app (re-)starts, all sqlite3 databases present in that directory will be loaded.
  In the interface, that will make them available in the db selection menu, 
  and in the Admin page so that the admin can manage the access of each database
  to other users and himself.

  If you have not yet produced a Gemini database from your VCF, see :doc:`method`.



Advanced
........

* Useful `mod_wsgi` development options ::

    --reload-on-changes: restart the server everytime a change is made to the source files.
    --log-to-terminal: print log to standard out instead of Apache's error_log.

  For more options, see::

    mod_wsgi-express -h
    mod_wsgi-express start-server -h

* For more control, one can set up the server configuration with::

    mod_wsgi-express setup-server varmed/wsgi.py [options]

  The result is a folder ``mod_wsgi_server`` inside the source directory
  with Apache config files and executables inside.

  Then one can call Apache binaries directly, for instance to restart the app::

    mod_wsgi-server/apachectl restart

* An environment variable `DJANGO_SETTINGS_MODULE` is set automatically by Django when
  the app is started to indicate where the settings are to be taken from.
  But if one wants to run some part of the library in a script,
  e.g. unit tests, one needs to specify it::

    export DJANGO_SETTINGS_MODULE="varmed.settings.settings_example"

  This makes references to the file
   ``$venv/lib/python3.4/site-packages/varmed/settings/settings_example.py``.

  When using `mod_wsgi`, setting the environment variable will have no effect;
  instead, configure it in ``varmed/wsgi.py``


Frontend deployment
-------------------

From a precompiled distribution
...............................

The easier way to install it is to download the latest release archive:
`varapp-browser-react.tar.gz <https://github.com/varapp/varapp-frontend-react/releases/tag/v1.0>`_.

Copy that archive into a destination folder that can be read by Apache, 
typically some ``htdocs/`` or ``/var/www/html/``, and extract. 
The destination folder is the one indicated by ``DocumentRoot`` 
in the usual Apache configuration file (`httpd.conf`, see below).

From source
...........

The Javascript frontend can be found in `Github <https://github.com/varapp/varapp-frontend-react>`_.
Clone or download the archive and unarchive it.

Install `npm` (with the `node.js` installer, for instance)::

    yum -y install nodejs
    sudo npm install npm -g

The installation has been successfully tested with node v4.2.0 and npm 2.14.7.

Configuration parameters must be set in ``app/conf/conf.js``.
In particular, depending on whether you decided to protect the backend by using
the HTTPS protocol, you will need to set the `USE_HTTPS` variable.

Install sass (to compile .sass/.scss files to .css)::

    sudo gem install sass

(It requires Ruby, get it somehow if necessary).

Build the app::

    npm install
    bower install
    gulp build
    gulp targz

This will create a .tar.gz file in ``build/``. Then proceed as above starting from that archive.

Apache configuration (httpd.conf)
.................................

  We are interested in the user/machine specific Apache config file, 
  commonly called `httpd.conf`, often located in ``/etc/httpd/`` or in the
  ``apache2/`` directory.

  N.B. `mod_wsgi-express` generated another one that should not be 
  edited direcly (it would be overwritten anyway).

  Here is our development config (shortened), given as example::

    <VirtualHost *:80>
      ServerAdmin  admin_name
      DocumentRoot .../htdocs
      ServerName   varapp-demo.vital-it.ch

      ProxyPass         /backend  http://localhost:8887/varapp
      ProxyPassReverse  /backend  http://localhost:8887/varapp

      <Directory ".../htdocs">
        AllowOverride All
        Options FollowSymLinks
        Order allow,deny
        Allow from all
      </Directory>
    </VirtualHost>

  Configure, then restart Apache::

    sudo /etc/init.d/httpd restart

  or it might be::

    /sbin/service httpd restart

  The ProxyPasslines redirect ``:8000/backend`` (e.g. varapp-demo.vital-it.ch/backend) 
  queries to ``localhost:8887/varapp``.

