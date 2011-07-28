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

import flash.display.DisplayObject;
import flash.events.Event;
import flash.utils.clearInterval;
import flash.utils.getTimer;
import flash.utils.setInterval;

public class Framerate
{
    // init with optimistic numbers to avoid special cases later
    public var fpsCur :Number = 30;
    public var frameTimeCur :Number = 1000 / fpsCur;
    public var fpsMean :Number = 30;
    public var fpsMin :Number = 30;
    public var fpsMax :Number = 30;

    public function Framerate (disp :DisplayObject, timeWindow :int = DEFAULT_TIME_WINDOW)
    {
        // keep enough historty for the number of 1/60 frames in timeWindow
        // TODO: if this all flies, establish a way to use historySize or approxTimeWindow
        setHistorySize(timeWindow * 60 / 1000);
        _disp = disp;
        _disp.addEventListener(Event.ENTER_FRAME, onEnterFirstFrame);

        // calculate mean, min, max every so often
        _statsInterval = setInterval(calcStats, AVERAGE_INTERVAL);
    }

    public function setHistorySize (histSize :int) :void
    {
        // start with all 30 to avoid edge special cases in sampler
        _fpsBuffer = Arrays.create(histSize, 30);
        _fpsOffset = 0;
    }

    public function shutdown () :void
    {
        _disp.removeEventListener(Event.ENTER_FRAME, onEnterFirstFrame);
        _disp.removeEventListener(Event.ENTER_FRAME, onEnterFrame);
        clearInterval(_statsInterval);
    }

    protected function onEnterFirstFrame (_:*) :void
    {
        _lastTime = flash.utils.getTimer();
        _disp.removeEventListener(Event.ENTER_FRAME, onEnterFirstFrame);
        _disp.addEventListener(Event.ENTER_FRAME, onEnterFrame);
    }

    protected function onEnterFrame (_:*) :void
    {
        // calculate sample
        var time :int = flash.utils.getTimer();
        frameTimeCur = time - _lastTime;
        fpsCur = 1000 / frameTimeCur;

        // record sample
        _fpsBuffer[_fpsOffset] = fpsCur;
        _fpsOffset = (_fpsOffset + 1) % _fpsBuffer.length;

        _lastTime = time;
    }

    protected function calcStats () :void
    {
        var fpsSum :Number = 0;
        fpsMin = Number.MAX_VALUE;
        fpsMax = Number.MIN_VALUE;
        for each (var num :Number in _fpsBuffer) {
            fpsSum += num;
            fpsMin = Math.min(fpsMin, num);
            fpsMax = Math.max(fpsMax, num);
        };
        fpsMean = fpsSum / _fpsBuffer.length;
    }

    protected var _disp :DisplayObject;

    protected var _fpsBuffer :Array;
    protected var _fpsOffset :int;
    protected var _lastTime :int;
    protected var _statsInterval :uint;

    protected static const DEFAULT_TIME_WINDOW :int = 5 * 1000; // 5 seconds
    protected static const AVERAGE_INTERVAL :int = 500; // half second
}

}
