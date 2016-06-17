
.. Non-breaking white space, to fill empty divs
.. |nbsp| unicode:: 0xA0
   :trim:

This page describes how to setup your host machine with the tools that
Varapp needs to run. They may already be installed on your machine, in which
case you can skip the related section.

.. _LAMP:

Apache
++++++

We install the -devel version to have `apxs`, the plugins installer.
We need it to add `mod_wsgi`, so that Apache can serve Python files.

::
    
    sudo yum install httpd-devel
    sudo service httpd start

MySQL
+++++
  
In CentOS7, MySQL is now called MariaDB::

    sudo yum install mariadb-devel mariadb-server mariadb-client

For the classic mysql, the equivalent is::

    yum install mysql-community-devel mysql-community-server mysql-community-client mysql-community-libs-compat

N.B. In order for python driver ("mysqlclient") to work, we need the "-devel" version. 
Also it is compatible with MySQL up to version 5.5. For later versions, the "-compat"
lib is required.

Start/autostart the service::

    sudo systemctl [start/enable] mariadb.service

Create the root account (if necessary - depends on the MySQL version)::

    sudo /usr/bin/mysql_secure_installation

SMTP server (emails)
++++++++++++++++++++

We need an email server so that users can receive login information
in a secure way when signing in or resetting their password. 
Often, an SMTP server will already be available. The simplest one is `telnet`::

    sudo yum install telnet

Test that it works::

    telnet localhost 25
    
.. note:: If no service is available, these actions (e.g. sign in request) will not fail, 
    but the user interface will display an error, and no message will be sent.

Redis
+++++

Redis is an in-memory database that we use as a high-performance cache service.
It is a key component to Varapp's performance.

::

    wget http://download.redis.io/redis-stable.tar.gz
    tar xvzf redis-stable.tar.gz
    cd redis-stable
    make

Launch the server::

    src/redis-server &

Test that it works::

    redis-cli PING

(should answer "PONG").
For more details, see the `Redis docs <http://redis.io/documentation>`_.

Python 3
++++++++

The app has been developped and tested under Python 3.4/3.5.
Python3 provides binaries for Windows and OSX.
Here is how to install it from source (for Linux).

.. note:: Python3 has been built to not interfere with an existing Python2 installation. 
    Its executable is usually ``python3``, or could be specified by the version, e.g. ``python3.5``.
    
    Python3 is shipped with ``pip3``, the package manager, and ``pyvenv``, the virtual environments manager.
    If you don't see them, they may be called e.g. ``pip3.5``, ``pyvenv3.5``.

* Install necessary tools::

    sudo yum -y update
    sudo yum groupinstall -y development   # a bunch of dev tools
    sudo yum install -y zlib-dev openssl-devel sqlite-devel bzip2-devel

* Get the latest version::

    wget https://www.python.org/ftp/python/3.4.3/Python-3.4.3.tar.xz
    xz -d Python-3.4.3.tar.xz
    tar -xvf Python-3.4.3.tar

* Add ``/usr/local/lib`` to the system's ``ld.so.conf.d/`` and re-run ``ldconfig`` :
  
  The recommended way is to edit ``/etc/ld.so.conf`` or create a new file::

    sudo touch /etc/ld.so.conf.d/usrlocal.conf

  and put only the line "/usr/local/lib" inside. Then run as root::

    sudo ldconfig -v

  Alternatively, add this to the .bashrc::

    export PATH=$PATH:/usr/local/lib
    export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/lib

* Compilation:

  It must be compiled with `sqlite-devel` (just install `sqlite-devel` before compiling, as above).
  The `--enable-shared` option must be supplied to the "configure" script.
  Do not override an already existing version, in case some other local libs need it, so use
  `altinstall` instead of `install`::

    sudo ./configure --enable-shared
    sudo make && sudo make altinstall

* **[Optional]** The following aliases solve problems of sudo/non-sudo users, 
  and make it possible to call related executables simply as ``python3``, ``pip3``, etc.::

    sudo ln -s /usr/local/bin/pip3.4 /usr/bin/pip3
    sudo ln -s /usr/local/bin/python3.4 /usr/bin/python3
    sudo ln -s /usr/local/bin/pyvenv-3.4 /usr/bin/pyvenv

* **[Optional]** It is recommended to install the following Python libraries globally::

    pip3 install virtualenv         # virtual environments
    sudo yum install ncurses-devel  # for readline, see below
    sudo pip3 install readline      # to avoid strange characters when arrow keys are pushed

    
