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

import com.threerings.util.ArrayUtil;
import com.threerings.util.Map;

/**
 * A Map that disposes of key/value mappings that were least-recently used or inserted
 * after filling up.
 * Re-inserting a value for a key updates the ordering.
 * Note: this implementation is O(n) for maintaining the ordering. This was done
 * (rather than using a linked map implementation) because it was easy, it works
 * with a HashMap or DictionaryMap underneath, and we don't really need more.
 * Does not work with a weak-value map as the source.
 */
public class LRMap extends LinkedMap
{
    public function LRMap (source :Map, maxSize :int, accessOrder :Boolean = true)
    {
        super(source);
        _maxSize = maxSize;
        _accessOrder = accessOrder;
    }

    /** @inheritDoc */
    override public function put (key :Object, value :Object) :*
    {
        var oldVal :* = super.put(key, value);
        if ((oldVal === undefined) && (size() > _maxSize)) {
            // remove the oldest entry
            remove(_anchor.after.key);
        }
        return oldVal;
    }

    /** @private */
    override protected function getEntry (key :Object) :*
    {
        var val :* = super.getEntry(key);
        if ((val !== undefined) && _accessOrder) {
            var le :LinkedEntry = LinkedEntry(val);
            le.remove();
            le.addBefore(_anchor);
        }
        return val;
    }

    /** The maximum size before we roll off entries. @private */
    protected var _maxSize :int;

    /** Are we keeping in access order, or merely insertion order? @private */
    protected var _accessOrder :Boolean;
}
}
