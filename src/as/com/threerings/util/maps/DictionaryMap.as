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

import flash.utils.Dictionary;

import com.threerings.util.Map;
import com.threerings.util.Util;

/**
 * An implemention of Map that uses a Dictionary internally for storage. Any Object (and null)
 * may be used as a key with no loss in efficiency.
 */
public class DictionaryMap extends AbstractMap
    implements Map
{
    /** @inheritDoc */
    public function put (key :Object, value :Object) :*
    {
        var oldVal :* = _dict[key];
        _dict[key] = value;
        if (oldVal === undefined) {
            _size++;
        }
        return oldVal;
    }

    /** @inheritDoc */
    public function get (key :Object) :*
    {
        return _dict[key];
    }

    /** @inheritDoc */
    public function containsKey (key :Object) :Boolean
    {
        return (key in _dict);
    }

    /** @inheritDoc */
    public function remove (key :Object) :*
    {
        var oldVal :* = _dict[key];
        if (oldVal !== undefined) {
            delete _dict[key];
            _size--;
        }
        return oldVal;
    }

    /** @inheritDoc */
    public function clear () :void
    {
        _dict = new Dictionary();
        _size = 0;
    }

    /** @inheritDoc */
    public function keys () :Array
    {
        return Util.keys(_dict);
    }

    /** @inheritDoc */
    public function values () :Array
    {
        return Util.values(_dict);
    }

    /** @inheritDoc */
    override public function forEach (fn :Function) :void
    {
        for (var key :Object in _dict) {
            if (Boolean(fn(key, _dict[key]))) {
                return;
            }
        }
    }

    /** Our actual storage. @private */
    protected var _dict :Dictionary = new Dictionary();
}
}
