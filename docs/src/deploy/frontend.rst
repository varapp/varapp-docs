

From a precompiled distribution
...............................

The easiest way to install it is to download the latest release archive:
`varapp-frontend-react.tar.gz <https://github.com/varapp/varapp-frontend-react/releases>`_.

Copy that archive into a destination folder that can be read by Apache, 
typically some ``htdocs/`` or ``/var/www/html/``, and extract. 
The destination folder is the one indicated by ``DocumentRoot`` 
in the usual Apache configuration file (`httpd.conf`, see below).

Edit the configuration file ``app/conf/conf.js`` to specify the ``BACKEND_URL``,
that all REST calls will use. E.g.: "`http://127.0.0.1:8000/varapp`" for the default 
local dev server, or "`https://varapp-demo.vital-it.ch/backend`" for our demo server (HTTPS),
depending on your server's specific configuration (see below for Apache).


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

Then restart Apache::

  sudo /etc/init.d/httpd restart
  
Depending on your system, it may be different, like 
``/sbin/service httpd restart``, or ``/etc/init.d/httpd restart``.

The ProxyPass lines are the common way to redirect ``<domain>/backend`` URLs
(e.g. varapp-demo.vital-it.ch/backend) to ``localhost:<port>/varapp``, 
the local wsgi server (that the client cannot access directly otherwise).

Replace ``*:80`` by ``*:443`` to use HTTPS instead of HTTP. Do not forget to 
edit the ``BACKEND_URL`` accordingly in ``app/conf/conf.js``.

