
Updating Varapp
---------------

Varapp is still under development. It means that a new version can have breaking changes.

* **Clear the cache**: Cached internal data structures could have changed. 
  **Delete the Redis database** and let it rebuild itself from scratch.

* **Settings**: Make sure that your settings files still have the right fields,
  compared to the given template in both backend and frontend.
  In particular, new variables specific to new features.

* **Database schema**: The database model can have changed slightly,
  and accessing an inexistent column or table will throw an error.
  In this case, try using ``python3 manage.py migrate`` after an update. 
  It it conflicts too much, fix changes manually 
  (e.g. add missing columns based on server logs and models definition).
  In the worst case, dump the data, create a new db, use the migrate command,
  then copy the data back.

* **Clear your browser's cache**: You browser can keep in memory several static parts of
  the interface for efficiency. After an update, the older cached parts can appear instead
  of the new features, although the former will get cleaned eventually after some time.
  In most browsers, you can find such an option somewhere in the browser settings:
  `Firefox <https://support.mozilla.org/en-US/kb/how-clear-firefox-cache>`_ 
  - `Chrome <https://support.google.com/accounts/answer/32050?hl=en>`_ 
  - `Safari <https://kb.wisc.edu/page.php?id=45060>`_.
