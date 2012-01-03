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

import flash.events.Event;

/**
 * A handy event for simply dispatching a value associated with the event type.
 */
public class ValueEvent extends Event
{
    /**
     * Returns an event handler for a value event that will call the given listener with the value
     * of the event. Since actionscript will attempt to cast the value on call, the listener
     * parameter type can be * or whatever is expected.
     * @param listener
     * <listing version="3.0">
     *      function listener (value :~~) :void {}
     *      function listener (foo :Foo) :void {}
     * </listing>
     */
    public static function adapt (listener :Function) :Function
    {
        return function (evt :ValueEvent) :void {
            listener(evt.value);
        }
    }

    /**
     * Accessor: get the value.
     */
    public function get value () :*
    {
        return _value;
    }

    /**
     * Construct the value event.
     */
    public function ValueEvent (
        type :String, value :*, bubbles :Boolean = false, cancelable :Boolean = false)
    {
        super(type, bubbles, cancelable);
        _value = value;
    }

    override public function clone () :Event
    {
        return new ValueEvent(type, _value, bubbles, cancelable);
    }

    /** The value. */
    protected var _value :*;
}
}
