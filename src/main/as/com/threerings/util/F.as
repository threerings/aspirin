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

import flash.events.Event;

/**
 * Functional programming elements for AS3.
 */
public class F
{
    /** @see #partial */
    public static const _1 :F_Positional = new F_Positional(0);
    public static const _2 :F_Positional = new F_Positional(1);
    public static const _3 :F_Positional = new F_Positional(2);
    public static const _4 :F_Positional = new F_Positional(3);
    public static const _5 :F_Positional = new F_Positional(4);
    public static const _6 :F_Positional = new F_Positional(5);
    public static const _7 :F_Positional = new F_Positional(6);
    public static const _8 :F_Positional = new F_Positional(7);
    public static const _9 :F_Positional = new F_Positional(8);

    /**
     * Curry a function to be evaluated later.
     *
     * @param left Arguments to be partially applied to the function.
     * @return A function that when invoked, calls the original function f with collected arguments.
     *         The invoked arguments are "woven" into arbitrary positions using F._1, F._2, etc.
     *
     * @example
     * <listing version="3.0">
     * function add (x :Number, y :Number) :Number {
     *     return x + y;
     * }
     * function divide (x :Number, y :Number) :Number {
     *     return x / y;
     * }
     * var addFirstAndThird :Function = F.partial(add, F._3, F._1);
     * var divideByTwo :Function = F.partial(divide, F._1, 2);
     *
     * trace(addFirstAndThird(10, 999, 7)); // 17
     * trace(divideByTwo(12)); // 6
     * </listing>
     */
    public static function partial (f :Function, ... left) :Function
    {
        return function (... right) :* {
            return adapt(f).apply(this,
                left.map(function (arg :*, index :int, arr :Array) :* {
                    return (arg is F_Positional) ? right[F_Positional(arg).idx] : arg;
                }));
        }
    }

    /** Creates a function that calls f with args and ignores any extra args passed to it. */
    public static function callback (f: Function, ... args) :Function
    {
        return function (... _) :* {
            return f.apply(this, args);
        }
    }

    public static function compose (f :Function, g :Function) :Function
    {
        return function (... rest) :* {
            return f(g.apply(this, rest));
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
            return f.apply(this, args);
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
     * Array.forEach with a one argument callback.
     *
     * @param f (Object -> void)
     */
    public static function forEach (xs :Array, f :Function) :void
    {
        return xs.forEach(adapt(f));
    }

    /**
     * Array.every with a one argument predicate.
     *
     * @param f (Object -> Boolean)
     */
    public static function every (xs :Array, f :Function) :Boolean
    {
        return xs.every(adapt(f));
    }

    /**
     * Array.some with a one argument predicate.
     *
     * @param f (Object -> Boolean)
     */
    public static function some (xs :Array, f :Function) :Boolean
    {
        return xs.some(adapt(f));
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
            f.apply(this, args);
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

    /**
     * Creates a function that calls through to the given varargs function with a well-defined
     * number of parameters.
     */
    public static function argify (fn :Function, argCount :int) :Function
    {
        switch (argCount) {
            case 0: return function () :* {
                return fn();
            };
            case 1: return function (a1 :*) :* {
                return fn(a1);
            };
            case 2: return function (a1 :*, a2 :*) :* {
                return fn(a1, a2);
            };
            case 3: return function (a1 :*, a2 :*, a3 :*) :* {
                return fn(a1, a2, a3);
            };
            case 4: return function (a1 :*, a2 :*, a3 :*, a4 :*) :* {
                return fn(a1, a2, a3, a4);
            };
            case 5: return function (a1 :*, a2 :*, a3 :*, a4 :*, a5 :*) :* {
                return fn(a1, a2, a3, a4, a5);
            };
            case 6: return function (a1 :*, a2 :*, a3 :*, a4 :*, a5 :*, a6 :*) :* {
                return fn(a1, a2, a3, a4, a5, a6);
            };
            case 7: return function (a1 :*, a2 :*, a3 :*, a4 :*, a5 :*, a6 :*, a7 :*) :* {
                return fn(a1, a2, a3, a4, a5, a6, a7);
            };
            case 8: return function (a1 :*, a2 :*, a3 :*, a4 :*, a5 :*, a6 :*, a7 :*, a8 :*) :* {
                return fn(a1, a2, a3, a4, a5, a6, a7, a8);
            };
            default:
                throw new Error("Eight is not enough! Harsh");
        }
    }
}
}
