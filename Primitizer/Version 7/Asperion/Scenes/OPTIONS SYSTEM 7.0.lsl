///////////////////////////////////////////////////////////////////////////////
// Dazzle Software - Dialog API Version (1.0)
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

integer api_debug = FALSE;

integer api_menu   = 10001;
integer api_option_data = 10002;
integer api_menu_loaded = 10003;
integer api_reset_menu_system = 10004;
integer api_read_string = 10005;
integer api_read_string_data = 10006;
integer api_custom_menu   = 10007;

integer api_menu_listen = 1;

string api_notecard = "~menu";

integer api_notecard_line;
key api_query;

integer mc_tomenu = 1;
integer mc_option = 2;
integer mc_option_ask = 3;

integer menu_number;
list menu_data;
list menu_offsets;
integer menu_size = 4;

string cl_menu_id;
list cl_buttons;
list cl_actions;
string cl_menu_text;

string current_menu_name;
integer current_menu_number;
list current_buttons;
list current_actions;
integer current_menu_type;
integer current_sender_id;
integer current_offset; // current menu start offset
key current_user; // current user

integer base_channel;

integer handle_1;
integer handle_2;

integer is_listening = FALSE;
float response_timeout = 60.0;

integer mt_normal = 1;
integer mt_ask = 2;
integer mt_readstring = 3;
integer mt_custom = 4;

DebugSay( string message ) {
    llSay(DEBUG_CHANNEL, message);
}

MessageSender( integer num, string msg ) {
    if (api_debug) DebugSay("Emit MSG: chn#"+(string)num+" : "+msg);
    llMessageLinked(llGetLinkNumber(),num,msg,current_user);
}
MessageGlobal( integer num ) {
    if (api_debug) DebugSay("Emit MSG Global: chn#"+(string)num+" : ");
    llMessageLinked(llGetLinkNumber(),num,"",NULL_KEY);
}

// read data
ReadConfig() {
    menu_number = 0;
    menu_data = [];
    menu_offsets = [];
    cl_menu_id = "";
    cl_buttons = [];
    cl_actions = [];
    cl_menu_text = "";
    api_notecard_line = 1;
    api_query = llGetNotecardLine( api_notecard, api_notecard_line - 1 ); // request first line
}

commitEntry() {
    // [ menuID, startOffset, startOffsetActions, endOffset ]
    integer sofs = llGetListLength(menu_data);
    menu_offsets += [ cl_menu_id, sofs, sofs + 1 + llGetListLength(cl_buttons), sofs + 1 + llGetListLength(cl_buttons) + llGetListLength(cl_actions) ];
    menu_data += [ cl_menu_text ];
    menu_data += cl_buttons;
    menu_data += cl_actions;
    
    cl_menu_id = "";
    cl_menu_text = "";
    cl_buttons = [];
    cl_actions = [];
}

ConfigLine( string data ) {
    if (data != EOF) 
    {    
        integer spos = llSubStringIndex(data," ");
        if (spos==-1) jump LreadNextLine; // not a line with space

        string command = llGetSubString( data, 0, spos - 1);
        data = llGetSubString( data, spos+1, -1);
        
        integer command_id = llListFindList(["MENU", "TEXT", "TOMENU", "OPTION", "OPTIONASK"],[command]);
        if (command_id==-1) jump LreadNextLine; // not a command
        // MENU
        if (command_id == 0) 
        {
            if (cl_menu_id!="") commitEntry();
            cl_menu_id = data;                        
        }
        // TEXT
        else if (command_id == 1) 
        {
            if (cl_menu_text!="") cl_menu_text += "\n";
            list tmpl = llParseString2List(data,["\\n"],[]);
            data = llDumpList2String(tmpl,"\n");
            cl_menu_text += data;
        }
        // TOMENU <MenuID> <ButtonText> or TOMENU <MenuID>
        else if (command_id == 2) 
        {
            integer wpos = llSubStringIndex(data," ");
            string tomenuid = data;
            string btext = data;
            if (wpos>=0) {
                tomenuid = llGetSubString(data,0,wpos - 1);
                btext = llGetSubString(data,wpos+1,-1);
            }
        
            cl_buttons  += [ btext ];
            cl_actions  += [ mc_tomenu, tomenuid ];
        }
        // OPTION <ButtonText>
        else if (command_id == 3) 
        {
            cl_buttons  += [ data ];
            cl_actions  += [ mc_option, data ];
        }
        // OPTIONASK <ButtonText>
        else if (command_id == 4) 
        {
            cl_buttons  += [ data ];
            cl_actions  += [ mc_option_ask, data ];
        }
        @LreadNextLine; // jump point
        api_notecard_line++;
        api_query = llGetNotecardLine( api_notecard, api_notecard_line - 1 );
    } 
    else 
    {
        if (cl_menu_id != "") commitEntry();
        menu_number = llGetListLength(menu_offsets) / menu_size;
        configLoaded();   
    }
}

//
// gets called when the config is done loading
//
configLoaded() {
    if (api_debug) {
        DebugSay("Menu data loaded, mem: "+(string)llGetFreeMemory());
        llInstantMessage(llGetOwner(),"OFS: "+llDumpList2String(menu_offsets,","));
        llInstantMessage(llGetOwner(),"DATA: "+llDumpList2String(menu_data,","));
    }

    // signal a message to the main prog
    MessageGlobal(api_menu_loaded);
}

clearListens() {
    if (is_listening) {
        llListenRemove(handle_1);
        if (handle_2 != -1) llListenRemove(handle_2);
        handle_2 = -1;
        is_listening = FALSE;
    }
}

integer MenuNumber( string menuid ) {
    integer c;
    for (c=0;c<menu_number;c++)
        if (llList2String(menu_offsets,c*menu_size) == menuid)
            return(c);
    return(-1);
}

