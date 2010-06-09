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

/**
 * Color utility methods.
 *
 * See also mx.utils.ColorUtil.
 */
public class ColorUtil
{
    /**
     * Blend the two colors, either 50-50 or according to the ratio specified.
     */
    public static function blend (
        first :uint, second :uint, firstPerc :Number = 0.5) :uint
    {
        var secondPerc :Number = 1 - firstPerc;

        var result :uint = 0;
        for (var shift :int = 0; shift <= 16; shift += 8) {
            var c1 :uint = (first >> shift) & 0xFF;
            var c2 :uint = (second >> shift) & 0xFF;
            result |= uint(Math.max(0, Math.min(255,
                (c1 * firstPerc) + (c2 * secondPerc)))) << shift;
        }
        return result;
    }

    /**
     * Returns a color's Hue value, in degrees. 0<=Hue<=360.
     * http://en.wikipedia.org/wiki/Hue
     */
    public static function getHue (color :uint) :Number
    {
        var r :Number = (color >> 16) & 0xff;
        var g :Number = (color >> 8) & 0xff;
        var b :Number = color & 0xff;

        var hue :Number = R2D * Math.atan2(ROOT_3 * (g - b), 2 * (r - g - b));
        return (hue >= 0 ? hue : hue + 360);
    }

    /**
     * Returns a color's brightness value, as a percentage. 0<=Brightness<=1.
     */
    public static function getBrightness (color :uint) :Number
    {
        var r :Number = ((color >> 16) & 0xff) * INV_255;
        var g :Number = ((color >> 8) & 0xff) * INV_255;
        var b :Number = (color & 0xff) * INV_255;

        return (r * LUMA_R) + (g * LUMA_G) + (b * LUMA_B);
    }

    /**
     * Adjusts the brightness of the given color. 0<=brightness<=1.
     */
    public static function setBrightness (color :uint, brightness :Number) :uint
    {
        if (brightness <= 0) {
            return 0;
        }

        var old :Number = getBrightness(color);
        if (old <= 0) {
            // special case: convert black to gray
            var component :Number = 255 * brightness;
            return composeColor(component, component, component);

        } else {
            var pct :Number = brightness / old;
            var r :Number = ((color >> 16) & 0xff) * pct;
            var g :Number = ((color >> 8) & 0xff) * pct;
            var b :Number = (color & 0xff) * pct;
            return composeColor(r, g, b);
        }
    }

    /**
     * Converts RGB components into a single 8 bit color value.
     * r, g, and b must all be in [0, 255]
     */
    public static function composeColor (r :uint, g :uint, b :uint) :uint
    {
        return (Math.min(r, 255) << 16) | (Math.min(g, 255) << 8) | Math.min(b, 255);
    }

    protected static const ROOT_3 :Number = Math.sqrt(3);
    protected static const R2D :Number = 180 / Math.PI; // radians to degrees
    protected static const INV_255 :Number = 1 / 255;

    // RGB to Luminance conversion constants as found on
    // Charles A. Poynton's colorspace-faq :
    // http://www.faqs.org/faqs/graphics/colorspace-faq/
    protected static const LUMA_R :Number = 0.212671;
    protected static const LUMA_G :Number = 0.71516;
    protected static const LUMA_B :Number = 0.072169;
}
}
