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
 * Contains methods that should be in Array, but aren't. Additionally
 * contains methods that understand the interfaces in this package.
 * So, for example, removeFirst() understands Equalable and will remove
 * an element that is equals() to the specified element, rather than just
 * === (strictly equals) to the specified element.
 */
public class Arrays
{
    /**
     * Creates a new Array and fills it with a default value.
     * @param size the size of the array
     * @param val the value to store at each index of the Array
     */
    public static function create (size :uint, val :* = null) :Array
    {
        return padToLength([], size, val);
    }

    /**
     * Creates a new Array filled with a range of numbers.
     *
     * @param min Number to start counting from.
     * @param max Number to count up to.
     * @param step Count by this number. Must be positive.
     * @return [min, max)
     */
    public static function range (min :Number, max :Number = 0, step :Number = 1) :Array
    {
        var list :Array = [];
        if (min > max) {
            var swap :Number = max;
            max = min;
            min = swap;
        }
        while (min < max) {
            list.push(min);
            min += step;
        }
        return list;
    }

    /**
     * Properly resizes an Array, truncating if it's too large, and padding it with 'undefined'
     * if too small.
     *
     * An Array grown with the Array class's length setter will not actually have the
     * number of elements that it claims to.
     */
    public static function resize (arr :Array, newLength :uint) :void
    {
        if (arr.length > newLength) {
            arr.length = newLength;
        } else {
            padToLength(arr, newLength, undefined);
        }
    }

    /**
     * Pad the array to the specified length with the value specified, returning the passed-in
     * array for convenience.
     */
    public static function padToLength (arr :Array, size :uint, val :* = null) :Array
    {
        while (arr.length < size) {
            arr.push(val);
        }
        return arr;
    }

    /**
     * Creates a shallow copy of the array.
     *
     * @internal TODO: add support for copy ranges and deep copies?
     */
    public static function copyOf (arr :Array) :Array
    {
        return arr.slice();
    }

    /**
     * Find the maximum element in the array according to the specified Comparator, or
     * according to Comparators.compareUnknowns if no Comparator is specified.
     *
     * @return the maximum value, or undefined if the array is empty.
     */
    public static function max (arr :Array, comp :Function = null) :*
    {
        var len :uint = arr.length;
        if (len == 0) {
            return undefined;
        }
        if (comp == null) {
            comp = Comparators.compareUnknowns;
        }
        var max :* = arr[0];
        for (var ii :uint = 1; ii < len; ii++) {
            if (comp(max, arr[ii]) < 0) {
                max = arr[ii];
            }
        }
        return max;
    }

    /**
     * Find the minimum element in the array according to the specified Comparator, or
     * according to Comparators.compareUnknowns if no Comparator is specified.
     *
     * @return the minimum value, or undefined if the array is empty.
     */
    public static function min (arr :Array, comp :Function = null) :*
    {
        if (comp == null) {
            comp = Comparators.compareUnknowns;
        }
        return max(arr, Comparators.createReverse(comp));
    }

    /**
     * Sort the specified array according to natural order- all elements
     * must implement Comparable or be null.
     */
    public static function sort (arr :Array) :void
    {
        arr.sort(Comparators.compareComparables);
    }

    /**
     * Sort the specified array according to one or more fields of the objects in the Array.
     *
     * Array.sortOn() only works with public variables, and not with public getters.
     * This implementation works with both.
     *
     * @param sortFields an Array of Strings, representing the order of fields to sort the array by
     */
    public static function sortOn (arr :Array, sortFields :Array) :void
    {
        stableSort(arr, Comparators.createFields(sortFields));
    }

    /**
     * Perform a stable sort on the specified array.
     * @param comp a function that takes two objects in the array and returns -1 if the first
     * object should appear before the second in the container, 1 if it should appear after,
     * and 0 if the order does not matter. If omitted, Comparators.compareComparables is used and
     * the array elements should be Comparable objects.
     */
    public static function stableSort (arr :Array, comp :Function = null) :void
    {
        if (comp == null) {
            comp = Comparators.compareComparables;
        }
        // insertion sort implementation
        var nn :int = arr.length;
        for (var ii :int = 1; ii < nn; ii++) {
            var val :* = arr[ii];
            var jj :int = ii - 1;
            for (; jj >= 0; jj--) {
                var compVal :* = arr[jj];
                if (comp(val, compVal) >= 0) {
                    break;
                }
                arr[jj + 1] = compVal;
            }
            arr[jj + 1] = val;
        }
    }

