import std.stdio;

import vibe.vibe;
import std.json;
import dlog : DefaultLogger, DLogger = Logger;

// TODO: Investigate if we need the belowe (I copied it from Birchwood)
__gshared DLogger logger;
__gshared static this()
{
    logger = new DefaultLogger();
}

/** 
 * Handles an incoming websocket connection

 * Params:
 *   socket = the web socket to the client
 */
void websocketHandler(scope WebSocket socket)
{
	logger.log("Handling web socket: "~to!(string)(socket));

	string receivedText = socket.receiveText();
	logger.log(receivedText);


	JSONValue jsonReceived;
	jsonReceived = parseJSON(receivedText);

	logger.log(jsonReceived.toPrettyString());
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
