/*
 * SSDT-dGPU-Off — Dell Inspiron 15 7510 (i5-11400H, Tiger Lake-H)
 *
 * Powers off the NVIDIA RTX 3050 Laptop GPU (10DE:25A2) under macOS only.
 * The internal panel is wired to the Intel iGPU (\_SB.PC00.GFX0), so it
 * is unaffected.
 *
 *   dGPU ACPI path : \_SB.PC00.PEG1.PEGP   (PciRoot(0x0)/Pci(0x1,0x0)/Pci(0x0,0x0))
 *   Power control  : \_SB.PC00.PEG1.PG01   (RTD3 PowerResource in SSDT "NvdTable")
 *
 * PEGP has no _OFF/_PS3 of its own; the GPU is powered through PG01, so
 * PG01._OFF is the method to call. It chains NPOF(1) → \_SB.PC00.PGOF(1).
 *
 * PG01._OFF is a no-op unless OSYS > 0x07D9 (newer than Windows 7). DSDT
 * \_SB._INI derives OSYS from _OSI("Windows …"), which macOS doesn't answer
 * for 2012+, so OSYS is raised to Windows 2015 for the call, then restored.
 *
 * Compile: iasl SSDT-dGPU-Off.dsl  → SSDT-dGPU-Off.aml
 * OpenCore: EFI/OC/ACPI/SSDT-dGPU-Off.aml + config.plist ACPI → Add entry.
 */
DefinitionBlock ("", "SSDT", 2, "HACK", "DGPU_OFF", 0x00001000)
{
    External (_SB_.PC00.PEG1.PG01._OFF, MethodObj)
    External (OSYS, FieldUnitObj)

    Device (DGPU)
    {
        Name (_HID, "DGPU1000")

        Method (_INI, 0, Serialized)
        {
            If (_OSI ("Darwin"))
            {
                If (CondRefOf (\_SB.PC00.PEG1.PG01._OFF))
                {
                    Local0 = \OSYS
                    If ((Local0 < 0x07DF))
                    {
                        \OSYS = 0x07DF
                    }

                    \_SB.PC00.PEG1.PG01._OFF ()
                    \OSYS = Local0
                }
            }
        }

        Method (_STA, 0, NotSerialized)
        {
            If (_OSI ("Darwin"))
            {
                Return (0x0F)
            }

            Return (Zero)
        }
    }
}
