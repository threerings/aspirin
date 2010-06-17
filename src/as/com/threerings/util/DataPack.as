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

import flash.display.DisplayObject;

import flash.errors.IllegalOperationError;

import flash.events.ErrorEvent;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.IOErrorEvent;
import flash.events.SecurityErrorEvent;

import flash.net.URLLoader;
import flash.net.URLLoaderDataFormat;
import flash.net.URLRequest;

import flash.media.Sound;

import flash.system.ApplicationDomain;

import flash.utils.ByteArray;

import com.threerings.util.MultiLoader;

/**
 * Dispatched when the DataPack has completed loading.
 *
 * @eventType flash.events.Event.COMPLETE
 */
[Event(name="complete", type="flash.events.Event")]

/**
 * A DataPack is a bundle of stored goodies for use by your game, avatar, or other whirled
 * creation. In a DataPack can be named data values as well as named files.
 */
public class DataPack extends BaseDataPack
{
    /**
     * A static helper method to load one or more DataPacks without using any event listeners.
     * Take a deep breath and then read the parameter documentation.
     *
     * @param sources can be a String (representing a URL), or a URLRequest object, or a
     * ByteArray containing an embedded DataPack, or a Class object that will instantiate
     * with no args into a ByteArray or (unlikely) a URLRequest. Orrrrrr, sources can be
     * an Array, Dictionary or plain Object containing primary kinds of sources as the values.
     * @param completeListener a function with the signature:
     * <code>function (result :Object) :void;</code>
     * If you passed in only a single source, then this completeListener is called and provided
     * with a result of either a DataPack (for a successful load) or an Error object.
     * If it's an Error but your function only accepts a DataPack, an error message will be
     * calmly logged. If your sources was an Array, Dictionary, or Object then the result will
     * be an object of the same type, with the same keys, but with each value being either a
     * DataPack or an Error.
     *
     * @example Load one DataPack from a url.
     * <listing version="3.0">
     * function gotDataPack (result :Object) :void {
     *     if (!(result is DataPack)) { // result must be an Error
     *         trace("Why? Oh why!? .. Oh: " + result);
     *         return;
     *     }
     *     var pack :DataPack = (result as DataPack);
     *     // _weapon is something set up outside the scope of this example
     *     _weapon.name = pack.getString("name");
     *     _weapon.astonishmentPoints = pack.getNumber("ap");
     *     // etc.
     * }
     *
     * // ok, the function is set up, let's load the DataPack
     * var itemInfos :Array = _gameCtrl.getItemPacks();
     * for each (var itemInfo :Object in itemInfos) {
     *     if (itemInfo.ident == "bubblePopper") {
     *          DataPack.load(itemInfo.mediaURL, gotDataPack);
     *          break;
     *     }
     * }
     * </listing>
     */
    public static function load (sources :Object, completeListener :Function) :void
    {
        var generator :Function = function (source :*) :DataPack {
            return new DataPack(source);
        };

        new MultiLoader(sources, completeListener, generator, false, "isComplete",
            [ ErrorEvent.ERROR ]);
    }

