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

import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.net.URLLoader;
import flash.net.URLLoaderDataFormat;
import flash.net.URLRequest;
import flash.net.URLRequestMethod;
import flash.net.URLVariables;
import flash.utils.ByteArray;
import flash.utils.getQualifiedClassName;

import com.threerings.util.Log;
import com.threerings.util.XmlUtil;

public class Http
{
    public function Http (url :String)
    {
        _url = url;
    }

    public function get (data :Object = null) :void
    {
        if (data != null) {
            Preconditions.checkArgument(getQualifiedClassName(data) === "Object",
                "get must received a vanilla object");
            _data = data;
        }
        _method = URLRequestMethod.GET;
        call();
    }

    public function post (data :Object) :void
    {
        Preconditions.checkNotNull(data, "postData data must be non-null");
        if (data is ByteArray) {
            binary();
        } else if (data is XML && _contentType == null) {
            contentType("text/xml");
        }
        _data = data;
        _method = URLRequestMethod.POST;
        call();
    }

    public function onSuccess (callback :Function) :Http
    {
        _successCallback = callback;
        return this;
    }

    public function onFailure (callback :Function) :Http
    {
        _failureCallback = callback;
        return this;
    }

    /**
     * Send/Retrieve data in binary, the success callback will receive a ByteArray
     */
    public function binary () :Http
    {
        _dataFormat = URLLoaderDataFormat.BINARY;
        return this;
    }

    /**
     * Create XML with the response body before passing it to the onSuccess callback.
     */
    public function xml () :Http
    {
        return parser(XmlUtil.newXML);
    }

    /**
     * Set the MIME type of the data in the request.
     */
    public function contentType (type :String) :Http
    {
        _contentType = type;
        return this;
    }

    /**
     * Convert the response body to another type using a function before passing it to the
     * onSuccess callback.
     */
    public function parser (parser :Function) :Http
    {
        _parser = parser;
        return this;
    }

    protected function call () :void
    {
        var req :URLRequest = new URLRequest(_url);
        if (_method != null) {
            req.method = _method;
        }
        if (_data is XML) {
            req.data = _data;
        } else if (_data is ByteArray) {
            req.data = _data;
        } else if (getQualifiedClassName(_data) === "Object") {
            req.data = new URLVariables();
            for (var key :Object in _data) {
                req.data[key] = _data[key];
            }
        } else if (_data != null) {
            throw new Error("Unknown type of data: " + _data);
        }
        if (_contentType != null) {
            req.contentType = _contentType;
        }
        var loader :URLLoader = new URLLoader(req);
        if (_dataFormat != null) {
            loader.dataFormat = _dataFormat;
        }
        if (_successCallback != null) {
            loader.addEventListener(Event.COMPLETE, function (event :Event) :void {
                _successCallback((_parser != null) ? _parser(loader.data) : loader.data);
            });
        }
        loader.addEventListener(IOErrorEvent.IO_ERROR,
            _failureCallback == null ? failureLogger : _failureCallback);
    }

    protected function failureLogger (event :IOErrorEvent) :void
    {
        log.warning("Remote request failed", "reason", event.text);
    }

    protected var _url :String;
    protected var _method :String;
    protected var _data :Object;
    protected var _successCallback :Function;
    protected var _failureCallback :Function;
    protected var _dataFormat :String;
    protected var _parser :Function;
    protected var _contentType :String;

    private static const log :Log = Log.getLog(Http);
}
}
