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

public class MediaPlayerCodes
{
    public static const STATE :String = "state";

    public static const DURATION :String = "duration";

    public static const POSITION :String = "position";

    public static const METADATA :String = "metadata";

    /** Only applicable for VideoPlayer. */
    public static const SIZE :String = "size";

    public static const ERROR :String = "error";

    /** Indicates we're still loading or initializing. */
    public static const STATE_UNREADY :int = 0;

    /** Indicates we're ready to play. */
    public static const STATE_READY :int = 1;

    public static const STATE_PLAYING :int = 2;

    public static const STATE_PAUSED :int = 3;

    /** Indicates that the playhead reached the end and the media has stopped. */
    public static const STATE_STOPPED :int = 4;
}
}
