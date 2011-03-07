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

import flash.events.TimerEvent;
import flash.utils.Timer;

/**
 * Allows a group of Timers to be cancelled en masse.
 */
public class TimerGroup
{
    /**
     * Constructs a new TimerGroup.
     *
     * @param parent (optional) if not null, this TimerGroup will become a child of
     * the specified parent TimerGroup. If the parent is shutdown, or its cancelAllTimers()
     * function is called, this TimerGroup will be similarly affected.
     */
    public function TimerGroup (parent :TimerGroup = null)
    {
        if (parent != null) {
            _parent = parent;
            parent._children.push(this);
        }
    }

    /**
     * Cancels all running timers, and disconnects the TimerGroup from its parent, if it has one.
     * All child TimerGroups will be shutdown as well.
     *
     * It's an error to call any function on TimerGroup after shutdown() has been called.
     */
    public function shutdown () :void
    {
        // detach from our parent, if we have one
        if (_parent != null) {
            Arrays.removeFirst(_parent._children, this);
        }

        // shutdown our children
        for each (var child :TimerGroup in _children) {
            child._parent = null;
            child.shutdown();
        }

        cancelAllTimers();

        // null out internal state so that future calls to this TimerGroup will
        // immediately NPE
        _parent = null;
        _children = null;
        _timers = null;
    }

    /**
     * Creates and runs a timer that will run once, and clean up after itself.
     */
    public function runOnce (delay :Number, callback :Function) :void
    {
        var timer :Timer = createTimer(delay, 1);
        timer.addEventListener(TimerEvent.TIMER,
            function (e :TimerEvent) :void {
                cancelTimer(timer);
                callback(e);
            });

        timer.start();
    }

    /**
     * Creates and runs a timer that will run forever, or until canceled.
     */
    public function runForever (delay :Number, callback :Function) :Timer
    {
        var timer :Timer = createTimer(delay, 0);
        timer.addEventListener(TimerEvent.TIMER, callback);
        timer.start();
        return timer;
    }

    /**
     * Creates, but doesn't run, a new Timer managed by this TimerGroup.
     */
    public function createTimer (delay :Number, repeatCount :int = 0) :Timer
    {
        var timer :Timer = new Timer(delay, repeatCount);
        _timers.push(timer);
        return timer;
    }

    /**
     * Delay invocation of the specified function closure by one frame.
     */
    public function delayFrame (fn :Function, args :Array = null) :void
    {
        delayFrames(1, fn, args);
    }

    /**
     * Delay invocation of the specified function closure by one or more frames.
     */
    public function delayFrames (frames :int, fn :Function, args :Array = null) :void
    {
        _delayer.delayFrames(frames, fn, args);
    }

    /**
     * Stops all timers being managed by this TimerGroup.
     * All child TimerGroups will have their timers stopped as well.
     */
    public function cancelAllTimers () :void
    {
        for each (var timer :Timer in _timers) {
            // we can have holes in the _timers array
            if (timer != null) {
                timer.stop();
            }
        }

        _timers = [];

        _delayer.shutdown();
        _delayer = new FrameDelayer();

        for each (var child :TimerGroup in _children) {
            child.cancelAllTimers();
        }
    }

    /**
     * Causes the timer to be stopped, and removed from the TimerGroup's list of managed timers.
     */
    public function cancelTimer (timer :Timer) :void
    {
        var idx :int = Arrays.indexOf(_timers, timer);
        if (idx >= 0) {
            _timers.splice(idx, 1);
        }

        timer.stop();
    }

    protected var _delayer :FrameDelayer = new FrameDelayer();
    protected var _timers :Array = []; // Array<Timer>
    protected var _parent :TimerGroup;
    protected var _children :Array = []; // Array<TimerGroup>
}
}