    /**
     * Inserts an object into a sorted Array in its correct, sorted location.
     *
     * @param comp a function that takes two objects in the array and returns -1 if the first
     * object should appear before the second in the container, 1 if it should appear after,
     * and 0 if the order does not matter. If omitted, Comparators.compareComparables is used and
     * the array elements should be Comparable objects.
     *
     * @return the index of the inserted item
     */
    public static function sortedInsert (arr :Array, val :*, comp :Function = null) :int
    {
        if (comp == null) {
            comp = Comparators.compareComparables;
        }
        var index :int = binarySearch(arr, 0, arr.length, val, comp);
        if (index < 0) {
            index = -(index + 1);
        }
        arr.splice(index, 0, val);
        return index;
    }

    /**
     * Randomly shuffle the elements in the specified array.
     *
     * @param rando a random number generator to use, or null if you don't care.
     */
    public static function shuffle (arr :Array, rando :Random = null) :void
    {
        var randFunc :Function = (rando != null) ? rando.nextInt :
            function (n :int) :int {
                return int(Math.random() * n);
            };
        // starting from the end of the list, repeatedly swap the element in
        // question with a random element previous to it up to and including
        // itself
        for (var ii :int = arr.length - 1; ii > 0; ii--) {
            var idx :int = randFunc(ii + 1);
            var tmp :Object = arr[idx];
            arr[idx] = arr[ii];
            arr[ii] = tmp;
        }
    }

    /**
     * Returns the index of the first item in the array for which the predicate function
     * returns true, or -1 if no such item was found. The predicate function should be of type:
     *   function (element :*) :Boolean { }
     *
     * @return the zero-based index of the matching element, or -1 if none found.
     */
    public static function indexIf (arr :Array, predicate :Function) :int
    {
        if (arr != null) {
            for (var ii :int = 0; ii < arr.length; ii++) {
                if (predicate(arr[ii])) {
                    return ii;
                }
            }
        }
        return -1; // never found
    }

    /**
     * Returns the first item in the array for which the predicate function returns true, or
     * undefined if no such item was found. The predicate function should be of type:
     *   function (element :*) :Boolean { }
     *
     * @return the matching element, or undefined if no matching element was found.
     */
    public static function findIf (arr :Array, predicate :Function) :*
    {
        var index :int = (arr != null ? indexIf(arr, predicate) : -1);
        return (index >= 0 ? arr[index] : undefined);
    }

    /**
     * Returns the first index of the supplied element in the array. Note that if the element
     * implements Equalable, an element that is equals() will have its index returned, instead
     * of requiring the search element to be === (strictly equal) to an element in the array
     * like Array.indexOf().
     *
     * @return the zero-based index of the matching element, or -1 if none found.
     */
    public static function indexOf (arr :Array, element :Object) :int
    {
        if (arr != null) {
            for (var ii :int = 0; ii < arr.length; ii++) {
                if (Util.equals(arr[ii], element)) {
                    return ii;
                }
            }
        }
        return -1; // never found
    }

    /**
     * @return true if the specified element, or one that is Equalable.equals() to it, is
     * contained in the array.
     */
    public static function contains (arr :Array, element :Object) :Boolean
    {
        return (indexOf(arr, element) != -1);
    }

    /**
     * Remove the first instance of the specified element from the array.
     *
     * @return true if an element was removed, false otherwise.
     */
    public static function removeFirst (arr :Array, element :Object) :Boolean
    {
        return removeImpl(arr, element, true);
    }

    /**
     * Remove the last instance of the specified element from the array.
     *
     * @return true if an element was removed, false otherwise.
     */
    public static function removeLast (arr :Array, element :Object) :Boolean
    {
        arr.reverse();
        var removed :Boolean = removeFirst(arr, element);
        arr.reverse();
        return removed;
    }

    /**
     * Removes all instances of the specified element from the array.
     *
     * @return true if at least one element was removed, false otherwise.
     */
    public static function removeAll (arr :Array, element :Object) :Boolean
    {
        return removeImpl(arr, element, false);
    }

    /**
     * Removes the first element in the array for which the specified predicate returns true.
     *
     * @param pred a Function of the form: function (element :*) :Boolean
     *
     * @return true if an element was removed, false otherwise.
     */
    public static function removeFirstIf (arr :Array, pred :Function) :Boolean
    {
        return removeIfImpl(arr, pred, true);
    }

    /**
     * Removes the last element in the array for which the specified predicate returns true.
     *
     * @param pred a Function of the form: function (element :*) :Boolean
     *
     * @return true if an element was removed, false otherwise.
     */
    public static function removeLastIf (arr :Array, pred :Function) :Boolean
    {
        arr.reverse();
        var removed :Boolean = removeFirstIf(arr, pred);
        arr.reverse();
        return removed;
    }

    /**
     * Removes all elements in the array for which the specified predicate returns true.
     *
     * @param pred a Function of the form: function (element :*) :Boolean
     *
     * @return true if an element was removed, false otherwise.
     */
    public static function removeAllIf (arr :Array, pred :Function) :Boolean
    {
        return removeIfImpl(arr, pred, false);
    }

