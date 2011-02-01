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

package com.threerings.ui {

import com.threerings.util.EventHandlerManager;
import com.threerings.util.F;

import flash.display.DisplayObject;
import flash.display.MovieClip;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.EventPhase;
import flash.events.MouseEvent;

/**
 * A Sprite that simulates SimpleButton behavior and gets around its annoying limitations.
 *
 * If a SimpleButton is customized with MovieClip-based states, those MovieClips will be
 * restarted every time the SimpleButton's state changes. CustomButton doesn't do this.
 */
public class CustomButton extends Sprite
{
    public function CustomButton (upState :DisplayObject = null, overState :DisplayObject = null,
        downState :DisplayObject = null)
    {
        this.mouseChildren = false;
        this.buttonMode = true;

        _upState = upState;
        _overState = overState;
        _downState = downState;
        updateState();

        addEventListener(Event.ADDED_TO_STAGE, F.callback(setupMouseEvents));
        addEventListener(Event.REMOVED_FROM_STAGE, F.callback(_events.freeAllHandlers));
    }

    public function get upState () :DisplayObject
    {
        return _upState;
    }

    public function set upState (val :DisplayObject) :void
    {
        _upState = val;
        updateState();
    }

    public function get overState () :DisplayObject
    {
        return _overState;
    }

    public function set overState (val :DisplayObject) :void
    {
        _overState = val;
        updateState();
    }

    public function get downState () :DisplayObject
    {
        return _downState;
    }

    public function set downState (val :DisplayObject) :void
    {
        _downState = val;
        updateState();
    }

    public function set toggled (toggled :Boolean) :void
    {
        _toggled = toggled;
        updateState();
    }

    public function get toggled () :Boolean
    {
        return _toggled;
    }

    protected function setupMouseEvents () :void
    {
        // We capture mouse-ups on the stage, rather than on the button itself, so that
        // we can detect when the mouse is pressed, moved off the button, and then released
        function captureMouseUp (e :MouseEvent) :void {
            if (e.eventPhase != EventPhase.BUBBLING_PHASE) {
                _events.unregisterListener(stage, MouseEvent.MOUSE_UP, captureMouseUp);
                _events.unregisterListener(stage, MouseEvent.MOUSE_UP, captureMouseUp, true);
                _mouseDown = false;
                updateState();
            }
        }

        _events.registerListener(this, MouseEvent.ROLL_OVER,
            function (..._) :void {
                _mouseOver = true;
                updateState();
            });
        _events.registerListener(this, MouseEvent.ROLL_OUT,
            function (..._) :void {
                _mouseOver = false;
                updateState();
            });
        _events.registerListener(this, MouseEvent.MOUSE_DOWN,
            function (..._) :void {
                _events.registerListener(stage, MouseEvent.MOUSE_UP, captureMouseUp);
                _events.registerListener(stage, MouseEvent.MOUSE_UP, captureMouseUp, true);
                _mouseDown = true;
                updateState();
            });
    }

    protected function updateState () :void
    {
        var newState :DisplayObject;
        if (_mouseDown && _mouseOver || _toggled) {
            newState = _downState;
        } else if (_mouseDown || _mouseOver) {
            newState = _overState;
        } else {
            newState = _upState;
        }

        if (_curState != newState) {
            if (_curState != null) {
                _curState.parent.removeChild(_curState);
            }
            _curState = newState;
            if (_curState != null) {
                addChild(_curState);
            }
        }
    }

    protected var _upState :DisplayObject;
    protected var _overState :DisplayObject;
    protected var _downState :DisplayObject;

    protected var _curState :DisplayObject;

    protected var _mouseOver :Boolean;
    protected var _mouseDown :Boolean;
    protected var _toggled :Boolean;

    protected var _events :EventHandlerManager = new EventHandlerManager();
}

}
