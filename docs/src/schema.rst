
Database schema
===============

Here we describe the MySQL users database.
For the Gemini database schema, refer to 
`their documentation <http://gemini.readthedocs.io/en/latest/content/database_schema.html>`_.


Table "Roles"
-------------

A role is given to a user to give him rights to perform certain actions.

* name: 'superuser', 'admin', 'head', 'guest', etc.
* rank [INT]: 1 for superuser, 2 for admin, etc.
* can_validate_user [TINYINT]
* can_delete_user [TINYINT]


Table "People"
--------------

Gathers details about a user.

* firstname 
* lastname 
* institution
* street
* city
* phone [VARCHAR]
* is_laboratory [TINYINT]
* laboratory [FOREIGN KEY to "People"]


Table "Users"
-------------

Representation of a user. Requires a Role and a minimal description in People.

* username
* password: hashed, using salt
* salt: a random string to generate hashes more robust to rainbow tables
* email
* code: a random code unique to that user
* activation_code: code that must be sent to activate the account
* is_active [TINYINT]
* is_password_reset [TINYINT]
* person [FOREIGN KEY to "People"]
* role [FOREIGN KEY to "Roles"]


Table "VariantsDb"
------------------

Represents a variants dataset. "filename" and "hash" must be unique together.

* name: unique internal name of the database in the app, usually the file name without extension
* visible_name: (unused yet) maybe not unique name to display in the interface
* filename: name of the sqlite file
* location: path, directory constaining the sqlite file
* hash: SHA1 sum of the sqlite file
* description
* size [BIGINT]: in bytes
* is_active [TINYINT]
* parent_db_id [FOREIGN KEY to "VariantsDb"]: if it represents an updated version of another entry, the id of that older entry


Table "DbAccess"
----------------

Manages accesses of users to variants databases.

* is_active [TINYINT]
* user [FOREIGN KEY to "Users"]
* variants_db [FOREIGN KEY to "VariantsDb"]


Table "Preferences"
-------------------

(Unused yet). Personal settings of a user, e.g. set of favorite filters or annotation columns.


Table "Annotation"
------------------

Tracking the sources of annotation used to create a variants database.

* source: annotation tool
* source_version
* annotation: kind of annotation, e.g. ClinVar, 1000Genomes, Sift,...
* annotation_version
* is_active [TINYINT]
* variants_db [FOREIGN KEY to "VariantsDb"]


Table "Bookmarks"
-----------------

Records states of a user's analysis, recorded with the bookmarking functionality.

* query: a string representing a state of the app, e.g. the query part of the URL
* description: currently used to store a timestamp for unique identification
* long_description: what the user entered as a bookmark description in the interface
* is_active [TINYINT]
* db_access [FOREIGN KEY to "DbAccess"]


Table "History"
---------------

(unused yet). Record user actions to provide an "auto-save" functionality.
