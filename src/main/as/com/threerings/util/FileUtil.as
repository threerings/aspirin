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

package com.threerings.util {

public class FileUtil
{
    /**
     * Returns the substring composed of the characters after the last '.' in the supplied string.
     * The substring will be converted to lowercase.
     */
    public static function getDotSuffix (filename :String) :String
    {
        // is there a dot?
        var ix :int = filename.lastIndexOf(".");
        if (ix >= 0) {
            var ext :String = filename.substr(ix + 1);
            // is there a ?foo=bar component?
            ix = ext.indexOf('?');
            if (ix > 0) {
                ext = ext.substring(0, ix);
            }
            return ext.toLowerCase();
        }
        return "";
    }

    /**
     * Returns the substring composed of the characters before the last '.' in the supplied string.
     */
    public static function stripDotSuffix (filename :String) :String
    {
        var ix :int = filename.lastIndexOf(".");
        return (ix >= 0 ? filename.substr(0, ix) : filename);
    }

    /**
     * Returns the substring composed of the characters after the last path separator
     * in the supplied string.
     */
    public static function stripPath (filename :String, separator :String = "/") :String
    {
        var ix :int = filename.lastIndexOf(separator);
        return (ix >= 0 ? filename.substr(ix + 1) : filename);
    }

    /**
     * Strips the path and dot-suffix from the given filename.
     */
    public static function stripPathAndDotSuffix (filename :String, separator :String = "/") :String
    {
        return stripDotSuffix(stripPath(filename, separator));
    }
}

}
