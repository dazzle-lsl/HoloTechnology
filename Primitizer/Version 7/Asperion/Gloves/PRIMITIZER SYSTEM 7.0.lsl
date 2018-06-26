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
// Configuration Options
///////////////////////////////////////////////////////////////////////////////
string  PRODUCT_NAME = "Primitizer Residential";
float LISTEN_TIME = 30.0;                  // How long to listen for a menu response before shutting down the listener
integer LISTEN_TIMEOUT = 0;
float TIMER_INTERVAL = 0.25;                 // How often (in seconds) to perform any timed checks
///////////////////////////////////////////////////////////////////////////////
// Primitizer Channel Handles
///////////////////////////////////////////////////////////////////////////////
integer DEFAULT_CHANNEL = -68191;                // channel used for saving
integer PRIMITIZER_CHANNEL = DEFAULT_CHANNEL;    // channel used by primitizer to talk to label scripts;
integer CONTROLLER_CHANNEL;
integer MENU_CHANNEL;
integer SENSOR_CHANNEL;
integer RANGE_CHANNEL;
integer CONTROLLER_HANDLE;
integer PRIMITIZER_HANDLE;
integer SENSOR_HANDLE;
integer RANGE_HANDLE;
integer DEFAULT_HANDLE;
integer MENU_HANDLE;
///////////////////////////////////////////////////////////////////////////////
// Primitizer Movement Handles
///////////////////////////////////////////////////////////////////////////////
integer BASE_MOVING;
vector LAST_POSITION;
rotation LAST_ROTATION;
///////////////////////////////////////////////////////////////////////////////
// Link Messages Variables
///////////////////////////////////////////////////////////////////////////////
integer PRIMITIZER_MENU = 20000;
integer API_MENU   = 20001;
integer API_OPTION_DATA = 20002;
integer API_MENU_LOADED = 20003;
integer API_RESET_MENU_SYSTEM = 20004;
integer API_READ_STRING = 20005;
integer API_READ_STRING_DATA = 20006;
integer API_CUSTOM_MENU   = 20007;
///////////////////////////////////////////////////////////////////////////////
// Menu System Variables
///////////////////////////////////////////////////////////////////////////////
integer ISACTIVE;
integer PAGE;
integer LINE;
integer INBOX;
string  NOTECARD = "users";
string  MENU_MESSAGE;
list    BUTTONS;
string  CURRENT_USERNAME;
key     CURRENT_USERKEY;
key     QUERY;
list    USERS;
///////////////////////////////////////////////////////////////////////////////
// Toggle System Variables
///////////////////////////////////////////////////////////////////////////////
integer TUTORIAL_TOGGLE;
integer SENSOR_TOGGLE;
integer SIM_TOGGLE;
///////////////////////////////////////////////////////////////////////////////
// Clean Scene When Avatar Not Present
///////////////////////////////////////////////////////////////////////////////
integer SENSOR_ENABLED = FALSE;
float SENSOR_TIME = 900.0;                  // How long to listen for a menu response before shutting down the listener
float SENSOR_RANGE = 96.0;
list SENSOR_DIALOG = [ "-", "0","enter","7","8","9","4","5","6","1","2","3"];
string SENSOR_INPUT = "";
string SENSOR_SIGN = "+";
string SENSOR_SIGN_INPUT = " ";
string SENSOR_CAPTION = "Enter a number, include any leading 0's: ";
list RANGE_DIALOG = [ "-", "0","enter","7","8","9","4","5","6","1","2","3"];
string RANGE_INPUT = "";
string RANGE_SIGN = "+";
string RANGE_SIGN_INPUT = " ";
string RANGE_CAPTION = "Enter a number, include any leading 0's: ";
///////////////////////////////////////////////////////////////////////////////
// Toggle Tutorial Messages
///////////////////////////////////////////////////////////////////////////////
integer TUTORIAL_CHATTY = TRUE; //Set to FALSE if you dont want the script to say anything while 'working'
///////////////////////////////////////////////////////////////////////////////
// Save Location Type
///////////////////////////////////////////////////////////////////////////////
// Set to TRUE to save piece's location based on sim coordinates instead of relationship to base prim
integer SIM_LOCATION = FALSE;
///////////////////////////////////////////////////////////////////////////////
// Primitizer Rezz Offset
///////////////////////////////////////////////////////////////////////////////
vector PRIMITIZER_OFFSET = <0.00, 0.00, 0.30>;
///////////////////////////////////////////////////////////////////////////////
// Prim Counter Variables
///////////////////////////////////////////////////////////////////////////////
integer PRIMITIZER_COUNTER = FALSE;
float COUNT_TIME = 5.0; // How long to listen for a prim count
integer COUNT_TIMEOUT = 0;
integer COUNT_PRIMS;
///////////////////////////////////////////////////////////////////////////////
// Primitizer Owner or Group Variables
///////////////////////////////////////////////////////////////////////////////
// The UUID of the creator of the object Leave this as "" unless SL displays wrong name in object properties
key OWNER_UUID = "";
///////////////////////////////////////////////////////////////////////////////
// Primitizer Menu Buttons
///////////////////////////////////////////////////////////////////////////////
string  BTN_CREATE = "*Create*";
string  BTN_NEXT = "Next ►";
string  BTN_BACK = "◄ Back";
string  BTN_OPTION = "● Option";
string  BTN_CLEAR = "*Clear*";
///////////////////////////////////////////////////////////////////////////////
// Tutorial Messages Variables
///////////////////////////////////////////////////////////////////////////////
string MSG_TEXTURES_NOTECARD = "// Generated By % (Paste each line into a notecard named tex_yourscene)";
string MSG_REGION_ENABLED = "Sim coordinates enabled";
string MSG_REGION_DISABLED = "Sim coordinates disabled";
string MSG_SENSOR_ENABLED = "Sensor enabled";
string MSG_SENSOR_DISABLED = "Sensor disabled";
string MSG_SENSOR_RANGE = "Range set to ";
string MSG_SENSOR_TIME = "Seconds set to ";
string MSG_TUTORIAL_ENABLED = "Tutorial mode enabled";
string MSG_TUTORIAL_DISABLED = "Tutorial mode disabled";
string MSG_EMPTY_INBOX = "No scenes in primitizer!";
string MSG_EDIT_SCENE = "Remove all label scripts and freeze objects in current position";
string MSG_CLEAR_SCENE = "Remove all objects and clear current scene";
string MSG_CREATE_SCENE = "Scene Create Message goes Here!";
string MSG_POSITION = "position the parts to a new location";
string MSG_SAVE_ABSOLUTE = "Saving absolute sim positions...";
string MSG_SAVE = "Saving relative prims positions...";
string MSG_MISSING_NOTECARD = "No Notecard by the name of ";
string MSG_CHANGED_INVENTORY = "Primitizer Ready";
string MSG_CHANGED_OWNER = "New Owner Detected, Resetting Primitizer Please Wait...";
string MSG_CHANGED_ALLOW_DROP = "New Scene Added, Updating Primitizer Scenes.";
string MSG_COUNT_PRIMS = "Scene Prims Used %";

