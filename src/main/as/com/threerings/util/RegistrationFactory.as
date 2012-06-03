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

public class RegistrationFactory
{
    public static function createWithFunction (f :Function) :Registration {
        return new FunctionRegistration(f);
    }
}
}

import com.threerings.util.Registration;

class FunctionRegistration
    implements Registration
{
    public function FunctionRegistration (f :Function) {
        _f = f;
    }

    public function cancel () :void {
        var f :Function = _f;
        _f = null;
        f();
    }

    protected var _f :Function;
}
