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
import flash.geom.Point;

import com.threerings.util.ValueEvent;

/**
 * Disptached when the size of the video is known.
 * <b>value</b>: a Point expressing the width/height.
 *
 * @eventType com.threerings.flash.media.MediaPlayerCodes.SIZE
 */
[Event(name="size", type="com.threerings.util.ValueEvent")]

/**
 * Implemented by video-playing backends.
 */
public interface VideoPlayer extends MediaPlayer
{
    /**
     * Get the actual visualization of the video.
     */
    function getDisplay () :DisplayObject;

    /**
     * Get the size of the video, or null if not yet known.
     */
    function getSize () :Point;
}
}
