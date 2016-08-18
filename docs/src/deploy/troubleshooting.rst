
Troubleshooting
---------------

After an update
...............

Varpp is still under development. It means that a new version can have breaking changes.

* Settings: Make sure that your settings files still have the right fields,
  compared to the given template in both backend and frontend.
  In particular, new variables specific to new features.

* Cached internal data structures could have changed. Delete the Redis
  database and let it rebuild itself fron scratch.

* Database schema: The database model can have changed slightly,
  and accessing to an inexistent column or table will throw an error.
  Use `python3 manage.py migrate` after an update. It it conflicts too much,
  fix changes manually 
  (e.g. add missing columns based on server logs and models definition).


During installation
...................

Here are listed issues that could be encountered at various states
of the deployment:

* ``numpy/arrayobject.h: No such file or directory``: 

  Numpy must be installed before building Cython extensions.
  It should not happen anymore, so please file an issue.
  Installing the latest numpy version and reinstalling should fix it.

* ``ImportError: No module named 'varmed.settings.settings'``:

  Your settings file was probably moved or renamed, but the default
  is to look for a file "settings.py" in "varmed/settings/".
  You must tell Django where to find the settings and restart the server::

      export DJANGO_SETTINGS_MODULE='varmed.settings.my_new_settings_file'

* ``No module named ...``:

  A Python dependency is missing. All dependencies should get installed automatically.
  The most probable cause is that you ran ``python`` (Python 2) instead of ``python3``.
  Otherwise, please file an issue, and install the missing dependency with ``pip3 install <lib>``.
  It could also be a version clash outside of a virtualenv.

* ``django.core.cache.backends.base.InvalidCacheBackendError: Could not find backend 
  'django_redis.cache.RedisCache': No module named 'django_redis.cache'``: 

  Same as above.

* ``"module 'mod_wsgi' has no attribute 'server'"``:

  mod_wsgi could not use an existing Apache server. You can install the extension
  "mod_wsgi-httpd" to provide mod_wsgi with a usable Apache instance 
  (or if you want a more up-to-date version of it)::
    
      pip3 install mod_wsgi-httpd

  It should already get installed automatically in the latest versions of Varapp.

* ``django.db.utils.OperationalError: (1071, 'Specified key was too long; max key length is 1000 bytes')``:

  The main cause is that the default database engine is not InnoDB.
  Your installation of MySQL is probably too old. The driver Varapp uses to connect is "mysqlclient"
  and supports MySQL versions 4.1 to 5.5. If you install a later version of MySQL, 
  you will need to add the "-compat" libs, e.g.::

      yum install mysql-community-libs-compat

* ``django.db.utils.OperationalError: (1045, "Access denied for user 'root'@'localhost' (using password: YES)")``:

  Varapp could not connect to your MySQL users database.
  You must set ``MYSQL_USER`` and ``MYSQL_PWD`` (maybe also ``MYSQL_HOST`` and ``MYSQL_PORT``)
  in the settings to match you MySQL login information.

* ``EONENT``, especially for "gulp-ruby-sass", when compiling the frontend from source: 

  Means "no such file or directory" and probably sass is not installed. 
  Install sass (and Ruby if necessary)::

      sudo gem install sass

* ``django_redis.cache.RedisCache backend not found``:

  The library "django_redis" is too old. Update to version 4.4 or higher.
  This should not happen according to the package's dependencies,
  but it could be a version clash outside of a virtualenv.


