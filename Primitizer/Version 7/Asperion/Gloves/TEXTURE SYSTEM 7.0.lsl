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

///////////////////////////////////////////////////////////////////////////////
// Channel Handler Variables
///////////////////////////////////////////////////////////////////////////////
integer CHANNEL;
integer CHANNEL_HANDLE;
integer TEXTURE_CHANNEL;
///////////////////////////////////////////////////////////////////////////////
// Inventory Index Variables
///////////////////////////////////////////////////////////////////////////////
integer INDEX;
///////////////////////////////////////////////////////////////////////////////
// Notecard System Variables
///////////////////////////////////////////////////////////////////////////////
list NOTECARD_READ;
string TEXTURE_NOTECARD;
string TEXTURE_PREFIX = "tex_";
key NOTECARD_QUERY;
///////////////////////////////////////////////////////////////////////////////
// Lighting System Variables
///////////////////////////////////////////////////////////////////////////////

string strReplace(string str, string search, string replace) {
    return llDumpList2String(llParseStringKeepNulls((str = "") + str, [search], []), replace);
}
 
string FormatFloat(float number, integer precision)
{    
    float roundingValue = llPow(10, -precision) * 0.5;
    float rounded;
    if (number < 0) rounded = number - roundingValue;
    else            rounded = number + roundingValue;
    if (precision < 1) 
    { 
        precision = 1; 
    }
    string result = llGetSubString((string)rounded, 0, llSubStringIndex((string)rounded, ".") + precision);
    result = strReplace(result, ".000", ".0");
    result = strReplace(result, "00,", "0,");
    return result;
}
 
string FormatVector(vector hector, integer precision)
{
    if(hector == ZERO_VECTOR) 
    { 
       return "ZERO_VECTOR";
    } 
    else 
    {
        if (precision < 1) 
        { 
            precision = 1; 
        }   
        float roundingValue = llPow(10, -precision) * 0.5;
        float relx; 
        float rely;
        float relz;
        float elx;
        float ely;
        float elz;
        elx = hector.x;
        ely = hector.y;
        elz = hector.z;
        if (elx < 0) 
        {
            relx = elx - roundingValue;
        } 
        else 
        {
            relx = elx + roundingValue;
        }
        if (ely < 0) 
        {
            rely = ely - roundingValue;
        } 
        else 
        {
            rely = ely + roundingValue;
        }
        if (elz < 0) 
        {
            relz = elz - roundingValue;
        } 
        else 
        {
            relz = elz + roundingValue;
        }
        string result = "<"+llGetSubString((string)relx, 0, llSubStringIndex((string)relx, ".") + precision)+"," + llGetSubString((string)rely, 0, llSubStringIndex((string)rely, ".") + precision)+"," + llGetSubString((string)relz, 0, llSubStringIndex((string)relz, ".") + precision)+">";
        result = strReplace(result, ".000", ".0");
        result = strReplace(result, "00,", "0,");
        result = strReplace(result, "00>", "0>");
        return result;    
    }
}

