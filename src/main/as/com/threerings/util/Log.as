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

import flash.events.ErrorEvent;
import flash.system.Capabilities;
import flash.utils.getQualifiedClassName;

/**
 * A simple logging mechanism.<p/>
 *
 * Log instances are created for modules, and the logging level can be configured per
 * module in a hierarchical fashion.<p/>
 *
 * Typically, you should create a module name based on the full path to a class:
 * calling getLog() and passing an object or Class will do this. Alternattely, you
 * may create a Log to share in several classes in a package, in which case the
 * module name can be like "com.foocorp.games.bunnywar". Finally, you can just
 * create made-up module names like "mygame" or "util", but this is not recommended.
 * You really should name things based on your packages, and your packages should be
 * named according to Sun's recommendations for Java packages.<p/>
 *
 * @example Typical usage for creating a Log to be used by the entire class would be:
 * <listing version="3.0">
 * public class MyClass
 * {
 *     private static const log :Log = Log.getLog(MyClass);
 *
 *     public function doStuff (kind :String, x :int = 0) :void
 *     {
 *         log.info("Now doing stuff", "kind", kind, "x", x);
 *         ...
 * </listing>
 *
 * @example Or, if you just need a one-off Log:
 * <listing version="3.0">
 *     protected function doStuff (thingy :Thingy) :void
 *     {
 *          if (!isValid(thingy)) {
 *              Log.getLog(this).warning("Invalid thingy specified", "thingy", thingy);
 *              ....
 * </listing>
 */
public class Log
{
    /** A fine-grained logging level containing detailed information. */
    public static const DEBUG :int = 0;
    /** A logging level for informational messages. */
    public static const INFO :int = 1;
    /** A logging level indicating a potential problem. */
    public static const WARNING :int = 2;
    /** A logging level indicating a serious problem. */
    public static const ERROR :int = 3;
    /** A logging level used in setLevels() to disable logged for a module. */
    public static const OFF :int = 4;
    // if you add to this, update LEVEL_NAMES and stringToLevel() at the bottom...

    /**
     * Retrieve a Log for the specified module.
     *
     * @param moduleSpec can be a String of the module name, or any Object or Class to
     * have the module name be the full package and name of the class (recommended).
     */
    public static function getLog (moduleSpec :*) :Log
    {
        const module :String = (moduleSpec is String) ? String(moduleSpec)
            : getQualifiedClassName(moduleSpec).replace("::", ".");
        return new Log(module);
    }

    /**
     * A convenience function for quickly and easily inserting printy
     * statements during application development.
     */
    public static function testing (... params) :void
    {
        var log :Log = new Log("testing");
        log.debug.apply(log, params);
    }

    /**
     * A convenience function for quickly printing a stack trace
     * to the log, useful for debugging.
     */
    public static function dumpStack (msg :String = "dumpStack") :void
    {
        testing(new Error(msg).getStackTrace());
    }

    /**
     * Add a logging target.
     */
    public static function addTarget (target :LogTarget) :void
    {
        _targets.push(target);
    }

    /**
     * Remove a logging target.
     */
    public static function removeTarget (target :LogTarget) :void
    {
        var dex :int = _targets.indexOf(target);
        if (dex != -1) {
            _targets.splice(dex, 1);
        }
    }

    /**
     * Set the log level for the specified module.
     *
     * @param module The smallest prefix desired to configure a log level.
     * For example, you can set the global level with Log.setLevel("", Log.INFO);
     * Then you can Log.setLevel("com.foo.game", Log.DEBUG). Now, everything
     * logs at INFO level except for modules within com.foo.game, which is at DEBUG.
     */
    public static function setLevel (module :String, level :int) :void
    {
        var settings :Object = {};
        settings[module] = level;
        setLevels(settings);
    }

    /**
     * If given an Object, sets levels using the mapping between modules and log levels eg
     * {"com.threerings":Log.INFO, "com.threerings.util":Log.DEBUG}
     *
     * An empty string specifies the top-level (global) module.
     *
     * If given a String in the form of
     * ":info;com.foo.game:debug;com.bar.util:warning", it parses it to set the levels.
     *
     * Semicolons separate modules, colons separate a module name from the log level.
    */
    public static function setLevels (settings :Object) :void
    {
        if (settings is String) {
            for each (var setting :String in String(settings).split(";")) {
                var pieces :Array = setting.split(":");
                _setLevels[pieces[0]] = stringToLevel(String(pieces[1]));
            }
        } else {
            for (var module :String in settings) {
                _setLevels[module] = settings[module];
            }
        }
        _levels = {}; // reset cached levels
    }

