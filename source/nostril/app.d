module nostril.app;

import std.stdio;

import vibe.vibe;
import vibe.http.dist;
import std.json;

import gogga;

// TODO: Investigate if we need the belowe (I copied it from Birchwood)
__gshared GoggaLogger logger;
__gshared static this()
{
    logger = new GoggaLogger();
}

import nostril.server;

void main()
{
    string[] bindAddresseds = ["::"];
    int bindPort = 8082;
	Server server = new Server(bindAddresseds, bindPort);
    server.startServer();
}
