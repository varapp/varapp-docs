
.. Non-breaking white space, to fill empty divs
.. |nbsp| unicode:: 0xA0
   :trim:

Installation
============

This page explains in all details how to deploy Varapp on a new, empty server.
The installation has been tested only on CentOS and Mac OSX.
In this example we will suppose that the OS is CentOS 6/7.

Varapp is a standard web application with decoupled backend (Python/Django/Cython)
and frontend (Javascript/React). It depends on the following components to work:

* Python3
* Apache
* MySQL
* SMTP server (telnet)
* Redis

Make sure that all of them are running before installing Varapp.
Where necessary, see the :doc:`Dependencies <deploy/dependencies>` section to install them 
in a way that is guaranteed to work.

.. toctree::
   :maxdepth: 1
   
   deploy/backend_local
   deploy/backend_prod
   deploy/dependencies
   deploy/backend_dev_notes

