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
            Function(classOrFactoryFunction));

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
