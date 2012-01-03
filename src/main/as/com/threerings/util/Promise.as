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

/**
 * Contains a value which may not be ready yet. If you request the value with get(), we'll promise
 * to get back to you eventually, or immediately if the value is already available.
 */
public class Promise
{
    public function get (f :Function) :void
    {
        if (_callbacks != null) {
            _callbacks.push(f);
        } else {
            f.apply(undefined, _value);
        }
    }

    public function set (...value) :void
    {
        _value = value;

        if (_callbacks != null) {
            var c :Array = _callbacks;
            _callbacks = null; // Promise fulfilled

            for each (var f :Function in c) {
                f.apply(undefined, value);
            }
        }
    }

    public function and (other :Promise) :Promise
    {
        var p :Promise = new Promise();
        var values :Array = null; // The results from the first promise to complete

        this.get(function (...x) :void {
            if (values != null) {
                p.set.apply(p, x.concat(values));
            } else {
                values = x;
            }
        });
        other.get(function (...y) :void {
            if (values != null) {
                p.set.apply(p, values.concat(y));
            } else {
                values = y;
            }
        });

        return p;
    }

    public function get ready () :Boolean
    {
        return (_callbacks == null);
    }

    protected var _value :*;
    protected var _callbacks :Array = [];
}
}
