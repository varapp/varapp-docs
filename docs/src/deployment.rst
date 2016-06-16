
.. Non-breaking white space, to fill empty divs
.. |nbsp| unicode:: 0xA0
   :trim:

Installation
============

This page explains in all details how to deploy Varapp on a new, empty server.
The installation has been tested only on CentOS and Mac OSX.
In this example we will suppose that the OS is CentOS 6/7.

Varapp is a standard web application with decoupled backend (Python/Django/Cython)
and frontend (Javascript/React).

Dependencies
------------

If necessary, see the :doc:`Dependencies <deploy/dependencies>` section to install them 
in a way that is guaranteed to work.

* Python3
* Apache (-devel)
* MySQL (MariaDb)
* SMTP server (telnet)
* Redis cache

.. toctree::
   :hidden:

   deploy/dependencies


Backend deployment
------------------

How to deploy the server-side (REST API):

.. toctree::
   :maxdepth: 1
   
   deploy/backend_local
   deploy/backend_prod
   deploy/backend_dev_notes

Frontend deployment
-------------------

How to deploy the web interface:

.. toctree::
   :maxdepth: 1

   deploy/frontend
   deploy/frontend_dev_notes

