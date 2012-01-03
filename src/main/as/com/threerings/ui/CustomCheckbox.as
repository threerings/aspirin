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

package com.threerings.ui {

import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;

import com.threerings.ui.CustomButton;

/**
 * Dispatched when the checkbox's "checked" property changes
 * @eventType flash.events.Event.CHANGE
 */
[Event(name="change", type="flash.events.Event.CHANGE")]

public class CustomCheckbox extends Sprite
{
    public function CustomCheckbox (
        uncheckedUpState :DisplayObject = null,
        uncheckedOverState :DisplayObject = null,
        uncheckedDownState :DisplayObject = null,
        checkedUpState :DisplayObject = null,
        checkedOverState :DisplayObject = null,
        checkedDownState :DisplayObject = null)
    {
        _btnUnchecked = new CustomButton(uncheckedUpState, uncheckedOverState, uncheckedDownState);
        _btnChecked = new CustomButton(checkedUpState, checkedOverState, checkedDownState);

        addEventListener(MouseEvent.CLICK,
            function (..._) :void {
                checked = !checked;
            });

        addChild(_btnChecked);
        addChild(_btnUnchecked);

        // unchecked by default
        _checked = false;
        _btnChecked.visible = false;
    }

    public function get checked () :Boolean
    {
        return _checked;
    }

    public function set checked (val :Boolean) :void
    {
        if (_checked != val) {
            _checked = val;
            _btnChecked.visible = _checked;
            _btnUnchecked.visible = !_checked;
            dispatchEvent(new Event(Event.CHANGE));
        }
    }

    protected var _btnUnchecked :CustomButton;
    protected var _btnChecked :CustomButton;
    protected var _checked :Boolean;
}

}