default
{
    state_entry()
    {
        TEXTURE_NOTECARD = llGetInventoryName(INVENTORY_NOTECARD, INDEX = 0);
        if( ~llGetInventoryType(  TEXTURE_PREFIX + TEXTURE_NOTECARD ) ) NOTECARD_QUERY = llGetNotecardLine(TEXTURE_PREFIX + TEXTURE_NOTECARD, INDEX);
        TEXTURE_CHANNEL = (-1 * (integer)("0x"+llGetSubString((string)llGetKey(),-5,-1)) + 3);       
    }

    on_rez(integer start_param)
    {
        llResetScript();
    }
            
    link_message(integer sender, integer number, string message, key id)
    {
        if(message == "CHANNEL")
        {
           CHANNEL = number;
           CHANNEL_HANDLE = llListen(CHANNEL, "", NULL_KEY, "");
        }
        else if (number == TEXTURE_CHANNEL)
        {    
           list TEXTURE_VALUES = llParseString2List(message,["|"],[]);
           string PRIMITIZER_OBJECTNAME = llList2String(TEXTURE_VALUES,0);
           integer i = llGetNumberOfPrims();
           for (; i >= 0; --i)
           {
              if (llGetLinkName(i) == PRIMITIZER_OBJECTNAME)
              {
                 string TEXTURE_UID = llList2String(TEXTURE_VALUES,1);
                 float TEXTURE_GLOW = (float)llList2String(TEXTURE_VALUES,2);
                 integer TEXTURE_TEXGEN = (integer)llList2String(TEXTURE_VALUES,3);
                 integer TEXTURE_SHINY = (integer)llList2String(TEXTURE_VALUES,4);
                 integer TEXTURE_BUMP = (integer)llList2String(TEXTURE_VALUES,5);
                 vector TEXTURE_REPEATS = (vector)llList2String(TEXTURE_VALUES,6);
                 vector TEXTURE_OFFSETS = (vector)llList2String(TEXTURE_VALUES,7);
                 float TEXTURE_ROTATE = ((float)llList2String(TEXTURE_VALUES,8)) * DEG_TO_RAD;
                 vector TEXTURE_COLOR = (vector)llList2String(TEXTURE_VALUES,9);
                 float TEXTURE_ALPHA = (float)llList2String(TEXTURE_VALUES,10);

                 //texture change
                 llSetLinkPrimitiveParamsFast(i,[PRIM_TEXTURE,5,TEXTURE_UID,TEXTURE_REPEATS,TEXTURE_OFFSETS,TEXTURE_ROTATE]);
                 llSetLinkPrimitiveParamsFast(i,[PRIM_GLOW,5,TEXTURE_GLOW]);
                 llSetLinkPrimitiveParamsFast(i,[PRIM_BUMP_SHINY,5,TEXTURE_SHINY,TEXTURE_BUMP]); 
                 llSetLinkPrimitiveParamsFast(i,[PRIM_COLOR,5,TEXTURE_COLOR,TEXTURE_ALPHA]);
                 llSetLinkPrimitiveParamsFast(i,[PRIM_TEXGEN,5,TEXTURE_TEXGEN]);
              }
           }
        }
        else if (message == llToLower("TEXTURES") || message == llToUpper("TEXTURES"))
        {
            // list conversions
            integer i = llGetNumberOfPrims();
            for (; i >= 0; --i)
            {
                //list conversions
                string LOCATE_PRIM_UUID = llList2String(llGetLinkPrimitiveParams(i,[PRIM_TEXTURE,5]), 0);
                float LOCATE_PRIM_GLOW = (float)llList2String(llGetLinkPrimitiveParams(i,[PRIM_GLOW,5]),0);
                integer LOCATE_TEXTURE_TEXGEN = (integer)llList2String(llGetLinkPrimitiveParams(i,[PRIM_TEXGEN,5]),0);
                string LOCATE_TEXTURE_BUMP = llList2String([0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17] ,llList2Integer(llGetLinkPrimitiveParams(i,[PRIM_BUMP_SHINY,5]),1));
                string LOCATE_TEXTURE_SHINY = llList2String([0,1,2,3] ,llList2Integer(llGetLinkPrimitiveParams(i,[PRIM_BUMP_SHINY,5]),0));
                vector LOCATE_TEXTURE_REPEATS = (vector)llList2String(llGetLinkPrimitiveParams(i,[PRIM_TEXTURE,5]),1);
                vector LOCATE_TEXTURE_OFFSETS = (vector)llList2String(llGetLinkPrimitiveParams(i,[PRIM_TEXTURE,5]),2);
                float LOCATE_TEXTURE_ROTATE = (float)llList2String(llGetLinkPrimitiveParams(i,[PRIM_TEXTURE,5]),3) * RAD_TO_DEG;
                vector LOCATE_TEXTURE_COLOR = (vector)llList2String(llGetLinkPrimitiveParams(i,[PRIM_COLOR,5]),0);
                float LOCATE_TEXTURE_ALPHA = (float)llList2String(llGetLinkPrimitiveParams(i,[PRIM_COLOR,5]),1);
              
                // Primitizer Residential Links
                if( llGetLinkName(i) == "ese_wall" || llGetLinkName(i) == "south_wall" || llGetLinkName(i) == "west_wall" || 
                    llGetLinkName(i) == "north_wall" || llGetLinkName(i) == "ene_wall" || llGetLinkName(i) == "ene_door" || 
                    llGetLinkName(i) == "sw_floor" || llGetLinkName(i) == "nw_floor" || llGetLinkName(i) == "se_floor" || 
                    llGetLinkName(i) == "ne_floor" || llGetLinkName(i) == "ceiling")                 
                {
                    llSay(0, (string)llGetLinkName(i) + "|"+(string)LOCATE_PRIM_UUID + "|" + (string)FormatFloat(LOCATE_PRIM_GLOW, 3) + "|" + (string)LOCATE_TEXTURE_TEXGEN + "|" + (string)LOCATE_TEXTURE_SHINY + "|" + (string)LOCATE_TEXTURE_BUMP + "|" + (string)FormatVector(LOCATE_TEXTURE_REPEATS, 3) + "|" + (string)FormatVector(LOCATE_TEXTURE_OFFSETS, 3) + "|" + (string)FormatFloat(LOCATE_TEXTURE_ROTATE, 3) + "|" + (string)FormatVector(LOCATE_TEXTURE_COLOR, 3) + "|" + (string)FormatFloat(LOCATE_TEXTURE_ALPHA, 3));
                }
            }   
        }        
    }
    
    listen(integer channel, string name, key id, string message) 
    {
        NOTECARD_READ = llParseString2List(message, [" "], [""]);
        if(channel == channel)
        {
            if(llList2String(NOTECARD_READ, 0) == llToLower("TEXTURE") || llList2String(NOTECARD_READ, 0) == llToUpper("TEXTURE"))
            {
                TEXTURE_NOTECARD = llList2String(NOTECARD_READ, 1);
                if( ~llGetInventoryType(  TEXTURE_PREFIX + TEXTURE_NOTECARD ) )  NOTECARD_QUERY = llGetNotecardLine(TEXTURE_PREFIX + TEXTURE_NOTECARD, INDEX = 0);
            }        
        }
    }
    
    dataserver(key query_id, string data) 
    {
        if (query_id == NOTECARD_QUERY) 
        {
            if (data != EOF && TEXTURE_PREFIX == "tex_") 
            {
                llMessageLinked(LINK_THIS,TEXTURE_CHANNEL,data,NULL_KEY);               
                INDEX++;
                if( ~llGetInventoryType(  TEXTURE_PREFIX + TEXTURE_NOTECARD ) ) NOTECARD_QUERY = llGetNotecardLine(TEXTURE_PREFIX + TEXTURE_NOTECARD, INDEX);
            }
        }
    }
}