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
     * Returns a color's Hue value, in degrees. 0 &lt;= Hue &lt;= 360.
     * http://en.wikipedia.org/wiki/Hue
     */
    public static function getHue (color :uint) :Number
    {
        var r :Number = getRed(color);
        var g :Number = getGreen(color);
        var b :Number = getBlue(color);

        var hue :Number = R2D * Math.atan2(ROOT_3 * (g - b), 2 * (r - g - b));
        return (hue >= 0 ? hue : hue + 360);
    }

    /**
     * Returns a color's brightness value, as a percentage. 0 &lt;= Brightness &lt;= 1.
     */
    public static function getBrightness (color :uint) :Number
    {
        var r :Number = getRed(color) * INV_255;
        var g :Number = getGreen(color) * INV_255;
        var b :Number = getBlue(color) * INV_255;

        return (r * LUMA_R) + (g * LUMA_G) + (b * LUMA_B);
    }

    /**
     * Adjusts the brightness of the given color. 0&lt;=brightness&lt;=1.
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
            var r :Number = getRed(color) * pct;
            var g :Number = getGreen(color) * pct;
            var b :Number = getBlue(color) * pct;
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

    /**
     * Returns the 8-bit red component of the 24-bit color.
     */
    public static function getRed (color :uint) :uint
    {
        return color >> 16 & 0xFF;
    }

    /**
     * Returns the 8-bit green component of the 24-bit color.
     */
    public static function getGreen (color :uint) :uint
    {
        return color >> 8 & 0xFF;
    }

    /**
     * Returns the 8-bit blue component of the 24-bit color.
     */
    public static function getBlue (color :uint) :uint
    {
        return color & 0xFF;
    }

    /**
     * Returns an array of Numbers representing Hue, Saturation, and Brightness for the color
     *  specified in RGB.  Based on java.awt.Color.RGBtoHSB.
     */
    public static function RGBtoHSB (r :int, g :int, b :int) :Array
    {
        var hue :Number;
        var saturation :Number;
        var brightness :Number;

        var hsbvals :Array = new Array(3);

    	var cmax :int = (r > g) ? r : g;
	if (b > cmax) {
            cmax = b;
        }
	var cmin :int = (r < g) ? r : g;
	if (b < cmin) {
            cmin = b;
        }

	brightness = cmax / 255.0;
	if (cmax != 0) {
	    saturation = (Number(cmax - cmin)) / (Number(cmax));
        } else {
	    saturation = 0;
        }
	if (saturation == 0) {
	    hue = 0;
        } else {
	    var redc :Number = (Number(cmax - r)) / (Number(cmax - cmin));
	    var greenc :Number = (Number(cmax - g)) / (Number(cmax - cmin));
	    var bluec :Number = (Number(cmax - b)) / (Number(cmax - cmin));
	    if (r == cmax) {
		hue = bluec - greenc;
            } else if (g == cmax) {
	        hue = 2.0 + redc - bluec;
            } else {
		hue = 4.0 + greenc - redc;
            }
	    hue = hue / 6.0;
	    if (hue < 0) {
		hue = hue + 1.0;
            }
	}
	hsbvals[0] = hue;
	hsbvals[1] = saturation;
	hsbvals[2] = brightness;
	return hsbvals;
    }

    /**
     * Returns the uint representing the color in RGB that is equivalent to the hue, saturation,
     *  and brightness specified.  Based upon java.awt.Color.HSBtoRGB.
     */
    public static function HSBtoRGB (hue :Number, saturation :Number, brightness :Number) :uint
    {
        var r :int = 0;
        var g :int = 0;
        var b :int = 0;

        if (saturation == 0) {
            r = g = b = int(brightness * 255.0 + 0.5);
        } else {
            var h :Number = (hue - Math.floor(hue)) * 6.0;
            var f :Number = h - Math.floor(h);
            var p :Number = brightness * (1.0 - saturation);
            var q :Number = brightness * (1.0 - saturation * f);
            var t :Number = brightness * (1.0 - (saturation * (1.0 - f)));
            switch (int(h)) {
            case 0:
                r = int(brightness * 255.0 + 0.5);
                g = int(t * 255.0 + 0.5);
                b = int(p * 255.0 + 0.5);
                break;
            case 1:
                r = int(q * 255.0 + 0.5);
                g = int(brightness * 255.0 + 0.5);
                b = int(p * 255.0 + 0.5);
                break;
            case 2:
                r = int(p * 255.0 + 0.5);
                g = int(brightness * 255.0 + 0.5);
                b = int(t * 255.0 + 0.5);
                break;
            case 3:
                r = int(p * 255.0 + 0.5);
                g = int(q * 255.0 + 0.5);
                b = int(brightness * 255.0 + 0.5);
                break;
            case 4:
                r = int(t * 255.0 + 0.5);
                g = int(p * 255.0 + 0.5);
                b = int(brightness * 255.0 + 0.5);
                break;
            case 5:
                r = int(brightness * 255.0 + 0.5);
                g = int(p * 255.0 + 0.5);
                b = int(q * 255.0 + 0.5);
                break;
            }
        }
        return 0xff000000 | (r << 16) | (g << 8) | (b << 0);

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
