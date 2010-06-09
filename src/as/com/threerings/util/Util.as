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

import flash.utils.ByteArray;
import flash.utils.getQualifiedClassName;

/**
 * Contains a variety of utility functions.
 */
public class Util
{
    /**
     * Initialize the target object with values present in the initProps object and the defaults
     * object. Neither initProps nor defaults will be modified.
     * @throws ReferenceError if a property cannot be set on the target object.
     *
     * @param target any object or class instance.
     * @param initProps a plain Object hash containing names and properties to set on the target
     *                  object.
     * @param defaults a plain Object hash containing names and properties to set on the target
     *                 object, only if the same property name does not exist in initProps.
     * @param maskProps a plain Object hash containing names of properties to omit setting
     *                  from the initProps object. This allows you to add custom properties to
     *                  initProps without having to modify the value from your callers.
     */
    public static function init (
        target :Object, initProps :Object, defaults :Object = null, maskProps :Object = null) :void
    {
        var prop :String;
        for (prop in initProps) {
            if (maskProps == null || !(prop in maskProps)) {
                target[prop] = initProps[prop];
            }
        }

        if (defaults != null) {
            for (prop in defaults) {
                if (initProps == null || !(prop in initProps)) {
                    target[prop] = defaults[prop];
                }
            }
        }
    }

    /**
     * Return a var-args function that will attempt to pass only the arguments accepted by the
     * passed-in function. Does not work if the passed-in function is varargs, and anyway
     * then you don't need adapting, do you? An array of arguments to prepend to each call may also
     * be given.
     *
     *
     * @example
     * <listing version="3.0">
     * // let's say you have this function
     * function printUser (user :User) :void
     * {
     *     trace("UserId: " + user.id + ", name: " + user.name);
     * }
     *
     * // and you want to print all your users. (Normally the forEach callback requires 3 params)
     * allUsersArray.forEach(Util.adapt(printUser))
     *
     * // now let's say you have this function
     * function printUser (indent :String, user :User) :void
     * {
     *     trace(indent + "UserId: " + user.id + ", name: " + user.name);
     * }
     *
     * // and you want to print all your users with some spaces before each line:
     * allUsersArray.forEach(Util.adapt(printUser, "   "))
     * </listing>
     */
    public static function adapt (fn :Function, ... prepend) :Function
    {
        return function (... args) :* {
            // fit the args to the fn, filling in 'undefined' if growing
            if (prepend.length > 0) {
                args.unshift.apply(null, prepend);
            }
            ArrayUtil.resize(args, fn.length);
            return fn.apply(null, args);
        };
    }

    /**
     * Returns a function that will call each of the given functions in order.
     */
    public static function sequence (... functions) :Function
    {
        return function (... args) :void {
            for each (var fn :Function in functions) {
                fn.apply(null, args);
            }
        };
    }

    /**
     * Returns a function that returns its nth argument, or undefined if there is no nth argument.
     */
    public static function unit (n :int) :Function
    {
        return function (... args) :* {
            return args[n];
        };
    }

    /**
     * Returns true if the specified object is just a regular old associative hash.
     */
    public static function isPlainObject (obj :Object) :Boolean
    {
        return getQualifiedClassName(obj) == "Object";
    }

    /**
     * Is the specified object 'simple': one of the basic built-in flash types.
     */
    public static function isSimple (obj :Object) :Boolean
    {
        var type :String = typeof(obj);
        switch (type) {
        case "number":
        case "string":
        case "boolean":
            return true;

        case "object":
            return (obj is Date) || (obj is Array);

        default:
            return false;
        }
    }

    /**
     * Returns a property of an object by name if the object contains the property, otherwise
     * returns a default value.
     */
    public static function getDefault (props :Object, name :String, defaultValue :Object) :Object
    {
        return (name in props) ? props[name] : defaultValue;
    }

    /**
     * Get an array containing the property keys of the specified object, in their
     * natural iteration order.
     */
    public static function keys (obj :Object) :Array
    {
        var arr :Array = [];
        for (var k :* in obj) { // no "each": iterate over keys
            arr.push(k);
        }
        return arr;
    }

    /**
     * Get an array containing the property values of the specified object, in their
     * natural iteration order.
     */
    public static function values (obj :Object) :Array
    {
        var arr :Array = [];
        for each (var v :* in obj) { // "each" iterates over values
            arr.push(v);
        }
        return arr;
    }

    /**
     * A nice utility method for testing equality in a better way.
     * If the objects are Equalable, then that will be tested. Arrays
     * and ByteArrays are also compared and are equal if they have
     * elements that are equals (deeply).
     */
    public static function equals (obj1 :Object, obj2 :Object) :Boolean
    {
        // catch various common cases (both primitive or null)
        if (obj1 === obj2) {
            return true;

        } else if (obj1 is Equalable) {
            // if obj1 is Equalable, then that decides it
            return (obj1 as Equalable).equals(obj2);

        } else if ((obj1 is Array) && (obj2 is Array)) {
            return ArrayUtil.equals(obj1 as Array, obj2 as Array);

        } else if ((obj1 is ByteArray) && (obj2 is ByteArray)) {
            var ba1 :ByteArray = (obj1 as ByteArray);
            var ba2 :ByteArray = (obj2 as ByteArray);
            if (ba1.length != ba2.length) {
                return false;
            }
            for (var ii :int = 0; ii < ba1.length; ii++) {
                if (ba1[ii] != ba2[ii]) {
                    return false;
                }
            }
            return true;
        }

        return false;
    }

    /**
     * If you call a varargs method by passing it an array, the array
     * will end up being arg 1.
     */
    public static function unfuckVarargs (args :Array) :Array
    {
        return (args.length == 1 && (args[0] is Array)) ? (args[0] as Array)
                                                        : args;
    }
}
}
