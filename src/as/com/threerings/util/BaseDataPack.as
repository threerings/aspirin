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

import flash.errors.IllegalOperationError;

import flash.events.ErrorEvent;
import flash.events.Event;
import flash.events.EventDispatcher;

import flash.geom.Point;
import flash.geom.Rectangle;

import flash.utils.ByteArray;

import com.threerings.util.Util;
import com.threerings.util.XmlUtil;

import nochump.util.zip.ZipEntry;
import nochump.util.zip.ZipError;
import nochump.util.zip.ZipFile;

/**
 * Dispatched when the DataPack could not load due to an error.
 *
 * @eventType flash.events.ErrorEvent.ERROR
 */
[Event(name="error", type="flash.events.ErrorEvent")]

/**
 * Use DataPack. This class exists so that a version could run inside a serverside actionscript
 * environment.
 * TODO
 */
public class BaseDataPack extends EventDispatcher
{

    /**
     * Construct a DataPack to be loaded from the specified source.
     * Note that passing a ByteArray will result in a DataPack that is instantly complete.
     *
     * @param bytes a ByteArray containing the raw data.
     */
    public function BaseDataPack (bytes :ByteArray = null)
    {
        if (bytes != null) {
            bytesAvailable(bytes);
        }
    }

    /**
     * Has the loading of the datapack completed?
     */
    public function isComplete () :Boolean
    {
        return (_metadata != null);
    }

//    /**
//     * TODO
//     * @private
//     */
//    public function getNamespace () :String
//    {
//        validateComplete();
//        return unescape(String(_metadata.attribute("namespace")));
//    }

    /**
     * Convenience function to access some data as a String.
     */
    public function getString (name :String) :String
    {
        var data :* = getData(name);
        // avoid turning null into "null", but otherwise String-ify any other type
        return (data == null) ? null : String(data);
    }

    /**
     * Convenience function to access some data as a Number.
     */
    public function getNumber (name :String) :Number
    {
        return Number(getData(name, "Number")); // coerce to a Number
    }

    /**
     * Convenience function to access some data as an int.
     */
    public function getInt (name :String) :int
    {
        return int(getData(name, "int")); // coerce to an int
    }

    /**
     * Convenience function to access some data as a Boolean.
     */
    public function getBoolean (name :String) :Boolean
    {
        return Boolean(getData(name, "Boolean")); // coerce to a Boolean
    }

    /**
     * Convenience function to access some data as a color (uint).
     */
    public function getColor (name :String) :uint
    {
        return uint(getData(name, "Color")); // coerce to a uint
    }

    /**
     * Convenience function to access some data as an Array.
     */
    public function getArray (name :String) :Array
    {
        var data :* = getData(name, "Array");
        if (data is Array) {
            return data as Array;

        } else if (data == null) {
            return null; // keep null as-is: do not wrap in an Array!

        } else {
            // hoopjump to always return a filled-in single-element array
            // (If we coerced, and the value was numeric, it would set the length of the array)
            var retval :Array = new Array();
            retval.push(data);
            return retval;
        }
    }

    /**
     * Convenience function to access some data as a Point.
     */
    public function getPoint (name :String) :Point
    {
        return (getData(name, "Point") as Point); // as Point or null
    }

    /**
     * Convenience function to access some data as a Rectangle.
     */
    public function getRectangle (name :String) :Rectangle
    {
        return (getData(name, "Rectangle") as Rectangle); // as Rectangle or null
    }

    /**
     * Get some data, optionally formatted as a different type than that specified in the data xml.
     */
    public function getData (name :String, formatType :String = null) :*
    {
        name = validateAccess(name);

        var datum :XML = getDatum(_metadata..data, name);
        if (datum == null) {
            return undefined;
        }

        var data :* = parseValue(datum);
        if ((formatType != null) && (formatType != "String") && (data is String)) {
            data = parseValueFromString(String(data), formatType);
        }
        return data;
    }

    /**
     * Get a File, as a ByteArray.
     */
    public function getFile (name :String) :ByteArray
    {
        return getFileInternal(name, false) as ByteArray;
    }

    /**
     * Get a File, as a String.
     */
    public function getFileAsString (name :String) :String
    {
        return getFileInternal(name, true) as String;
    }

    /**
     * Get a File, as an XML object.
     */
    public function getFileAsXML (name :String) :XML
    {
        return XmlUtil.newXML(getFileAsString(name));
    }

    /**
     * Parse a data value from the specified XML datum.
     *
     * @private
     */
    protected function parseValue (
        datum :XML, valueField :String = "value", typeOverride :String = null) :*
    {
        var str :* = extractStringValue(datum, valueField);
        if (str === undefined) {
            return str;
        }

        var type :String = (typeOverride != null) ? typeOverride : String(datum.@type);
        return parseValueFromString(str, type);
    }

    /**
     * Extract from the datum either a String, null, or undefined.
     *
     * @private
     */
    protected function extractStringValue (datum :XML, valueField :String = "value") :*
    {
        var val :XMLList = datum.@[valueField];
        if (val.length == 0 || val[0] === undefined) {
            return undefined;
        }

        var value :String = String(val[0]);
//        trace("Raw " + valueField + " for data '" + name + "' is '" + value + "'");
        return value;
    }

