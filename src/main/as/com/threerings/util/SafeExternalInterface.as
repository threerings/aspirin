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

import flash.external.ExternalInterface;

/**
 * A wrapper around ExternalInterface that fails silently if ExternalInterface is not available,
 * instead of throwing an error.
 */
public class SafeExternalInterface
{
    public static function addCallback (functionName :String, closure :Function) :void
    {
        if (available) {
            ExternalInterface.addCallback(functionName, closure);
        }
    }

    public static function removeCallback (functionName :String) :void
    {
        addCallback(functionName, null);
    }

    public static function call (functionName :String, ...arguments) :*
    {
        if (available) {
            arguments.unshift(functionName);
            return ExternalInterface.call.apply(null, arguments);
        } else {
            return undefined;
        }
    }

    public static function get available () :Boolean
    {
        return ExternalInterface.available;
    }

    public static function get marshallExceptions () :Boolean
    {
        return (available && ExternalInterface.marshallExceptions);
    }

    public static function set marshallExceptions (val :Boolean) :void
    {
        if (available) {
            ExternalInterface.marshallExceptions = val;
        }
    }

    public static function get objectId () :String
    {
        return (available ? ExternalInterface.objectID : "");
    }
}

}
