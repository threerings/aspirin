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

package com.threerings.media {

import flash.display.DisplayObject;
import flash.display.Graphics;
import flash.display.Shape;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.geom.Point;

import com.threerings.util.ValueEvent;

/**
 * An extremely simple video display. Click to pause/play.
 */
public class SimpleVideoDisplay extends Sprite
{
    public static const NATIVE_WIDTH :int = 320;

    public static const NATIVE_HEIGHT :int = 240;

    /**
     * Create a video displayer.
     */
    public function SimpleVideoDisplay (player :VideoPlayer)
    {
        _player = player;
        _player.addEventListener(MediaPlayerCodes.SIZE, handlePlayerSize);

        addChild(_player.getDisplay());

        var masker :Shape = new Shape();
        this.mask = masker;
        addChild(masker);

        // create the mask...
        var g :Graphics = masker.graphics;
        g.clear();
        g.beginFill(0xFFFFFF);
        g.drawRect(0, 0, NATIVE_WIDTH, NATIVE_HEIGHT);
        g.endFill();

        addEventListener(MouseEvent.CLICK, handleClick);
    }

    override public function get width () :Number
    {
        return NATIVE_WIDTH;
    }

    override public function get height () :Number
    {
        return NATIVE_HEIGHT;
    }

    /**
     * Stop playing our video.
     */
    public function unload () :void
    {
        _player.unload();
    }

    protected function handleClick (event :MouseEvent) :void
    {
        // the buck stops here!
        event.stopImmediatePropagation();

        switch (_player.getState()) {
        case MediaPlayerCodes.STATE_READY:
        case MediaPlayerCodes.STATE_PAUSED:
            _player.play();
            break;

        case MediaPlayerCodes.STATE_PLAYING:
            _player.pause();
            break;

        default:
            trace("Click while player in unhandled state: " + _player.getState());
            break;
        }
    }

    protected function handlePlayerSize (event :ValueEvent) :void
    {
        const size :Point = Point(event.value);

        const disp :DisplayObject = _player.getDisplay();
        // TODO: siggggghhhhh
//        disp.scaleX = NATIVE_WIDTH / size.x;
//        disp.scaleY = NATIVE_HEIGHT / size.y;
        disp.width = NATIVE_WIDTH;
        disp.height = NATIVE_HEIGHT;

        // and, we redispatch
        dispatchEvent(event);
    }

    protected var _player :VideoPlayer;
}
}
