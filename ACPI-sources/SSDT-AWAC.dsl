/*
 * SSDT-AWAC — Dell Inspiron 15 7510
 *
 * DSDT exposes both AWAC (enabled while STAS == 0) and the legacy RTC.
 * macOS only supports the RTC, so AWAC is switched off under macOS.
 */
DefinitionBlock ("", "SSDT", 2, "HACK", "AWAC", 0x00001000)
{
    External (STAS, FieldUnitObj)

    Scope (\)
    {
        If (_OSI ("Darwin"))
        {
            STAS = One
        }
    }
}
