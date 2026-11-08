/*
 * SSDT-GPI0 — Dell Inspiron 15 7510
 *
 * \_SB.PC00.GPI0 (INT34C6, Tiger Lake-H GPIO) returns 0x0B from _STA when
 * GPHD == 1. VoodooGPIO needs the controller fully enabled (0x0F) to route
 * the touchpad's GpioInt, so GPHD is cleared under macOS.
 */
DefinitionBlock ("", "SSDT", 2, "HACK", "GPI0", 0x00001000)
{
    External (GPHD, FieldUnitObj)

    Scope (\)
    {
        If (_OSI ("Darwin"))
        {
            GPHD = Zero
        }
    }
}
