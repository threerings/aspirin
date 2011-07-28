//
// aspirin library - Taking some of the pain out of Actionscript development.
// Copyright (C) 2007-2011 Three Rings Design, Inc., All Rights Reserved
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
 * A Set contains unique instances of objects.
 *
 * @see com.threerings.util.Sets
 */
public interface Set
{
    /**
     * Adds the specified element to the set if it's not already present.
     * Returns true if the set did not already contain the specified element.
     */
    function add (o :Object) :Boolean;

    /**
     * Returns true if this set contains the specified element.
     */
    function contains (o :Object) :Boolean;

    /**
     * Removes the specified element from this set if it is present.
     * Returns true if the set contained the specified element.
     */
    function remove (o :Object) :Boolean;

    /**
     * Retuns the number of elements in this set.
     */
    function size () :int;

    /**
     * Returns true if this set contains no elements.
     */
    function isEmpty () :Boolean;

    /**
     * Remove all elements from this set.
     */
    function clear () :void;

    /**
     * Returns all elements in the set in an Array.
     * The Array is not a 'view': it can be modified without disturbing
     * the Map from whence it came.
     */
    function toArray () :Array;

    /**
     * Call the specified function, which accepts an element as an argument.
     * Signature:
     * function (o :Object) :void
     *    or
     * function (o :Object) :Boolean
     *
     * If you return a Boolean, you may return <code>true</code> to indicate that you've
     * found what you were looking for, and halt iteration.
     */
    function forEach (fn :Function) :void;
}
}
