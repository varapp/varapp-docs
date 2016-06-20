
Build from source
.................

The Javascript frontend can be found in `Github <https://github.com/varapp/varapp-frontend-react>`_.
Clone or download the archive and unarchive it.

Install `npm` (with the `node.js` installer, for instance)::

    sudo yum -y install nodejs
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

