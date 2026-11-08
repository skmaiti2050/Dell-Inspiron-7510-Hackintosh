/*
 * SSDT-GPRW — Instant Wake fix for Dell Inspiron 15 7510
 *
 * Hooks GPRW and UPRW to prevent GPE 0x6D (XHCI / XDCI) from returning
 * wake states 0x03 / 0x04 under macOS, resolving instant wake after sleep.
 */
DefinitionBlock ("", "SSDT", 2, "HACK", "GPRW", 0x00000000)
{
    External (XPRW, MethodObj)
    External (_SB_.PC00, DeviceObj)
    External (_SB_.PC00.XPRW, MethodObj)

    Method (GPRW, 2, NotSerialized)
    {
        If (_OSI ("Darwin"))
        {
            // Suppress wake for XHCI / XDCI / HDAS (0x6D)
            If ((Arg0 == 0x6D) && ((Arg1 == 0x04) || (Arg1 == 0x03)))
            {
                Return (Package (0x02)
                {
                    0x6D, 
                    Zero
                })
            }

            // Suppress wake for LAN / Wi-Fi (0x69)
            If ((Arg0 == 0x69) && ((Arg1 == 0x04) || (Arg1 == 0x03)))
            {
                Return (Package (0x02)
                {
                    0x69, 
                    Zero
                })
            }
        }

        Return (XPRW (Arg0, Arg1))
    }

    Scope (\_SB.PC00)
    {
        Method (UPRW, 0, NotSerialized)
        {
            If (_OSI ("Darwin"))
            {
                Return (Zero)
            }

            If (CondRefOf (\_SB.PC00.XPRW))
            {
                Return (\_SB.PC00.XPRW ())
            }

            Return (Zero)
        }
    }
}
