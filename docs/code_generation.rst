Code Generation
***************

Code generation in ``cmake-helpers`` generates code for C or C++. Currently there is one function which
embeds any resource as a string literal or binary array into C or C++ code. This serves as a replacement of the
C23 `#embed`_ directive.

.. _#embed: https://en.cppreference.com/w/c/preprocessor/embed

.. include:: cmake_helpers.rst
   :parser: rst
   :start-line: 0
   :end-line: 2