// load a data for a menu and start a dialog
Menu( key user,  string menuname ) {
    if (api_debug) DebugSay("Menu: "+menuname);
    integer mnum = MenuNumber(menuname);
    if ( mnum == -1 ) { // menu not found
        llSay(0,"Error: no such menu: "+menuname);
        return;
    }    

    current_offset = llList2Integer( menu_offsets, mnum * menu_size + 1 );
    integer actOfs = llList2Integer( menu_offsets, mnum * menu_size + 2 );
    integer actEnd = llList2Integer( menu_offsets, mnum * menu_size + 3 );

    current_menu_number = mnum;
    current_menu_name = menuname;
    current_user = user;
    current_buttons = llList2List( menu_data, current_offset+1, actOfs - 1 );
    current_actions = llList2List( menu_data, actOfs, actEnd );
    current_menu_type = mt_normal; // normal menu

    clearListens();    
    handle_1 = llListen( base_channel + current_menu_number, "", user, "");
    is_listening = TRUE;
    llDialog( user, llList2String( menu_data, current_offset ), current_buttons, base_channel + current_menu_number );
    llSetTimerEvent(response_timeout);
}


// param: <TEXT>
AskMenu( key user, string param ) {    
    current_menu_type = mt_ask;
    current_buttons = [ "Yes", "No" ];
    current_actions = [ param ];
    clearListens();    
    handle_1 = llListen( base_channel + current_menu_number, "", user, "");
    is_listening = TRUE;
    llDialog( user, param, current_buttons, base_channel + current_menu_number );
    llSetTimerEvent(response_timeout);   
}

////////////////////////////////////////////
default
{
    changed(integer change)
    {
        if (change & CHANGED_INVENTORY) 
        {
            llResetScript();
        }
    }
             
    state_entry()
    {
        if (api_debug) llSay(0, "Loading menu... mem: "+(string)llGetFreeMemory());
        base_channel = ( -1 * (integer)("0x"+llGetSubString((string)llGetKey(),-5,-1)) );
        ReadConfig();
    }

    dataserver(key query_id, string data) 
    {
        if (query_id == api_query) ConfigLine(data);
    }
    
    listen( integer channel, string name, key id, string message ) 
    {
        llSetTimerEvent(0.0);
        clearListens();

        if (current_menu_type==mt_ask) {
            if (message=="Yes") {
                string param = llList2String( current_actions, 0 ); // special case
                MessageSender(api_option_data,llDumpList2String([ current_menu_name, param ],"|"));                
            }
            return;
        }
        if (current_menu_type==mt_custom) {
            MessageSender(api_option_data,llDumpList2String([ current_menu_name, message ],"|"));
            return;
        }
        if (current_menu_type==mt_readstring) {
            string param = llList2String( current_actions, 0 ); // special case
            MessageSender(api_read_string_data,llDumpList2String([ param, message ],"|"));
            return;
        }

        integer c;
        integer nb = llGetListLength(current_buttons);
        integer fnd = -1;
        for (c=0;c<nb;c++) {
            if (llList2String(current_buttons,c)==message) {
                fnd = c;
                jump doneSR;
            }
        }
        @doneSR;
        if (fnd>=0) {
            integer act = llList2Integer( current_actions, fnd * 2 );
            string parameter = llList2String( current_actions, fnd * 2 + 1 );
            if (api_debug) {
                DebugSay("r: "+(string)act+" "+parameter);
            }
            if (act==mc_tomenu) {
                string tomenu = parameter;
                integer spos = llSubStringIndex(tomenu," ");
                if (spos>=0) tomenu = llGetSubString(tomenu,0,spos - 1);

                Menu(id,tomenu);
                return;
            }
            if (act==mc_option) {
                MessageSender(api_option_data,llDumpList2String([ current_menu_name, parameter ],"|"));
                return;
            }
            if (act==mc_option_ask) 
            {
                AskMenu(id,parameter);
                return;
            }

        }
    }
    
    link_message(integer sender_number, integer number, string message, key id )
    {
        if (number == api_menu) 
        {
            current_sender_id = sender_number;
            Menu(id, message);
            return;
        }
        if (number == api_read_string) 
        {
            current_sender_id = sender_number;
            current_menu_type = mt_readstring;

            string str = message;
            string retval  = message;
            integer spos = llSubStringIndex(message," ");
            if (spos>=0) {
                str = llGetSubString( message, spos+1, -1 );
                retval = llGetSubString( message, 0, spos - 1 );
            }
            current_actions = [ retval ];
            handle_1 = llListen( 0, "", id, ""); // listen from the user only
            handle_2 = llListen( api_menu_listen, "", id, ""); // and on secondary channel, too
            is_listening = TRUE;
            if (llStringLength(str)>0) llInstantMessage(id,str);
            llSetTimerEvent(response_timeout);   
            return;
        }
        if (number == api_custom_menu) 
        {
            list parameters = llParseString2List(message,["~|~"],[]);

            if (llGetListLength(parameters)<2) {
                llSay(0,"Error: not enough parameters for custom menu");
                return;                
            }

            current_menu_name = llList2String(parameters,0);
            string str = llList2String(parameters,1);
            current_user = id;
            current_buttons = llList2List( parameters, 2, llGetListLength(parameters) - 1 );
            current_menu_type = mt_custom;

            clearListens();    
            handle_1 = llListen( base_channel, "", current_user, "");
            is_listening = TRUE;
            llDialog( current_user, str, current_buttons, base_channel );
            llSetTimerEvent(response_timeout);
            return;
        }
        if (number == api_reset_menu_system) 
        {
            llResetScript();
        }
    }
    
    timer() 
    {
        llSetTimerEvent(0.0);
        clearListens();
    }
}
