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
import com.threerings.util.Preconditions;

/**
 * A building-block Map that forwards requests to another map.
 * @private
 */
public class ForwardingMap
    implements Map
{
    public function ForwardingMap (source :Map)
    {
        _source = Preconditions.checkNotNull(source);
    }

    /** @inheritDoc */
    public function put (key :Object, value :Object) :*
    {
        return _source.put(key, value);
    }

    /** @inheritDoc */
    public function get (key :Object) :*
    {
        return _source.get(key);
    }

    /** @inheritDoc */
    public function containsKey (key :Object) :Boolean
    {
        return _source.containsKey(key);
    }

    /** @inheritDoc */
    public function remove (key :Object) :*
    {
        return _source.remove(key);
    }

    /** @inheritDoc */
    public function size () :int
    {
        return _source.size();
    }

    /** @inheritDoc */
    public function isEmpty () :Boolean
    {
        return _source.isEmpty();
    }

    /** @inheritDoc */
    public function clear () :void
    {
        _source.clear();
    }

    /** @inheritDoc */
    public function keys () :Array
    {
        return _source.keys();
    }

    /** @inheritDoc */
    public function values () :Array
    {
        return _source.values();
    }

    /** @inheritDoc */
    public function items () :Array
    {
        return _source.items();
    }

    /** @inheritDoc */
    public function forEach (fn :Function) :void
    {
        _source.forEach(fn);
    }

    /** The Map to which we forward requests. @private */
    protected var _source :Map;
}
}
