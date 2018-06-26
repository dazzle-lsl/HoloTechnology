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
integer LIGHT_CHANNEL;
integer CHANNEL_HANDLE;
///////////////////////////////////////////////////////////////////////////////
// Inventory Index Variables
///////////////////////////////////////////////////////////////////////////////
integer INDEX;
///////////////////////////////////////////////////////////////////////////////
// Notecard System Variables
///////////////////////////////////////////////////////////////////////////////
list NOTECARD_READ;
string LIGHT_NOTECARD;
string LIGHT_PREFIX = "light_";
key LIGHT_QUERY;
///////////////////////////////////////////////////////////////////////////////
// Lighting System Variables
///////////////////////////////////////////////////////////////////////////////
string PRIMITIZER_OBJECTNAME;
list LIGHT_VALUES;
integer LIGHT_STATUS;
vector LIGHT_COLOR;             // Color of the light (RGB - each value between 0.0 and 1.0)
float LIGHT_LEVEL;             // Intensity of the light (values from 0.0 .. 1.0)
float LIGHT_DISTANCE;          // Radius of light cone
float LIGHT_FALLOFF;           // Fall off (distance/intensity decrease) values from 0.0 ..1.0


string strReplace(string str, string search, string replace) {
    return llDumpList2String(llParseStringKeepNulls((str = "") + str, [search], []), replace);
}
 
string FormatFloat(float number, integer precision)
{    
    float roundingValue = llPow(10, -precision)*0.5;
    float rounded;
    if (number < 0) rounded = number - roundingValue;
    else            rounded = number + roundingValue;
 
    if (precision < 1) { precision = 1; }       // float is float 
 
    string result = llGetSubString((string)rounded, 0, llSubStringIndex((string)rounded, ".") + precision);
    result = strReplace(result, ".000", ".0");
    result = strReplace(result, "00,", "0,");
    return result;
}
 
