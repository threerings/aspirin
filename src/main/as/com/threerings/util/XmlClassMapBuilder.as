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
import com.threerings.util.maps.MapBuilder;

public class XmlClassMapBuilder
{
    public function constructorParamTypes (...types) :XmlClassMapBuilder
    {
        _ctorParamTypes = types;
        return this;
    }

    /**
     * Binds an XML element name to a constructor. 'classOrFactoryFunction' can either be
     * a 'Class' object, or a Function that generates an instance of the class.
     */
    public function map (elementName :String, classOrFactoryFunction :Object) :XmlClassMapBuilder
    {
        Preconditions.checkArgument(
            classOrFactoryFunction is Class || classOrFactoryFunction is Function,
            "classOrFactoryFunction must be of type Class or Function");

        var ctorFn :Function = (classOrFactoryFunction is Class ?
            F.constructor(Class(classOrFactoryFunction)) :
            classOrFactoryFunction as Function);

        var oldVal :Object = _entries.put(elementName, ctorFn);
        Preconditions.checkState(oldVal == null, "Duplicate mapping for '" + elementName + "'");
        return this;
    }

    public function mapWithClassName (clazz :Class) :XmlClassMapBuilder
    {
        return map(ClassUtil.tinyClassName(clazz), clazz);
    }

    public function build () :XmlClassMap
    {
        return new XmlClassMapImpl(_ctorParamTypes, _entries);
    }

    protected var _ctorParamTypes :Array = [];
    protected const _entries :Map = Maps.newMapOf(String); // Map<String, Function>
}

}

import com.threerings.util.Map;
import com.threerings.util.XmlClassMap;

class XmlClassMapImpl
    implements XmlClassMap
{
    public function XmlClassMapImpl (ctorParamTypes :Array, entries :Map)
    {
        _ctorParamTypes = ctorParamTypes;
        _entries = entries;
    }

    public function getConstructorParamTypes () :Array
    {
        return _ctorParamTypes;
    }

    public function getConstructor (xmlElement :XML) :Function
    {
        return _entries.get(xmlElement.localName());
    }

    protected var _ctorParamTypes :Array;
    protected var _entries :Map;
}
