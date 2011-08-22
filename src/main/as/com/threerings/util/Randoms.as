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

package com.threerings.util {

/**
* Provides utility routines to simplify obtaining randomized values.
 *
 * <p>Each instance of Randoms contains an underlying Random instance. If you wish to have a
 * private stream of pseudorandom numbers, use the {@link #with} factory.
 */
public class Randoms
{
    public static const RAND :Randoms = new Randoms(new Random());

    /**
     * Construct a Randoms.
     */
    public function Randoms (rand :Random)
    {
        _r = rand;
    }

    /**
     * Returns a pseudorandom, uniformly distributed <code>int</code> value between <code>0</code>
     * (inclusive) and <code>high</code> (exclusive).
     *
     * @param high the high value limiting the random number sought.
     *
     * @throws IllegalArgumentException if <code>high</code> is not positive.
     */
    public function getInt (high :int) :int
    {
        return _r.nextInt(high);
    }

    /**
     * Returns a pseudorandom, uniformly distributed <code>int</code> value between
     * <code>low</code> (inclusive) and <code>high</code> (exclusive).
     *
     * @throws IllegalArgumentException if <code>high - low</code> is not positive.
     */
    public function getInRange (low :int, high :int) :int
    {
        return low + _r.nextInt(high - low);
    }

    /**
     * Returns true approximately one in <code>n</code> times.
     *
     * @throws IllegalArgumentException if <code>n</code> is not positive.
     */
    public function getChance (n :int) :Boolean
    {
        return (0 == _r.nextInt(n));
    }

    /**
     * Returns <code>true</code> or <code>false</code> with approximately even probability.
     */
    public function getBoolean () :Boolean
    {
        return _r.nextBoolean();
    }

    /**
     * Shuffle the specified list using our Random.
     */
    public function shuffle (list :Array) :void
    {
        Arrays.shuffle(list, _r);
    }

    /**
     * Pick a random element from the specified Array, or return <code>ifEmpty</code>
     * if it is empty.
     */
    public function pick (list :Array, ifEmpty :*) :*
    {
        if (list == null || list.length == 0) {
            return ifEmpty;
        }

        return list[_r.nextInt(list.length)];
    }

    protected var _r :Random;
}
}
