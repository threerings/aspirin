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

package com.threerings.util.sets {

import com.threerings.util.ClassUtil;
import com.threerings.util.Set;
import com.threerings.util.maps.MapBuilder;

/**
 * Builds Sets.
 *
 * @example
 * <listing version="3.0">
 * // builds a sorted Set that keeps the 10 most-recently inserted entries.
 * var mySet :Set = Sets.newBuilder(String)
 *     .makeSorted()
 *     .makeLRI(10)
 *     .build();
 * </listing>
 */
public class SetBuilder
{
    public function SetBuilder (valueClazz :Class)
    {
        _mb = new MapBuilder(valueClazz);
    }

    /**
     * Make the Map sorted. If no Comparator is specified, then one is picked
     * based on the valueClazz, falling back to Comparators.compareUnknowns.
     *
     * @return this SetBuilder, for chaining.
     */
    public function makeSorted (comp :Function = null) :SetBuilder
    {
        _mb.makeSorted(comp);
        return this;
    }

    /**
     * Make the Set a cache, disposing of the least-recently-accessed (or just inserted) value
     * whenever size exceeds maxSize. Iterating over this Set (via forEach() or toArray()) will
     * see the oldest entries first.
     *
     * @return this SetBuilder, for chaining.
     */
    public function makeLR (maxSize :int, accessOrder :Boolean = true) :SetBuilder
    {
        _mb.makeLR(maxSize, accessOrder);
        return this;
    }

    /**
     * Make the Set auto-expire elements.
     *
     * @param ttl the time to live
     * @param a function to receieve notifications when an element expires.
     * signature: function (element :Object) :void;
     *
     * @return this SetBuilder, for chaining.
     */
    public function makeExpiring (ttl :int, expireHandler :Function = null) :SetBuilder
    {
        _mb.makeExpiring(ttl, (expireHandler == null) ? null :
            function (key :*, value :*) :* {
                return expireHandler(key);
            });
        return this;
    }

    /**
     * Make the Set immutable.
     */
    public function makeImmutable () :SetBuilder
    {
        _mb.makeImmutable();
        return this;
    }

    /**
     * Add a value to the Set, once built.
     */
    public function add (value :Object) :SetBuilder
    {
        _mb.put(value, true); // since MapSet stores trues for everything
        return this;
    }

    /**
     * Add all the values in the specified Set or Array.
     */
    public function addAll (objects :Object) :SetBuilder
    {
        if (objects is Set) {
            Set(objects).forEach(function (item :Object) :void {
                _mb.put(o, true);
            });
        } else if (objects is Array) {
            for each (var o :Object in objects as Array) {
                _mb.put(o, true);
            }
        } else {
            throw new ArgumentError("objects must be an Array or a Set, not a '" +
                ClassUtil.getClassName(objects) + "'");
        }
        return this;
    }

    /**
     * Adds all objects in the values Array to the Set, once built.
     */
    public function addEach (values :Array) :SetBuilder
    {
        for each (var value :Object in values) {
            add(value);
        }
        return this;
    }

    /**
     * Build the Set!
     */
    public function build () :Set
    {
        return new MapSet(_mb.build());
    }

    /** @private */
    protected var _mb :MapBuilder;
}
}