string FormatVector(vector hector, integer precision)
{
    if(hector == ZERO_VECTOR) { return "ZERO_VECTOR";} else {
    if (precision < 1) { precision = 1; }       // a vector contains floats   
    float roundingValue = llPow(10, -precision)*0.5;
    float relx; float rely; float relz; float elx; float ely; float elz;
    elx = hector.x; ely = hector.y; elz = hector.z;
 
    if (elx < 0) {relx = elx - roundingValue;} else {relx = elx + roundingValue;}
    if (ely < 0) {rely = ely - roundingValue;} else {rely = ely + roundingValue;}
    if (elz < 0) {relz = elz - roundingValue;} else {relz = elz + roundingValue;}
 
    string result = "<"+llGetSubString((string)relx, 0, llSubStringIndex((string)relx, ".") + precision)+","+
                llGetSubString((string)rely, 0, llSubStringIndex((string)rely, ".") + precision)+","+
                llGetSubString((string)relz, 0, llSubStringIndex((string)relz, ".") + precision)+">";
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
        LIGHT_NOTECARD = llGetInventoryName(INVENTORY_NOTECARD, INDEX = 0);
        if( ~llGetInventoryType(  LIGHT_PREFIX + LIGHT_NOTECARD ) ) LIGHT_QUERY = llGetNotecardLine(LIGHT_PREFIX + LIGHT_NOTECARD, INDEX);
        LIGHT_CHANNEL = (-1 * (integer)("0x"+llGetSubString((string)llGetKey(),-5,-1)) + 2);
    }
    
    on_rez(integer start_param)
    {
        llResetScript();
    }
    
    link_message(integer sent,integer num,string message,key id)
    {
        list command = llParseString2List(message,["|"],[]);
        if(message == "CHANNEL")
        {
            CHANNEL = num;
            CHANNEL_HANDLE = llListen(CHANNEL, "", NULL_KEY, "");
        } 
        else if (num == LIGHT_CHANNEL)
        {
            LIGHT_VALUES = llParseString2List(message, ["|"], []);
            PRIMITIZER_OBJECTNAME = llList2String(LIGHT_VALUES,0);
            string self = llGetObjectName();
            integer i = llGetNumberOfPrims();
            for (; i >= 0; --i)
            {
                if (llGetLinkName(i) == PRIMITIZER_OBJECTNAME)
                {
                   //list conversions
                   LIGHT_STATUS = (integer)llList2String(LIGHT_VALUES,1);
                   LIGHT_COLOR = (vector)llList2String(LIGHT_VALUES,2);
                   LIGHT_LEVEL = (float)llList2String(LIGHT_VALUES,3);
                   LIGHT_DISTANCE = (float)llList2String(LIGHT_VALUES,4);
                   LIGHT_FALLOFF = (float)llList2String(LIGHT_VALUES,5);

                   // Lighting Change
                   llSetLinkPrimitiveParamsFast(i, [PRIM_POINT_LIGHT, LIGHT_STATUS, LIGHT_COLOR, LIGHT_LEVEL, LIGHT_DISTANCE, LIGHT_FALLOFF]);
                }
            }
        }
        else if ( message == llToUpper("LIGHTS"))
        {
            integer i = llGetNumberOfPrims();
            for (; i >= 0; --i)
            {
                // list conversions
                list LOCATE_PRIM_POINT_LIGHT =  llGetLinkPrimitiveParams(i, [PRIM_POINT_LIGHT]);
                list LOCATE_STATUS = (["0","1"]);
                vector LIGHT_COLOR;
    
                // output the notecard to chat
                if( llGetLinkName(i) == "ese_wall" || llGetLinkName(i) == "south_wall" || llGetLinkName(i) == "west_wall" || llGetLinkName(i) == "north_wall" || llGetLinkName(i) == "ene_wall" || llGetLinkName(i) == "ene_door" || llGetLinkName(i) == "sw_floor" || llGetLinkName(i) == "nw_floor" || llGetLinkName(i) == "se_floor" || llGetLinkName(i) == "ne_floor" || llGetLinkName(i) == "ceiling")
                {
                    llSay(0, (string)llGetLinkName(i) + "|" +(string)llList2String(LOCATE_STATUS ,llList2Integer(LOCATE_PRIM_POINT_LIGHT,0)) + "|" +(string)FormatVector(llList2Vector(LOCATE_PRIM_POINT_LIGHT,1),3) + "|"+(string)FormatFloat(llList2Float(LOCATE_PRIM_POINT_LIGHT,2),3) + "|"+(string)FormatFloat(llList2Float(LOCATE_PRIM_POINT_LIGHT,3),3) + "|"+(string)FormatFloat(llList2Float(LOCATE_PRIM_POINT_LIGHT,4),3));
                    LOCATE_PRIM_POINT_LIGHT = [];
                }
            }
        }        
    }
                       
    listen(integer channel, string name, key id, string message) 
    {
        NOTECARD_READ = llParseString2List(message, [" "], [""]);
        if(channel == CHANNEL)
        {
            if( llList2String(NOTECARD_READ, 0) == llToLower("LIGHTS") || llList2String(NOTECARD_READ, 0) == llToUpper("LIGHTS") )
            {
                LIGHT_NOTECARD = llList2String(NOTECARD_READ, 1);
                if( ~llGetInventoryType(  LIGHT_PREFIX + LIGHT_NOTECARD ) )  LIGHT_QUERY = llGetNotecardLine(LIGHT_PREFIX + LIGHT_NOTECARD, INDEX = 0);
            }
        }
    }
    
    dataserver(key query_id, string data) 
    {
        if (query_id == LIGHT_QUERY) 
        {
            if (data != EOF && LIGHT_PREFIX == "light_") 
            {
                llMessageLinked(LINK_THIS,LIGHT_CHANNEL, data, NULL_KEY);               
                INDEX++;
                if( ~llGetInventoryType(  LIGHT_PREFIX + LIGHT_NOTECARD ) ) LIGHT_QUERY = llGetNotecardLine(LIGHT_PREFIX + LIGHT_NOTECARD, INDEX);
            }
        }
    }            
}