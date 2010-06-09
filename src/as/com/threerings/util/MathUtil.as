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

package com.threerings.util {

/**
 * Collection of math utility functions.
 */
public class MathUtil
{
    /**
     * Returns the value of n clamped to be within the range [min, max].
     */
    public static function clamp (n :Number, min :Number, max :Number) :Number
    {
        return Math.min(Math.max(n, min), max);
    }

    /**
     * Converts degrees to radians.
     */
    public static function toRadians (degrees :Number) :Number
    {
        return degrees * Math.PI / 180;
    }

    /**
     * Normalizes an angle in radians to occupy the [0, 2pi) range.
     */
    public static function normalizeRadians (radians :Number) :Number
    {
        const twopi :Number = Math.PI * 2;
        var norm :Number = radians % twopi;
        return (norm >= 0) ? norm : (norm + twopi);
    }

    /**
     * Converts radians to degrees.
     */
    public static function toDegrees (radians :Number) :Number
    {
        return radians * 180 / Math.PI;
    }

    /**
     * Normalizes an angle in degrees to occupy the [0, 360) range.
     */
    public static function normalizeDegrees (degrees :Number) :Number
    {
        var norm :Number = degrees % 360;
        return (norm >= 0) ? norm : (norm + 360);
    }

    /**
     * Returns distance from point (x1, y1) to (x2, y2) in 2D.
     *
     * <p>Supports various distance metrics: the common Euclidean distance, taxicab distance,
     * arbitrary Minkowski distances, and Chebyshev distance.
     *
     * <p>See the <a href="http://www.nist.gov/dads/HTML/lmdistance.html">NIST web page on 
     * distance definitions</a>.<p>
     *
     * @param x1 x value of the first point
     * @param y1 y value of the first point
     * @param x2 x value of the second point
     * @param y2 y value of the second point    
     * @param p Optional: p value of the norm function. Common cases:
     *          <ul><li>p = 2 (default): standard Euclidean distance on a plane
     *              <li>p = 1: taxicab distance (aka Manhattan distance)
     *              <li>p = Infinity: Chebyshev distance
     *          </ul>
     *          <b>Note</b>: p < 1 or p = NaN are treated as equivalent to p = Infinity
     */
    public static function distance (
        x1 :Number, y1 :Number, x2 :Number, y2 :Number, p :Number = 2) :Number
    {
        var dx :Number = x2 - x1;
        var dy :Number = y2 - y1;

        if (p == 2) {
            // optimized version for Euclidean
            return Math.sqrt(dx * dx + dy * dy);
        }

        // from here on out: we're not squaring dx and dy, so make them positive.
        dx = Math.abs(dx);
        dy = Math.abs(dy);

        if (p == 1) {
            // optimized version for taxicab distance
            return (dx + dy);

        } else if (!isFinite(p) || (p < 1)) { // aka: (p is Infinity, -Infinity, NaN, or negative)
            // optimized version for Chebyshev
            return Math.max(dx, dy);

        } else {
            // generic version (p > 2 && p < Infinity)
            var xx :Number = Math.pow(dx, p);
            var yy :Number = Math.pow(dy, p);
            return Math.pow(xx + yy, 1 / p);
        }
    }

    /**
     * Computes the floored division <code>dividend/divisor</code> which
     * is useful when dividing potentially negative numbers into bins. For
     * positive numbers, it is the same as normal division, for negative
     * numbers it returns <code>(dividend - divisor + 1) / divisor</code>.
     *
     * <p> For example, the following numbers floorDiv 10 are:
     * <pre>
     * -15 -10 -8 -2 0 2 8 10 15
     *  -2  -1 -1 -1 0 0 0  1  1
     * </pre>
     */
    public static function floorDiv (dividend :int, divisor :int) :int
    {
        return ((dividend >= 0) ? dividend : (dividend - divisor + 1))/divisor;
    }    
}
}
