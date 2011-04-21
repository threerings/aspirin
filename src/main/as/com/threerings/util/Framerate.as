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

import flash.display.DisplayObject;
import flash.events.Event;
import flash.utils.getTimer;

public class Framerate
{
    public var frameTimeCur :Number = -1;
    public var fpsCur :Number = -1;
    public var fpsMean :Number = -1;
    public var fpsMin :Number = -1;
    public var fpsMax :Number = -1;

    public function Framerate (disp :DisplayObject, timeWindow :int = DEFAULT_TIME_WINDOW)
    {
        _fpsBuffer = new TimeBuffer(timeWindow, 128);
        _disp = disp;
        _disp.addEventListener(Event.ENTER_FRAME, onEnterFrame);
    }

    public function shutdown () :void
    {
        _disp.removeEventListener(Event.ENTER_FRAME, onEnterFrame);
    }

    protected function onEnterFrame (... ignored) :void
    {
        if (_lastTime < 0) {
            _lastTime = flash.utils.getTimer();
            return;
        }

        var time :int = flash.utils.getTimer();
        frameTimeCur = time - _lastTime;
        fpsCur = 1000 / frameTimeCur;

        // calculate mean, min, max
        _fpsBuffer.push(fpsCur);
        var fpsSum :Number = 0;
        fpsMin = Number.MAX_VALUE;
        fpsMax = Number.MIN_VALUE;
        _fpsBuffer.forEach(function (num :Number, timestamp :int) :void {
            fpsSum += num;
            fpsMin = Math.min(fpsMin, num);
            fpsMax = Math.max(fpsMax, num);
        });
        fpsMean = fpsSum / _fpsBuffer.length;

        _lastTime = time;
    }

    protected var _fpsBuffer :TimeBuffer;
    protected var _disp :DisplayObject;

    protected var _lastTime :int = -1;

    protected static const DEFAULT_TIME_WINDOW :int = 5 * 1000; // 5 seconds
}

}
