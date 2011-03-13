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

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Loader;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.IOErrorEvent;
import flash.net.URLRequest;
import flash.system.LoaderContext;

/**
 * Dispatched when an image successfully loads
 *
 * @eventType com.threerings.util.RemoteImageCacheEvent.LOAD_SUCCESS
 */
[Event(name="LoadSuccess", type="com.threerings.util.RemoteImageCacheEvent")]

/**
 * Dispatched when an image fails to load
 *
 * @eventType com.threerings.util.RemoteImageCacheEvent.LOAD_ERROR
 */
[Event(name="LoadError", type="com.threerings.util.RemoteImageCacheEvent")]

public class RemoteImageCache extends EventDispatcher
{
    /**
     * Frees all resources used by the cache.
     */
    public function shutdown () :void
    {
        _events.shutdown();

        // cancel all pending loaders
        _loadingImages.forEach(
            function (url :String, ctx :LoadingImageCtx) :void {
                ctx.cancelLoad();
            });

        _loadingImages = null;
        _loadedImages = null;
    }

    /**
     * Returns true if the image contained at the url is loaded in the cache.
     */
    public function isImageLoaded (url :String) :Boolean
    {
        return _loadedImages.get(url) != null;
    }

    /**
     * Removes the image with the given url from the cache (or stops it from loading, if it's
     * currently loading)
     */
    public function removeImage (url :String) :void
    {
        _loadedImages.remove(url);
        var ctx :LoadingImageCtx = _loadingImages.remove(url);
        if (ctx != null) {
            ctx.cancelLoad();
        }
    }

    /**
     * Returns the BitmapData for the image associated with the given url, if the image has been
     * loaded. Otherwise, returns null. No load will be initiated as a result of calling this
     * function.
     */
    public function getBitmapData (url :String) :BitmapData
    {
        var loaded :LoadedImage = _loadedImages.get(url);
        return (loaded != null ? loaded.bmd : null);
    }

    /**
     * If the image at the given url has been loaded, returns a Sprite containing a single
     * Bitmap child with the contents of that image. If the image has not been loaded, a load
     * will be initiated, and the returned Sprite will have the image added to it when the image
     * has completed loading.
     *
     * @param retryOnFailure if the image isn't already loaded, and it fails to load, retry
     * until it succeeds, or until there's an unrecoverable failure.
     */
    public function getImage (url :String, retryOnFailure :Boolean = false) :Sprite
    {
        if (url == null) {
            throw new ArgumentError("url must be non-null");
        }

        var sprite :Sprite = new Sprite();
        var loaded :LoadedImage = _loadedImages.get(url);
        if (loaded != null) {
            loaded.updateSprite(sprite);

        } else {
            // the image is loading, or has not yet been requested
            var ctx :LoadingImageCtx = loadImage(url, retryOnFailure);
            ctx.pendingSprites.push(sprite);
        }

        return sprite;
    }

    protected function loadImage (url :String, retryOnFailure :Boolean) :LoadingImageCtx
    {
        var ctx :LoadingImageCtx = _loadingImages.get(url);
        if (ctx != null) {
            // if retryOnFailure is true, update the ctx
            ctx.retryOnFailure ||= retryOnFailure;

        } else {
            // this image isn't being loaded yet. Begin loading it now.
            ctx = new LoadingImageCtx(url, retryOnFailure);
            _loadingImages.put(url, ctx);

            _events.registerListener(ctx.loader.contentLoaderInfo, Event.COMPLETE,
                function (..._) :void {
                    if (!ctx.loader.contentLoaderInfo.childAllowsParent) {
                        log.warning("LoaderInfo.childAllowsParent is false; cannot use image " +
                            " (policy file not in place at url?)", "url", url);
                        onLoadError(ctx, true);

                    } else {
                        onLoadComplete(ctx);
                    }
                });
            _events.registerListener(ctx.loader.contentLoaderInfo, IOErrorEvent.IO_ERROR,
                function (e :IOErrorEvent) :void {
                    // e.text will contain the URL, so don't include it again
                    log.warning("error loading image", "errText", e.text);
                    onLoadError(ctx, false);
                });

            // set checkPolicyFile to true to allow programmatic access to the image's pixels
            var loaderContext :LoaderContext = new LoaderContext();
            loaderContext.checkPolicyFile = true;
            // load!
            ctx.loader.load(new URLRequest(url), loaderContext);
        }

        return ctx;
    }

    protected function onLoadComplete (ctx :LoadingImageCtx) :void
    {
        var loadedImage :LoadedImage = new LoadedImage(ctx);
        _loadingImages.remove(ctx.url);
        _loadedImages.put(ctx.url, loadedImage);

        // update all sprites that were waiting for this load to complete
        for each (var pendingSprite :Sprite in ctx.pendingSprites) {
            loadedImage.updateSprite(pendingSprite);
        }

        dispatchEvent(new RemoteImageCacheEvent(RemoteImageCacheEvent.LOAD_SUCCESS, ctx.url));
    }

    protected function onLoadError (ctx :LoadingImageCtx, fatal :Boolean) :void
    {
        _loadingImages.remove(ctx.url);

        if (!fatal && ctx.retryOnFailure) {
            // retry the load!
            var newCtx :LoadingImageCtx = loadImage(ctx.url, true);
            newCtx.pendingSprites = ctx.pendingSprites;

        } else {
            // this was a fatal error, or we weren't asked to retry on failure
            dispatchEvent(new RemoteImageCacheEvent(RemoteImageCacheEvent.LOAD_ERROR, ctx.url));
        }
    }

    protected var _events :EventHandlerManager = new EventHandlerManager();
    protected var _loadedImages :Map = Maps.newMapOf(String); // Map<url, LoadedImage>
    protected var _loadingImages :Map = Maps.newMapOf(String); // Map<url, LoadingImageCtx>

    protected static const log :Log = Log.getLog(RemoteImageCache);
}

}


import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Loader;
import flash.display.Sprite;

import com.threerings.display.DisplayUtil;

class LoadingImageCtx
{
    public var url :String;
    public var retryOnFailure :Boolean;

    public var loader :Loader;
    public var pendingSprites :Array = [];

    public function LoadingImageCtx (url :String, retryOnFailure :Boolean)
    {
        this.url = url;
        this.retryOnFailure = retryOnFailure;

        loader = new Loader();
    }

    public function cancelLoad () :void
    {
        try {
            loader.close();
        } catch (e :Error) {
            // swallow
        }
        loader = null;
    }
}

class LoadedImage
{
    public var bmd :BitmapData;

    public function LoadedImage (ctx :LoadingImageCtx)
    {
        bmd = DisplayUtil.createBitmapData(ctx.loader);
    }

    public function updateSprite (sprite :Sprite) :void
    {
        if (bmd != null) {
            sprite.addChild(new Bitmap(bmd));
        }
    }
}
