///////////////////////////////////////////////////////////////////////////////
// Dazzle Software - Primitizer Version (7.0)
//
// An Commerical primitizer for Second Life and Open Simulator by Revolution Perenti & Dazzle Software
//
// This file is commerical software; you can not redistribute it and/or modify
// or reverse enginner this source code in anyway or in any form
// it under the terms of the Commerical License as published by Stephen Bishop (Revolution Perenti)
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
///////////////////////////////////////////////////////////////////////////////

default
{
    link_message(integer sender, integer number, string message, key id)
    {
        if(message == "RESIDENTIAL")
        {
            integer i = llGetNumberOfPrims();
            for (; i >= 0; --i) 
            {
                list open = llGetLinkPrimitiveParams(i,[PRIM_TYPE]);
                string open2 = llList2String(open, 3);
                if(llGetLinkName(i) == "ene_door")
                {
                    if (llGetSubString(open2,0,2) != "0.0")
                    {
                        llSetLinkPrimitiveParams(i,[PRIM_TYPE, PRIM_TYPE_BOX,0,<0.0,1.0,0.0>,0.0,ZERO_VECTOR,<1.0,1.0,0.0>,ZERO_VECTOR]);
                    }
                    else
                    {
                        llSetLinkPrimitiveParams(i,[PRIM_TYPE, PRIM_TYPE_BOX,0,<0.0,1.0,0.0>,0.95,ZERO_VECTOR,<1.0,1.0,0.0>,ZERO_VECTOR]);
                    }
                }       
            }    
        }
    }
}