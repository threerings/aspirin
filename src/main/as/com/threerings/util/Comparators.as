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
 * Contains sorting Comparators.
 * These functions take any parameters but require only the first to, so they are suitable
 * for passing to Array.sort(), or with a flex Sort object. Note that returning values other
 * than 1, 0, or -1 confuse a flex Sort object.
 * In general, these functions don't handle sorting undefined, it will be coerced to null.
 */
public class Comparators
{
    /**
     * Create a Comparator function that reverses the ordering of the specified Comparator.
     */
    public static function createReverse (comparator :Function) :Function
    {
        return function (o1 :Object, o2 :Object, ... ignored) :int {
            return comparator(o2, o1); // simply reverse the ordering
        };
    }

    /**
     * Create a Comparator appropriate for comparing objects of the specified class.
     * If an appropriate comparator cannot be determined, compareUnknowns is returned.
     */
    public static function createFor (clazz :Class) :Function
    {
        switch (clazz) {
        case String:  return compareStrings;
        case int:     return compareInts;
        case uint:    // fall through to Number (TODO?)
        case Number:  return compareNumbers;
        case Boolean: return compareBooleans;
        }
        if (ClassUtil.isAssignableAs(Comparable, clazz)) {
            return compareComparables;
        }
        return compareUnknowns;
    }

    /**
     * Create a Comparator function that sorts according to one or more fields of Objects.
     * Array.sortOn() only works with public variables, and not with public getters. This
     * implementation works with both.
     */
    public static function createFields (sortFields :Array, defaults :Array = null) :Function
    {
        if (defaults == null) {
            defaults = [];
        }
        // TODO: copy the arrays for safety?
        return function (a :Object, b :Object, ... ignored) :int {
            for (var ii :int = 0; ii < sortFields.length; ii++) {
                var sortField :String = sortFields[ii];
                var def :Object = defaults[ii];
                var aVal :Object = (a != null && a.hasOwnProperty(sortField) ? a[sortField] : def);
                var bVal :Object = (b != null && b.hasOwnProperty(sortField) ? b[sortField] : def);
                var c :int = compareUnknowns(aVal, bVal);
                if (c != 0) {
                    return c;
                }
            }
            return 0;
        };
    }

    /**
     * Compose another comparator into one that can compare null and non-null elements
     * safely, sorting the nulls to the bottom.
     *
     * @example
     * <listing version="3.0">
     * Arrays.sort(myStringArray, Comparators.createNullSafe(Comparators.compareStrings));
     * </listing>
     */
    public static function createNullSafe (comparator :Function) :Function
    {
        return function (o1 :Object, o2 :Object, ... ignored) :int {
            if (o1 === o2) { // same obj, or both null
                return 0;
            } else if (o1 == null) {
                return -1;
            } else if (o2 == null) {
                return 1;
            } else {
                return comparator(o1, o2);
            }
        };
    }

    /**
     * A standard Comparator for comparing Comparable values.
     */
    public static function compareComparables (c1 :Comparable, c2 :Comparable, ... ignored) :int
    {
        return c1.compareTo(c2);
    }

    /**
     * Compare two objects by their toString() values, case sensitively.
     * Yes, you can pass any objects to this function, and actionscript will coerce them
     * to Strings, calling toString() if not a simple type.
     */
    public static function compareStrings (s1 :String, s2 :String, ... ignored) :int
    {
        return (s1 == s2) ? 0 : ((s1 > s2) ? 1 : -1);
    }

    /**
     * Compare two objects by their toString().toLowerCase() values, case insensitively.
     * Yes, you can pass any objects to this function, and actionscript will coerce them
     * to Strings, calling toString() if not a simple type.
     */
    public static function compareStringsInsensitively (s1 :String, s2 :String, ... ignored) :int
    {
        return compareStrings(s1.toLowerCase(), s2.toLowerCase());
    }

    /**
     * Compare two Enums by their name().
     * If your Enum doesn't override toString(), then you could just use compareStrings.
     */
    public static function compareEnumsByName (e1 :Enum, e2 :Enum, ... ignored) :int
    {
        return compareStrings(e1.name(), e2.name());
    }

    /**
     * Compare two values whose type is not known at compile type. Tries to figure it out.
     * Also handles nulls.
     * Note that this method may look like it can safely compare heterogeneous types,
     * but <b>it cannot</b>. Consider the array: [ true, "meerkat", false ].
     * compareUnknowns(true, "meerkat") returns -1;
     * compareUnknowns("meerkat", false) returns -1;
     * but compareUnknowns(true, false) returns 1, which violates transitivity.
     * If in doubt, try using createNullSafe(compareStrings), which can safely and consistently
     * sort <b>anything</b>.
     */
    public static function compareUnknowns (o1 :Object, o2 :Object, ... ignored) :int
    {
        if (o1 === o2) { // use strict equality
            return 0;
        } else if (o1 == null) {
            return -1;
        } else if (o2 == null) {
            return 1;
        } else if (o1 is Comparable) {
            return Comparable(o1).compareTo(o2); // it doesn't matter if o2 is Comparable
        } else if ((o1 is Number) && (o2 is Number)) { // ints are Numbers
            return compareNumbers(Number(o1), Number(o2));
        } else if ((o1 is Boolean) && (o2 is Boolean)) {
            return compareBooleans(Boolean(o1), Boolean(o2));
        } else {
            // fuck it, coerce them both to String
            return compareStrings(String(o1), String(o2));
        }
    }

    /**
     * Compares two Boolean values.
     */
    public static function compareBooleans (v1 :Boolean, v2 :Boolean, ... ignored) :int
    {
        return (v1 == v2) ? 0 : (v1 ? 1 : -1);
    }

    /**
     * Compares two int values in an overflow safe manner.
     */
    public static function compareInts (v1 :int, v2 :int, ... ignored) :int
    {
        return (v1 > v2) ? 1 : (v1 == v2 ? 0 : -1);
    }

    /**
     * Compares two Number values, taking into account the intricacies of dealing with NaN.
     */
    public static function compareNumbers (v1 :Number, v2 :Number, ... ignored) :int
    {
        if (v1 > v2) {
            return 1;
        } else if (v1 < v2) {
            return -1;
        } else if (v1 == v2) {
            return 0;
        }
        // at this point, we know that at least one value is NaN. Luckily, there doesn't seem
        // to be a -0 in actionscript, even though it's supposedly IEEE-754. TODO: test more?
        return compareBooleans(isNaN(v1), isNaN(v2));
    }
}
}
