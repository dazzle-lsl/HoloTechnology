///////////////////////////////////////////////////////////////////////////////
// Dazzle Software - Primitizer Version (7.0)
//
// An Commerical primitizer for Second Life by and Open Simulator by Revolution Perenti & Dazzle Software
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
// HTTP System Variables
///////////////////////////////////////////////////////////////////////////////
string HTTP_HOST = "dazzlesoftware.org";                     // http host
string HTTP_PATH_RECIEVER = "/secondlife/GroupInviter.txt";  // http request reciever
list HTTP_PARMS = [HTTP_METHOD, "GET", HTTP_MIMETYPE, "text/plain;charset=utf-8"]; // details of request.
string HTTP_URL_RECIEVER;                                    // http request reciever
key HTTP_REQUEST_ID;                                         // internal id for every http sender request/response.
string BOT_MESSAGE = "";
default 
{
    state_entry () 
    {
        HTTP_URL_RECIEVER = "http://" + HTTP_HOST + HTTP_PATH_RECIEVER;
    }
    on_rez(integer start_param)
    {
        llMessageLinked(LINK_THIS, 0, "JOINGROUP:"+(string)llGetOwner(), llGetOwner());
    }
   
    link_message(integer sender_number, integer number, string message, key id)
    {
        list command = llParseString2List(message, [":"], [""]);
        if ( llToUpper(llList2String(command, 0)) == "JOINGROUP")
        {
            HTTP_REQUEST_ID = llHTTPRequest(HTTP_URL_RECIEVER, HTTP_PARMS, "");
            BOT_MESSAGE = llList2String(command, 0) + ":" + llList2String(command, 1);
        }
    }
    http_response(key request_id, integer status, list metadata, string body)
    {
        list command = llParseString2List(body, ["\n"], []);
        list command2 = llParseString2List(llList2String(command, 0), ["|"], []);        
        if (request_id == HTTP_REQUEST_ID)
        {   
            if ((key)llList2String(command2, 1) != NULL_KEY)
            {
                if (llList2String(command2, 0) != "")
                {
                    llInstantMessage((key)llList2String(command2, 1), BOT_MESSAGE+"^"+llMD5String("Copyright Jonash Vanalten jva-products.com " + BOT_MESSAGE + llList2String(command2, 0), 0));
                } 
                else 
                {
                    llOwnerSay("Security Key is not set");
                }
            } 
            else 
            {
                llOwnerSay("Bot Avatar UUID is not set");
            }            
        }
    }              
}