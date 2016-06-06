
.. Non-breaking white space, to fill empty divs
.. |nbsp| unicode:: 0xA0
   :trim:

Installation
============

This page explains in all details how to deploy Varapp on a new, empty server.
The installation has been tested only on CentOS and Mac OSX.
In this example we will suppose that the OS is CentOS 6/7.

Varapp is a standard web application with decoupled backend (Python)
and frontend (Javascript).

Backend deployment
------------------

.. include:: deploy/deployment_backend.rst

Frontend deployment
-------------------

.. include:: deploy/deployment_frontend.rst

Notes to developers
-------------------

.. include:: deploy/deployment_advanced.rst
