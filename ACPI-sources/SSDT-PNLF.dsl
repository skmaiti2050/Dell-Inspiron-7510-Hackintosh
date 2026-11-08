/*
 * SSDT-PNLF — Dell Inspiron 15 7510 (Tiger Lake-H, 8086:9A68) for WhateverXe.
 *
 * Minimal backlight device: WhateverXe's brightness profile is only applied when
 * PNLF reports _UID 19 with a 0..65535 range (kern_backlight_profile.hpp
 * `eligible()`), and WEX keeps the firmware's PCH PWM period (0xC8254 = 96000 on
 * this machine) and programs the duty (0xC8258) itself (kern_xelp_panel_pwm.hpp).
 * The OpenCore sample SSDT-PNLF computed _UID 16 here (0x9A68 is not in its
 * device-id tables) and its INI code writes the CFL packed PWM layout, which is
 * wrong for this PCH — so no register access at all in this SSDT.
 */
DefinitionBlock ("", "SSDT", 2, "HACK", "PNLF", 0x00000000)
{
    External (_SB_.PC00.GFX0, DeviceObj)

    If (_OSI ("Darwin"))
    {
        Scope (\_SB.PC00.GFX0)
        {
            Device (PNLF)
            {
                Name (_HID, EisaId ("APP0002"))  // _HID: Hardware ID
                Name (_CID, "backlight")         // _CID: Compatible ID
                Name (_UID, 0x13)                // 19: WhateverGreen/WhateverXe 16-bit PWM profile
                Method (_STA, 0, NotSerialized)  // _STA: Status
                {
                    Return (0x0B)
                }
            }
        }
    }
}
