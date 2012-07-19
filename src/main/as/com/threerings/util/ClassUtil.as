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
import flash.utils.Dictionary;
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

        const metadata :Metadata = getMetadata(srcClass);
        return metadata.extSet.contains(asClass) || metadata.impSet.contains(asClass);
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

    protected static function getMetadata (forClass :Class) :Metadata
    {
        var metadata :Metadata = _metadata[forClass];
        if (metadata == null) {
            metadata = _metadata[forClass] = new Metadata(forClass);
        }
        return metadata;
    }

    protected static const _metadata :Dictionary = new Dictionary();
}
}

import flash.utils.Dictionary;
import flash.utils.describeType;

import com.threerings.util.ClassUtil;
import com.threerings.util.Set;
import com.threerings.util.maps.DictionaryMap;
import com.threerings.util.sets.MapSet;

class Metadata
{
    public const extSet :Set = new MapSet(new DictionaryMap());
    public const impSet :Set = new MapSet(new DictionaryMap());

    public function Metadata (forClass :Class)
    {
        const typeInfo :XMLList = describeType(forClass).child("factory");

        // See which classes we extend.
        const exts :XMLList = typeInfo.child("extendsClass").attribute("type");
        for each (var extStr :String in exts) {
            extSet.add(ClassUtil.getClassByName(extStr));
        }

        // See which interfaces we implement.
        var imps :XMLList = typeInfo.child("implementsInterface").attribute("type");
        for each (var impStr :String in imps) {
            impSet.add(ClassUtil.getClassByName(impStr));
        }
    }
}
