module nostril.app;

import  nostril.logging;
import nostril.server;

void main()
{
    string[] bindAddresseds = ["::"];
    ushort bindPort = 8082;
	Server server = new Server(bindAddresseds, bindPort);
    server.startServer();
}
