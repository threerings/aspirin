The aspirin library contains utility classes for ActionScript 3. These were developed at [Three Rings Design](http://www.threerings.net) during the creation of [Whirled](http://www.whirled.com) and other games.

API documentation
==================

Note: APIs may change
Aspirin is meant to be a .swc that you link against when building a swf, not a runtime shared library (RSL). We may modify or delete methods in incompatible ways in order to improve the library. Typically we will deprecate a method for a while first, so it should not be difficult to keep up with changes.

Adding aspirin.swc to your build
================================
Integration into a Maven- or Ivy-based build is easy. Add a dependency on com.threerings:aspirin:1.13. Aspirin is published to Maven Central, so you need not add it to your local Maven repository.

You can also [download aspirin-1.13.swc](https://github.com/downloads/threerings/aspirin/aspirin-1.13.swc).

You can also build it from source and incorporate it into your build in any way that suits your fancy.
