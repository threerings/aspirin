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
import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;

import com.threerings.util.F;
import com.threerings.util.Ordering;

/**
 * Allows children to be added and removed from a container while maintaining a fixed ordering.
 * This is useful when one would normally set the visibility of a child but doing so would impact
 * performance, which is often the case. <p>Note this is intended for situations in which the
 * visibility of a child only needs to change relatively rarely. If the visibility is changing
 * frequently, the overhead of updating the display list could outweigh the benefits.</p>
 * <p>So instead of:
 * <listing version="3.0">
 *     // init
 *     _container.addChild(child1);
 *     _container.addChild(child2);
 *     // hide child1
 *     child1.visible = false;
 *     // later on... show it
 *     child1.visible = true;
 * </listing>
 * this can be used instead:
 * <listing version="3.0">
 *     // init
 *     _order = new ContainerOrder(_container, [child1, child2]);
 *     _order.reset();
 *     // hide child1
 *     _order.remove(child1);
 *     // later on... show it
 *     _order.insert(child1);
 * </listing></p>
 */
public class ContainerOrder
{
    /**
     * Creates a new container order with the given container and sequence of children.
     */
    public function ContainerOrder (container :DisplayObjectContainer, sequence :Array = null)
    {
        _container = container;
        this.sequence = sequence == null ? [] : sequence;
    }

    /**
     * Accesses the sequence of children that belong to this container order. It is an error to
     * modify the passed in children after this call and may produce incorrect results.
     */
    public function set sequence (children :Array) :void
    {
        _children = children;
        _cmp = new Ordering(children).compare;
    }

    public function get sequence () :Array
    {
        return _children;
    }

    /**
     * Accesses the container whose children are being ordered.
     */
    public function set container (container :DisplayObjectContainer) :void
    {
        _container = container;
    }

    public function get container () :DisplayObjectContainer
    {
        return _container;
    }

    /**
     * Removes all children from the underlying container and adds the ones designated by the last
     * call to <code>set sequence</code>.
     */
    public function reset () :void
    {
        DisplayUtil.removeAllChildren(_container);
        F.forEach(_children, _container.addChild);
    }

    /**
     * Inserts the given child into the underlying container, if it is not already a child.
     * Maintains the ordering given by the last call to <code>set sequence</code>. It is an error
     * for the child to not be an element of the sequence and may produce incorrect results.
     */
    public function insert (child :DisplayObject) :void
    {
        if (child.parent != _container) {
            DisplayUtil.sortedInsert(_container, child, _cmp);
        }
    }

    /**
     * Removes the given child from the underlying container, if it is a child.
     */
    public function remove (child :DisplayObject) :void
    {
        if (child.parent == _container) {
            _container.removeChild(child);
        }
    }

    /**
     * Toggles the presence of the given child in the underlying container, removing it is already
     * a child, otherwise inserting it.
     */
    public function toggle (child :DisplayObject) :void
    {
        if (child.parent == _container) {
            remove(child);
        } else {
            insert(child);
        }
    }

    private var _container :DisplayObjectContainer;
    private var _children :Array;
    private var _cmp :Function;
}
}
