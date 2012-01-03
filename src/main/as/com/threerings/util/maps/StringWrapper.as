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

package com.threerings.util.maps {

import com.threerings.util.Hashable;
import com.threerings.util.StringUtil;

/**
 * Wraps Strings (and nulls) for use in a HashMap.
 *
 * @private
 */
// This can be made a private subclass of HashMap when the Flash CS3 compiler doesn't choke on it.
public class StringWrapper
    implements Hashable
{
    public function StringWrapper (val :String)
    {
        _val = val;
    }

    public function hashCode () :int
    {
        return StringUtil.hashCode(_val); // this function returns 0 for nulls
    }

    public function equals (other :Object) :Boolean
    {
        return (other is StringWrapper) && (_val == StringWrapper(other)._val);
    }

    public function get () :String
    {
        return _val;
    }

    /** @private */
    protected var _val :String;
}
}
