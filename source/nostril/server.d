module nostril.server;

import gogga;

// TODO: Investigate if we need the belowe (I copied it from Birchwood)
__gshared GoggaLogger logger;
__gshared static this()
{
    logger = new GoggaLogger();
}

import core.thread : Thread;

import std.json;
import vibe.vibe : URLRouter, HTTPServerSettings;
import vibe.vibe : WebSocket, handleWebSockets;

import vibe.vibe;

import vibe.vibe : WebSocket, WebSocketException;
import core.thread.fiber : Fiber;

/** 
 * Server
 *
 * A BRUHTODO which manages all of the vibe.d fibers
 * for running a server which accepts client connections
 *
 * TODO: Make this a thread (so seperate FIberSchedulr associated with it I would hope)
 */
public class Server
{
    /** 
     * HTTP server
     */
    private HTTPServerSettings httpSettings;
    private URLRouter router;
    private @safe void delegate(scope HTTPServerRequest, HTTPServerResponse) websocketNegotiater;

    /**
     * Connection queue
     */
    private Connection[Connection] connections;
  
    /** 
     * TODO
     *
     * Params:
     *   bindAddresses = 
     *   bindPort = 
     */
    this(string[] bindAddresses, ushort bindPort)
    {
        // Setup where to listen
        this.httpSettings = new HTTPServerSettings();
	    httpSettings.port = bindPort;
        httpSettings.bindAddresses = bindAddresses;

        // Setup a websocket negotiater with a handler attached
        this.websocketNegotiater = handleWebSockets(&websocketHandler);

        // Handle `/` as the web socket path
	    this.router = new URLRouter();
	    router.get("/", this.websocketNegotiater);
    }

    /** 
     * TODO
     */
    public void startServer()
    {
        // Bind the router to the server
        // TODO: Investigate multi-threaded listener rather
        listenHTTP(httpSettings, router);
        // listenHTTPDist(httpSettings, toDelegate(&threadHandler), "[]::]", 8082);

        runApplication();
    }
    /** 
    * Handles an incoming websocket connection
    *
    * Params:
    *   socket = the web socket to the client
    */
    void websocketHandler(scope WebSocket socket)
    {
        /* Create a new connection to handle this client */
        Connection connection = new Connection(this, socket);

        /* Call the fiber and let it start */
        connection.call();
    }


    /** 
     * Adds the given Connection to the connection queue
     * even if it already exists in it (it won't duplicate)
     *
     * Params:
     *   newConnection = the connection to add
     */
    public final void addConnection(Connection newConnection)
    {
        connections[newConnection] = newConnection;
    }

    public final void delConnection(Connection existingConnection)
    {
        connections.remove(existingConnection);
    }


   
}


// TODO: This won't work with Thread, must be a fiber
// ... because of how vibe.d works
public class Connection : Fiber
{
    /* Client socket */
    private WebSocket socket;

    /* Request information */
    private HTTPServerRequest httpRequest;

    /* The server instance associated with */
    private Server server;

    this(Server server, WebSocket ws)
    {
        super(&worker);
        this.server = server;

        this.socket = ws;
        this.httpRequest = cast(HTTPServerRequest)socket.request();
    }

    private void worker()
    {
        /* Add it to the queue */
        server.addConnection(this);

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

        /* Remove it from the queue */
        server.delConnection(this);

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

/** 
 * BackingStore
 *
 * Represents the backing storage where
 * events are to be read from and written
 * to
 */
public abstract class BackingStore
{
    // TODO: Add a queue here
}