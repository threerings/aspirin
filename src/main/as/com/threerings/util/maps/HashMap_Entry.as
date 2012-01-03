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

package com.threerings.util.maps {

import com.threerings.util.Hashable;

/**
 * A key/value pair in a HashMap. This is really an internal class to HashMap, and when
 * Flash CS4 is fixed, it will go nestle back into HashMap.as's luxurious folds.
 * @private
 */
public class HashMap_Entry
{
    public var key :Hashable;
    public var value :Object;
    public var hash :int;
    public var next :HashMap_Entry;

    public function HashMap_Entry (hash :int, key :Hashable, value :Object, next :HashMap_Entry)
    {
        this.hash = hash;
        this.key = key;
        this.value = value;
        this.next = next;
    }
}
}
