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

package com.threerings.util.lists {

import com.threerings.util.List;
import com.threerings.util.Preconditions;
import com.threerings.util.Util;

/**
 * A List that uses an Array for backing.
 */
public class ArrayList
    implements List
{
    /**
     * Construct a new ArrayList.
     */
    public function ArrayList ()
    {
        _array = [];
    }

    /** @inheritDoc */
    public function add (o :Object) :Boolean
    {
        _array.push(o);
        return true;
    }

    /** @inheritDoc */
    public function addAt (index :int, o :Object) :void
    {
        _array.splice(Preconditions.checkIndex(index, _array.length + 1), 0, o);
    }

    /** @inheritDoc */
    public function get (index :int) :Object
    {
        return _array[Preconditions.checkIndex(index, _array.length)];
    }

    /** @inheritDoc */
    public function set (index :int, o :Object) :void
    {
        _array[Preconditions.checkIndex(index, _array.length)] = o;
    }

    /** @inheritDoc */
    public function contains (o :Object) :Boolean
    {
        return (indexOf(o) != -1);
    }

    /** @inheritDoc */
    public function indexOf (o :Object) :int
    {
        for (var ii :int = 0, nn :int = _array.length; ii < nn; ii++) {
            if (Util.equals(_array[ii], o)) {
                return ii;
            }
        }
        return -1;
    }

    /** @inheritDoc */
    public function lastIndexOf (o :Object) :int
    {
        for (var ii :int = _array.length - 1; ii >= 0; ii--) {
            if (Util.equals(_array[ii], o)) {
                return ii;
            }
        }
        return -1;
    }

    /** @inheritDoc */
    public function remove (o :Object) :Boolean
    {
        var index :int = indexOf(o);
        if (index == -1) {
            return false;
        }
        _array.splice(index, 1);
        return true;
    }

    /** @inheritDoc */
    public function removeAt (index :int) :Object
    {
        return _array.splice(Preconditions.checkIndex(index, _array.length), 1)[0];
    }

    /** @inheritDoc */
    public function size () :int
    {
        return _array.length;
    }

    /** @inheritDoc */
    public function isEmpty () :Boolean
    {
        return (size() == 0);
    }

    /** @inheritDoc */
    public function clear () :void
    {
        _array = [];
    }

    /** @inheritDoc */
    public function toArray () :Array
    {
        return _array.slice();
    }

    /** @inheritDoc */
    public function forEach (fn :Function) :void
    {
        for each (var o :Object in _array) {
            if (Boolean(fn(o))) {
                return;
            }
        }
    }

    /** Our array o' storage. @private */
    protected var _array :Array;
}
}
