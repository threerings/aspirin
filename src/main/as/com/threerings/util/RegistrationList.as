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

public class RegistrationList
    implements Registration
{
    /**
     * Adds a Registration to the manager.
     * @return the Registration passed to the function.
     */
    public function add (r :Registration) :Registration
    {
        _regs.push(r);
        return r;
    }

    /**
     * Cancels all Registrations that have been added to the manager.
     */
    public function cancel () :void
    {
        var regs :Array = _regs;
        _regs = [];
        for each (var r :Registration in regs) {
            r.cancel();
        }
    }

    protected var _regs :Array = [];
}
}
