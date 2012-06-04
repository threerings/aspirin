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

public class WeightedArray
{
    public function WeightedArray (rands :Randoms)
    {
        _rands = rands;
    }

    public function clear () :void
    {
        _data = [];
        _dataDirty = true;
    }

    public function push (data :*, relativeChance :Number) :void
    {
        if (relativeChance <= 0) {
            throw new ArgumentError("relativeChance must be > 0");
        }

        _data.push(new WeightedData(data, relativeChance));
        _dataDirty = true;
    }

    public function getNextData () :*
    {
        updateData();

        if (_data.length == 0) {
            return undefined;
        }

        var max :Number = WeightedData(_data[_data.length - 1]).max;
        var val :Number = _rands.getNumberInRange(0, max);

        // binary-search the set of WeightedData
        var loIdx :int = 0;
        var hiIdx :int = _data.length - 1;
        for (;;) {
            if (loIdx > hiIdx) {
                // something's broken
                break;
            }

            var idx :int = loIdx + ((hiIdx - loIdx) * 0.5);
            var wd :WeightedData = _data[idx];
            if (val < wd.min) {
                // too high
                hiIdx = idx - 1;
            } else if (val >= wd.max) {
                // too low
                loIdx = idx + 1;
            } else {
                // hit!
                return wd.data;
            }
        }

        // How did we get here?
        return undefined;
    }

    /**
     * Get an array of all of the items that can be returned by this WeightedArray.
     */
    public function getAllData () :Array
    {
        return _data.map(function (wd :WeightedData, ...ignored) :* {
            return wd.data;
        });
    }

    /**
     * The function argument should have the following signature:
     * function (item :*, relativeChance :Number) :void.
     * It will be called once per item in the array.
     */
    public function forEach (callback :Function) :void
    {
        _data.forEach(function (wd :WeightedData, ...ignored) :void {
            callback(wd.data, wd.relativeChance);
        });
    }

    /**
     * @return the percentage chance - a value in [0, 1] - that the given data will be returned
     * from a call to getNextData(), given the relative chance of all other data in the array.
     */
    public function getAbsoluteChance (data :*) :Number
    {
        updateData();

        if (_data.length == 0) {
            return 0;
        }

        var max :Number = WeightedData(_data[_data.length - 1]).max;
        var dataChance :Number = 0;
        forEach(function (thisData :*, relativeChance :Number) :void {
            if (thisData === data) {
                dataChance += relativeChance;
            }
        });

        return dataChance / max;
    }

    public function get length () :int
    {
        return _data.length;
    }

    protected function updateData () :void
    {
        if (_dataDirty) {
            var totalVal :Number = 0;
            for each (var wd :WeightedData in _data) {
                wd.min = totalVal;
                totalVal += wd.relativeChance;
            }

            _dataDirty = false;
        }
    }

    protected var _rands :Randoms;
    protected var _dataDirty :Boolean;

    protected var _data :Array = [];
}

}

class WeightedData
{
    public var data :*;
    public var relativeChance :Number;
    public var min :Number;

    public function get max () :Number
    {
        return min + relativeChance;
    }

    public function WeightedData (data :*, relativeChance :Number)
    {
        this.data = data;
        this.relativeChance = relativeChance;
    }
}
