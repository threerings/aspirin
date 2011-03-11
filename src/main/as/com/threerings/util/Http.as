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
            req.contentType = "text/xml";
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

    private static const log :Log = Log.getLog(Http);
}
}
