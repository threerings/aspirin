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

/**
 * Records the completion of multiple conditions and calls a function when all are completed.
 */
public class AsyncConditions
{
    /**
     * Creates an AsyncConditions that calls onAllComplete when satisfy is called for everything in
     * conditions.
     */
    public function AsyncConditions (conditions :Array, onAllSatisfied :Function)
    {
        _onAllSatisfied = onAllSatisfied;
        for each (var cond :String in conditions) {
            _unsatisfied.add(cond);
        }
    }

    /**
     * Marks condition as satisfied. If satisfy has already been called for condition or condition
     * wasn't in the set of conditions, a warning is logged. If condition is the last unsatisfied
     * condition, the satisfaction callback is called.
     */
    public function satisfy (condition :Object) :void
    {
        if (_unsatisfied.remove(condition)) {
            _satisfied.add(condition);
            if(_unsatisfied.isEmpty()) {
                _onAllSatisfied();
            }
        } else if (_satisfied.contains(condition)) {
            log.warning("Condition satisfied multiple times", "condition", condition);
        } else {
            log.warning("Unknown condition satisfied", "condition", condition);
        }
    }

    protected var _onAllSatisfied :Function;

    protected const _unsatisfied :Set = Sets.newSetOf(String);
    protected const _satisfied :Set = Sets.newSetOf(Object);

    private static const log :Log = Log.getLog(AsyncConditions);
}
}
