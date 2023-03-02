module nostril.logging;

// NOTE: If we include threads then use `__gshared` so we have
// ... one logger for the whole threadgroup and not a per-TLS
// ... (per-thread) logger (as we do below)
private mixin template LoggerSetup()
{
    import gogga;
    GoggaLogger logger;
    static this()
    {
        logger = new GoggaLogger();

        version(dbg)
        {
            logger.enableDebug();
        }
    }
}

/* Where you import, setup logging */
mixin LoggerSetup!();