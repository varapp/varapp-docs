
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


