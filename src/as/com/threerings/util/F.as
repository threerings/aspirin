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

import flash.events.Event;

/**
 * Functional programming elements for AS3.
 */
public class F
{
    /** @see #partial */
    public static const _ :Object = new Object();

    /**
     * Curry a function to be evaluated later.
     *
     * @param left Arguments to be partially applied to the function.
     * @return A function that when invoked, calls the original function f with collected arguments.
     *         Normally the invoked arguments are appended, but they can be "woven" into arbritrary
     *         positions using F._.
     *
     * @example
     * <listing version="3.0">
     * function add (x :Number, y :Number) :Number {
     *     return x + y;
     * }
     * function divide (x :Number, y :Number) :Number {
     *     return x / y;
     * }
     * var addToSeven :Function = F.partial(add, 7);
     * var divideByTwo :Function = F.partial(divide, F._, 2);
     *
     * trace(addToSeven(10)); // 17
     * trace(divideByTwo(12)); // 6
     * </listing>
     */
    public static function partial (f :Function, ... left) :Function
    {
        if (left.indexOf(F._) == -1) {
            // Trade some up front creation time for execution speed later
            return function (... right) :* {
                return adapt(f).apply(undefined, left.concat(right));
            }

        } else {
            return function (... right) :* {
                return adapt(f).apply(undefined,
                    left.map(function (arg :*, index :int, arr :Array) :* {
                        return (arg === F._) ? right.shift() : arg;
                    }).concat(right));
            }
        }
    }

    /** Creates a function that calls f with args and ignores any extra args passed to it. */
    public static function callback (f: Function, ... args) :Function
    {
        return function (... _) :* {
            return f.apply(undefined, args);
        }
    }

    public static function compose (f :Function, g :Function) :Function
    {
        return function (... rest) :* {
            return f(g.apply(undefined, rest));
        }
    }

    /** Creates a function that always returns x. */
    public static function constant (x :*) :Function
    {
        return function (... _) :* {
            return x;
        }
    }

    /** The identity function. */
    public static function id (x :*) :*
    {
        return x;
    }

    public static function foldl (xs :Array, e :*, f :Function) :*
    {
        for each (var x :* in xs) {
            e = f(e, x);
        }

        return e;
    }

    /**
     * Return a var-args function that will attempt to pass only the arguments accepted by the
     * passed-in function. Does not work if the passed-in function is varargs, and anyway
     * then you don't need adapting, do you?
     *
     * @see com.threerings.util.Util#adapt()
     */
    // TODO: Reconcile with Util.adapt, having both is weird
    public static function adapt (f :Function) :Function
    {
        return function (... args) :* {
            args.length = f.length; // fit the args to the fn, filling in 'undefined' if growing
            return f.apply(undefined, args);
        }
    }

    /**
     * Array.map with a one argument function.
     *
     * @param f (Object -> Object)
     */
    public static function map (xs :Array, f :Function) :Array
    {
        return xs.map(adapt(f));
    }

    /**
     * Array.filter with a one argument predicate.
     *
     * @param f (Object -> Boolean)
     */
    public static function filter (xs :Array, f :Function) :Array
    {
        return xs.filter(adapt(f));
    }

    /**
     * Creates a listener that removes itself from the event source and delegates to handler.
     *
     * @param handler (Event -> void)
     */
    public static function justOnce (handler :Function) :Function
    {
        return function listener (event :Event) :void {
            event.currentTarget.removeEventListener(event.type, listener);
            handler(event);
        }
    }

    /**
     * Creates a listener that removes itself from the event source and calls f with args.
     *
     * Functionally equivalent to justOnce(callback(f, args));
     */
    public static function callbackOnce (f: Function, ... args) :Function
    {
        return function listener (event :Event) :void {
            event.currentTarget.removeEventListener(event.type, listener);
            f.apply(undefined, args);
        }
    }

    /**
     * Creates a function that calls through to klass' constructor with the args given to it and
     * returns the created object.
     */
    public static function constructor (klass :Class) :Function
    {
        return function (... a) :* {
            switch (a.length) {
                case 0:
                    return new klass();
                case 1:
                    return new klass(a[0]);
                case 2:
                    return new klass(a[0], a[1]);
                case 3:
                    return new klass(a[0], a[1], a[2]);
                case 4:
                    return new klass(a[0], a[1], a[2], a[3]);
                case 5:
                    return new klass(a[0], a[1], a[2], a[3], a[4]);
                case 6:
                    return new klass(a[0], a[1], a[2], a[3], a[4], a[5]);
                case 7:
                    return new klass(a[0], a[1], a[2], a[3], a[4], a[5], a[6]);
                case 8:
                    return new klass(a[0], a[1], a[2], a[3], a[4], a[5], a[6], a[7]);
                case 9:
                    return new klass(a[0], a[1], a[2], a[3], a[4], a[5], a[6], a[7], a[8]);
                case 10:
                    return new klass(a[0], a[1], a[2], a[3], a[4], a[5], a[6], a[7], a[8], a[9]);
                default:
                    throw new Error("You animal!  F.constructor only handles up to 10 args!");
            }

        }
    }
}

}
