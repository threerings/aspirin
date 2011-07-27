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

import flash.utils.describeType;
import flash.utils.getDefinitionByName;
import flash.utils.getQualifiedClassName;

/**
 * Class related utility methods.
 */
public class ClassUtil
{
    /**
     * Get the full class name, e.g. "com.threerings.util.ClassUtil".
     * Calling getClassName with a Class object will return the same value as calling it with an
     * instance of that class. That is, getClassName(Foo) == getClassName(new Foo()).
     */
    public static function getClassName (obj :Object) :String
    {
        return getQualifiedClassName(obj).replace("::", ".");
    }

    /**
     * Get the class name with the last part of the package, e.g. "util.ClassUtil".
     */
    public static function shortClassName (obj :Object) :String
    {
        var s :String = getQualifiedClassName(obj);
        var dex :int = s.lastIndexOf(".");
        s = s.substring(dex + 1); // works even if dex is -1
        return s.replace("::", ".");
    }

    /**
     * Get just the class name, e.g. "ClassUtil".
     */
    public static function tinyClassName (obj :Object) :String
    {
        var s :String = getClassName(obj);
        var dex :int = s.lastIndexOf(".");
        return s.substring(dex + 1); // works even if dex is -1
    }

    /**
     * Return a new instance that is the same class as the specified
     * object. The class must have a zero-arg constructor.
     */
    public static function newInstance (obj :Object) :Object
    {
        var clazz :Class = getClass(obj);
        return new clazz();
    }

    public static function isSameClass (obj1 :Object, obj2 :Object) :Boolean
    {
        return (getQualifiedClassName(obj1) == getQualifiedClassName(obj2));
    }

    /**
     * Returns true if an object of type srcClass is a subclass of or
     * implements the interface represented by the asClass paramter.
     *
     * <code>
     * if (ClassUtil.isAssignableAs(Streamable, someClass)) {
     *     var s :Streamable = (new someClass() as Streamable);
     * </code>
     */
    public static function isAssignableAs (asClass :Class, srcClass :Class) :Boolean
    {
        if ((asClass == srcClass) || (asClass == Object)) {
            return true;

        // if not the same class and srcClass is Object, we're done
        } else if (srcClass == Object) {
            return false;
        }

        // ok, let's introspect on the class and see what we've got.
        var typeInfo :XMLList = describeType(srcClass).child("factory");

        // See which classes we extend.
        var exts :XMLList = typeInfo.child("extendsClass").attribute("type");
        var type :String;
        for each (type in exts) {
            if (asClass == getClassByName(type)) {
                return true;
            }
        }

        // See which interfaces we implement.
        var imps :XMLList = typeInfo.child("implementsInterface").attribute("type");
        for each (type in imps) {
            if (asClass == getClassByName(type)) {
                return true;
            }
        }

        return false;
    }

    public static function getClass (obj :Object) :Class
    {
        if (obj.constructor is Class) {
            return Class(obj.constructor);
        }
        return getClassByName(getQualifiedClassName(obj));
    }

    public static function getClassByName (cname :String) :Class
    {
        try {
            return (getDefinitionByName(cname.replace("::", ".")) as Class);

        } catch (error :ReferenceError) {
            Log.getLog(ClassUtil).warning("Unknown class", "name", cname, error);
        }
        return null; // error case
    }
}
}
