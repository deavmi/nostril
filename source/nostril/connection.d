module nostril.connection;


import std.stdio;

import vibe.vibe;
import vibe.http.dist;
import std.json;

import gogga;
import gogga;

// TODO: Investigate if we need the belowe (I copied it from Birchwood)
__gshared GoggaLogger logger;
__gshared static this()
{
    logger = new GoggaLogger();
}


import vibe.vibe : WebSocket, WebSocketException;
import core.thread.fiber : Fiber;
import std.json;

// TODO: This won't work with Thread, must be a fiber
// ... because of how vibe.d works
public class Connection : Fiber
{
    /* Client socket */
    private WebSocket socket;

    /* Request information */
    private HTTPServerRequest httpRequest;

    this(WebSocket ws)
    {
        super(&worker);
        this.socket = ws;
        this.httpRequest = cast(HTTPServerRequest)socket.request();
    }

    private void worker()
    {
        logger.print("Handling web socket: "~to!(string)(socket)~"\n",DebugType.INFO);
        
        
        logger.print("New connection from: "~to!(string)(httpRequest.peer)~"\n",DebugType.INFO);

        

        while(socket.waitForData())
        {
            string data;

            try
            {
                import std.stdio;
                writeln("Ha");

                data = socket.receiveText();
                writeln("Hello receve done");
            }
            catch(WebSocketException e)
            {
                logger.print("Error in receive text\n", DebugType.ERROR);
            }

            try
            {
                handler(data);
            }
            catch(Exception e)
            {
                logger.print("Error in handler\n", DebugType.ERROR);
            }
            
        }

        logger.print("Web socket connection closing...\n", DebugType.WARNING);
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