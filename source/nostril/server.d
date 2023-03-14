module nostril.server;

import nostril.storage : BackingStore;
import  nostril.logging;


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
     * Backend storage
     */
    private BackingStore store;
  
    /** 
     * Constructs a new server listening on the given
     * network parameters
     *
     * Params:
     *   bindAddresses = list of addresses to bind to
     *   bindPort = port to bind to
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
        logger.dbg("Adding connection '"~newConnection.toString()~"'...");
        connections[newConnection] = newConnection;
        logger.dbg("Adding connection '"~newConnection.toString()~"'... [done]");
    }

    /** 
     * Removes the provided connection from the connection queue
     *
     * Params:
     *   existingConnection = the connection to remove
     */
    public final void delConnection(Connection existingConnection)
    {
        logger.dbg("Removing connection '"~existingConnection.toString()~"'...");
        connections.remove(existingConnection);
        logger.dbg("Removing connection '"~existingConnection.toString()~"'... [done]");
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

        logger.info("Handling web socket: "~to!(string)(socket));
        
        
        logger.info("New connection from: "~to!(string)(httpRequest.peer));
        
        /**
         * Loop whilst the connection is active
         */
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
                logger.error("Error in receive text");
            }

            try
            {
                handler(data);
            }
            catch(Exception e)
            {
                logger.error("Error in handler");
            }
            
            logger.info("Loop end");
            // TODO: Bruv yield it would seem
        }

        /* Remove it from the queue */
        server.delConnection(this);

        logger.warn("Web socket connection closing...");
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
        logger.info(receivedText);


        JSONValue jsonReceived;
        try
        {
            jsonReceived = parseJSON(receivedText);
            logger.info("Received data:\n\n"~jsonReceived.toPrettyString());

            // TODO: Add handling here

        }
        catch(JSONException e)
        {
            logger.error("There was an error parsing the client's JSON");
        }
    }
}