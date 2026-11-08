/*
 * SSDT-XOSI — Dell Inspiron 15 7510
 *
 * Requires the config.plist ACPI patch "_OSI to XOSI" (5F4F5349 → 584F5349).
 *
 * The DSDT gates the touchpad (TPD0._CRS returns its I2C + GpioInt resources
 * only when OSYS >= 0x07DC) and other Windows-8+ paths on _OSI("Windows …").
 * Under macOS this answers like Windows 10 so OSYS becomes 0x07DF.
 */
DefinitionBlock ("", "SSDT", 2, "HACK", "XOSI", 0x00001000)
{
    Method (XOSI, 1, NotSerialized)
    {
        If (_OSI ("Darwin"))
        {
            Local0 = Package ()
                {
                    "Windows 2001",
                    "Windows 2001 SP1",
                    "Windows 2001 SP2",
                    "Windows 2001.1",
                    "Windows 2006",
                    "Windows 2006 SP1",
                    "Windows 2006.1",
                    "Windows 2009",
                    "Windows 2012",
                    "Windows 2013",
                    "Windows 2015",
                    "Microsoft Windows NT",
                    "Microsoft Windows",
                    "Microsoft WindowsME: Millennium Edition"
                }
            Return ((Ones != Match (Local0, MEQ, Arg0, MTR, Zero, Zero)))
        }

        Return (_OSI (Arg0))
    }
}
