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

/**
 * Simplified access functions to flash.system.Capabilities.
 */

package com.threerings.util {

import flash.system.Capabilities;

public class Capabilities {
    /**
     * Get the flash player version as an array of Strings, like [ "9", "0", "115", "0" ].
     */
    public static function getFlashVersion () :Array
    {
        // the version looks like "LNX 9,0,31,0"
        var bits :Array = flash.system.Capabilities.version.split(" ");
        return (bits[1] as String).split(",");
    }

    /**
     * Get the major flash player version as an integer, e.g. 9.
     */
    public static function getFlashMajorVersion () :int
    {
        return int(getFlashVersion()[0]);
    }

    /**
     * Determine if the current Flash player is at least of major version 10. */
    public static function isFlash10 () :Boolean
    {
        return getFlashMajorVersion() >= 10;
    }
}
}
