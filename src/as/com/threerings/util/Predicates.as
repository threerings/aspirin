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

/**
 * Predicates suitable for Array.filter() and other needs.
 */
public class Predicates
{
    /**
     * A predicate that tests for null (or undefined) items.
     */
    public static function isNull (item :*, ... ignored) :Boolean
    {
        return (item == null);
    }

    /**
     * A predicate that tests for items that are not null (or undefined).
     */
    public static function notNull (item :*, ... ignored) :Boolean
    {
        return (item != null);
    }

    /**
     * Create a predicate that tests if the item is Util.equals() to the specified value.
     */
    public static function createEquals (value :Object) :Function
    {
        return function (item :*, ... _) :Boolean {
            return Util.equals(item, value);
        };
    }

    /**
     * Create a predicate that tests if the item has the specified property (with any value).
     */
    public static function createHasProperty (propName :String) :Function
    {
        return function (item :*, ... _) :Boolean {
            return (item != null) && item.hasOwnProperty(propName);
        };
    }

    /**
     * Create a predicate that tests if the item has a property that is Util.equals() to the
     * specified value.
     */
    public static function createPropertyEquals (propName :String, value :Object) :Function
    {
        return function (item :*, ... _) :Boolean {
            return (item != null) && item.hasOwnProperty(propName) &&
                Util.equals(item[propName], value);
        };
    }

    /**
     * Create a predicate that returns true if the item is in the specified Array.
     */
    public static function createIn (array :Array) :Function
    {
        return function (item :*, ... _) :Boolean {
            return ArrayUtil.contains(array, item);
        };
    }

    /**
     * Return a predicate that tests for items that are "is" the specified class.
     */
    public static function createIs (clazz :Class) :Function
    {
        return function (item :*, ... _) :Boolean {
            return (item is clazz);
        };
    }

    /**
     * Return a predicate that is the negation of the specified predicate.
     */
    public static function createNot (pred :Function) :Function
    {
        return function (... args) :Boolean {
            return !pred.apply(null, args);
        };
    }

    /**
     * Return a predicate that is true if all the specified predicate Functions are true
     * for any item.
     */
    public static function createAnd (... predicates) :Function
    {
        return function (... args) :Boolean {
            for each (var pred :Function in predicates) {
                if (!pred.apply(null, args)) {
                    return false;
                }
            }
            return true;
        };
    }

    /**
     * Return a predicate that is true if any of the specified predicate Functions are true
     * for any item.
     */
    public static function createOr (... predicates) :Function
    {
        return function (... args) :Boolean {
            for each (var pred :Function in predicates) {
                if (pred.apply(null, args)) {
                    return true;
                }
            }
            return false;
        };
    }
}
}