primitizer_moved()
{
    llRegionSay(PRIMITIZER_CHANNEL, "MOVE " + llDumpList2String([ llGetPos(), llGetRot() ], "|"));
    llResetTime();
    LAST_POSITION = llGetPos();
    LAST_ROTATION = llGetRot();
    return;
}

rez_object(string inventory, vector position)
{           
    //Rez the object indicated by message
    llRezObject(inventory, llGetPos() + position, ZERO_VECTOR, llGetRot(), PRIMITIZER_CHANNEL);
}

scene_selection()
{
    if (INBOX == 0)
    {
        llDialog(CURRENT_USERKEY, MSG_EMPTY_INBOX, [], -1);
        return;   
    }
    integer ITEMS_PER_DLG = 10;
    integer LASTPAGE= llCeil((float)INBOX / (float)ITEMS_PER_DLG);
    if (PAGE > LASTPAGE)
    {
        PAGE = LASTPAGE;
    }
    if (PAGE < 1)
    {
        PAGE = 1;
    }
    BUTTONS = [];
    MENU_MESSAGE = "";
    integer i;
    integer MIN = (PAGE - 1) * ITEMS_PER_DLG;
    integer MAX = PAGE * ITEMS_PER_DLG;
    if (MAX >= INBOX)
    {
        MAX = INBOX;
    }
    for (i = MIN; i < MAX; ++i)
    {
        string item =  llGetInventoryName(INVENTORY_OBJECT, i);
        if (item != "")
        {
            BUTTONS += (string)item;
        }
    }
    if (PAGE == 1 && LASTPAGE > 1)
    {
        BUTTONS += [BTN_OPTION,BTN_NEXT];
    }
    if (PAGE == 1 && LASTPAGE == 1)
    {
        BUTTONS += BTN_OPTION;
    }
    if (PAGE > 1 && PAGE < LASTPAGE)
    {
        BUTTONS += [BTN_BACK,BTN_NEXT];
    }
    if (PAGE == LASTPAGE && PAGE != 1)
    {
        BUTTONS += BTN_BACK;
    }
    integer len = llGetListLength(BUTTONS);
    for (i = 0; i < len; i = i + 3)
    {
        BUTTONS = llListInsertList(llDeleteSubList(BUTTONS, -3, -1), llList2List(BUTTONS, -3, -1), i);
    }
    llDialog(CURRENT_USERKEY, MENU_MESSAGE + " ", BUTTONS, MENU_CHANNEL);
    llMessageLinked(LINK_THIS, PRIMITIZER_CHANNEL, "CHANNEL", NULL_KEY); 
}
 
