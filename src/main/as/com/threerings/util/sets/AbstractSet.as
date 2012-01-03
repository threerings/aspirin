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

package com.threerings.util.sets {

import com.threerings.util.Set;

/**
 * A skeletal building block for sets.
 * @private
 */
public /* abstract */ class AbstractSet
{
    /**
     * Return a String representation of this Set.
     * @public
     */
    public function toString () :String
    {
        var s :String = "Set [";
        var theSet :Object = this;
        var comma :Boolean = false;
        forEach(function (value :Object) :void {
            if (comma) {
                s += ", ";
            }
            s += (value === theSet) ? "(this Set)" : value;
            comma = true;
        });
        s += "]";
        return s;
    }

    /** @copy com.threerings.util.Set#forEach() */
    public function forEach (fn :Function) :void
    {
        throw new Error("Abstract");
    }
}
}
