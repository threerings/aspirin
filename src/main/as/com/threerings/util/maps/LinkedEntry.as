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

/**
 * A special metastructure for keeping track of the ordering in a LinkedMap.
 * @private
 */
public class LinkedEntry
{
    public var before :LinkedEntry;

    public var after :LinkedEntry;

    public var key :Object;

    public var value :Object;

    public function LinkedEntry (key :Object, value :Object)
    {
        this.key = key;
        this.value = value;
    }

    public function addBefore (existing :LinkedEntry) :void
    {
        after = existing;
        before = existing.before;
        before.after = this;
        after.before = this;
    }

    public function remove () :void
    {
        before.after = after;
        after.before = before;
    }
}
}