    /**
     * Use Log.getLog();
     *
     * @private
     */
    public function Log (module :String)
    {
        if (module == null) module = "";
        _module = module;
    }

    /**
     * Log a message with 'debug' priority.
     *
     * @param args The first argument is the actual message to log. After that, each pair
     * of parameters is printed in key/value form, the benefit being that if no log
     * message is generated then toString() will not be called on the values.
     * If any argument is a function, it is invoked with no args, so that you may avoid
     * converting detailed data into a String unless the message is actually logged.
     * A final parameter may be an Error, ErrorEvent, or UnhandledErrorEvent: the stack trace
     * is printed on debug players, or a "message={message}" is appended if there is no stack trace.
     *
     * @example
     * <listing version="3.0">
     *    log.debug("Message", "key1", value1, "key2", value2, optionalError);
     * </listing>
     */
    public function debug (... args) :void
    {
        doLog(DEBUG, args);
    }

    /**
     * Log a message with 'info' priority.
     *
     * @param args The first argument is the actual message to log. After that, each pair
     * of parameters is printed in key/value form, the benefit being that if no log
     * message is generated then toString() will not be called on the values.
     * If any argument is a function, it is invoked with no args, so that you may avoid
     * converting detailed data into a String unless the message is actually logged.
     * A final parameter may be an Error, ErrorEvent, or UnhandledErrorEvent: the stack trace
     * is printed on debug players, or a "message={message}" is appended if there is no stack trace.
     *
     * @example
     * <listing version="3.0">
     *    log.info("Message", "key1", value1, "key2", value2, optionalError);
     * </listing>
     */
    public function info (... args) :void
    {
        doLog(INFO, args);
    }

    /**
     * Log a message with 'warning' priority.
     *
     * @param args The first argument is the actual message to log. After that, each pair
     * of parameters is printed in key/value form, the benefit being that if no log
     * message is generated then toString() will not be called on the values.
     * If any argument is a function, it is invoked with no args, so that you may avoid
     * converting detailed data into a String unless the message is actually logged.
     * A final parameter may be an Error, ErrorEvent, or UnhandledErrorEvent: the stack trace
     * is printed on debug players, or a "message={message}" is appended if there is no stack trace.
     *
     * @example
     * <listing version="3.0">
     *    log.warning("Message", "key1", value1, "key2", value2, optionalError);
     * </listing>
     */
    public function warning (... args) :void
    {
        doLog(WARNING, args);
    }

    /**
     * Log a message with 'error' priority.
     *
     * @param args The first argument is the actual message to log. After that, each pair
     * of parameters is printed in key/value form, the benefit being that if no log
     * message is generated then toString() will not be called on the values.
     * If any argument is a function, it is invoked with no args, so that you may avoid
     * converting detailed data into a String unless the message is actually logged.
     * A final parameter may be an Error, ErrorEvent, or UnhandledErrorEvent: the stack trace
     * is printed on debug players, or a "message={message}" is appended if there is no stack trace.
     *
     * @example
     * <listing version="3.0">
     *    log.error("Message", "key1", value1, "key2", value2, optionalError);
     * </listing>
     */
    public function error (... args) :void
    {
        doLog(ERROR, args);
    }

    /**
     * Log just a stack trace with 'warning' priority.
     */
    [Deprecated(replacement="warning(\"message\", error)")]
    public function logStackTrace (error :Error) :void
    {
        warning("stackTrace", error);
    }

    public function format (... args) :String
    {
        var msg :String = String(args[0]); // the primary log message
        var strace :String = (args.length % 2 == 1) ? null : processFinalArg(args);
        if (args.length > 1) {
            for (var ii :int = 1; ii < args.length; ii += 2) {
                msg += (ii == 1) ? " [" : ", ";
                msg += argToString(args[ii]) + "=" + argToString(args[ii + 1]);
            }
            msg += "]";
        }
        if (strace != null) {
            msg += "\n" + strace;
        }

        return msg;
    }

    /** @private */
    protected function doLog (level :int, args :Array) :void
    {
        if (level < getLevel(_module)) {
            return; // we don't want to log it!
        }
        var logMessage :String = formatMessage(level, args);
        trace(logMessage);
        // possibly also dispatch to any other log targets.
        for each (var target :LogTarget in _targets) {
            if (target is PreformatLogTarget) {
                PreformatLogTarget(target).logArgs(level, args, logMessage);
            }
            target.log(logMessage);
        }
    }

