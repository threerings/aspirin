package com.threerings.util {

public interface XmlClassMap
{
    function getConstructorParamTypes () :Array;
    function getConstructor (xmlElement :XML) :Class;
}

}
