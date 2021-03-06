
.. Non-breaking white space, to fill empty divs
.. |nbsp| unicode:: 0xA0
   :trim:

Production setup
----------------

Serve with Apache and mod_wsgi
..............................

The development server (``manage.py runserver``) is not suitable for production.
We describe here how to serve the Python backend with Apache and mod_wsgi::

    mod_wsgi-express start-server varmed/wsgi.py \
        --port=8887 \
        --user <USERNAME> \
        --server-root=./mod_wsgi-server \
        --processes 2 --threads 5 \
        --queue-timeout 60 --request-timeout 90

where ``<USERNAME>`` is to be replaced by your own user name.
One is free to change the port number, processes and threads, or timeouts
specified in the command above.

It will behave then as a mini Apache serving locally at ``localhost:8887``.

* Test that it works:

  You can enter ``http://127.0.0.1:8887/varapp`` in your browser's address bar 
  and it should answer "Hello World!". 
  This is the URL that the frontend will call to fetch data from the server.

* Notes:
  
  "varmed/wsgi.py" contains the configuration for this step, and tells the app where to find
  the settings file. If the settings file was moved or renamed,
  you must edit "varmed/wsgi.py" or set :ref:`DJANGO_SETTINGS_MODULE <dev-django-settings-module>` accordingly.

  "--server-root" is the directory where the wsgi/httpd configuration will be written,
  along with Apache control executables.

For more details, see :doc:`backend_dev_notes`.


Production settings
...................

A few settings (in "varmed/settings/settings/py") have to be changed for security:

* Set ``DEBUG = False``
* Change the ``SECRET_KEY`` 

Typically, the settings file specific to the environment should be written and stored externally, 
then copied into the module before the installation to overwrite the current one. 

To change settings once the app is already up and running, reinstall and restart the wsgi server::

    python3 setup.py install
    ./mod_wsgi-server/apachectl restart


Apache configuration
....................

We are interested in the user/machine specific Apache config file, 
commonly called `httpd.conf`, often located in ``/etc/httpd/`` or in the
``apache2/`` directory.

N.B. `mod_wsgi-express` generated another one that should not be 
edited direcly (it would be overwritten anyway).

Here is our development config (shortened), given as example::

  <VirtualHost *:80>
    ServerAdmin  admin_name
    DocumentRoot /var/www/html/varapp
    ServerName   varapp-demo.vital-it.ch

    ProxyPass         /backend  http://localhost:8887/varapp
    ProxyPassReverse  /backend  http://localhost:8887/varapp

    <Directory "/var/www/html/varapp">
      AllowOverride All
      Options FollowSymLinks
      Order allow,deny
      Allow from all
    </Directory>
  </VirtualHost>

Then restart Apache::

  sudo /etc/init.d/httpd restart
  
Depending on your system, it may be different, like 
``/sbin/service httpd restart``, or ``/etc/init.d/httpd restart``.

The ProxyPass lines are the common way to redirect ``<domain>/backend`` URLs
(e.g. varapp-demo.vital-it.ch/backend) to ``localhost:<port>/varapp``, 
the local wsgi server (that the client cannot access directly otherwise).

Using HTTPS (SSL)
.................

Now the client accesses to Varapp through an Apache proxy. 
The backend itself is not reachable from the outside.
Since the communication between Apache and the backend is local,
it is usually not necessary to secure this communication. 
However, we need to encrypt data between the client and the Apache proxy.

Using SSL requires to have a certificate. The best way is to buy an official one. 
You can also use a self-signed certificate, but this will warn every user on first 
connection that they might be at risk, until they accept to make an exception 
in their browser. Until then, CURL will also fail with a ERR_INSECURE_RESPONSE 
error (use -k option when testing to bypass it).

* Add a new VirtualHost similar as above, but replacing ``*:80`` by ``*:443``.
* Add SSL options and certificate to the config.
* Keep the ProxyPass lines just as they were before.

You config then should look like this::

  <IfModule mod_ssl.c>
  <VirtualHost *:443>
    ...
    SSLEngine on
    SSLCertificateFile    .../varapp.crt
    SSLCertificateKeyFile .../varapp.key
    ...
    ProxyPass         /backend  http://localhost:8887/varapp
    ProxyPassReverse  /backend  http://localhost:8887/varapp
    ...
  </VirtualHost>
  </IfModule>

* Edit the ``BASE_URL`` in the settings to point to the new HTTPS address.
* Edit the ``BACKEND_URL`` in the frontend's ``app/conf/conf.js`` to point to the new HTTPS address.

I you really want to use HTTPS between Apache and the local Django backend, 
you will have to add a Strict-Transport-Security header in Apache,
and look at `Django docs <https://docs.djangoproject.com/en/1.10/topics/security/#ssl-https>`_ 
to configure it in its settings.