    /** @private */
    protected function formatMessage (level :int, args :Array) :String
    {
        var msg :String = getTimeStamp() + " " + LEVEL_NAMES[level] + ": " + _module;
        if (args.length > 0) {
            msg += " " + format.apply(this, args);
        }
        return msg;
    }

    /**
     * Process the final arg and turn it into a message, if needed, or return a stack trace.
     * Note: we do not reference the UncaughtErrorEvent class to remain flash 9 compatible.
     * @private
     */
    protected function processFinalArg (args :Array) :String
    {
        var lastArg :Object = args.pop();
        var errMsg :String;
        if (lastArg == null) {
            lastArg = "null";

        } else if ("error" in lastArg) { // if an UncaughtErrorEvent, switch to the 'error' value
            lastArg = lastArg.error;
        }
        if (lastArg is Error) {
            var err :Error = lastArg as Error; // "as" preserves the stack trace.
            var strace :String = err.getStackTrace();
            if (strace != null) { // in a debug flashplayer, we get the stack trace. Yay!
                return strace;
            }
            errMsg = err.message; // otherwise, let's use the message (code) of the error

        } else if (lastArg is ErrorEvent) {
            errMsg = String(lastArg.text);

        } else {
            // Either the last arg was not an Error, ErrorEvent, or UncaughtErrorEvent,
            // or it was an UncaughtErrorEvent for a thrown non-Error, which is f'n weird.
            // Log it with a question mark to indicate misuse.
            args.push("error?", String(lastArg));
            return null;
        }

        args.push("message", errMsg);
        return null;
    }

    /**
     * Safely format the argument to a String, calling the function if it is one.
     * @private
     */
    protected function argToString (arg :*) :String
    {
        try {
            if (arg is Function) {
                return String(arg());
            } else {
                return String(arg);
            }
        } catch (e :Error) {
            try {
                return "<" + e + ">";
            } catch (e2 :Error) {
                // return value at end of method...
            }
        }
        return "<Error>";
    }

    /** @private */
    protected function getTimeStamp () :String
    {
        var d :Date = new Date();
        // return d.toLocaleTimeString();

        // format it like the date format in our java logs
        return d.fullYear + "-" +
            padZero(d.month + 1) + "-" +
            padZero(d.date) + " " +
            padZero(d.hours) + ":" +
            padZero(d.minutes) + ":" +
            padZero(d.seconds) + "," +
            padZero(d.milliseconds, 3);
    }

    /**
     * Inlined version of StringUtil.prepad, so that we don't drag in that class
     * (and all its dependencies)
     * @private
     */
    protected static function padZero (value :int, digits :int = 2) :String
    {
        var s :String = String(value);
        while (s.length < digits) {
            s = "0" + s;
        }
        return s;
    }

    /**
     * Get the logging level for the specified module.
     * @private
     */
    protected static function getLevel (module :String) :int
    {
        // we probably already have the level cached for this module
        var lev :Object = _levels[module];
        if (lev == null) {
            // cache miss- copy some parent module's level...
            var ancestor :String = module;
            while (true) {
                lev = _setLevels[ancestor];
                if (lev != null || ancestor == "") {
                    // bail if we found a setting or get to the top level,
                    // but always save the level from _setLevels into _levels
                    _levels[module] = int(lev); // if lev was null, this will become 0 (DEBUG)
                    break;
                }
                var dex :int = ancestor.lastIndexOf(".");
                ancestor = (dex == -1) ? "" : ancestor.substring(0, dex);
            }
        }
        return int(lev);
    }

    /** @private */
    protected static function stringToLevel (s :String) :int
    {
        switch (s.toLowerCase()) {
        default: // default to DEBUG
        case "debug": return DEBUG;
        case "info": return INFO;
        case "warning": case "warn": return WARNING;
        case "error": return ERROR;
        case "off": return OFF;
        }
    }

    /** The module to which this log instance applies. @private */
    protected var _module :String;

    /** Other registered LogTargets, besides the trace log. @private */
    protected static var _targets :Array = [];

    /** A cache of log levels, copied from _setLevels. @private */
    protected static var _levels :Object = {};

    /** The configured log levels. @private */
    protected static var _setLevels :Object = {
        "": (flash.system.Capabilities.isDebugger ? DEBUG : OFF) // global: debug or off
    };

    /** The string names of each level. The last one is unused, it corresponds with OFF. @private */
    protected static const LEVEL_NAMES :Array = [ "debug", "INFO", "WARN", "ERROR", false ];
}
}
