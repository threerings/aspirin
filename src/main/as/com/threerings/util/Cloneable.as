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
 * Implemented by objects that support creating a clone.
 */
public interface Cloneable
{
    /**
     * Create a clone of this object.
     *
     * @example A smart implementation that allows for subclassing.
     * <listing version="3.0">
     * public function clone () :Object
     * {
     *     var myObj :MyClass = MyClass(ClassUtil.newInstance(this)); // requires 0-arg constructor
     *     myObj.someInt = this.someInt; // copy all vars
     *     myObj.someArray = this.someArray.concat(); // make a clone of any mutable vars
     *     return myObj;
     * }
     * </listing>
     */
    function clone () :Object;
}
}
