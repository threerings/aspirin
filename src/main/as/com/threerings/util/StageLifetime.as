package com.threerings.util
{
import flash.display.DisplayObject;
import flash.events.Event;

/**
 * Manages the pairing of ADDED_TO_STAGE and REMOVED_FROM_STAGE events since strict pairing is
 * very useful but not supported.
 */
public class StageLifetime
{
    /**
     * Adds the given handlers for ADDED_TO_STAGE and REMOVED_FROM_STAGE events coming from the
     * given disp, but guarantee the call order will always be interleaved. The first listener
     * added will be onAdd if disp.stage is null, otherwise onRemove.
     */ 
    public static function listen (disp :DisplayObject, onAdd :Function, onRemove :Function) :void
    {
        function handleOn (_:*) :void {
            toggle(true);
            handle(_, true);
        }
        function handleOff (_:*) :void {
            toggle(false);
            handle(_, false);
        }
        function toggle (added :Boolean) :void {
            if (added) {
                disp.addEventListener(Event.REMOVED_FROM_STAGE, handleOff);
                disp.removeEventListener(Event.ADDED_TO_STAGE, handleOn);
            } else {
                disp.addEventListener(Event.ADDED_TO_STAGE, handleOn);
                disp.removeEventListener(Event.REMOVED_FROM_STAGE, handleOff);
            }
        }
        function handle (_:*, added :Boolean) :void {
            var fn :Function = added ? onAdd : onRemove;
            if (fn != null) {
                fn(_);
            }
        }

        // listen for the next event the disp will dispatch
        toggle(disp.stage != null);
    }

    /**
     * Adds the given handler for ADDED_TO_STAGE, but guarantees not to call twice in succession
     * without an intervening REMOVED_FROM_STAGE event.
     */
    public static function onEachAdd (disp :DisplayObject, onAdd :Function) :void
    {
        listen(disp, onAdd, null);
    }

    /**
     * Adds the given handler for REMOVED_FROM_STAGE, but guarantees not to call twice in
     * succession without an intervening ADDED_TO_STAGE event.
     */
    public static function onEachRemove (disp :DisplayObject, onRemove :Function) :void
    {
        listen(disp, null, onRemove);
    }
}
}
