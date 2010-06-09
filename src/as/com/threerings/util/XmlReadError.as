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

public class XmlReadError extends Error
{
    /**
     * Creates a new XmlReadError
     *
     * @param args a list of argument pairs that will be included in the error string, in
     * the form: message [arg0=arg1, arg2=arg3 ... ]. If the last argument is an un-paired XML
     * (that is, if the args list has an odd number of elements, and the last element is an XML),
     * its XML content will be included in a new line, below the rest of the message content.
     */
    public function XmlReadError (message :String = "", ...args)
    {
        super(getErrString(message, args));
    }

    protected static function getErrString (message :String, args :Array) :String
    {
        // if the last arg is an XML, pull it out
        var badXml :XML;
        if (args.length % 2 != 0 && args[args.length - 1] is XML) {
            badXml = args.pop();
        }
        var errString :String = Joiner.pairsArray(message, args);
        if (badXml != null) {
            errString += "\n" + XmlUtil.toXMLString(badXml);
        }

        return errString;
    }
}

}
