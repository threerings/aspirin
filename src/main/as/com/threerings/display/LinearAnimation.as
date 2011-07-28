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

package com.threerings.display {

/**
 * An Animation that linearly transitions from one value to another and optionally executes a
 * callback function when the transition is complete.  A subclass must implement updateForValue
 * to change whatever is being animated for the value.
 */
public class LinearAnimation extends AnimationImpl
{
    public function LinearAnimation (
        from :Number = 0, to :Number = 1, duration :Number = 1, done :Function = null)
    {
        _from = from;
        _to = to;
        _duration = duration;
        _done = done;
    }

    override public function updateAnimation (elapsed :Number) :void
    {
        if (elapsed < _duration) {
            updateForValue(_from + ((_to - _from) * elapsed) / _duration);
        } else {
            updateForValue(_to);
            stopAnimation();
            if (_done != null) {
                _done();
            }
        }
    }

    public function updateForValue (value :Number) :void
    {
        // please implement!
    }

    protected var _from :Number;
    protected var _to :Number;
    protected var _duration :Number;
    protected var _done :Function;
}
}
