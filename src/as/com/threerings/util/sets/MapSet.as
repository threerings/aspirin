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

package com.threerings.util.sets {

import com.threerings.util.Map;
import com.threerings.util.Preconditions;
import com.threerings.util.Set;

/**
 * A Set that uses a Map for backing store, thus allowing us to build on the
 * various Maps in useful ways.
 */
public class MapSet extends AbstractSet
    implements Set
{
    public function MapSet (source :Map)
    {
        _source = Preconditions.checkNotNull(source);
    }

    /** @inheritDoc */
    public function add (o :Object) :Boolean
    {
        return (undefined === _source.put(o, true));
    }

    /** @inheritDoc */
    public function contains (o :Object) :Boolean
    {
        return _source.containsKey(o);
    }

    /** @inheritDoc */
    public function remove (o :Object) :Boolean
    {
        return (undefined !== _source.remove(o));
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
        return _source.clear();
    }

    /** @inheritDoc */
    public function toArray () :Array
    {
        return _source.keys();
    }

    /**
     * @copy com.threerings.util.Set#forEach()
     *
     * @internal inheritDoc doesn't work here because forEach is defined in our private superclass.
     */
    override public function forEach (fn :Function) :void
    {
        _source.forEach(function (k :Object, v :Object) :* {
            return fn(k);
        });
    }

    /** The map used for our source. @private */
    protected var _source :Map;
}
}
