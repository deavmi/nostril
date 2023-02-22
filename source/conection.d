module nostril.conection;

import vibe.vibe : WebSocket;

public class Connection
{
    /* Client socket */
    private WebSocket ws;

    this(WebSocket ws)
    {
        this.ws = ws;
    }
}