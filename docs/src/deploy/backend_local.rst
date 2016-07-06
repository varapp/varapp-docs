
.. Non-breaking white space, to fill empty divs
.. |nbsp| unicode:: 0xA0
   :trim:

Install varapp
..............

* Clone or download the archive from `Github <https://github.com/varapp/varapp-backend-py>`_::

    git clone https://github.com/varapp/varapp-backend-py.git

* **[Optional, recommended]** Create a Python virtual environment::

    venv=~/.virtualenvs/varapp     # Or any other location of your choice
    mkdir -p $venv; pyvenv $venv; source $venv/bin/activate

  This makes every python library you install from now on, including Varapp, exist only in this directory.
  To uninstall varapp, you only need to ``rm -rf $venv``.

* Enter the app's source folder and edit the **settings file** at "varmed/settings/settings.py" 
  to fit your environment (at least the MySQL connection settings).

* Install:

  There should be a file "setup.py" in the current directory.
  Install all required Python dependencies together with Varapp itself::

    python3 setup.py install

Create the database
+++++++++++++++++++

* Log in to MySQL using the ``MYSQL_USER`` and ``MYSQL_PWD`` defined in the settings.
  and create an empty database called "users_db" (or the ``USERS_DB`` you set in the settings)::

    mysql -u<MYSQL_USER> -p<MYSQL_PWD> --execute \
    "CREATE DATABASE users_db DEFAULT CHARACTER SET utf8 DEFAULT COLLATE utf8_general_ci;"

  It will contain users information, available variants databases, accesses of one to the other, etc.

* Generate the database schema (from models) and some sample data::

    python3 manage.py migrate
    python3 manage.py loaddata resources/dumps/init/demo_data.json

  This will create a new user "admin" with password "admin", the role of "superuser",
  and access to a sample database "demo_mini".
  This superuser will be able to manage variants databases and accesse from the frontend Admin page.

.. note::

    If you changed ``GEMINI_DB_PATH`` in the settings, you will need to move the
    demo database from ``resources/db/`` to that new location in order to access it.


Serve the app
+++++++++++++

This will start a simple local web server::

    python3 manage.py runserver
  
Now you can enter ``http://127.0.0.1:8000/varapp`` in your browser's address bar 
and it should answer "Hello World!". 

See :doc:`backend_prod` to see how to deploy it on a larger scale.

Add more data
+++++++++++++

Now you can add Gemini databases to the directory defined by ``GEMINI_DB_PATH`` in the settings.
When the app (re-)starts, all sqlite3 databases present in that directory will be loaded.
In the interface, that will make them available in the db selection menu, 
and in the Admin page so that the admin can manage the access of each database
to other users and himself.

If you have not yet produced a Gemini database from your VCF, see :doc:`../data_preparation`.

Install the web interface
+++++++++++++++++++++++++

The easiest way is to download the latest release archive:
`varapp-frontend-react.tar.gz <https://github.com/varapp/varapp-frontend-react/releases>`_.

* Copy that archive into a destination folder that can be read by your web server, and extract. 
  The web server directory is typically "/var/www/html/" (Linux), 
  "/Library/WebServer/Documents/" (OSX), 
  or for Apache the one indicated by "DocumentRoot" in its configuration. 

* Test that it works locally:

  Now point your browser to the address ``localhost/`` in your browser's address bar 
  and you should see the login screen. 

  If you placed the files in a subfolder (recommended), e.g. "/var/www/html/varapp-web/", 
  then the address becomes ``localhost/varapp-web/``.

* See :doc:`backend_prod` to see how to deploy it on a larger scale.
