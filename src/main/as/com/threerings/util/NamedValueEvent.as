//
// aspirin library - Taking some of the pain out of Actionscript development.
// Copyright (C) 2007-2011 Three Rings Design, Inc., All Rights Reserved
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

import flash.events.Event;

/**
 * A handy event for dispatching a name/value pair associated with the event type.
 */
public class NamedValueEvent extends ValueEvent
{
    /**
     * Accessor: get the name.
     */
    public function get name () :String
    {
        return _name;
    }

    /**
     * Construct the name/value event.
     */
    public function NamedValueEvent (
        type :String, name :String, value :*, bubbles :Boolean = false, cancelable :Boolean = false)
    {
        super(type, value, bubbles, cancelable);
        _name = name;
    }

    override public function clone () :Event
    {
        return new NamedValueEvent(type, _name, _value, bubbles, cancelable);
    }

    /** The name. */
    protected var _name :String;
}
}