integer IsAuthorized(string name)
{
    if (~llListFindList(USERS, [name]))
        return TRUE;
    return FALSE;
}
 
integer IsValidScene(string name)
{
    if (~llListFindList(BUTTONS, [name]))
        return TRUE;
    return FALSE;
}

string strReplace(string str, string search, string replace) {
    return llDumpList2String(llParseStringKeepNulls((str = "") + str, [search], []), replace);
}

InvertSign()
{
    if(SENSOR_SIGN == "+") SENSOR_SIGN = "-"; else SENSOR_SIGN = "+";
    if(RANGE_SIGN == "+") RANGE_SIGN = "-"; else RANGE_SIGN = "+";
}
                                                            
default 
{
    changed(integer change) 
    {
        if (change & CHANGED_INVENTORY) 
        {
            if(TUTORIAL_CHATTY) llSay(0, MSG_CHANGED_INVENTORY);
            llResetScript();
        } 
        if (change & CHANGED_OWNER) 
        { 
            if(TUTORIAL_CHATTY) llSay(0, MSG_CHANGED_OWNER);
            llResetScript(); 
        }
        if (change & CHANGED_ALLOWED_DROP) 
        { 
            if(TUTORIAL_CHATTY) llSay(0, MSG_CHANGED_ALLOW_DROP);
            llResetScript(); 
        }
    }
     
    state_entry () 
    {   
        PRIMITIZER_CHANNEL = (integer)llFloor(llFrand(-99999.0 - -100));
        
        // Open Controller Listen Handle
        DEFAULT_HANDLE = llListen(DEFAULT_CHANNEL, "", NULL_KEY, "");
        
        // Open Primitizer Listen Handle
        PRIMITIZER_HANDLE = llListen(PRIMITIZER_CHANNEL, "", NULL_KEY, "");        
        
        MENU_CHANNEL = ( -1 * (integer)("0x"+llGetSubString((string)llGetKey(),-5,-1)) );
        
        if(OWNER_UUID == "") OWNER_UUID = llGetOwner();
        if(PRODUCT_NAME == "") PRODUCT_NAME = llGetObjectName();

        ISACTIVE = FALSE;
        INBOX = llGetInventoryNumber(INVENTORY_OBJECT);
        LINE = 0;
        PAGE = 1;
        
        if (llGetInventoryKey(NOTECARD) != NULL_KEY)
        {
            QUERY = llGetNotecardLine(NOTECARD, LINE);
        }
        else
        {
            llOwnerSay(MSG_MISSING_NOTECARD + NOTECARD);
        }
               
        LAST_POSITION = llGetPos();
        LAST_ROTATION = llGetRot(); 

        llSetTimerEvent(TIMER_INTERVAL);
    }
                   
    link_message(integer sender_number, integer number, string message, key id)
    {
        if(number == PRIMITIZER_MENU) 
        {
            if(id != OWNER_UUID && !IsAuthorized(llKey2Name(id)) || id != OWNER_UUID &&  !llSameGroup(id) == FALSE)
            {
                return;
            }
            if (!ISACTIVE || id == CURRENT_USERKEY || llSameGroup(id) == TRUE)
            {
                LISTEN_TIMEOUT = llGetUnixTime() + llFloor(LISTEN_TIME);
                ISACTIVE = TRUE;
                MENU_HANDLE = llListen(MENU_CHANNEL, "", id, "");
                CURRENT_USERKEY = id;
                CURRENT_USERNAME = llKey2Name(id);
                PAGE = 1;
                scene_selection();
            }
        }
        if (number == API_OPTION_DATA)
        {
            list command = llParseString2List(message, ["|"], [""]);             
            if( llToUpper(llList2String(command, 0)) == "BUILD" )
            {
                if ( llToUpper(llList2String(command, 1)) == "EDIT" )
                {
                    if(TUTORIAL_CHATTY) llSay(0, MSG_EDIT_SCENE);
                    llRegionSay(PRIMITIZER_CHANNEL, "FINISH");
                    return;
                }
                if ( llToUpper(llList2String(command, 1)) == "POSITION" )
                {
                     if(TUTORIAL_CHATTY) llSay(0, MSG_POSITION);
                     llRegionSay(PRIMITIZER_CHANNEL, "MOVE " + llDumpList2String([ (vector)llGetPos(), (rotation)llGetRot() ], "|"));
                     return;
                }           
                if ( llToUpper(llList2String(command, 1)) == "RESET" )
                {
                    if(TUTORIAL_CHATTY) llSay(0, "Forgetting Positions...");
                    llRegionSay(PRIMITIZER_CHANNEL, "DELETE" );
                    return;
                }
                if ( llToUpper(llList2String(command, 1)) == "SAVE" )
                {
                    if(SIM_LOCATION) 
                    {
                        if(TUTORIAL_CHATTY) llSay(0, MSG_SAVE_ABSOLUTE);
                        llRegionSay(DEFAULT_CHANNEL, "SAVED_ABSOLUTE " + llDumpList2String([ llGetPos(), llGetRot() ], "|"));
                        return;
                    }
                    else
                    {
                        if(TUTORIAL_CHATTY) llSay(0, MSG_SAVE);
                        llRegionSay(DEFAULT_CHANNEL, "SAVED " + llDumpList2String([ llGetPos(), llGetRot() ], "|"));
                        return;
                    }
                }                
            }
            if( llToUpper(llList2String(command, 0)) == "NOTECARD" )
            {
                if (llToUpper(llList2String(command, 1)) == "TEXTURES" )
                {
                    llInstantMessage(id, strReplace(MSG_TEXTURES_NOTECARD,"%",PRODUCT_NAME));
                    llMessageLinked(LINK_THIS, 0, "TEXTURES", id);
                    return;
                }                
            }
            if ( llList2String(command, 0) == "SENSOR")
            {
                if(llToUpper(llList2String(command, 1)) == "TOGGLE")
                {
                    SENSOR_TOGGLE = !SENSOR_TOGGLE;
                    if(TRUE == SENSOR_TOGGLE)
                    {
                        llSay(0, MSG_SENSOR_ENABLED);
                        SENSOR_ENABLED = TRUE;
                        llSensorRepeat("", "", AGENT, SENSOR_RANGE, PI, SENSOR_TIME);
                        return;
                    }
                    else
                    {
                        llSay(0, MSG_SENSOR_DISABLED);
                        SENSOR_ENABLED = FALSE;
                        llSensorRemove();
                        return;
                    }
                }
                if (llToUpper(llList2String(command, 1)) == "SENSOR RANGE")
                {
                    RANGE_CHANNEL = ( -1 * (integer)("0x"+llGetSubString((string)id,-5,-1)) + 1);
                    RANGE_SIGN = "+"; //default is a positive number
                    RANGE_INPUT = "";
                    RANGE_HANDLE = llListen(RANGE_CHANNEL, "", id, "");
                    llDialog( id, RANGE_CAPTION, RANGE_DIALOG, RANGE_CHANNEL );
                }
                if (llToUpper(llList2String(command, 1)) == "SENSOR TIME")
                {
                    SENSOR_CHANNEL = ( -1 * (integer)("0x"+llGetSubString((string)id,-5,-1)) + 2);
                    SENSOR_SIGN = "+"; //default is a positive number
                    SENSOR_INPUT = "";
                    SENSOR_HANDLE = llListen(SENSOR_CHANNEL, "", id, "");
                    llDialog( id, SENSOR_CAPTION, SENSOR_DIALOG, SENSOR_CHANNEL );
                }                                
            }              
            if ( llList2String(command, 0) == "SETTINGS")
            {
                if(llToUpper(llList2String(command, 1)) == "COUNT")
                {
                    llRegionSay(PRIMITIZER_CHANNEL, "GETPRIMS");
                    return;
                }
                if(llToUpper(llList2String(command, 1)) == "REGION")
                {
                    SIM_TOGGLE = !SIM_TOGGLE;
                    if(TRUE == SIM_TOGGLE)
                    {
                        if(TUTORIAL_CHATTY) llSay(0, MSG_REGION_ENABLED);
                        SIM_LOCATION = TRUE;
                        return;
                    }
                    else
                    {
                        if(TUTORIAL_CHATTY) llSay(0, MSG_REGION_DISABLED);
                        SIM_LOCATION = FALSE;
                        return;
                    }
                }
                if(llToUpper(llList2String(command, 1)) == "TUTORIAL")
                {
                    TUTORIAL_TOGGLE = !TUTORIAL_TOGGLE;
                    if(TRUE == TUTORIAL_TOGGLE)
                    {
                        llSay(0, MSG_TUTORIAL_ENABLED);
                        TUTORIAL_CHATTY = TRUE;
                        return;
                    }
                    else
                    {
                        llSay(0, MSG_TUTORIAL_DISABLED);
                        TUTORIAL_CHATTY = FALSE;
                        return;
                    }
                }                               
            } 
        }            
    }
    
    listen(integer channel, string name, key id, string message) 
    {
        list command = llParseString2List(message, ["|"], [""]);
        list counter = llParseString2List(message, [" "], [""]);
        if( channel == DEFAULT_CHANNEL )
        {
            if( llList2String(command, 0) == "CHANNEL")
            {
                CONTROLLER_CHANNEL = (integer)llList2String(command, 1);
                CONTROLLER_HANDLE = llListen(CONTROLLER_CHANNEL, "", NULL_KEY, "");
            }                        
        }
        if( channel == PRIMITIZER_CHANNEL )
        {
            if( llList2String(counter, 0) == "PRIMS")
            {
                PRIMITIZER_COUNTER = TRUE;
                COUNT_TIMEOUT = llGetUnixTime() + llFloor(COUNT_TIME);
                COUNT_PRIMS += (integer)llList2String(counter, 1);
            }
        }        
        if( channel == CONTROLLER_CHANNEL )
        {            
            if( llList2String(command, 0) == "DIALOG")
            {
                llMessageLinked(LINK_THIS, PRIMITIZER_MENU, llList2String(command, 1), (key)llList2String(command, 2));
                return;
            }
        }
        if( channel == MENU_CHANNEL )
        {
            if (message == BTN_CREATE && IsValidScene(BTN_CREATE))
            {
                if(TUTORIAL_CHATTY) llSay(0, MSG_CREATE_SCENE);
                rez_object(message, PRIMITIZER_OFFSET);
                return;
            }
            if (message == BTN_CLEAR && IsValidScene(BTN_CLEAR))
            {
                if(TUTORIAL_CHATTY) llSay(0, MSG_CLEAR_SCENE);
                rez_object(message, PRIMITIZER_OFFSET);
                return;
            }
            if (message == BTN_OPTION && IsValidScene(BTN_OPTION))
            {
                llMessageLinked(LINK_THIS, API_MENU, "DEFAULT", id);
                return;
            }          
            if (message == BTN_NEXT && IsValidScene(BTN_NEXT))
            {
                ++PAGE;
                scene_selection();
                return;
            }
            if (message == BTN_BACK)
            {
                --PAGE;
                scene_selection();
                return;
            }
            if (IsValidScene(message))
            {
                if (message != "" && message != NOTECARD)
                {
                    if (id != OWNER_UUID)
                    {
                        integer owner_permission = llGetInventoryPermMask(message, MASK_OWNER);
                        if (owner_permission & PERM_TRANSFER)
                        {
                            rez_object(message, PRIMITIZER_OFFSET);
                        }
                    }
                    else
                    {
                        rez_object(message, PRIMITIZER_OFFSET);
                    }
                }
            }
        }
        if( channel == SENSOR_CHANNEL )
        {
            if ( llListFindList( SENSOR_DIALOG, [ message ]) != -1 ) 
            {
                if( llListFindList(["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"], [message]) != -1) 
                {
                    SENSOR_INPUT += message;
                    SENSOR_SIGN_INPUT = SENSOR_SIGN + SENSOR_INPUT;
                    llDialog( id, SENSOR_CAPTION + SENSOR_SIGN_INPUT, SENSOR_DIALOG, SENSOR_CHANNEL );
                } 
                else if( message == "-" ) 
                {
                    InvertSign();
                    SENSOR_SIGN_INPUT = SENSOR_SIGN + SENSOR_INPUT;
                    llDialog( id, SENSOR_CAPTION + SENSOR_SIGN_INPUT, SENSOR_DIALOG, SENSOR_CHANNEL );
                } 
                else if( message == "enter" ) 
                {
                    string SENSOR_CALCULATE = SENSOR_INPUT;
                    SENSOR_TIME = (float)SENSOR_CALCULATE * 60;
                    llOwnerSay(MSG_SENSOR_TIME + (string)SENSOR_TIME);
                }
 
            } 
            else 
            {
                llDialog( id, SENSOR_CAPTION, SENSOR_DIALOG, SENSOR_CHANNEL );
            }
        }
        if( channel == RANGE_CHANNEL )
        {
            if ( llListFindList( RANGE_DIALOG, [ message ]) != -1 ) 
            {
                if( llListFindList(["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"], [message]) != -1) 
                {
                    RANGE_INPUT += message;
                    RANGE_SIGN_INPUT = RANGE_SIGN + RANGE_INPUT;
                    llDialog( id, RANGE_CAPTION + RANGE_SIGN_INPUT, RANGE_DIALOG, RANGE_CHANNEL );
                } 
                else if( message == "-" ) 
                {
                    InvertSign();
                    RANGE_SIGN_INPUT = RANGE_SIGN + RANGE_INPUT;
                    llDialog( id, RANGE_CAPTION + RANGE_SIGN_INPUT, RANGE_DIALOG, RANGE_CHANNEL );
                } 
                else if( message == "enter" ) 
                {
                    string RANGE_CALCULATE = RANGE_INPUT;
                    SENSOR_RANGE = (float)RANGE_CALCULATE;
                    llOwnerSay(MSG_SENSOR_RANGE + (string)SENSOR_RANGE);
                }
 
            } 
            else 
            {
                llDialog( id, RANGE_CAPTION, RANGE_DIALOG, RANGE_CHANNEL );
            }
        }          
    }
            
    moving_start()
    {
        if( !BASE_MOVING )
        {
            BASE_MOVING = TRUE;
            primitizer_moved();
        }
    }
 
    timer() 
    {
        if( (llGetRot() != LAST_ROTATION) || (llGetPos() != LAST_POSITION) )
        {
            if( llGetTime() > TIMER_INTERVAL ) 
            {
                primitizer_moved();
            }
        }
        //Open listener?
        if( LISTEN_TIMEOUT != 0 )
        {
            //Past our close timeout?
            if( LISTEN_TIMEOUT <= llGetUnixTime() )
            {
                LISTEN_TIMEOUT = 0;
                ISACTIVE = FALSE;
                CURRENT_USERNAME = "";
                CURRENT_USERKEY = NULL_KEY;                
                llListenRemove(MENU_HANDLE);
                llListenRemove(SENSOR_HANDLE);
                llListenRemove(RANGE_HANDLE);
            }
        }
        if( COUNT_TIMEOUT != 0 )
        {
            //Past our close timeout?
            if( COUNT_TIMEOUT <= llGetUnixTime() && PRIMITIZER_COUNTER)
            {
                if(PRIMITIZER_COUNTER)
                {
                    llSay(0, strReplace(MSG_COUNT_PRIMS, "%", (string)COUNT_PRIMS));
                    PRIMITIZER_COUNTER = FALSE;
                    COUNT_TIMEOUT = 0;
                }               
            }
        }
    }
    
    dataserver(key query_id, string data)
    {
        if (query_id == QUERY)
        {
            if (data != EOF)
            {
                data = llStringTrim(data,STRING_TRIM);
                if (data != "\n" && data != "")
                USERS += data;
                ++LINE;
                QUERY = llGetNotecardLine(NOTECARD, LINE);
            }
            else
            {
                llOwnerSay("No more lines in "+NOTECARD+", read " + (string)LINE + " lines.");
            }
        }                
    }
    
    no_sensor()
    {
        if(SENSOR_ENABLED) rez_object(BTN_CLEAR, PRIMITIZER_OFFSET);
    }            
}