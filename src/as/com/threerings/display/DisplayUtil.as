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

package com.threerings.display {

import com.threerings.util.ArrayUtil;
import com.threerings.util.ClassUtil;

import flash.display.BitmapData;
import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.display.Sprite;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.geom.Rectangle;

public class DisplayUtil
{
    /**
     * Masks the Sprite according to the given rectangular area.
     */
    public static function maskSprite (sprite :Sprite, area :Rectangle) :void
    {
        var masker :Sprite = new Sprite();
        masker.graphics.beginFill(0);
        masker.graphics.drawRect(area.x, area.y, area.width, area.height);
        masker.graphics.endFill();
        sprite.addChild(masker);
        sprite.mask = masker;
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
     * Sorts a container's children, using ArrayUtil.stableSort.
     *
     * comp is a function that takes two DisplayObjects, and returns int -1 if the first
     * object should appear before the second in the container, 1 if it should appear after,
     * and 0 if the order does not matter. If omitted, Comparators.COMPARABLE
     * will be used- all the children should implement Comparable.
     */
    public static function sortDisplayChildren (
        container :DisplayObjectContainer, comp :Function = null) :void
    {
        var numChildren :int = container.numChildren;
        // put all children in an array
        var children :Array = new Array(numChildren);
        var ii :int;
        for (ii = 0; ii < numChildren; ii++) {
            children[ii] = container.getChildAt(ii);
        }

        // stable sort the array
        ArrayUtil.stableSort(children, comp);

        // set their new indexes
        for (ii = 0; ii < numChildren; ii++) {
            container.setChildIndex(DisplayObject(children[ii]), ii);
        }
    }

    /**
     * Call the specified function for the display object and all descendants.
     *
     * This is nearly exactly like mx.utils.DisplayUtil.walkDisplayObjects,
     * except this method copes with security errors when examining a child.
     *
     * @param callbackFunction Signature:
     * function (disp :DisplayObject) :void
     *    or
     * function (disp :DisplayObject) :Boolean
     *
     * If you return a Boolean, you may return <code>true</code> to indicate that you've
     * found what you were looking for, and halt iteration.
     *
     * @return true if iteration was halted by callbackFunction returning true
     */
    public static function applyToHierarchy (
        disp :DisplayObject, callbackFunction :Function) :Boolean
    {
        // halt iteration if callbackFunction returns true
        if (Boolean(callbackFunction(disp))) {
            return true;
        }

        if (disp is DisplayObjectContainer) {
            var container :DisplayObjectContainer = disp as DisplayObjectContainer;
            var nn :int = container.numChildren;
            for (var ii :int = 0; ii < nn; ii++) {
                try {
                    disp = container.getChildAt(ii);
                } catch (err :SecurityError) {
                    continue;
                }
                // and then we apply outside of the try/catch block so that
                // we don't hide errors thrown by the callbackFunction.
                if (applyToHierarchy(disp, callbackFunction)) {
                    return true;
                }
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
     * Find a component with the specified name in the specified display hierarchy.
     * Whether finding deeply or shallowly, if two components have the target name and are
     * at the same depth, the first one found will be returned.
     *
     * Note: This method will not find rawChildren of flex componenets.
     */
    public static function findInHierarchy (
        top :DisplayObject, name :String, findShallow :Boolean = true,
        maxDepth :int = int.MAX_VALUE) :DisplayObject
    {
        var result :Array = findInHierarchy0(top, name, findShallow, maxDepth);
        return (result != null) ? DisplayObject(result[0]) : null;
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
        return dumpHierarchy0(top);
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
     * Internal worker method for findInHierarchy.
     */
    private static function findInHierarchy0 (
        obj :DisplayObject, name :String, shallow :Boolean, maxDepth :int, curDepth :int = 0) :Array
    {
        if (obj == null) {
            return null;
        }

        var bestResult :Array;
        if (obj.name == name) {
            if (shallow) {
                return [ obj, curDepth ];

            } else {
                bestResult = [ obj, curDepth ];
            }

        } else {
            bestResult = null;
        }

        if (curDepth < maxDepth && (obj is DisplayObjectContainer)) {
            var cont :DisplayObjectContainer = obj as DisplayObjectContainer;
            var nextDepth :int = curDepth + 1;
            for (var ii :int = 0; ii < cont.numChildren; ii++) {
                try {
                    var result :Array = findInHierarchy0(
                        cont.getChildAt(ii), name, shallow, maxDepth, nextDepth);
                    if (result != null) {
                        if (shallow) {
                            // we update maxDepth for every hit, so result is always
                            // shallower than any current bestResult
                            bestResult = result;
                            maxDepth = int(result[1]) - 1;
                            if (maxDepth == curDepth) {
                                break; // stop looking
                            }

                        } else {
                            // only replace if it's deeper
                            if (bestResult == null || int(result[1]) > int(bestResult[1])) {
                                bestResult = result;
                            }
                        }
                    }
                } catch (err :SecurityError) {
                    // skip this child
                }
            }
        }

        return bestResult;
    }

    /**
     * Internal worker method for dumpHierarchy.
     */
    private static function dumpHierarchy0 (
        obj :DisplayObject, spaces :String = "", inStr :String = "") :String
    {
        if (obj != null) {
            if (inStr != "") {
                inStr += "\n";
            }
            inStr += spaces + "\"" + obj.name + "\"  " + ClassUtil.getClassName(obj);

            if (obj is DisplayObjectContainer) {
                spaces += "  ";
                var container :DisplayObjectContainer = obj as DisplayObjectContainer;
                for (var ii :int = 0; ii < container.numChildren; ii++) {
                    try {
                        var child :DisplayObject = container.getChildAt(ii);
                        inStr = dumpHierarchy0(container.getChildAt(ii), spaces, inStr);
                    } catch (err :SecurityError) {
                        inStr += "\n" + spaces + "SECURITY-BLOCKED";
                    }
                }
            }
        }
        return inStr;
    }


}
}
