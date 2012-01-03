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

package com.threerings.display {

import flash.display.DisplayObject;

/**
 * An Animation that linearly transitions the alpha attribute of a given display object from
 * one value to another and optionally executes a callback function when the transition is
 * complete.
 */
public class AlphaFade extends LinearAnimation
{
    /**
     * Constructs a new AlphaFade instance. The alpha values should lie in [0, 1] and the
     * duration is measured in milliseconds.
     */
    public function AlphaFade (
        disp :DisplayObject, from :Number = 0, to :Number = 1, duration :Number = 1,
        done :Function = null)
    {
        super(from, to, duration, done);
        _disp = disp;
    }

    override public function updateForValue (value :Number) :void
    {
        _disp.alpha = value;
    }

    protected var _disp :DisplayObject;
}
}
