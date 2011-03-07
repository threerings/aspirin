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

import com.threerings.util.Comparators;
import com.threerings.util.Map;
import com.threerings.util.Util;

/**
 * A sorted Map implementation.
 * Note that the sorting is performed when you iterate over the map, the internal representation
 * is not sorted. Thus, it does not offer performance benefits, it is merely a convenience class.
 */
public class SortedMap extends ForwardingMap
{
    /**
     * Construct a SortedMap.
     *
     * @param source the backing Map
     * @param comp the Comparator used to sort the keys, or null to use Comparators.compareUnknown.
     */
    public function SortedMap (source :Map, comp :Function = null)
    {
        super(source);
        _comp = comp || Comparators.compareUnknowns;
    }

    /** @inheritDoc */
    override public function keys () :Array
    {
        var keys :Array = super.keys();
        keys.sort(_comp);
        return keys;
    }

    /** @inheritDoc */
    override public function values () :Array
    {
        // not very optimal, but we need to return the values in order...
        return keys().map(Util.adapt(get));
    }

    /** @inheritDoc */
    override public function forEach (fn :Function) :void
    {
        // also not very optimal. In an ideal world we'd maintain an ordering of entries,
        // but since we can be combined with expiring maps, etc, this is fine for now.
        var keys :Array = keys();
        for each (var key :Object in keys) {
            if (Boolean(fn(key, get(key)))) {
                return;
            }
        }
    }

    /** The comparator used to sort the keys of this Map. @private */
    protected var _comp :Function;
}
}
