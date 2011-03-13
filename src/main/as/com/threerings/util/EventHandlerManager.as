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

package com.threerings.util {

import flash.events.Event;
import flash.events.IEventDispatcher;

/**
 * A class for keeping track of event listeners and freeing them all at a given time.  This is
 * useful for keeping track of your ENTER_FRAME listeners, and releasing them all on UNLOAD to
 * make sure your game/furni/avatar fully unloads at the proper time.
 */
public class EventHandlerManager
{
    /**
     * Create a EventHandlerManager, optionally specifying a "globalErrorHandler" with the
     * following signature:
     * <listing version="3.0">
     *    function (error :Error) :void;
     * </listing>
     *
     * NOTE: a global error handler will soon be built-in to Flash player 10.1.
     *
     * @param parent (optional) if not null, this EventHandlerManager will become a child of
     * the specified parent. If the parent is shutdown, or its freeAllHandlers() or freeAllOn()
     * functions are called, this EventHandlerManager will be similarly affected.
     */
    public function EventHandlerManager (globalErrorHandler :Function = null,
        parent :EventHandlerManager = null)
    {
        _errorHandler = globalErrorHandler;

        if (parent != null) {
            _parent = parent;
            parent._children.push(this);
        }
    }

    /**
     * Unregisters all event handlers, and disconnects the EventHandlerManager from its parent,
     * if it has one. All child EventHandlerManagers will be shutdown as well.
     *
     * It's an error to call any function on EventHandlerManager after shutdown() has been called.
     */
    public function shutdown () :void
    {
        // detach from our parent, if we have one
        if (_parent != null) {
            Arrays.removeFirst(_parent._children, this);
            _parent = null;
        }

        // shutdown our children
        for each (var child :EventHandlerManager in _children) {
            child._parent = null;
            child.shutdown();
        }
        _children = null;

        // Free all handlers
        freeAllHandlers();

        // null out internal state so that future calls to this object will immediately NPE
        _listeners = null;
    }

    /**
     * Adds the specified listener to the specified dispatcher for the specified event.
     */
    public function registerListener (
        dispatcher :IEventDispatcher, event :String, listener :Function,
        useCapture :Boolean = false, priority :int = 0) :void
    {
        var l :Listener = new Listener(_errorHandler, dispatcher, event, listener, useCapture);
        // canonicalize
        var l2 :Listener = Listener(_listeners.get(l));
        if (l2 != null) {
            l = l2;
        } else {
            _listeners.put(l, l);
        }

        // register (or re-register) at the priority
        l.register(priority);
    }

    /**
     * Removes the specified listener from the specified dispatcher for the specified event.
     */
    public function unregisterListener (
        dispatcher :IEventDispatcher, event :String, listener :Function,
        useCapture :Boolean = false) :void
    {
        var l :Listener = new Listener(_errorHandler, dispatcher, event, listener, useCapture);
        var l2 :Listener = Listener(_listeners.remove(l));
        if (l2 != null) {
            l = l2;
        }

        // unregister (even if it wasn't there before, we call it just to be safe)
        l.unregister();
    }

    /**
     * Registers a callback function that will be called the first time the given event fires.
     */
    public function registerOneShotCallback (
        dispatcher :IEventDispatcher, event :String, listener :Function,
        useCapture :Boolean = false, priority :int = 0) :void
    {
        var eventListener :Function = function (e :Event) :void {
            unregisterListener(dispatcher, event, eventListener, useCapture);
            // for legacy reasons, we support 0-arg callbacks
            if (listener.length == 0) {
                listener();
            } else {
                listener(e);
            }
        };

        registerListener(dispatcher, event, eventListener, useCapture, priority);
    }

    /**
     * Registers the freeAllHandlers() method to be called upon Event.UNLOAD on the supplied
     * event dispatcher.
     */
    public function registerUnload (dispatcher :IEventDispatcher) :void
    {
        registerListener(dispatcher, Event.UNLOAD, Util.adapt(freeAllHandlers));
    }

    /**
     * Registers a 0-argument callback that will be called when pred() returns true. pred
     * will be called immediately, and then again each time the specified event is fired,
     * until pred is satisfied (or freeAllHandlers() is called).
     */
    public function doWhen (dispatcher :IEventDispatcher, event :String, pred :Function,
        callback :Function, useCapture :Boolean = false, priority :int = 0) :void
    {
        if (pred()) {
            callback();
        } else {
            function handler (..._) :void {
                if (pred()) {
                    unregisterListener(dispatcher, event, handler, useCapture);
                    callback();
                }
            };
            registerListener(dispatcher, event, handler, useCapture, priority);
        }
    }

    /**
     * Will either call a given function now, or defer it based on the boolean parameter.  If the
     * parameter is false, the function will be registered as a one-shot callback on the dispatcher
     */
    public function callWhenTrue (
        callback :Function, callNow :Boolean, dispatcher :IEventDispatcher, event :String,
        useCapture :Boolean = false, priority :int = 0) :void
    {
        if (callNow) {
            callback();
        } else {
            registerOneShotCallback(dispatcher, event, callback, useCapture, priority);
        }
    }

    /**
     * Will register a listener on a dispatcher for an event until the trigger event has been
     * dispatched on the trigger dispatcher.  Useful for attaching listeners until an object
     * has been REMOVED_FROM_STAGE or UNLOADed.
     *
     * All associated event listeners use the default useCapture and priority settings.
     */
    public function registerListenerUntil (
        triggerDispatcher :IEventDispatcher, triggerEvent :String,
        dispatcher :IEventDispatcher, event :String, listener :Function) :void
    {
        registerListener(dispatcher, event, listener);
        registerOneShotCallback(triggerDispatcher, triggerEvent, function () :void {
            unregisterListener(dispatcher, event, listener);
        });
    }

    /**
     * Free all event listeners on the specified dispatcher. Children EventHandlerManagers will
     * be similarly affected.
     */
    public function freeAllOn (dispatcher :IEventDispatcher) :void
    {
        for each (var l :Listener in _listeners.keys()) {
            if (l.getDispatcher() == dispatcher) {
                l.unregister();
                _listeners.remove(l);
            }
        }

        for each (var child :EventHandlerManager in _children) {
            child.freeAllOn(dispatcher);
        }
    }

    /**
     * Free all handlers that have been added via this registerListener() and have not been
     * freed already via unregisterListener(). Children EventHandlerManagers will also have their
     * handlers freed.
     */
    public function freeAllHandlers () :void
    {
        for each (var l :Listener in _listeners.keys()) {
            l.unregister();
        }
        _listeners.clear();

        for each (var child :EventHandlerManager in _children) {
            child.freeAllHandlers();
        }
    }

    protected var _errorHandler :Function;
    protected var _listeners :Map = Maps.newMapOf(Listener);
    protected var _parent :EventHandlerManager;
    protected var _children :Array = []; // Array<EventHandlerManager>
}
}

