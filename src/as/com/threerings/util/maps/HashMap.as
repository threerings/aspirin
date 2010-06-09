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

import com.threerings.util.Hashable;
import com.threerings.util.Map;

/**
 * Objects that implement Hashable, Strings, and null may be used as keys.
 */
public class HashMap extends AbstractMap
    implements Map
{
    /**
     * Construct a HashMap
     *
     * @param loadFactor - A measure of how full the hashtable is allowed to
     *                     get before it is automatically resized. The default
     *                     value of 1.75 should be fine.
     */
    public function HashMap (loadFactor :Number = 1.75)
    {
        _loadFactor = loadFactor;
        clear(); // build the _entries array
    }

    /** @inheritDoc */
    public function put (key :Object, value :Object) :*
    {
        var hkey :Hashable = toKey(key);
        var hash :int = hkey.hashCode();
        var index :int = indexFor(hash);
        var firstEntry :HashMap_Entry = (_entries[index] as HashMap_Entry);
        for (var e :HashMap_Entry = firstEntry; e != null; e = e.next) {
            if ((e.hash == hash) && e.key.equals(hkey)) {
                var oldValue :Object = e.value;
                e.value = value;
                return oldValue; // size did not change
            }
        }

        // create a new entry
        _entries[index] = new HashMap_Entry(hash, hkey, value, firstEntry);
        _size++;
        // check to see if we should grow the map
        if (_size > _entries.length * _loadFactor) {
            resize(2 * _entries.length);
        }
        // indicate that there was no value previously stored for the key
        return undefined;
    }

    /** @inheritDoc */
    public function get (key :Object) :*
    {
        var hkey :Hashable = toKey(key);
        var hash :int = hkey.hashCode();
        var index :int = indexFor(hash);
        var e :HashMap_Entry = (_entries[index] as HashMap_Entry);
        while (e != null) {
            if ((e.hash == hash) && e.key.equals(hkey)) {
                return e.value;
            }
            e = e.next;
        }
        return undefined;
    }

    /** @inheritDoc */
    public function containsKey (key :Object) :Boolean
    {
        return (undefined !== get(key));
    }

    /** @inheritDoc */
    public function remove (key :Object) :*
    {
        var hkey :Hashable = toKey(key);
        var hash :int = hkey.hashCode();
        var index :int = indexFor(hash);
        var prev :HashMap_Entry = (_entries[index] as HashMap_Entry);
        var e :HashMap_Entry = prev;
        while (e != null) {
            var next :HashMap_Entry = e.next;
            if ((e.hash == hash) && e.key.equals(hkey)) {
                if (prev == e) {
                    _entries[index] = next;
                } else {
                    prev.next = next;
                }
                _size--;
                // check to see if we should shrink the map
                if ((_entries.length > DEFAULT_BUCKETS) &&
                        (_size < _entries.length * _loadFactor * .125)) {
                    resize(Math.max(DEFAULT_BUCKETS, _entries.length / 2));
                }
                return e.value;
            }
            prev = e;
            e = next;
        }
        return undefined; // never found
    }

    /** @inheritDoc */
    public function clear () :void
    {
        _entries = [];
        _entries.length = DEFAULT_BUCKETS;
        _size = 0;
    }

    /** @inheritDoc */
    public function keys () :Array
    {
        var keys :Array = [];
        forEach(function (k :*, v :*) :void {
            keys.push(k);
        });
        return keys;
    }

    /** @inheritDoc */
    public function values () :Array
    {
        var vals :Array = [];
        forEach(function (k :*, v :*) :void {
            vals.push(v);
        });
        return vals;
    }

    /** @inheritDoc */
    public function forEach (fn :Function) :void
    {
        for (var ii :int = _entries.length - 1; ii >= 0; ii--) {
            for (var e :HashMap_Entry = (_entries[ii] as HashMap_Entry); e != null; e = e.next) {
                if (Boolean(fn(fromKey(e.key), e.value))) {
                    return;
                }
            }
        }
    }

    /**
     * Return a Hashable that represents the key.
     * Will throw a ReferenceError if the key is not Hashable.
     * @private
     */
    protected function toKey (key :Object) :Hashable
    {
        if ((key is String) || (key == null)) {
            return new StringWrapper(key as String);
        } else {
            return Hashable(key);
        }
    }

    /**
     * Return the original key from a Hashable.
     * @private
     */
    protected function fromKey (key :Hashable) :Object
    {
        if (key is StringWrapper) {
            return StringWrapper(key).get();
        } else {
            return key;
        }
    }

    /**
     * Return an index for the specified hashcode.
     * @private
     */
    protected function indexFor (hash :int) :int
    {
        // TODO: improve?
        return Math.abs(hash) % _entries.length;
    }

    /**
     * Resize the entries with Hashable keys to optimize
     * the memory/performance tradeoff.
     * @private
     */
    protected function resize (newSize :int) :void
    {
        var oldEntries :Array = _entries;
        _entries = [];
        _entries.length = newSize;

        // place all the old entries in the new map
        for (var ii :int = 0; ii < oldEntries.length; ii++) {
            var e :HashMap_Entry = (oldEntries[ii] as HashMap_Entry);
            while (e != null) {
                var next :HashMap_Entry = e.next;
                var index :int = indexFor(e.hash);
                e.next = (_entries[index] as HashMap_Entry);
                _entries[index] = e;
                e = next;
            }
        }
    }

    /** The load factor. @private */
    protected var _loadFactor :Number;

    /** If non-null, contains Hashable keys and their values. @private */
    protected var _entries :Array;

    /** The default size for the bucketed hashmap. @private */
    protected static const DEFAULT_BUCKETS :int = 16;
}
}
