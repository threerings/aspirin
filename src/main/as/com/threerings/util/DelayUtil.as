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
 * A simple way to delay invocation of a function closure by one or more frames.
 * Similar to UIComponent's callLater, only flex-free.
 * If not running in the flash player, but instead in some tamarin environment like
 * thane, "frames" are a minimum of 1ms apart, but may be more if other code doesn't yield.
 */
public class DelayUtil
{
    /**
     * Delay invocation of the specified function closure by one frame.
     */
    public static function delayFrame (fn :Function, args :Array = null) :void
    {
        delayFrames(1, fn, args);
    }

    /**
     * Delay invocation of the specified function closure by one or more frames.
     */
    public static function delayFrames (frames :int, fn :Function, args :Array = null) :void
    {
        _delayer.delayFrames(frames, fn, args);
    }

    /** The underlying delayer. */
    protected static var _delayer :FrameDelayer = new FrameDelayer();
}
}
