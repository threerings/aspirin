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

package com.threerings.util.maps {

import com.threerings.util.Map;

/**
 * A skeletal building block for maps.
 * @private
 */
public /* abstract */ class AbstractMap
{
    /** @copy com.threerings.util.Map#size() */
    public function size () :int
    {
        return _size;
    }

    /** @copy com.threerings.util.Map#isEmpty() */
    public function isEmpty () :Boolean
    {
        // call size(), don't examine _size directly, this helps subclasses...
        return (0 == size());
    }

    /**
     * Return a String representation of this Map.
     */
    public function toString () :String
    {
        var s :String = "Map {";
        var theMap :Object = this;
        var comma :Boolean = false;
        forEach(function (key :Object, value :Object) :void {
            if (comma) {
                s += ", ";
            }
            s += ((key === theMap) ? "(this Map)" : key) + "=" +
                ((value === theMap) ? "(this Map)" : value);
            comma = true;
        });
        s += "}";
        return s;
    }

    /** @copy com.threerings.util.Map#forEach() */
    public function forEach (fn :Function) :void
    {
        throw new Error("Abstract");
    }

    /** The size of the map. @private */
    protected var _size :int;
}
}
