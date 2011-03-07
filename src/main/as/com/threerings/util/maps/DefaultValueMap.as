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
 * A Map that returns the specified default value for missing keys, rather than returning
 * undefined. containsKey() can still safely be used to see whether a mapping exists or not.
 */
public class DefaultValueMap extends ForwardingMap
{
    public function DefaultValueMap (source :Map, defaultValue :Object)
    {
        super(source);
        _defVal = defaultValue;
    }

    /** @inheritDoc */
    override public function get (key :Object) :*
    {
        var val :* = super.get(key);
        return (val !== undefined) ? val : _defVal;
    }

    /** The default value to return. @private */
    protected var _defVal :Object;
}
}
