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

package com.threerings.util {
import flash.utils.Dictionary;

/**
 * Implements a sort function based on position in a fixed backing array. This is equivalent to
 * using indexOf(a) - indexOf(b) but with dictionary lookup performance instead of linear. This is
 * intended for arrays that do not change often, but could be adapted by exposing specific
 * mutators like push and splice that only update the necessary indices.
 */
public class Ordering
{
    /**
     * Creates a new ordering backed by the given array. The array is copied so subsequent
     * modifications have no effect.
     */
    public function Ordering (elements :Array = null)
    {
        if (elements != null) {
            this.elements = elements;
        }
    }

    /**
     * Compares two elements in the array in the usual way. Throws an error is either element is
     * not in the array.
     */
    public function compare (elema :*, elemb :*) :int
    {
        return _indices[elema] - _indices[elemb];
    }

    /**
     * Returns a copy of the backing array for the ordering.
     */
    public function get elements () :Array
    {
        return Arrays.copyOf(_elements);
    }

    /**
     * Sets the backing array for this ordering. The array is copied so subsequent modifications
     * have no effect.
     */
    public function set elements (elems :Array) :void
    {
        _elements = Arrays.copyOf(elems);
        refresh();
    }

    /**
     * Invokes a function on the backing array then updates the sorting index.
     * <listing version ="3.0">
     *     function doSomething (elements :Array) :void;
     * </listing>
     */
    public function withElements (doSomething :Function) :void
    {
        try {
            doSomething(_elements);
        } finally {
            refresh();
        }
    }

    private function refresh () :void
    {
        _indices = new Dictionary();
        for (var ii :int = 0; ii < _elements.length; ++ii) {
            _indices[_elements[ii]] = ii;
        }
    }

    private var _elements :Array = [];
    private var _indices :Dictionary;
}
}
