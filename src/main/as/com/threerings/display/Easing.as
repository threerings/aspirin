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

package com.threerings.display {

/**
 * Some easing functions.
 */
public class Easing
{
    /**
     * Interpolates cubically between two values, with beginning and end derivates set
     * to zero. See http://en.wikipedia.org/wiki/Cubic_Hermite_spline for details.
     */
    public static function cubicHermiteSpline (
        t :Number, b :Number, c :Number, d :Number, p_params :Object = null) :Number
    {
        // convert t to 0-1
        t = (t / d);
        if (t <= 0) {
            return b;
        }
        const end :Number = b + c;
        if (t >= 1) {
            return end;
        }
        const startSlope :Number = (p_params == null) ? 0 : Number(p_params["startSlope"]);
        const endSlope :Number = (p_params == null) ? 0 : Number(p_params["endSlope"]);
        const tt :Number = t * t;
        const ttt :Number = tt * t;
        return b * (2*ttt - 3*tt + 1) +
               startSlope * (ttt - 2*tt + t) +
               end * (-2*ttt + 3*tt) +
               endSlope * (ttt -tt);
    }
}
}
