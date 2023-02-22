module nostril.connection;

import gogga;

// TODO: Investigate if we need the belowe (I copied it from Birchwood)
__gshared GoggaLogger logger;
__gshared static this()
{
    logger = new GoggaLogger();
}


import vibe.vibe : WebSocket;
import core.thread : Thread;
import std.json;

public class Connection : Thread
{
    /* Client socket */
    private WebSocket ws;

    this(WebSocket ws)
    {
        super(&worker);
        this.ws = ws;
    }

    private void worker()
    {
        // TODO: Add this
    }

    /** 
    * Handles received data
    *
    * Params:
    *    text = received data 
    */
    private void handler(string text)
    {
        string receivedText = text;
        logger.print(receivedText~"\n", DebugType.INFO);


        JSONValue jsonReceived;
        try
        {
            jsonReceived = parseJSON(receivedText);
            logger.print(jsonReceived.toPrettyString()~"\n", DebugType.INFO);

            // TODO: Add handling here

        }
        catch(JSONException e)
        {
            logger.print("There was an error parsing the client's JSON\n", DebugType.ERROR);
        }
    }
}