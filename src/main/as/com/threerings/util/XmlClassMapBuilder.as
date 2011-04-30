package com.threerings.util {
import com.threerings.util.maps.MapBuilder;

public class XmlClassMapBuilder
{
    public function constructorParamTypes (...types) :XmlClassMapBuilder
    {
        _ctorParamTypes = types;
        return this;
    }

    public function map (elementName :String, clazz :Class) :XmlClassMapBuilder
    {
        var oldVal :Object = _entries.put(elementName, clazz);
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
    protected const _entries :Map = Maps.newMapOf(String);
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

    public function getConstructor (xmlElement :XML) :Class
    {
        return _entries.get(xmlElement.localName());
    }

    protected var _ctorParamTypes :Array;
    protected var _entries :Map;
}
