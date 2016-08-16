
.. _bamserver:

Serving BAM files for IGV view
==============================

If given access to BAM files, Varapp allows users to see the read alignments 
at the origin of the variants calls, directly in the app's window, 
thanks to `IGV.js <https://github.com/igvteam/igv.js/tree/master>`_.

The way IGV.js works is that for each requested sample, 
it downloads the BAM index to know the range of bytes 
corresponding to the genomic region to display. 
Then it makes Range requests to extract these bytes from the BAM.

Since BAM files are typically big, they will not be stored on the client's machine.
Thus we need to give it a URL base to find the BAM files, and this is
the ``BAM_SERVER_URL`` variable in the frontend's `conf/conf.js`.

Let's assume that you have all your BAM files stored in a directory ``BAM_PATH``.


The quick way, with Apache
..........................

If you want to share your BAM files with the world, just configure Apache to 
serve the directory ``BAM_PATH``. It is necessary to allow 
`byte Range requests <https://tools.ietf.org/html/rfc7233>`_.
Here is for example what our configuration looked like::

    <Directory "BAM_PATH">
        AllowOverride None
        Options FollowSymLinks
        Order allow,deny
        Allow from 127.0.0.1
        XBitHack Off
        <IfModule mod_php5.c>
          php_admin_flag engine off
        </IfModule>

        <Files ~ "\.(bam|.bai)$">
        <IfModule mod_headers.c>
            Header set Access-Control-Allow-Origin "http://localhost:3000"
            Header set Access-Control-Allow-Headers "origin, x-requested-with, content-type, Range"
            Header set Access-Control-Allow-Methods "PUT, GET, POST, DELETE, OPTIONS"
            Header set Access-Control-Allow-Credentials "true"
        </IfModule>
        </Files>
    </Directory>

* Set ``BAM_SERVER_URL`` to ``http[s]://<hostname>/BAM_PATH``.

* In the `bam` table of Varapp's users db, the ``key`` will be the BAM file name
  (or a sub-path starting from ``BAM_PATH``).


A more secure way
.................

Since for human data they are very sensible, they should not be downloadable
directly. There should be some sort of authentication. 
Here is how we implemented it in Varapp:

* Some BAM server application can return the appropriate BAM file
  when a corresponding ``key`` is passed in the URL, e.g.
  ``https://<host>/bamserver/<key>``
  
  That key can be anything - a secret hash, a file name, a full path, ...
  The correspondance between key and path to the BAM file is stored in 
  a database table.

  This BAM server must accept `byte Range requests <https://tools.ietf.org/html/rfc7233>`_.

* The same key is stored in the `bam` table of Varapp's users db, along with the 
  variants database id and the sample name.

* Set ``BAM_SERVER_URL`` to be ``http[s]://<host>/bamserver/<key>``.

Such a very simple BAM server can be found here: 
`<https://github.com/jdelafon/bam-server-scala>`_
and set up easily. In this case the key is a secret random string that is
shared between Varapp's and the BAM server databases.
But you are free to use another, or implement you own BAM server.



