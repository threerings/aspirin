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

[Deprecated(replacement="com.threerings.util.Arrays")]
public class ArrayUtil
{
    public static function create (size :uint, val :* = null) :Array
    {
        return Arrays.create(size, val);
    }

    public static function range (min :Number, max :Number = 0, step :Number = 1) :Array
    {
        return Arrays.range(min, max, step);
    }

    public static function resize (arr :Array, newLength :uint) :void
    {
        Arrays.resize(arr, newLength);
    }

    public static function padToLength (arr :Array, size :uint, val :* = null) :Array
    {
        return Arrays.padToLength(arr, size, val);
    }

    public static function copyOf (arr :Array) :Array
    {
        return Arrays.copyOf(arr);
    }

    public static function max (arr :Array, comp :Function = null) :*
    {
        return Arrays.max(arr, comp);
    }

    public static function min (arr :Array, comp :Function = null) :*
    {
        return Arrays.min(arr, comp);
    }

    public static function sort (arr :Array) :void
    {
        Arrays.sort(arr);
    }

    public static function sortOn (arr :Array, sortFields :Array) :void
    {
        Arrays.sortOn(arr, sortFields);
    }

    public static function stableSort (arr :Array, comp :Function = null) :void
    {
        Arrays.stableSort(arr, comp);
    }

    public static function sortedInsert (arr :Array, val :*, comp :Function = null) :int
    {
        return Arrays.sortedInsert(arr, val, comp);
    }

    public static function shuffle (arr :Array, rando :Random = null) :void
    {
        Arrays.shuffle(arr, rando);
    }

    public static function indexIf (arr :Array, predicate :Function) :int
    {
        return Arrays.indexIf(arr, predicate);
    }

    public static function findIf (arr :Array, predicate :Function) :*
    {
        return Arrays.findIf(arr, predicate);
    }

    public static function indexOf (arr :Array, element :Object) :int
    {
        return Arrays.indexOf(arr, element);
    }

    public static function contains (arr :Array, element :Object) :Boolean
    {
        return Arrays.contains(arr, element);
    }

    public static function removeFirst (arr :Array, element :Object) :Boolean
    {
        return Arrays.removeFirst(arr, element);
    }

    public static function removeLast (arr :Array, element :Object) :Boolean
    {
        return Arrays.removeLast(arr, element);
    }

    public static function removeAll (arr :Array, element :Object) :Boolean
    {
        return Arrays.removeAll(arr, element);
    }

    public static function removeFirstIf (arr :Array, pred :Function) :Boolean
    {
        return Arrays.removeFirstIf(arr, pred);
    }

    public static function removeLastIf (arr :Array, pred :Function) :Boolean
    {
        return Arrays.removeLastIf(arr, pred);
    }

    public static function removeAllIf (arr :Array, pred :Function) :Boolean
    {
        return Arrays.removeAllIf(arr, pred);
    }

    public static function splice (
        arr :Array, index :int, deleteCount :int, insertions :Array = null) :Array
    {
        return Arrays.splice(arr, index, deleteCount, insertions);
    }

    public static function equals (ar1 :Array, ar2 :Array) :Boolean
    {
        return Arrays.equals(ar1, ar2);
    }

    public static function copy (
        src :Array, srcoffset :uint, dst :Array, dstoffset :uint, count :uint) :void
    {
        Arrays.copy(src, srcoffset, dst, dstoffset, count);
    }

    public static function transpose (x :Array, y :Array, ...arrays) :Array
    {
        // TODO: Call Arrays version

        arrays.splice(0, 0, x, y);
        var len :int = Math.max.apply(null, arrays.map(Util.adapt(function (arr :Array) :int {
            return arr.length;
        })));
        var result :Array = new Array(len);
        var tuple :Array;
        for (var ii :int = 0; ii < len; ++ii) {
            result[ii] = tuple = new Array(arrays.length);
            for (var jj :int = 0; jj < arrays.length; ++jj) {
                tuple[jj] = arrays[jj][ii]; // may be undefined, ok
            }
        }
        return result;
    }

    public static function binarySearch (
        array :Array, offset :int, length :int, key :*, comp :Function) :int
    {
        return Arrays.binarySearch(array, offset, length, key, comp);
    }

    public static function fill (array :Array, val :*) :void
    {
        Arrays.fill(array, val);
    }
}
}
