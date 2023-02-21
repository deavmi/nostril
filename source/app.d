import std.stdio;

import vibe.vibe;
import std.json;

import gogga;

// TODO: Investigate if we need the belowe (I copied it from Birchwood)
__gshared GoggaLogger logger;
__gshared static this()
{
    logger = new GoggaLogger();
}


/** 
 * Handles an incoming websocket connection

 * Params:
 *   socket = the web socket to the client
 */
void websocketHandler(scope WebSocket socket)
{
	logger.print("Handling web socket: "~to!(string)(socket)~"\n",DebugType.INFO);

	string receivedText = socket.receiveText();
	logger.print(receivedText~"\n", DebugType.INFO);


	JSONValue jsonReceived;
	jsonReceived = parseJSON(receivedText);

	logger.print(jsonReceived.toPrettyString()~"\n", DebugType.INFO);
}

void main()
{
	// Setup where to listen
	HTTPServerSettings httpSettings = new HTTPServerSettings();
	
	// TODO: Customize these with a config file or environment variables
	httpSettings.port = 8082;

	// Setup a websocket negotiater with a handler attached
	auto websocketNegotiater = handleWebSockets(&websocketHandler);

	// Handle `/` as the web socket path
	URLRouter router = new URLRouter();
	router.get("/", websocketNegotiater);

	// Bind the router to the server
	listenHTTP(httpSettings, router);

	runApplication();
}