    /**
     * A splice that takes an optional Array of elements to splice in.
     * The function on Array is fairly useless unless you know exactly what you're splicing
     * in at compile time. Fucking varargs.
     */
    public static function splice (
        arr :Array, index :int, deleteCount :int, insertions :Array = null) :Array
    {
        var i :Array = (insertions == null) ? [] : insertions.concat(); // don't modify insertions
        i.unshift(index, deleteCount);
        return arr.splice.apply(arr, i);
    }

    /**
     * Do the two arrays contain elements that are all equals()?
     */
    public static function equals (ar1 :Array, ar2 :Array) :Boolean
    {
        if (ar1 === ar2) {
            return true;

        } else if (ar1 == null || ar2 == null || ar1.length != ar2.length) {
            return false;
        }

        for (var jj :int = 0; jj < ar1.length; jj++) {
            if (!Util.equals(ar1[jj], ar2[jj])) {
                return false;
            }
        }
        return true;
    }

    /**
     * Copy a segment of one array to another. If the two arrays are the same reference,
     * a temporary copy may be made to safely copy the range.
     *
     * @param src the array to copy from
     * @param srcOffset the position in the source array to begin copying from
     * @param dst the array to copy into
     * @param dstOffset the position in the destition array to begin copying into
     * @param count the number of elements to copy
     */
    public static function copy (
        src :Array, srcOffset :uint, dst :Array, dstOffset :uint, count :uint) :void
    {
        // see if we need to make a temporary copy
        if ((src == dst) && (srcOffset + count > dstOffset)) {
            src = src.slice(srcOffset, srcOffset + count);
            srcOffset = 0;
        }
        for (var ii :uint = 0; ii < count; ++ii) {
            dst[dstOffset++] = src[srcOffset++];
        }
    }

    /**
     * Returns an array whose nth element is an array of the nth elements of each of the passed
     * in arrays. Therefore, the length of the returned array will be the maximum of the lengths
     * of the passed in arrays and will have no undefined entries. Also, the nth element of the
     * returned array will contain undefined entries for each corresponding array whose nth
     * element was undefined.
     * @example
     * <listing version="3.0">
     *     var trans :Array = transpose([1, 2, 3], ["a", "b", "c"], ["foo", "bar", "baz"]);
     *     trace(trans[0]); // [1, "a", "foo"]
     *     trace(trans[1]); // [2, "b", "bar"]
     *     trace(trans[2]); // [3, "c", "baz"]
     * </listing>
     */
    public static function transpose (x :Array, y :Array, ...arrays) :Array
    {
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

    /**
     * Performs a binary search, attempting to locate the specified
     * object. The array must be in the sort order defined by the supplied
     * comparator function for this to operate correctly.
     *
     * @param array the array of objects to be searched.
     * @param offset the index of the first element in the array to be* considered.
     * @param length the number of elements including and following the
     * element at <code>offset</code> to consider when searching.
     * @param key the object to be located.
     * @param comp the comparison function to use when searching.
     *
     * @return the index of the object in question or
     * <code>(-(<i>insertion point</i>) - 1)</code> (always a negative
     * value) if the object was not found in the list.
     */
    public static function binarySearch (
        array :Array, offset :int, length :int, key :*, comp :Function) :int
    {
        var low :int = offset;
        var high :int = offset + length - 1;
        while (low <= high) {
            // http://googleresearch.blogspot.com/2006/06/extra-extra-read-all-about-it-nearly.html
            var mid :int = (low + high) >>> 1;
            var midVal :* = array[mid];
            var cmp :int = comp(midVal, key);
            if (cmp < 0) {
                low = mid + 1;
            } else if (cmp > 0) {
                high = mid - 1;
            } else {
                return mid; // key found
            }
        }
        return -(low + 1); // key not found.
    }

    /**
     * Fills the array entirely with the value provided.
     */
    public static function fill (array :Array, val :*) :void
    {
        for (var idx :* in array) {
            array[idx] = val;
        }
    }

    /**
     * Implementation of remove methods.
     */
    private static function removeImpl (
        arr :Array, element :Object, firstOnly :Boolean) :Boolean
    {
        return removeIfImpl(arr, Predicates.createEquals(element), firstOnly);
    }

    /**
     * Implementation of removeIf methods.
     */
    private static function removeIfImpl (arr :Array, pred :Function, firstOnly :Boolean) :Boolean
    {
        var removed :Boolean = false;
        for (var ii :int = 0; ii < arr.length; ii++) {
            if (pred(arr[ii])) {
                arr.splice(ii--, 1);
                if (firstOnly) {
                    return true;
                }
                removed = true;
            }
        }
        return removed;
    }
}
}
