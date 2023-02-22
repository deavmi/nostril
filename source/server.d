module nostril.server;

import gogga;

// TODO: Investigate if we need the belowe (I copied it from Birchwood)
__gshared GoggaLogger logger;
__gshared static this()
{
    logger = new GoggaLogger();
}



import vibe.vibe : URLRouter;

public class Server
{
    private URLRouter router;

    private this()
    {

    }

    public void startServer()
    {
        // TODO: Make call to `runApplication()`
    }


    public static Server createServer()
    {
        Server newServer;



        return newServer;
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