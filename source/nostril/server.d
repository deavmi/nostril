module nostril.server;

import gogga;

// TODO: Investigate if we need the belowe (I copied it from Birchwood)
__gshared GoggaLogger logger;
__gshared static this()
{
    logger = new GoggaLogger();
}

import core.thread : Thread;

import vibe.vibe : URLRouter, HTTPServerSettings;
import vibe.vibe : WebSocket, handleWebSockets;

import vibe.vibe;

import nostril.connection;

/** 
 * Server
 *
 * A thread which manages all of the vibe.d fibers
 * for running a server which accepts client connections
 */
public class Server
{
    /** 
     * HTTP server
     */
    private HTTPServerSettings httpSettings;
    private URLRouter router;
    private @safe void delegate(scope HTTPServerRequest, HTTPServerResponse) websocketNegotiater;

  

    this(string[] bindAddresses, int bindPort)
    {
        // Setup where to listen
        this.httpSettings = new HTTPServerSettings();
	    httpSettings.port = 8082;
        httpSettings.bindAddresses = bindAddresses;

        // Setup a websocket negotiater with a handler attached
        this.websocketNegotiater = handleWebSockets(&websocketHandler);

        // Handle `/` as the web socket path
	    this.router = new URLRouter();
	    router.get("/", this.websocketNegotiater);
    }

    public void startServer()
    {
        // Bind the router to the server
        // TODO: Investigate multi-threaded listener rather
        listenHTTP(httpSettings, router);
        // listenHTTPDist(httpSettings, toDelegate(&threadHandler), "[]::]", 8082);

        runApplication();
    }


    public static Server createServer()
    {
        Server newServer;



        return newServer;
    }

    /** 
    * Handles an incoming websocket connection
    *
    * Params:
    *   socket = the web socket to the client
    */
    void websocketHandler(scope WebSocket socket)
    {
        new Connection(socket).call();
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