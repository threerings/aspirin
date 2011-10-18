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

package com.threerings.display {
import flash.display.BitmapData;
import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.display.Graphics;
import flash.display.Shape;
import flash.display.Sprite;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.geom.Rectangle;

import com.threerings.util.ClassUtil;
import com.threerings.util.Comparators;
import com.threerings.util.F;

import com.threerings.geom.Vector2;

public class DisplayUtil
{
    /**
     * Uniformly scales a DisplayObject if its width or height are outside the given size
     * constraints.
     * Any constraint that's &lt;= 0 will be ignored.
     */
    public static function clampSize (disp :DisplayObject, minWidth :Number = 0,
        maxWidth :Number = 0, minHeight :Number = 0, maxHeight :Number = 0) :void
    {
        var scaleX :Number;
        var scaleY :Number;
        var scale :Number;
        if ((maxWidth > 0 && disp.width > maxWidth) ||
            (maxHeight > 0 && disp.height > maxHeight)) {

            scaleX = (maxWidth > 0 ? maxWidth / disp.width : 1);
            scaleY = (maxHeight > 0 ? maxHeight / disp.height : 1);
            scale = Math.min(scaleX, scaleY);
            disp.scaleX *= scale;
            disp.scaleY *= scale;

        } else if ((minWidth > 0 && disp.width < minWidth) ||
            (minHeight > 0 && disp.height < minHeight)) {

            scaleX = (minWidth > 0 ? minWidth / disp.width : 1);
            scaleY = (minHeight > 0 ? minHeight / disp.height : 1);
            scale = Math.max(scaleX, scaleY);
            disp.scaleX *= scale;
            disp.scaleY *= scale;
        }
    }

    /**
     * Add a mask for the specified object. If a rectangle is specified, that area is
     * masked, but additionally a Graphics is returned that can be drawn upon to specify the mask
     * area.
     */
    public static function addMask (disp :DisplayObjectContainer, area :Rectangle = null) :Graphics
    {
        removeMask(disp);
        var masker :Shape = new Shape();
        disp.addChild(masker);
        disp.mask = masker;
        var g :Graphics = masker.graphics;
        if (area != null) {
            g.beginFill(0);
            g.drawRect(area.x, area.y, area.width, area.height);
            g.endFill();
        }
        return g;
    }

    /**
     * Remove any mask on the specified object.
     */
    public static function removeMask (disp :DisplayObjectContainer) :void
    {
        if (disp.mask != null) {
            disp.removeChild(disp.mask);
            disp.mask = null;
        }
    }

    /**
     * Removes all children from the specified DisplayObjectContainer
     */
    public static function removeAllChildren (parent :DisplayObjectContainer) :void
    {
        while (parent.numChildren > 0) {
            // Removing nodes from the front of the child list is about twice as fast as
            // removing them from the end.
            parent.removeChildAt(0);
        }
    }

    /**
     * Detaches the specified DisplayObject from its parent DisplayObjectContainer, if it
     * has one.
     */
    public static function detach (d :DisplayObject) :void
    {
        if (d.parent != null) {
            d.parent.removeChild(d);
        }
    }

    /**
     * Transforms a point from one DisplayObject's coordinate space to another's.
     */
    public static function transformPoint (p :Point, fromDisp :DisplayObject, toDisp :DisplayObject)
        :Point
    {
        return toDisp.globalToLocal(fromDisp.localToGlobal(p));
    }

    /**
     * Transforms a Vector2 from one DisplayObject's coordinate space to another's.
     */
    public static function transformVector (v :Vector2, fromDisp :DisplayObject,
        toDisp :DisplayObject) :Vector2
    {
        return Vector2.fromPoint(transformPoint(v.toPoint(), fromDisp, toDisp));
    }

    /**
     * Adds newChild to container, directly below another child of the container.
     */
    public static function addChildBelow (container :DisplayObjectContainer,
                                          newChild :DisplayObject,
                                          below :DisplayObject) :void
    {
        container.addChildAt(newChild, container.getChildIndex(below));
    }

    /**
     * Adds newChild to container, directly above another child of the container.
     */
    public static function addChildAbove (container :DisplayObjectContainer,
                                          newChild :DisplayObject,
                                          above :DisplayObject) :void
    {
        container.addChildAt(newChild, container.getChildIndex(above) + 1);
    }

    /**
     * Changes the DisplayObject's index in its parent container so that it's layered behind
     * all its siblings.
     */
    public static function moveToBack (disp :DisplayObject) :void
    {
        var parent :DisplayObjectContainer = disp.parent;
        if (parent != null) {
            parent.setChildIndex(disp, 0);
        }
    }

    /**
     * Changes the DisplayObject's index in its parent container so that it's layered in front of
     * all its siblings.
     */
    public static function moveToFront (disp :DisplayObject) :void
    {
        var parent :DisplayObjectContainer = disp.parent;
        if (parent != null) {
            parent.setChildIndex(disp, parent.numChildren - 1);
        }
    }

    /**
     * Sets the top-left pixel of a DisplayObject to the given location, relative to another
     * DisplayObject's coordinate space.
     */
    public static function positionBoundsRelative (disp :DisplayObject, relativeTo :DisplayObject,
        x :Number, y :Number) :void
    {
        var bounds :Rectangle = disp.getBounds(relativeTo);
        disp.x = x - bounds.left;
        disp.y = y - bounds.top;
    }

    /**
     * Sets the top-left pixel of a DisplayObject to the given location, taking the
     * object's bounds into account.
     */
    public static function positionBounds (disp :DisplayObject, x :Number, y :Number) :void
    {
        positionBoundsRelative(disp, disp, x, y);
    }

    /**
     * Sorts a container's children.
     * @param container the container whose children to sort
     * @param comp a function that takes two DisplayObjects, and returns int -1 if the first
     * object should appear before the second in the container, 1 if it should appear after,
     * and 0 if the order does not matter. If omitted, Comparators.compareComparables
     * will be used- all the children should implement Comparable.
     */
    public static function sortDisplayChildren (
        container :DisplayObjectContainer, comp :Function = null) :void
    {
        if (comp == null) {
            comp = Comparators.compareComparables;
        }

        // insertion sort implementation
        var numChildren :int = container.numChildren;
        for (var ii :int = 1; ii < numChildren; ii++) {
            var val :DisplayObject = container.getChildAt(ii);
            var jj :int = ii - 1;
            for (; jj >= 0; jj--) {
                if (comp(val, container.getChildAt(jj)) >= 0) {
                    break;
                }
            }
            if (++jj != ii) {
                container.setChildIndex(val, jj);
            }
        }
    }

    /**
     * Inserts a display object into a sorted container in its correct location according to a
     * comparison function.
     *
     * @param comp a function that takes two objects and returns -1 if the first object should
     * appear before the second in the container, 1 if it should appear after, and 0 if the order
     * does not matter. If omitted, Comparators.compareComparables is used and all current children
     * and the one to insert should be Comparable objects.
     */
    public static function sortedInsert (container :DisplayObjectContainer, child :DisplayObject,
        comp :Function) :void
    {
        var low :int = 0;
        var high :int = container.numChildren - 1;
        while (low <= high) {
            // http://googleresearch.blogspot.com/2006/06/extra-extra-read-all-about-it-nearly.html
            var mid :int = (low + high) >>> 1;
            var midVal :DisplayObject = container.getChildAt(mid);
            var cmp :int = comp(midVal, child);
            if (cmp < 0) {
                low = mid + 1;
            } else if (cmp > 0) {
                high = mid - 1;
            } else {
                container.addChildAt(child, mid);
                return;
            }
        }

        container.addChildAt(child, low);
    }

    /**
     * Call <code>callback</code> for <code>disp</code> and all its descendants.
     *
     * This is nearly exactly like mx.utils.DisplayUtil.walkDisplayObjects,
     * except this method copes with security errors when examining a child.
     * @param disp the root of the hierarchy at which to start the iteration
     * @param callback function to call for each node in the display tree for disp. The passed
     * object will never be null and the function will be called exactly once for each node, unless
     * iteration is halted. The callback can have one of four signatures:
     * <listing version="3.0">
     *     function callback (disp :DisplayObject) :void
     *     function callback (disp :DisplayObject) :Boolean
     *     function callback (disp :DisplayObject, depth :int) :void
     *     function callback (disp :DisplayObject, depth :int) :Boolean
     * </listing>
     *
     * If <code>callback</code> returns <code>true</code>, traversal will halt.
     *
     * The passed in depth is 0 for <code>disp</code>, and increases by 1 for each level of
     * children.
     *
     * @return <code>true</code> if <code>callback</code> returned <code>true</code>
     */
    public static function applyToHierarchy (
        root :DisplayObject, callback :Function, securityErrorCallback :Function=null,
        maxDepth :int=int.MAX_VALUE) :Boolean
    {
        var toApply :Function = callback;
        // Earlier versions of this function didn't pass a depth to callback, so don't
        // assume that. Since we know we're getting a function of length 1 or 2, adapt manually
        // instead of using F.adapt.
        if (callback.length == 1) {
            toApply = function (disp :DisplayObject, depth :int) :Boolean {
                return callback(disp);
            }
        }
        return applyToHierarchy0(root, maxDepth, toApply, securityErrorCallback, 0);
    }

    /** Helper for applyToHierarchy */
    protected static function applyToHierarchy0 (root :DisplayObject, maxDepth :int,
        callback :Function, securityErrorCallback :Function, depth :int) :Boolean
    {
        // halt traversal if callbackFunction returns true
        if (Boolean(callback(root, depth))) {
            return true;
        }

        if (++depth > maxDepth || !(root is DisplayObjectContainer)) {
            return false;
        }
        var container :DisplayObjectContainer = DisplayObjectContainer(root);
        var nn :int = container.numChildren;
        for (var ii :int = 0; ii < nn; ii++) {
            var child :DisplayObject;
            try {
                child = container.getChildAt(ii);
            } catch (err :SecurityError) {
                if (securityErrorCallback != null) {
                    securityErrorCallback(err, depth);
                }
                continue;
            }
            if (applyToHierarchy0(child, maxDepth, callback, securityErrorCallback, depth)) {
                return true;
            }
        }

        return false;
    }

    /**
     * Center the specified rectangle within the specified bounds. If the bounds are too
     * small then the rectangle will be pinned to the upper-left.
     */
    public static function centerRectInRect (rect :Rectangle, bounds :Rectangle) :Point
    {
        return new Point(
            bounds.x + Math.max(0, (bounds.width - rect.width) / 2),
            bounds.y + Math.max(0, (bounds.height - rect.height) / 2));
    }

    /**
     * Returns the most reasonable position for the specified rectangle to
     * be placed at so as to maximize its containment by the specified
     * bounding rectangle while still placing it as near its original
     * coordinates as possible.
     *
     * @param rect the rectangle to be positioned.
     * @param bounds the containing rectangle.
     */
    public static function fitRectInRect (rect :Rectangle, bounds :Rectangle) :Point
    {
        // Guarantee that the right and bottom edges will be contained
        // and do our best for the top and left edges.
        return new Point(
            Math.min(bounds.right - rect.width, Math.max(rect.x, bounds.x)),
            Math.min(bounds.bottom - rect.height, Math.max(rect.y, bounds.y)));
    }

    /**
     * Position the specified rectangle within the bounds, avoiding
     * any of the Rectangles in the avoid array, which may be destructively
     * modified.
     *
     * @return true if the rectangle was successfully placed, given the
     * constraints, or false if the positioning failed (the rectangle will
     * be left at its original location.
     */
    public static function positionRect (
            r :Rectangle, bounds :Rectangle, avoid :Array) :Boolean
    {
        var origPos :Point = r.topLeft;
        var pointSorter :Function = createPointSorter(origPos);
        var possibles :Array = new Array();
        // start things off with the passed-in point (adjusted to
        // be inside the bounds, if needed)
        possibles.push(fitRectInRect(r, bounds));

        // keep track of area that doesn't generate new possibles
        var dead :Array = new Array();

        // Note: labeled breaks and continues are supposed to be legal,
        // but they throw wacky runtime exceptions for me. So instead
        // I'm throwing a boolean and using that to continue the while
        /* CHECKPOSSIBLES: */ while (possibles.length > 0) {
            try {
                var p :Point = (possibles.shift() as Point);
                r.x = p.x;
                r.y = p.y;

                // make sure the rectangle is in the view
                if (!bounds.containsRect(r)) {
                    continue;
                }

                // and not over a dead area
                for each (var deadRect :Rectangle in dead) {
                    if (deadRect.intersects(r)) {
                        //continue CHECKPOSSIBLES;
                        throw true; // continue outer loop
                    }
                }

                // see if it hits any rects we're trying to avoid
                for (var ii :int = 0; ii < avoid.length; ii++) {
                    var avoidRect :Rectangle = (avoid[ii] as Rectangle);
                    if (avoidRect.intersects(r)) {
                        // remove it from the avoid list
                        avoid.splice(ii, 1);
                        // but add it to the dead list
                        dead.push(avoidRect);

                        // add 4 new possible points, each pushed in
                        // one direction
                        possibles.push(
                            new Point(avoidRect.x - r.width, r.y),
                            new Point(r.x, avoidRect.y - r.height),
                            new Point(avoidRect.x + avoidRect.width, r.y),
                            new Point(r.x, avoidRect.y + avoidRect.height));

                        // re-sort the list
                        possibles.sort(pointSorter);
                        //continue CHECKPOSSIBLES;
                        throw true; // continue outer loop
                    }
                }

                // hey! if we got here, then it worked!
                return true;

            } catch (continueWhile :Boolean) {
                // simply catch the boolean and use it to continue inner loops
            }
        }

        // we never found a match, move the rectangle back
        r.x = origPos.x;
        r.y = origPos.y;
        return false;
    }

    /**
     * Create a sort Function that can be used to compare Points in an
     * Array according to their distance from the specified Point.
     *
     * Note: The function will always sort according to distance from the
     * passed-in point, even if that point's coordinates change after
     * the function is created.
     */
    public static function createPointSorter (origin :Point) :Function
    {
        return function (p1 :Point, p2 :Point) :Number {
            var dist1 :Number = Point.distance(origin, p1);
            var dist2 :Number = Point.distance(origin, p2);

            return (dist1 > dist2) ? 1 : ((dist1 < dist2) ? -1 : 0); // signum
        };
    }

    /**
     * Traverses a display hierarchy and returns the DisplayObject at the given path.
     *
     * @param path a String containing the dot-delimited path of the descendent to return;
     * e.g. "child.grandchild.greatgrandchild".
     *
     * @param pathDelimiter the delimiter used to separate different elements of the path.
     * Defaults to "."
     *
     * @return the DisplayObject at the given path, or null if the path could not be resolved
     * to a DisplayObject
     */
    public static function getDescendent (
        root :DisplayObjectContainer, path :String, pathDelimiter :String = ".") :DisplayObject
    {
        var desc :DisplayObject = root;
        for each (var elem :String in path.split(pathDelimiter)) {
            try {
                desc = DisplayObjectContainer(desc).getChildByName(elem);
            } catch (err :TypeError) {
                return null;
            }
        }
        return desc;
    }

    /**
     * Returns the path used to reach the given DisplayObject from the display hierarchy rooted
     * at "root".
     *
     * @param root the root of the display hierarchy that contains disp
     *
     * @param disp the descendent to retrieve a path for
     *
     * @param pathDelimiter the delimiter used to separate different elements of the path.
     * Defaults to "."
     *
     * @return a String representing the path from root to disp, or null if disp is not a
     * descendent of root, or has some unnamed ancestor
     */
    public static function getDescendentPath (
        root :DisplayObjectContainer, disp :DisplayObject, pathDelimiter :String = ".") :String
    {
        var path :String = "";
        // walk up the display hierarchy until we hit the root
        while (disp != root) {
            var curName :String = disp.name;
            if (curName == null) {
                return null;
            }
            disp = disp.parent;
            if (disp == null) {
                return null;
            }
            // prepend the current name
            path = curName + ((path != "") ? (pathDelimiter + path) : "");
        }
        return path;
    }

    /**
     * Finds the first component with the specified name in the specified display hierarchy turned
     * up in a depth-first traversal.
     *
     * Note: This method will not find rawChildren of flex componenets.
     */
    public static function findInHierarchy (top :DisplayObject, name :String,
        maxDepth :int = int.MAX_VALUE) :DisplayObject
    {
        var found :DisplayObject;
        applyToHierarchy(top, function (cur :DisplayObject, depth :int) :Boolean {
            if (cur != null && cur.name == name) {
                found = cur;
                return true;
            }
            return false;
        }, null, maxDepth);
        return found;
    }

    /**
     * Finds the first component with the specified name in the specified display hierarchy turned
     * up in a depth-first traversal. Throws an error if nothing was found, or if the wrong type
     * object was found.
     *
     * Note: This method will not find rawChildren of flex componenets.
     */
    public static function requireInHierarchy (top :DisplayObject, name :String,
        requiredClass :Class = null, maxDepth :int = int.MAX_VALUE) :*
    {
        var found :DisplayObject = findInHierarchy(top, name, maxDepth);
        if (found == null) {
            throw new Error("Couldn't find '" + name + "' in display hierarchy");
        }
        if (requiredClass == null || (found is requiredClass)) {
            return found;
        }
        throw new Error("Display hierarchy object '" + name + "' is wrong type: " +
            ClassUtil.tinyClassName(found));
    }

    /**
     * Returns all components for which <code>filter</code> returns true in <code>top</code>'s
     * hierarchy.
     */
    public static function filterHierarchy (top :DisplayObject, filter :Function) :Array
    {
        var found :Array = [];
        applyToHierarchy(top, function (cur :DisplayObject) :void {
            if (filter(cur)) {
                found.push(cur);
            }
        });
        return found;
    }

    /**
     * Dump the display hierarchy to a String, each component on a newline, children indented
     * two spaces:
     * "instance0"  flash.display.Sprite
     *   "instance1"  flash.display.Sprite
     *   "entry_box"  flash.text.TextField
     *
     * Note: This method will not dump rawChildren of flex componenets.
     */
    public static function dumpHierarchy (top :DisplayObject) :String
    {
        var result :String = "";
        function printChild (depth :int, description :String) :void
        {
            if (depth > 0) {
                result += "\n";
            }
            for (var ii :int = 0; ii < depth; ii++) {
                result += "  ";
            }
            result += description;
        }
        function addChild (disp :DisplayObject, depth :int) :void {
            printChild(depth, disp == null ?
                "null" : "\"" + disp.name + "\"  " + ClassUtil.getClassName(disp));
        }
        applyToHierarchy(top, addChild, F.partial(printChild, F._1, "SECURITY-BLOCKED"));
        return result;
    }

    /**
     * Draws the given DisplayObject into a BitmapData object.
     *
     * @param transparent specifies whether the created BitmapData supports per-pixel transparency.
     * Defaults to true.
     *
     * @param fillColor the 32-bit ARGB color value that will be used to fill the bitmap image area
     * before the DisplayObject is drawn into it. Defaults to 0x00FFFFFF, which will cause the
     * portions of the BitmapData that aren't occupied by the DisplayObject's pixels to be
     * transparent if 'transparent' is true, or white if 'transparent' is false.
     *
     * @param the scale that should be applied to the image when it's drawn to the bitmap
     */
    public static function createBitmapData (disp :DisplayObject, transparent :Boolean = true,
        fillColor :uint = 0x00FFFFFF, scale :Number = 1) :BitmapData
    {
        if (scale <= 0) {
            throw new ArgumentError("scale must be > 0");
        }

        var bounds :Rectangle = disp.getBounds(disp);
        var bd :BitmapData = new BitmapData(bounds.width * scale, bounds.height * scale,
            transparent, fillColor);
        bd.draw(disp, new Matrix(scale, 0, 0, scale, -bounds.x * scale, -bounds.y * scale));
        return bd;
    }

    /**
     * Gets the children of a display object container into an array.
     */
    public static function getChildren (parent :DisplayObjectContainer) :Array
    {
        var children :Array = [];
        forEachChild(parent, children.push);
        return children;
    }

    /**
     * Calls a method for each child of a display object.
     */
    public static function forEachChild (parent :DisplayObjectContainer, callback :Function) :void
    {
        var nn :int = parent.numChildren;
        for (var ii :int = 0; ii < nn; ++ii) {
            callback(parent.getChildAt(ii));
        }
    }

    /**
     * Searches up the display tree from an object and returns an ancestor container of an
     * expected type, or null if the type was not found. The search can optionally be stopped at a
     * given container.
     */
    public static function findAncestorOfType (start :DisplayObject, type :Class,
        stop :DisplayObjectContainer = null) :*
    {
        if (start is type) {
            return start;
        }

        var parent :DisplayObjectContainer = start.parent;
        while (parent != stop && parent != null) {
            if (parent is type) {
                break;
            }
            parent = parent.parent;
        }
        return parent as type;
    }
}
}
