//
// aspirin library - Taking some of the pain out of Actionscript development.
// Copyright (C) 2007-2011 Three Rings Design, Inc., All Rights Reserved
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

import com.threerings.util.Map;

/**
 * A forwarding Map that runs keys() and values() through forEach(), to take
 * advantage of subclass logic therein.
 * @private
 */
public /* abstract */ class ForeachingMap extends ForwardingMap
{
    public function ForeachingMap (source :Map)
    {
        super(source);
    }

    /** @inheritDoc */
    override public function keys () :Array
    {
        var arr :Array = [];
        forEach(function (k :*, v :*) :void {
            arr.push(k);
        });
        return arr;
    }

    /** @inheritDoc */
    override public function values () :Array
    {
        var arr :Array = [];
        forEach(function (k :*, v :*) :void {
            arr.push(v);
        });
        return arr;
    }
}
}
