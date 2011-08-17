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

package com.threerings.ui {

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Shape;
import flash.display.SimpleButton;
import flash.display.Sprite;
import flash.text.TextField;
import flash.text.TextFormat;

import com.threerings.display.ImageUtil;

import com.threerings.text.TextFieldUtil;

/**
 * A simple skin that shifts the text in the down state.
 */
public class SimpleSkinButton extends SimpleButton
{
    /**
     * Create a SimpleSkinButton.
     * @param skin a BitmapData, Bitmap, or class that will turn into either.
     * @param text the text to place on the button
     * @param textFieldProps initProps for the TextField
     * @param textFormatProps initProps for the TextFormat
     * @param outline if a uint, the color of the outline to put over the skin.
     */
    public function SimpleSkinButton (
        skin :*, text :String, textFieldProps :Object = null, textFormatProps :Object = null,
        padding :int = 10, height :Number = NaN, xshift :int = 0, yshift :int = 1,
        outline :Object = null)
    {
        var bmp :BitmapData = ImageUtil.toBitmapData(skin);
        if (bmp == null) {
            throw new Error("Skin must be a Bitmap, BitmapData, or Class");
        }

        upState = createState(bmp, text, textFieldProps, textFormatProps,
            padding, height, 0, 0, outline);
        overState = upState;
        hitTestState = overState;
        downState = createState(bmp, text, textFieldProps, textFormatProps,
            padding, height, xshift, yshift, outline);
    }

    protected function createState (
        bmp :BitmapData, text :String, textFieldProps :Object, textFormatProps :Object,
        padding :int, height :Number, xshift :int, yshift :int, outline :Object) :Sprite
    {
        var state :Sprite = new Sprite();
        var field :TextField = TextFieldUtil.createField(text, textFieldProps, textFormatProps);

        if (isNaN(height)) {
            height = field.height;
        }

        var skin :Bitmap = new Bitmap(bmp);
        skin.width = field.width + (padding * 2);
        skin.height = height;
        state.addChild(skin);

        field.x = padding + xshift;
        field.y = (height - field.height) / 2 + yshift;
        state.addChild(field);

        if (outline != null) {
            var border :Shape = new Shape();
            border.graphics.lineStyle(1, uint(outline));
            border.graphics.drawRect(0, 0, skin.width - 1, skin.height - 1);
            state.addChild(border);
        }

        return state;
    }
}
}
