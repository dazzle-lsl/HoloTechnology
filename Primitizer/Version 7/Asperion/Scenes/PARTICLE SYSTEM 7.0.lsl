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
integer PARTICLE_CHANNEL;
///////////////////////////////////////////////////////////////////////////////
// Inventory Index Variables
///////////////////////////////////////////////////////////////////////////////
integer INDEX;
///////////////////////////////////////////////////////////////////////////////
// Notecard System Variables
///////////////////////////////////////////////////////////////////////////////
string PARTICLE_NOTECARD;
string PARTICLE_PREFIX = "psys_";
key PARTICLE_QUERY;
///////////////////////////////////////////////////////////////////////////////
// Particle System Variables
///////////////////////////////////////////////////////////////////////////////
integer PARTICLE_PART_FLAGS;
list PARTICLE_VALUES;
key PARTICLE_SRC_TARGET_KEY = "";
string PARTICLE_SRC_TEXTURE = "";
float PARTICLE_SRC_MAX_AGE;
float PARTICLE_PART_MAX_AGE;
float PARTICLE_SRC_BURST_RATE;
integer PARTICLE_SRC_BURST_PART_COUNT;
float PARTICLE_SRC_BURST_RADIUS;
float PARTICLE_SRC_BURST_SPEED_MAX;
float PARTICLE_SRC_BURST_SPEED_MIN;
float PARTICLE_PART_START_ALPHA;
float PARTICLE_PART_END_ALPHA;
float PARTICLE_SRC_ANGLE_BEGIN;
float PARTICLE_SRC_ANGLE_END;
vector PARTICLE_PART_START_COLOR;
vector PARTICLE_PART_END_COLOR;
vector PARTICLE_PART_START_SCALE;
vector PARTICLE_PART_END_SCALE;
vector PARTICLE_SRC_ACCEL;
vector PARTICLE_SRC_OMEGA;
integer PARTICLE_SRC_PATTERN;

