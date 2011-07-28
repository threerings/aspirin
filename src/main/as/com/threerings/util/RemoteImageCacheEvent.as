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

package com.threerings.util {

import flash.events.Event;

public class RemoteImageCacheEvent extends Event
{
    public static const LOAD_SUCCESS :String = "LoadSuccess";
    public static const LOAD_ERROR :String = "LoadError";

    public var url :String;

    public function RemoteImageCacheEvent (type :String, url :String)
    {
        super(type);
        this.url = url;
    }

    override public function clone () :Event
    {
        return new RemoteImageCacheEvent(type, url);
    }
}
}
