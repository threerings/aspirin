//
// aspirin library - Taking some of the pain out of Actionscript development.
// Copyright (C) 2007-2012 Three Rings Design, Inc., All Rights Reserved
// http://github.com/threerings/aspirin
//
// This library is free software; you can redistribute it and/or modify it
// under the terms of the GNU Lesser General Public License as published
// by the Free Software Foundation; either version 2.1 of the License, or
// (at your option) any later version.
//
// This library is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
// Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public
// License along with this library; if not, write to the Free Software
// Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA

package com.threerings.util {

/**
 * A List contains an ordered collection of objects.
 *
 * @see com.threerings.util.Lists
 */
public interface List
{
    function add (o :Object) :Boolean;

    function addAt (index :int, o :Object) :void;

    function get (index :int) :Object;

    function set (index :int, o :Object) :void;

    function contains (o :Object) :Boolean;

    function indexOf (o :Object) :int;

    function lastIndexOf (o :Object) :int;

    function remove (o :Object) :Boolean;

    function removeAt (index :int) :Object;

    function size () :int;

    function isEmpty () :Boolean;

    function clear () :void;

    function toArray () :Array;

    function forEach (fn :Function) :void;
}
}