import flash.events.Event;
import flash.events.IEventDispatcher;

import com.threerings.util.Hashable;
import com.threerings.util.StringUtil;

class Listener
    implements Hashable
{
    public function Listener (
        errHandler :Function,
        dispatcher :IEventDispatcher, event :String, listener :Function, useCapture :Boolean)
    {
        _errHandler = errHandler;
        _dispatcher = dispatcher;
        _event = event;
        _listener = listener;
        _useCapture = useCapture;
    }

    public function getDispatcher () :IEventDispatcher
    {
        return _dispatcher;
    }

    // from Equalable
    public function equals (other :Object) :Boolean
    {
        if (!(other is Listener)) {
            return false;
        }
        var that :Listener = Listener(other);
        return (this._dispatcher == that._dispatcher) && (this._event == that._event) &&
                (this._listener == that._listener) && (this._useCapture == that._useCapture);
    }

    // from Hashable
    public function hashCode () :int
    {
        return StringUtil.hashCode(_event) + (_useCapture ? 1 : 0);
    }

    public function register (priority :int = 0) :void
    {
        _dispatcher.addEventListener(_event, handleEvent, _useCapture, priority);
    }

    public function unregister () :void
    {
        _dispatcher.removeEventListener(_event, handleEvent, _useCapture);
    }

    /** The event handler. */
    public function handleEvent (event :Event) :void
    {
        try {
            _listener(event);
        } catch (e :Error) {
            if (_errHandler != null) {
                try {
                    _errHandler(e);
                } catch (e2 :Error) {
                    // fuck that
                }
            }
            throw e; // rethrow the error, it can't hurt, and if we're in FP 10.1 and are
            // using the new built-in global event handler, we want it to see this!
        }
    }

    protected var _errHandler :Function;
    protected var _dispatcher :IEventDispatcher;
    protected var _event :String;
    protected var _listener :Function;
    protected var _useCapture :Boolean;
}
