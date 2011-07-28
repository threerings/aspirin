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

package com.threerings.util.maps {

import flash.events.TimerEvent;
import flash.utils.Timer;
import flash.utils.getTimer;

import com.threerings.util.Log;
import com.threerings.util.Map;

/**
 * A map that will automatically expire elements.
 */
public class ExpiringMap extends LinkedMap
{
    public function ExpiringMap (source :Map, ttl :int, expireHandler :Function = null)
    {
        super(source);
        _ttl = ttl;
        _expireHandler = expireHandler;
        _timer = new Timer(_ttl, 1);
        _timer.addEventListener(TimerEvent.TIMER, handleTimer);
    }

    /** @private */
    override protected function newEntry (key :Object, value :Object) :LinkedEntry
    {
        var ee :ExpiringEntry = new ExpiringEntry(key, value, getTimer() + _ttl);
        if (!_timer.running) {
            _timer.delay = _ttl;
            _timer.start();
        }
        return ee;
    }

    /** @private */
    protected function handleTimer (event :TimerEvent) :void
    {
        _timer.reset();
        var now :int = getTimer();
        // go through the entries, removing some as necessary
        while (_anchor.after is ExpiringEntry) {
            var exp :ExpiringEntry = ExpiringEntry(_anchor.after);
            var untilExpire :int = exp.expireTime - now;
            if (untilExpire <= 0) {
                remove(exp.key);
                if (_expireHandler != null) {
                    try {
                        _expireHandler(exp.key, exp.value);
                    } catch (e :Error) {
                        Log.getLog(this).warning("Error calling expire handler", e);
                    }
                }

            } else {
                _timer.delay = untilExpire;
                _timer.start();
                return;
            }
        }
    }

    /** @private */
    protected var _ttl :int;

    /** @private */
    protected var _expireHandler :Function;

    /** @private */
    protected var _timer :Timer;
}
}
