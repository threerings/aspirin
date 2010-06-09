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
 * Utility functions for checking function parameters and throwing appropriate errors.
 */
public class Preconditions
{
    /**
     * Check that the reference is not null (or undefined) and return it as a convenience.
     * @return the reference that was checked.
     * @throws TypeError
     */
    public static function checkNotNull (ref :*, message :String = null) :*
    {
        if (ref == null) {
            throw new TypeError(message || "");
        }
        return ref;
    }

    /**
     * Check that the specified expression is true.
     * @throws ArgumentError
     */
    public static function checkArgument (expression :Boolean, message :String = null) :void
    {
        if (!expression) {
            throw new ArgumentError(message || "");
        }
    }

    /**
     * Check that the specified index is valid: greater than or equal to 0, and less than size.
     * @return the index that was checked.
     * @throws RangeError
     */
    public static function checkIndex (index :int, size :int, message :String = null) :int
    {
        if ((index < 0) || (index >= size)) {
            throw new RangeError(message ||
                Joiner.pairs("Index out of bounds", "index", index, "size", size));
        }
        return index;
    }

    /**
     * Check that the specified value is not NaN and between the low and high values (inclusive).
     * Passing NaN for low or high will disable that test.
     * @return the value that was checked.
     * @throws RangeError
     */
    public static function checkRange (
        value :Number, low :Number, high :Number, message :String = null) :Number
    {
        if (isNaN(value) || (value < low) || (value > high)) {
            throw new RangeError(message ||
                Joiner.pairs("Value out of range", "value", value, "low", low, "high", high));
        }
        return value;
    }
}
}
