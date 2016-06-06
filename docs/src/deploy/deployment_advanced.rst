
Build the frontend from source
..............................

The Javascript frontend can be found in `Github <https://github.com/varapp/varapp-frontend-react>`_.
Clone or download the archive and unarchive it.

Install `npm` (with the `node.js` installer, for instance)::

    yum -y install nodejs
    sudo npm install npm -g

The installation has been successfully tested with node v4.2.0 and npm 2.14.7.

Install sass (to compile .sass/.scss files to .css. It requires Ruby, get it somehow if necessary)::

    sudo gem install sass

Build the app::

    npm install
    bower install
    gulp build
    gulp targz

This will create a .tar.gz file in ``build/``. Then move this archive to where
Apache reads, extract, and edit ``app/conf/conf.js`` to specify the ``BACKEND_URL``.


Backend advanced features
.........................

* To recompile the Cython extensions (.pyx), before running ``setup.py install``, run::

    python3 setup.py build_ext --inplace

  This will produce the .c files corresponding to .pyx sources mentioned in ``setup.py``. 
  ``--inplace`` moves them to the same location as the sources.

* Useful `mod_wsgi` development options ::

    --reload-on-changes: restart the server everytime a change is made to the source files.
    --log-to-terminal: print log to standard out instead of Apache`s error_log.

  For more options, see::

    mod_wsgi-express -h
    mod_wsgi-express start-server -h

* For more control, one can set up the server configuration with::

    mod_wsgi-express setup-server varmed/wsgi.py [options]

  The result is a folder ``mod_wsgi_server`` inside the source directory
  with Apache config files and executables inside.

  Then one can call Apache binaries directly, for instance to restart the app::

    mod_wsgi-server/apachectl restart

  One important difference is that ``mod_wsgi-express start-server`` 
  will not kill an existing process to restart it, while the above does.

* An environment variable `DJANGO_SETTINGS_MODULE` is set automatically by Django when
  the app is started to indicate where the settings are to be taken from.
  But if one wants to run some part of the library in a script,
  e.g. unit tests, one needs to specify it::

    export DJANGO_SETTINGS_MODULE="varmed.settings.settings_example"

  This makes reference to the file
  ``$venv/lib/python3.4/site-packages/varmed/settings/settings_example.py``.

  When using `mod_wsgi`, setting the environment variable will have no effect;
  instead, configure it in ``varmed/wsgi.py`
