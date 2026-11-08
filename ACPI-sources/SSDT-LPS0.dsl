/*
 * SSDT-LPS0 — Low Power S0 Idle (Modern Standby) for Dell Inspiron 15 7510
 *
 * Implements Device (LPS0) under \_SB with Intel Modern Standby _DSM UUID
 * (c4eb40a0-6cd2-11e2-bcfd-0800200c9a66) to enable macOS XNU Deep Idle / S0ix.
 * Delegates function execution directly to the motherboard's native \_SB.PEPD._DSM.
 */
DefinitionBlock ("", "SSDT", 2, "HACK", "LPS0", 0x00000000)
{
    External (_SB_.PEPD, DeviceObj)
    External (_SB_.PEPD._DSM, MethodObj)
    External (S0ID, FieldUnitObj)

    Scope (\_SB)
    {
        Device (LPS0)
        {
            Name (_HID, "INT33A1")
            Name (_CID, EisaId ("PNP0D80"))
            Name (_UID, One)

            Method (_STA, 0, NotSerialized)
            {
                Return (0x0F)
            }

            Method (_DSM, 4, Serialized)
            {
                If (Arg0 == ToUUID ("c4eb40a0-6cd2-11e2-bcfd-0800200c9a66"))
                {
                    // Function 0: Query supported functions (0x7F = functions 0 through 6)
                    If (Arg2 == Zero)
                    {
                        Return (Buffer (One) { 0x7F })
                    }

                    // Function 1: Ensure S0ID is active in GNVS
                    If (Arg2 == One)
                    {
                        If (CondRefOf (\S0ID))
                        {
                            \S0ID = One
                        }
                    }
                }

                // Delegate all Modern Standby DSM calls to native Dell PEPD
                If (CondRefOf (\_SB.PEPD._DSM))
                {
                    Return (\_SB.PEPD._DSM (Arg0, Arg1, Arg2, Arg3))
                }

                Return (Buffer (One) { 0x00 })
            }
        }
    }
}
