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

import flash.utils.describeType;

public class Joiner
{
    /**
     * Return a String in the form "message [arg0=arg1, arg2=arg3 ... ]"
     * Avoids constructing a Joiner instance.
     * Useful for making messages during Error construction.
     */
    public static function pairs (message :String, ... args) :String
    {
        return pairsArray(message, args);
    }

    /**
     * Return a String in the form "message [arg0=arg1, arg2=arg3 ... ]"
     * Avoids constructing a Joiner instance.
     * Useful for making messages during Error construction.
     */
    public static function pairsArray (message :String, args :Array) :String
    {
        return output(message, format(true, "", args));
    }

    /**
     * Return a String in the form "message [arg0, arg1, arg2 ... ]"
     * Avoids constructing a Joiner instance.
     * Useful for making messages during Error construction.
     */
    public static function args (message :String, ... args) :String
    {
        return argsArray(message, args);
    }

    /**
     * Return a String in the form "message [arg0, arg1, arg2 ... ]"
     * Avoids constructing a Joiner instance.
     * Useful for making messages during Error construction.
     */
    public static function argsArray (message :String, args :Array) :String
    {
        return output(message, format(false, "", args));
    }

    /**
     * Do a simple toString() on an object, printing the public fields.
     */
    public static function simpleToString (obj :Object, fieldNames :Array = null) :String
    {
        return createFor(obj).addFields(obj, fieldNames).toString();
    }

    /**
     * Create a Joiner for depicting some state for the specified object.
     */
    public static function createFor (instance :Object) :Joiner
    {
        return new Joiner(ClassUtil.tinyClassName(instance));
    }

    /**
     * Construct a joiner with the specified message and starting args.
     */
    public function Joiner (message :String = "")
    {
        _msg = message;
        _details = "";
    }

    /**
     * Add arguments onto the joiner.
     */
    public function addArgs (... args) :Joiner
    {
        _details = format(false, _details, args);
        return this;
    }

    /**
     * Add arguments, in array form, onto the joiner.
     */
    public function addArgsArray (args :Array) :Joiner
    {
        return addArgs.apply(null, args);
    }

    /**
     * Add pairs onto the joiner.
     */
    public function add (... args) :Joiner
    {
        _details = format(true, _details, args);
        return this;
    }

//    public function setNullString (s :String) :Joiner
//    {
//        _nullStr = s;
//        return this;
//    }
//
//    public function setUndefinedString (s :String) :Joiner
//    {
//        _undefStr = s;
//        return this;
//    }

    /**
     * Add public fields, as pairs, to this joiner.
     */
    public function addFields (obj :Object, fieldNames :Array = null) :Joiner
    {
        if (fieldNames == null) {
            fieldNames = [];
            // this just dumps variables, not getters
            for each (var bit :String in describeType(obj)..variable.@name) {
                fieldNames.push(bit);
            }
            // get dynamic field names as well (e.g. { key1: val1, key2: val2 })
            for (var dynamicFieldName :String in obj) {
                fieldNames.push(dynamicFieldName);
            }
        }

        var args :Array = [];
        for each (var field :String in fieldNames) {
            args.push(field);
            try {
                args.push(obj[field]);
            } catch (re :ReferenceError) {
                args.push("<ReferenceError>");
            }
        }
        return add.apply(null, args);
    }

    /**
     * Turn this joiner into a String.
     */
    public function toString () :String
    {
        return output(_msg, _details);
    }

    /**
     * Bracket the details, unless they're empty.
     */
    protected static function output (msg :String, details :String) :String
    {
        return (details == "") ? msg : msg + " [" + details + "]";
    }

    /**
     * Format the args into a String: a0=a1, a2=a3, a4=a5, a6
     */
    protected static function format (pairs :Boolean, s :String, args :Array) :String
    {
        for (var ii :int = 0; ii < args.length; ii++) {
            if (s != "") {
                s += ", ";
            }
            s += argToString(args[ii]);
            if (pairs && (++ii < args.length)) {
                s += "=" + argToString(args[ii]);
            }
        }
        return s;
    }

    protected static function argToString (arg :*) :String
    {
//        if (arg === undefined) {
//            return String(_undefStr);
//        } else if (arg === null) {
//            return String(_nullStr);
//        }
        return String(arg);
    }

    protected var _msg :String;
    protected var _details :String;
//    protected var _nullStr :String;
//    protected var _undefStr :*;
}
}
