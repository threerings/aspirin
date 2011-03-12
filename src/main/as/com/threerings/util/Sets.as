//
// $Id$
//
// aspirin library - Taking some of the pain out of Actionscript development.
// Copyright (C) 2007-2010 Three Rings Design, Inc., All Rights Reserved
// http://code.google.com/p/ooo-aspirin/
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

import com.threerings.util.sets.MapSet;
import com.threerings.util.sets.SetBuilder;

/**
 * Factory methods for creating Sets.
 *
 * @example
 * <listing version="3.0">
 * // contains the userIds of seen players
 * var seenUsers :Set = Sets.newSetOf(int);
 * </listing>
 *
 * @example
 * <listing version="3.0">
 * // contains a cache of the last 5 added instances of the Hashable class User.
 * var users :Set = Sets.newBuilder(User).makeLRI(5).build();
 * </listing>
 */
// TODO: expiring Sets
// TODO: weak-value Sets (requires weak-key maps)
public class Sets
{
    /**
     * Create a new Set for storing values of the specified class. If values is given, the items in
     * the Array are added to the created Set.
     */
    public static function newSetOf (valueClazz :Class, values :Array=null) :Set
    {
        var set :Set = new MapSet(Maps.newMapOf(valueClazz));
        if (values != null) {
            for each (var val :Object in values) {
                set.add(val);
            }
        }
        return set;
    }

    /**
     * Create a new sorted Set for storing value of the specified class.
     */
    public static function newSortedSetOf (valueClazz :Class, comp :Function = null) :Set
    {
        return new MapSet(Maps.newSortedMapOf(valueClazz, comp));
    }

    /**
     * Create a SetBuilder for creating a more complicated Set type.
     *
     * @example
     * <listing version="3.0">
     * // builds a sorted Set that keeps the 10 most-recently inserted entries.
     * var mySet :Set = Sets.newBuilder(String)
     *     .makeSorted()
     *     .makeLRI(10)
     *     .build();
     * </listing>
     */
    public static function newBuilder (valueClazz :Class) :SetBuilder
    {
        return new SetBuilder(valueClazz);
    }

    /**
     * Return true if the two sets are equal.
     */
    public static function equals (a :Set, b :Set) :Boolean
    {
        if (a === b) {
            return true;

        } else if (a == null || b == null || (a.size() != b.size())) {
            return false;
        }

        // now see if they have the same contents (assume they do, for empty maps)
        var sameContents :Boolean = true;
        a.forEach(function (val :Object) :Boolean {
            if (!b.contains(val)) {
                sameContents = false;
            }
            return !sameContents; // keep iterating until sameContents is false
        });
        return sameContents;
    }

    /**
     * Calculates the union of a and b and places it in result.
     * a and b are unmodified. result must be empty, and must not be a or b.
     *
     * @return result
     */
    public static function union (a :Set, b :Set, result :Set) :Set
    {
        checkSets(a, b, result);

        a.forEach(result.add);
        b.forEach(result.add);

        return result;
    }

    /**
     * Calculates the intersection of a and b and places it in result.
     * a and b are unmodified. result must be empty, and must not be a or b.
     *
     * @return result
     */
    public static function intersection (a :Set, b :Set, result :Set) :Set
    {
        checkSets(a, b, result);

        // iterate the smaller of the two sets
        if (b.size() < a.size()) {
            var tmp :Set = a;
            a = b;
            b = tmp;
        }

        a.forEach(function (o :Object) :void {
            if (b.contains(o)) {
                result.add(o);
            }
        });

        return result;
    }

    /**
     * Calculates a - b and places it in result.
     * a and b are unmodified. result must be empty, and must not be a or b.
     *
     * @return result
     */
    public static function difference (a :Set, b :Set, result :Set) :Set
    {
        checkSets(a, b, result);

        a.forEach(function (o :Object) :void {
            if (!b.contains(o)) {
                result.add(o);
            }
        });

        return result;
    }

    /**
     * Tests if at least one entry in a set meets a condition.
     * @param set the set whose entries are to be tested
     * @param condition a function that tests a set entry:
     * <listing version="3.0">
     *     function condition (o :Object) :Boolean
     * </listing>
     * @see Predicates
     */
    public static function some (theSet :Set, condition :Function) :Boolean
    {
        var found :Boolean = false;
        theSet.forEach(function (o :Object) :Boolean {
            if (condition(o)) {
                found = true;
                return true;
            }
            return false;
        });
        return found;
    }

    /**
     * Adds an Array of objects to the given set.
     * @return true if any object was added to the set, and false otherwise.
     */
    public static function addAll (theSet :Set, objects :Array) :Boolean
    {
        var modified :Boolean = false;
        for each (var o :Object in objects) {
            if (theSet.add(o)) {
                modified = true;
            }
        }
        return modified;
    }

    /**
     * Helper method for Set operations.
     */
    protected static function checkSets (a :Set, b :Set, result :Set) :void
    {
        if (a == result || b == result) {
            throw new ArgumentError("result must not be a or b");
        }
        if (result.size() > 0) {
            throw new ArgumentError("result must be empty");
        }
    }
}
}