    // TODO: detect errors and throw? Maybe only if a validation flag is passed in, and
    // then pass that flag optionally from the remixer... through entry.fromString()
    // from EditableDataPack.
    /**
     * @private
     */
    protected function parseValueFromString (string :String, type :String) :Object
    {
        var bits :Array;
        switch (type) {
        case "String":
        case "Choice": // parse as a string, but 
            return unescape(string);

        case "Number":
            return parseFloat(string);

        case "int":
            return parseInt(string);

        case "Boolean":
            return ("true" == string.toLowerCase());

        case "Color":
            return parseInt(string, 16);

        case "Array":
            return string.split(",").map(function (item :String, ... rest) :String {
                return unescape(item);
            });

        case "Point":
            bits = string.split(",");
            return new Point(parseFloat(bits[0]), parseFloat(bits[1]));

        case "Rectangle":
            bits = string.split(",");
            return new Rectangle(parseFloat(bits[0]), parseFloat(bits[1]),
                parseFloat(bits[2]), parseFloat(bits[3]));

        default:
            trace("Unknown resource type: " + type);
            return string;
        }
    }
    /**
     * Locate the data contained within a file with the specified data name.
     *
     * @private
     */
    protected function getFileInternal (name :String, asString :Boolean) :*
    {
        var value :String = getFileName(name);
        if (value == null) {
            return undefined;
        }

        var bytes :ByteArray = getFileBytes(value);
        if (asString && bytes != null) {
            return bytesToString(bytes);

        } else {
            return bytes;
        }
    }

    /**
     * Get the actual bytes in use for the specified filename.
     *
     * @private
     */
    protected function getFileBytes (fileName :String) :ByteArray
    {
        var entry :ZipEntry = _zip.getEntry(fileName);
        if (entry == null) {
            return null;
        }
        return _zip.getInput(entry);
    }

    /**
     * Translate the requested file into the actual filename stored in the zip.
     *
     * @private
     */
    protected function getFileName (name :String) :String
    {
        name = validateAccess(name);

        var datum :XML = getDatum(_metadata..file, name);
        if (datum == null) {
            return null;
        }

        return parseValue(datum, "value", "String");
    }

    /**
     * Fucking hell.
     *
     * var datum :XML = getDatum(_metadata..data, value);
     * This should be:
     * var datum :XML = _metadata..data.(@name == value)[0];
     * But the (@name == value) selector doesn't work if we're compiled in CS4,
     * so this method is a workaround.
     *
     * @private
     */ 
    protected function getDatum (list :XMLList, name :String) :XML
    {
        for each (var x :XML in list) {
            if (x.attribute("name") == name) {
                return x;
            }
        }
        return null;
    }

    /**
     * Validate that the everything is ok accessing the specified data name.
     *
     * @private
     */
    protected function validateAccess (name :String) :String
    {
        validateComplete();
        validateName(name);

        // TODO: we may need to verify that the urlencoding is happening the same
        // way that it is in Java
        return escape(name);
    }

    /**
     * Validate that this DataPack has completed loading.
     *
     * @private
     */
    protected function validateComplete () :void
    {
        if (!isComplete()) {
            throw new IllegalOperationError("DataPack is not loaded.");
        }
    }

    /**
     * Validate that the specified data name is legal.
     *
     * @private
     */
    protected function validateName (name :String) :void
    {
        switch (name) {
        case null: // names can't be null
        case CONTENT_DATANAME: // reserved for special all-in-one media
            throw new ArgumentError("Invalid name: " + name);
        }
    }

    /**
     * Read the zip file.
     *
     * @private
     */
    protected function bytesAvailable (bytes :ByteArray) :void
    {
        bytes.position = 0;
        try {
            _zip = new ZipFile(bytes);
        } catch (zipError :ZipError) {
            dispatchError("Unable to read datapack: " + zipError.message);
            return;
        }

        var dataFile :ZipEntry = _zip.getEntry(METADATA_FILENAME);
        if (dataFile == null) {
            dispatchError("No " + METADATA_FILENAME + " contained in DataPack.");
            return;
        }

        var asString :String = bytesToString(_zip.getInput(dataFile));

        // now try parsing the data
        try {
            // this also can throw an Error if the XML doesn't parse
            _metadata = XmlUtil.newXML(asString);

        } catch (error :Error) {
            dispatchError("Could not parse datapack: " + error.message);
            return;
        }
    }

    /**
     * Turn the specified ByteArray into a String.
     *
     * @private
     */
    protected function bytesToString (ba :ByteArray) :String
    {
        ba.position = 0;
        return ba.readUTFBytes(ba.bytesAvailable);
    }

    /**
     * Dispatch an error event with the specified message.
     *
     * @private
     */
    protected function dispatchError (message :String) :void
    {
        if (willTrigger(ErrorEvent.ERROR)) {
            dispatchEvent(new ErrorEvent(ErrorEvent.ERROR, false, false, message));
        } else {
            trace("Unhandled DataPack load error: " + message);
        }
    }

    /** The contents of the datapack. @private */
    protected var _zip :ZipFile;

    /** The metadata. @private */
    protected var _metadata :XML;

    /** The filename of the metadata file. @private */
    protected static const METADATA_FILENAME :String = "_data.xml";

    /** The data name of the primary media file, used for all-in-one remixable media. @private */
    protected static const CONTENT_DATANAME :String = "_CONTENT";
}
}
