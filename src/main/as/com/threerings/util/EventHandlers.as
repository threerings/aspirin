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

import flash.events.IEventDispatcher;

/**
 * A class for keeping track of event listeners and freeing them all at a given time.  This is
 * useful for keeping track of your ENTER_FRAME listeners, and releasing them all on UNLOAD to
 * make sure your game/furni/avatar fully unloads at the proper time.
 *
 * See {@link EventHandlerManager} for a non-static version of this class.
 */
[Deprecated(replacement="com.threerings.util.EventHandlerManager")]
public class EventHandlers
{
    /**
     * Adds the specified listener to the specified dispatcher for the specified event.
     */
    public static function registerListener (dispatcher :IEventDispatcher, event :String,
        listener :Function, useCapture :Boolean = false, priority :int = 0) :void
    {
        _mgr.registerListener(dispatcher, event, listener, useCapture, priority);
    }

    /**
     * Removes the specified listener from the specified dispatcher for the specified event.
     */
    public static function unregisterListener (dispatcher :IEventDispatcher, event :String,
        listener :Function, useCapture :Boolean = false) :void
    {
        _mgr.unregisterListener(dispatcher, event, listener, useCapture);
    }

    /**
     * Registers a zero-arg callback function that should be called once when the event fires.
     */
    public static function registerOneShotCallback (dispatcher :IEventDispatcher, event :String,
        callback :Function, useCapture :Boolean = false, priority :int = 0) :void
    {
        _mgr.registerOneShotCallback(dispatcher, event, callback, useCapture, priority);
    }

    /**
     * Registers the freeAllHandlers() method to be called upon Event.UNLOAD on the supplied
     * event dispatcher.
     */
    public static function registerUnload (dispatcher :IEventDispatcher) :void
    {
        _mgr.registerUnload(dispatcher);
    }

    /**
     * Will either call a given function now, or defer it based on the boolean parameter.  If the
     * parameter is false, the function will be registered as a one-shot callback on the dispatcher
     */
    public static function callWhenTrue (callback :Function, callNow :Boolean,
        dispatcher :IEventDispatcher, event :String, useCapture :Boolean = false,
        priority :int = 0) :void
    {
        _mgr.callWhenTrue(callback, callNow, dispatcher, event, useCapture, priority);
    }

    /**
     * Will register a listener on a dispatcher for an event until the trigger event has been
     * dispatched on the trigger dispatcher.  Useful for attaching listeners until an object
     * has been REMOVED_FROM_STAGE or UNLOADed.
     *
     * All associated event listeners use the default useCapture and priority settings.
     */
    public static function registerListenerUntil (triggerDispatcher :IEventDispatcher,
        triggerEvent :String, dispatcher :IEventDispatcher, event :String,
        listener :Function) :void
    {
        registerListener(dispatcher, event, listener);
        registerOneShotCallback(triggerDispatcher, triggerEvent, function () :void {
            unregisterListener(dispatcher, event, listener);
        });
    }

    /**
     * Free all handlers that have been added via this registerListener() and have not been
     * freed already via unregisterListener()
     */
    public static function freeAllHandlers (...ignored) :void
    {
        _mgr.freeAllHandlers();
    }

    /**
     * Returns the global manager that is accessed by all of the static members of this class.
     */
    public static function getGlobalManager () :EventHandlerManager
    {
        return _mgr;
    }

    protected static var _mgr :EventHandlerManager = new EventHandlerManager();
}
}
