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

/**
 * A utility for performing a "lazy" chained comparison statement, which
 * performs comparisons only until it finds a nonzero result. For example:
 *
 * The value of this expression will have the same sign as the <i>first
 * nonzero</i> comparison result in the chain, or will be zero if every
 * comparison result was zero.
 *
 * <p>Once any comparison returns a nonzero value, remaining comparisons are
 * "short-circuited".</p>
 *
 * @example
 * <listing version="3.0">
 *   public function compareTo (that :Object) :int
 *   {
 *       return ComparisonChain.start()
 *           .compareStrings(this.aString, that.aString)
 *           .compareInts(this.anInt, that.anInt)
 *           .compareComparables(this.anEnum, that.anEnum)
 *           .result();
 *   }
 * </listing>
 */
public class ComparisonChain
{
    /**
     * Start a ComparisonChain.
     */
    public static function start () :ComparisonChain
    {
        return ACTIVE;
    }

    /**
     * Compares two Objects of any type, <i>if</i> the result of this comparison chain
     * has not already been determined. If a comparator is specified, that is used, otherwise
     * it tries to suss-out the types of the arguments and compares them that way.
     */
    public function compare (left :*, right :*, comparator :Function = null) :ComparisonChain
    {
        if (comparator != null) {
            return classify(comparator(left, right));

        } else {
            return classify(Comparators.compareUnknowns(left, right));
        }
    }

    /**
     * Compares two comparable objects, <i>if</i> the result of this comparison chain
     * has not already been determined.
     */
    public function compareComparables (left :Comparable, right :Comparable) :ComparisonChain
    {
        return classify(Comparators.compareComparables(left, right));
    }

    /**
     * Compares two Strings, <i>if</i> the result of this comparison chain
     * has not already been determined.
     */
    public function compareStrings (left :String, right :String) :ComparisonChain
    {
        return classify(Comparators.compareStrings(left, right));
    }

    /**
     * Compares two strings, ignoring case, <i>if</i> the result of this comparison chain
     * has not already been determined.
     */
    public function compareStringsIgnoreCase (left :String, right :String) :ComparisonChain
    {
        return classify(Comparators.compareStringsInsensitively(left, right));
    }

    /**
     * Compares two ints, <i>if</i> the result of this comparison chain
     * has not already been determined.
     */
    public function compareInts (left :int, right :int) :ComparisonChain
    {
        return classify(Comparators.compareInts(left, right));
    }

    /**
     * Compares two Numbers, <i>if</i> the result of this comparison chain
     * has not already been determined.
     */
    public function compareNumbers (left :Number, right :Number) :ComparisonChain
    {
        return classify(Comparators.compareNumbers(left, right));
    }

    /**
     * Compares two Booleans, <i>if</i> the result of this comparison chain
     * has not already been determined.
     */
    public function compareBooleans (left :Boolean, right :Boolean) :ComparisonChain
    {
        return classify(Comparators.compareBooleans(left, right));
    }

    /**
     * Ends this ComparisonChain and returns its reuslt.
     */
    public function result () :int
    {
        return 0;
    }

    /**
     * Classify the result and return the next ComparisonChain.
     * @private
     */
    protected function classify (result :int) :ComparisonChain
    {
        return (result < 0) ? InactiveComparisonChain.LESS
                            : (result > 0) ? InactiveComparisonChain.GREATER : this;
    }

    protected static const ACTIVE :ComparisonChain = new ComparisonChain();
}
}

import com.threerings.util.Comparable;
import com.threerings.util.ComparisonChain;

class InactiveComparisonChain extends ComparisonChain
{
    public static const LESS :ComparisonChain = new InactiveComparisonChain(-1);
    public static const GREATER :ComparisonChain = new InactiveComparisonChain(1);

    public function InactiveComparisonChain (result :int)
    {
        _result = result;
    }

    override public function compare (
        left :*, right :*, comparator :Function = null) :ComparisonChain
    {
        return this;
    }

    override public function compareComparables (
        left :Comparable, right :Comparable) :ComparisonChain
    {
        return this;
    }

    override public function compareStrings (left :String, right :String) :ComparisonChain
    {
        return this;
    }

    override public function compareStringsIgnoreCase (left :String, right :String) :ComparisonChain
    {
        return this;
    }

    override public function compareInts (left :int, right :int) :ComparisonChain
    {
        return this;
    }

    override public function compareNumbers (left :Number, right :Number) :ComparisonChain
    {
        return this;
    }

    override public function compareBooleans (left :Boolean, right :Boolean) :ComparisonChain
    {
        return this;
    }

    override public function result () :int
    {
        return _result;
    }

    protected var _result :int;
}