    /**
     * Construct a DataPack to be loaded from the specified source.
     * Note that passing a ByteArray will result in a DataPack that is instantly complete.
     *
     * @param source a url (as a String or as a URLRequest) from which to load the
     *        DataPack, or a ByteArray containing the raw data, or a Class.
     * @param completeListener a listener function to automatically register for COMPLETE events.
     * @param errorListener a listener function to automatically register for ERROR events.
     *
     * @throws TypeError if urlOrByteArray is not of the right type.
     */
    public function DataPack (
        source :Object, completeListener :Function = null, errorListener :Function = null)
    {
        // first transform the source from convenient forms into true sources
        if (source is String) {
            source = new URLRequest(String(source));
        } else if (source is Class) {
            source = new (source as Class)();
        }
        var req :URLRequest = null;
        var bytes :ByteArray;
        if (source is URLRequest) {
            req = URLRequest(source);
        } else if (source is ByteArray) {
            bytes = ByteArray(source);
        } else {
            throw new TypeError("Expected a String or ByteArray");
        }

        // set up any Event listeners
        if (completeListener != null) {
            addEventListener(Event.COMPLETE, completeListener);
        }
        if (errorListener != null) {
            addEventListener(ErrorEvent.ERROR, errorListener);
        }

        if (req != null) {
            _loader = new URLLoader();
            _loader.dataFormat = URLLoaderDataFormat.BINARY;
            _loader.addEventListener(Event.COMPLETE, handleLoadingComplete);
            _loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, handleLoadError);
            _loader.addEventListener(IOErrorEvent.IO_ERROR, handleLoadError);
            _loader.load(req);

        } else {
            bytesAvailable(bytes);
        }
    }

    /**
     * If the DataPack is still loading, stop it, otherwise has no effect. It would
     * be a good idea to call this during your UNLOAD handling.
     */
    public function close () :void
    {
        if (_loader != null) {
            try {
                _loader.close();
            } catch (err :Error) {
                // ignore
            }
            _loader = null;
        }
    }

    /**
     * Get some display objects in the datapack.
     * <b>Note</b>: With the move to flash 10, it's now illegal to "reparent" a SWF that was
     * compiled with AVM1 (flash 8, or newer but compiled as actionscript 1/2). It will work
     * fine in flashplayer 9, but in flashplayer 10 it will give a runtime error. The workaround
     * is to use getLoaders() instead, and add the Loader to your hierarchy.
     *
     * @param sources an Object containing keys mapping to the names of the display objects to load.
     * @param callback a Function that will be called when all the display objects
     *                 are loaded (or were unable to load).
     *                 Signature: <code>function (results :Object) :void</code>
     *                 results will contain a mapping from name -> DisplayObject, or null if none.
     * @param appDom The ApplicationDomain in which to load the DisplayObjects. The default value
     *               of null will load into a child of the current ApplicationDomain.
     */
    public function getDisplayObjects (
        sources :Object, callback :Function, appDom :ApplicationDomain = null) :void
    {
        doGetObjects(sources, callback, appDom, false);
    }

    /**
     * Get Loaders containing the specified files from the datapack. These Loaders will hold the 
     * DisplayObject or Image files, and can be safely added to your display hierarchy without
     * causing any errors, even if loading an AVM1 swf.
     *
     * @param sources an Object containing keys mapping to the names of the display objects to load.
     * @param callback a Function that will be called when all the display objects
     *                 are loaded (or were unable to load).
     *                 Signature: <code>function (results :Object) :void</code>.
     *                 results will contain a mapping from name -> Loader, or null.
     * @param appDom The ApplicationDomain in which to load the DisplayObjects. The default value
     *               of null will load into a child of the current ApplicationDomain.
     */
    public function getLoaders (
        sources :Object, callback :Function, appDom :ApplicationDomain = null) :void
    {
        doGetObjects(sources, callback, appDom, true);
    }

//    /**
//     * Get sounds. TODO. This is not quite ready for primetime.
//     * @private
//     */
//    public function getSounds (names :Array, callback :Function) :void
//    {
//        var fn :Function = function (obj :Object) :void {
//            var newObj :Object = {};
//
//            for (var s :String in obj) {
//                var o :Object = obj[s];
//                try {
//                    o = o["getSound"]();
//                } catch (err :Error) {
//                    trace("Error getSound: " + err);
//                }
//                newObj[s] = (o as Sound);
//            }
//
//            callback(newObj);
//        };
//
//        getDisplayObjects(names, fn);
//    }

    /**
     * Helper method for getDisplayObjects and getLoaders. Turns the sources into
     * the ByteArrays they address, have MultiLoader coordinate the loading.
     *
     * @private
     */
    protected function doGetObjects (
        sources :Object, callback :Function, appDom :ApplicationDomain, returnRawLoaders :Boolean)
        :void
    {
        // transform sources from Strings to ByteArrays
        // TODO: move something like this to a utility function in MultiLoader?
        if (sources is String) {
            sources = getFile(String(sources));
        } else {
            for (var key :* in sources) {
                var o :Object = sources[key];
                if (o is String) {
                    sources[key] = getFile(String(o));
                }
            }
        }

        var toCall :Function = returnRawLoaders ? MultiLoader.getLoaders : MultiLoader.getContents;
        toCall(sources, callback, false, appDom);
    }

    /**
     * Handle some sort of problem loading the datapack.
     *
     * @private
     */
    protected function handleLoadError (event :ErrorEvent) :void
    {
        close();
        dispatchError("Error loading datapack: " + event.text);
    }

    /**
     * Handle the successful completion of datapack loading.
     *
     * @private
     */
    protected function handleLoadingComplete (event :Event) :void
    {
        var ba :ByteArray = ByteArray(_loader.data);
        _loader = null;
        bytesAvailable(ba);
    }

    /**
     * @inheritDoc
     */
    override protected function bytesAvailable (bytes :ByteArray) :void
    {
        super.bytesAvailable(bytes);

        if (isComplete()) {
            // yay, we're completely loaded!
            dispatchEvent(new Event(Event.COMPLETE));
       }
    }

    /** Used only while loading the zip bytes. @private */
    protected var _loader :URLLoader;
}
}
