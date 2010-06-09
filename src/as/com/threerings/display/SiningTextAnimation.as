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

package com.threerings.display {

import flash.text.TextFormat;

public class SiningTextAnimation extends TextCharAnimation
{
    public function SiningTextAnimation (text :String, textArgs :Object)
    {
        super(text, movementFn, textArgs);
    }

    protected function movementFn (elapsed :Number, index :Number) :Number
    {
        return 10 * Math.sin((elapsed / 500) + (index * Math.PI / 5));
    }
}
}
