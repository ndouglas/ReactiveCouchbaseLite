ReactiveCouchbaseLite
=====================

A merger of Reactive Cocoa and Couchbase-Lite.

In the course of working with ReactiveCocoa and Couchbase-Lite together on a major project, I generated a decent amount of useful code that could be separated out from the project and made useful to other developers.  I'm working on this task here.

I'm not expecting this to be a major undertaking, since a lot of this code is already written and tested, but I am cleaning it up and refactoring a bit, and making it a bit more comprehensive, so please bear with me.

My highest priorities are correctness, thread-safety (I'm trying to make the interface completely thread-agnostic), and performance on large datasets (as large as CBL can comfortably operate).

Questions, comments, pull requests, and so forth are welcomed and greatly appreciated.  Development is active as of December 8, 2014 and expected to continue through the foreseeable future.  It will probably be deprecated when ReactiveCocoa 2 is.
