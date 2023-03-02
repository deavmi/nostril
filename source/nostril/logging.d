module nostril.logging;

import gogga;

// NOTE: If we include threads then use `__gshared` so we have
// ... one logger for the whole threadgroup and not a per-TLS
// ... (per-thread) logger (as we do below)
private mixin template LoggerSetup()
{
    GoggaLogger logger;
    static this()
    {
        logger = new GoggaLogger();

        version(dbg)
        {
            logger.enableDebug();
        }

        logger.mode(GoggaMode.TwoKTwenty3);
    }
}

/* Where you import, setup logging */
mixin LoggerSetup!();