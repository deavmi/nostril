module nostril.server;

import vibe.vibe : URLRouter;

public class Server
{
    private URLRouter router;

    private this()
    {

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