default
{
    
    state_entry()
    {
        PARTICLE_NOTECARD = llGetInventoryName(INVENTORY_NOTECARD, INDEX = 0);
        if( ~llGetInventoryType(  PARTICLE_PREFIX + PARTICLE_NOTECARD ) ) PARTICLE_QUERY = llGetNotecardLine(PARTICLE_PREFIX + PARTICLE_NOTECARD, INDEX);
        PARTICLE_CHANNEL = (-1 * (integer)("0x"+llGetSubString((string)llGetKey(),-5,-1)) + 1);
    }
    
    on_rez(integer start_param)
    {
        llResetScript();
    }
            
    link_message(integer sent,integer number,string message,key id)
    {
        if(message == "CHANNEL")
        {
           CHANNEL = number;
           CHANNEL_HANDLE = llListen(CHANNEL, "", NULL_KEY, "");
        }
        else if (number == PARTICLE_CHANNEL)
        {
           PARTICLE_VALUES = llParseString2List(message,["|"],[]);
           integer i = llGetNumberOfPrims();
           for (; i >= 0; --i)
           {
              if (llGetLinkName(i) == llList2String(PARTICLE_VALUES,0))
              {
                 //list conversions 
                 PARTICLE_PART_FLAGS = (integer)llList2String(PARTICLE_VALUES,1);
                 PARTICLE_PART_START_SCALE = (vector)llList2String(PARTICLE_VALUES,2);            
                 PARTICLE_PART_END_SCALE = (vector)llList2String(PARTICLE_VALUES,3);
                 PARTICLE_PART_START_COLOR = (vector)llList2String(PARTICLE_VALUES,4);
                 PARTICLE_PART_END_COLOR = (vector)llList2String(PARTICLE_VALUES,5);
                 PARTICLE_PART_START_ALPHA = (float)llList2String(PARTICLE_VALUES,6);
                 PARTICLE_PART_END_ALPHA = (float)llList2String(PARTICLE_VALUES,7);
                 PARTICLE_SRC_PATTERN = (integer)llList2String(PARTICLE_VALUES,8);
                 PARTICLE_SRC_BURST_RATE = (float)llList2String(PARTICLE_VALUES,9);
                 PARTICLE_SRC_BURST_PART_COUNT = (integer)llList2String(PARTICLE_VALUES,10);
                 PARTICLE_SRC_BURST_RADIUS = (float)llList2String(PARTICLE_VALUES,11);
                 PARTICLE_SRC_BURST_SPEED_MIN = (float)llList2String(PARTICLE_VALUES,12);            
                 PARTICLE_SRC_BURST_SPEED_MAX = (float)llList2String(PARTICLE_VALUES,13);
                 PARTICLE_SRC_ANGLE_BEGIN = (float)llList2String(PARTICLE_VALUES,14);
                 PARTICLE_SRC_ANGLE_END = (float)llList2String(PARTICLE_VALUES,15);
                 PARTICLE_SRC_OMEGA = (vector)llList2String(PARTICLE_VALUES,16);
                 PARTICLE_SRC_ACCEL = (vector)llList2String(PARTICLE_VALUES,17);
                 PARTICLE_PART_MAX_AGE = (float)llList2String(PARTICLE_VALUES,18);
                 PARTICLE_SRC_MAX_AGE = (float)llList2String(PARTICLE_VALUES,19);
                 if(llList2String(PARTICLE_VALUES,20) == "NULL_KEY")
                 {
                     PARTICLE_SRC_TEXTURE = "";
                 }
                 else
                 {
                     PARTICLE_SRC_TEXTURE = llList2String(PARTICLE_VALUES,20);
                 }
                 if(llList2String(PARTICLE_VALUES,21) == "self")
                 {
                     PARTICLE_SRC_TARGET_KEY = llGetKey();
                 }
                 else if(llList2String(PARTICLE_VALUES,21) == "owner")
                 {
                     PARTICLE_SRC_TARGET_KEY = llGetOwner();
                 }
                 else
                 {
                    PARTICLE_SRC_TARGET_KEY = (key)llList2String(PARTICLE_VALUES,21);
                 } 
                 // Particle Change 
                 llLinkParticleSystem(i, [  
                             PSYS_PART_MAX_AGE, PARTICLE_PART_MAX_AGE,
                             PSYS_PART_FLAGS, PARTICLE_PART_FLAGS,
                             PSYS_PART_START_COLOR, PARTICLE_PART_START_COLOR,
                             PSYS_PART_END_COLOR, PARTICLE_PART_END_COLOR,
                             PSYS_PART_START_SCALE, PARTICLE_PART_START_SCALE,
                             PSYS_PART_END_SCALE, PARTICLE_PART_END_SCALE,
                             PSYS_SRC_PATTERN, PARTICLE_SRC_PATTERN,
                             PSYS_SRC_BURST_RATE,PARTICLE_SRC_BURST_RATE,
                             PSYS_SRC_ACCEL,PARTICLE_SRC_ACCEL,
                             PSYS_SRC_BURST_PART_COUNT,PARTICLE_SRC_BURST_PART_COUNT,
                             PSYS_SRC_BURST_RADIUS,PARTICLE_SRC_BURST_RADIUS,
                             PSYS_SRC_BURST_SPEED_MIN,PARTICLE_SRC_BURST_SPEED_MIN,
                             PSYS_SRC_BURST_SPEED_MAX,PARTICLE_SRC_BURST_SPEED_MAX,
                             PSYS_SRC_ANGLE_BEGIN,PARTICLE_SRC_ANGLE_BEGIN,
                             PSYS_SRC_ANGLE_END,PARTICLE_SRC_ANGLE_END,
                             PSYS_SRC_OMEGA,PARTICLE_SRC_OMEGA,
                             PSYS_SRC_MAX_AGE,PARTICLE_SRC_MAX_AGE,
                             PSYS_PART_START_ALPHA,PARTICLE_PART_START_ALPHA,
                             PSYS_PART_END_ALPHA,PARTICLE_PART_END_ALPHA,
                             PSYS_SRC_TEXTURE, PARTICLE_SRC_TEXTURE,
                             PSYS_SRC_TARGET_KEY,(key)PARTICLE_SRC_TARGET_KEY 
                               ]);                               
              }                        
           }            
        }
    }
    
    listen(integer channel, string name, key id, string message) 
    {
        list NOTECARD_READ = llParseString2List(message, [" "], [""]);
        if(channel == channel)
        {
            if( llList2String(NOTECARD_READ, 0) == llToUpper("PARTICLES") )
            {
                PARTICLE_NOTECARD = llList2String(NOTECARD_READ, 1);
                if( ~llGetInventoryType(  PARTICLE_PREFIX + PARTICLE_NOTECARD ) )  PARTICLE_QUERY = llGetNotecardLine(PARTICLE_PREFIX + PARTICLE_NOTECARD, INDEX = 0);
            }
        }
    }
    
    dataserver(key query_id, string data) 
    {
        if (query_id == PARTICLE_QUERY) 
        {
            if (data != EOF && PARTICLE_PREFIX == "psys_") 
            {
                llMessageLinked(LINK_THIS,PARTICLE_CHANNEL, data, NULL_KEY);               
                ++INDEX;
                if( ~llGetInventoryType(  PARTICLE_PREFIX + PARTICLE_NOTECARD ) ) PARTICLE_QUERY = llGetNotecardLine(PARTICLE_PREFIX + PARTICLE_NOTECARD, INDEX);
            }
        }
    }                 
}