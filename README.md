# OpenCore EFI — Dell Inspiron 15 7510 (i5-11400H, Tiger Lake-H) → macOS Tahoe 26.7.1

OpenCore 1.0.8 EFI for the Dell Inspiron 15 7510 with **working Intel Xe graphics acceleration (Metal)** on the UHD iGPU `8086:9A68` via WhateverXe, plus brightness, native Wi-Fi, audio, USB 3 map and a Dell-hotkey fix. State as of 2026-11-08.

This EFI is shared **without any identity**: `PlatformInfo → Generic` contains `FILL-ME-SERIAL`, `FILL-ME-MLB`, a zero UUID and a zero ROM. **You must generate your own** (GenSMBIOS, model `MacBookPro16,2`) before booting, or iMessage/iCloud will misbehave and you may be locked out of Apple services.

## Hardware this was built for

| Component | Detail |
|---|---|
| Model | Dell Inspiron 15 7510, BIOS 1.38.0, chipset HM570 |
| CPU | Intel Core i5-11400H (Tiger Lake-H, 6C/12T) — spoofed as Ice Lake (`Cpuid1Data E5060700`) |
| iGPU | Intel UHD Graphics `8086:9A68` (Xe-LP, 32 EU, TGL-H GT1) |
| dGPU | NVIDIA RTX 3050 Laptop `10DE:25A2` — powered off by `SSDT-dGPU-Off` (no macOS driver) |
| Panel | BOE NV156FHM-N4W 1920×1080 60 Hz eDP |
| Wi-Fi / BT | Intel AX201 (CNVi `8086:43F0`, BT `8087:0026`) |
| Audio | Realtek ALC236 behind Intel SST (`8086:43C8`) |
| Touchpad | I²C HID `DLL0A81` on `\_SB.PC00.I2C1.TPD0`; keyboard PS/2 |
| SSD | KIOXIA KBG40ZNS512G NVMe |

Other Tiger Lake-H laptops with `9A60/9A68/9A70` can reuse the graphics part; the ACPI patches, USB map and touchpad spoof are specific to this Dell.

## What works

| Area | Status | Notes |
|---|---|---|
| Boot / install | ✅ | Internal ESP, OpenCanopy (GoldenGate) picker, startup chime (AudioDxe `--force-device`), Ubuntu entry via `BlessOverride`, Windows entry |
| CPU power management | ✅ | XCPM 0.8–4.5 GHz, cores reach C7, ~3 W package at idle |
| **Graphics acceleration** | ✅ **Metal 2** | WhateverXe 0.7.0 built from the `gputicks-bootarg` branch (WhateverXe issue #11) + WhateverXe Graphics 0.4.0; 1536 MB VRAM, 30-bit colour, HiDPI modes, H.264/HEVC decode |
| Internal display + brightness | ✅ | Slider and Fn brightness keys (SSDT-PNLF `_UID 19` + BrightnessKeys) |
| External display HDMI | ✅ 4K@30 | HDMI 1.4-class link (297 MHz). Monitors that get YCbCr/washed colours need an EDID override (see `extras/`) |
| External display USB-C (DP alt mode) | ✅ 4K@60 | Set the monitor's USB-C mode to "USB 2.0" (4 DP lanes). Author warns reconnection can glitch |
| External monitor brightness (DDC/CI) | ✅ | MonitorControl 4.4 works over HDMI and USB-C; set it to start at login |
| Internal panel name | ✅ | The BOE eDP EDID has no name string; `extras/DisplayOverride-BOE-NV156FHM-N4W` names it (optional) |
| Wi-Fi | ✅ | AirportItlwm-Tahoe 2.4.0 alpha (laobamac): native Wi-Fi menu, 2.4 + 5 GHz. WPA3-only networks don't work; AirDrop/Hotspot/Continuity don't on Intel Wi-Fi |
| Bluetooth | ✅ | IntelBluetoothFirmware/IntelBTPatcher 2.5.3 (lshbluesky fork) + BlueToolFixup; headset A2DP/HFP, BLE mouse, phone pairing |
| Audio | ✅ | VoodooHDA 3.6.8 (release 368) **in /Library/Extensions, not in this EFI** (see below); speakers, 3.5 mm headphones, USB audio, Bluetooth audio |
| **Built-in microphone** | ✅ | Intel SST DMIC array (cAVS 2.5 DSP `8086:43C8`) via TGLDmic 0.5.0 + `TGLDmic.driver` CoreAudio HAL plug-in; 48 kHz stereo PDM capture with native CoreAudio integration |
| Keyboard / touchpad | ✅ | VoodooPS2 (`ps2kbdonly=1 ps2rst=0`), VoodooI2C 2.9.1 with the I²C controller spoofed as Ice Lake-LP (`device-id E8340000`) and `-vi2c-force-polling` (no TGL-H GPIO driver) |
| USB | ✅ | UTBMap for this model: both USB-A at USB 3 (5 Gb/s), webcam, Bluetooth, SD reader; USB-C: power + USB 2 lane only |
| Battery, Fn keys, keyboard backlight, webcam (browser) | ✅ | Photo Booth/FaceTime preview needs the GPU driver — fine now |

## What does not work

| Area | Why |
|---|---|
| Sleep (S3) | Firmware is Modern-Standby only; `pmset -a sleep 0 disablesleep 1` is set. Hibernate untested |
| 3.5 mm headset mic | Static only: ALC236 headset mode needs Dell codec verbs that VoodooHDA lacks (use USB/Bluetooth mic) |
| USB-C data at USB 3 | Tiger Lake Type-C mux has no macOS driver; the USB 2 lane works (hubs, phones, headsets); DP alt mode works |
| AirDrop / Personal Hotspot / Continuity | Intel Wi-Fi limitation on 26.5+ |
| Monitor speakers (HDMI / DisplayPort audio) | Not in this EFI. Tahoe has no AppleHDA and Apple's AppleGFXHDA cannot share the controller with VoodooHDA. A patched VoodooHDA (github.com/skmaiti2050/VoodooHDA, branch `intel-display-codec`) already enumerates the Intel display codec (power wells + codec wake), but enabling audio on the display pipe still blanks the screen — work in progress, kept out of this release |
| Fingerprint reader, Thunderbolt | No drivers (see labrouss/EliteBook840G8 for a Tiger Lake SSDT-TBT4 that reportedly tunnels PCIe over TB4) |

## Setup

1. **BIOS:** SATA/NVMe mode AHCI (not RAID/VMD), Secure Boot off. (TPM can stay.)
2. **SMBIOS:** run GenSMBIOS → `MacBookPro16,2`, put Serial, Board Serial (MLB), SmUUID into `config.plist → PlatformInfo → Generic`, and your Wi-Fi/Ethernet MAC into `ROM`.
3. **Install macOS Tahoe** (this EFI was used with the Olarila Tahoe 26.7.1 offline image and with Apple's recovery). Boot from a USB stick with this EFI, install, then copy `EFI/OC` to the internal ESP and add a firmware boot entry for `\EFI\OC\OpenCore.efi`.
4. **Audio:** Tahoe has no AppleHDA, so AppleALC is disabled. Install VoodooHDA 3.6.8 (release 368, github.com/CloverHackyColor/VoodooHDA) into `/Library/Extensions` with `VoodooHDAEnableVolumeChangeFix = true` in its Info.plist, approve it in Privacy & Security, reboot. (The OpenCore-injected `VoodooHDA_BL` build breaks USB audio — it is included but disabled.)
5. **Internal Digital Microphone:** This EFI includes `TGLDmic.kext` (with boot-arg `-tgldmic`). To expose the microphone to macOS CoreAudio, install the HAL plug-in: `sudo bash extras/TGLDmic/install-hal.sh`. This copies `TGLDmic.driver` to `/Library/Audio/Plug-Ins/HAL/` and restarts `coreaudiod`. Look for "Internal Microphone (TGLDmic)" in System Settings > Sound > Input. Use Apple's "Voice Isolation" in Control Center for real-time background noise removal.
6. **Graphics (Metal):** after first boot, install **WhateverXe Graphics 0.4.0** (`WhateverXe-Graphics-0.4.0.pkg` from github.com/b00t0x/WhateverXe-Graphics) with `sudo installer -pkg … -target /`, reboot. This EFI already carries `WhateverXe.kext` (gputicks build), `BrightnessKeys.kext`, the **AMFIPass 1.4.1 Mod** (required by WhateverXe Graphics; do not use upstream AMFIPass), `SSDT-PNLF`, the DVMT properties (`framebuffer-stolenmem 0000C003`, Dell fixes DVMT at 64 MB) and boot-args `-allow3d -disablegfxfirmware -igfxdvmt -wex-skip-gputicks`. `csr-active-config 03080000` is required.
   - Until the package is installed the display runs on the firmware framebuffer (software rendering). Once installed, every boot must use WhateverXe; Safe Mode (Shift+Enter in the picker) skips `/Library/Extensions` if you ever need to get back in.
7. **Verbose boot** is on (`-v keepsyms=1 debug=0x100`); remove those from boot-args once you are happy.
   - `PollAppleHotKeys` is **off**: Shift+Enter in the picker will not give a safe boot (a latched Shift once put every boot into safe mode). Use the Recovery entry instead, or set it to true if you prefer the hotkeys.
   - Install kexts into `/Library/Extensions` only from a normal boot and reboot only after the auxiliary kernel collection has been rebuilt; an install from safe mode leaves a stale collection and the next boot can hang on the console.
8. Optional: `extras/DisplayOverride-BenQ-PD2706UA` is an EDID override for that specific monitor (RGB instead of YCbCr, CEA block reduced to basic audio + HDMI VSDB, 4K30 HDMI / 4K60 DP / 1440p60 timings) — only useful for that model. `extras/DisplayOverride-BOE-NV156FHM-N4W` names the internal panel. Both go under `/Library/Displays/Contents/Resources/Overrides/`. Dell's factory ICC profile for the panel can be copied from a Windows install (`Dell_Inspiron_15_7510_FHD_BOE093F.icm`) into `/Library/ColorSync/Profiles`.

## ACPI (this Dell)

| SSDT / patch | Purpose |
|---|---|
| `_OSI → XOSI` + `SSDT-XOSI` | Firmware behaves as Windows 10 (touchpad `_CRS` only returns I²C/GPIO resources when OSYS ≥ Win8) |
| DSDT patch `_SBXOSID → _SB_OSID` | **Repairs collateral damage of the `_OSI` rename**: the name `_SB_OSID` contains `_OSI`; without this every EC hotkey (`SMEE`) fails with `AE_NOT_FOUND` and the brightness keys are dead |
| `SSDT-GPI0` | Clears `GPHD` so the GPIO controller is enabled for VoodooI2C |
| `SSDT-dGPU-Off` | Calls `PEG1.PG01._OFF` for the RTX 3050 |
| `SSDT-AWAC` | `STAS=1` (legacy RTC) |
| `SSDT-EC-USBX` | Fake EC (`ACID0001`) — the real EC is `ECDV` — plus USBX power properties |
| `SSDT-PNLF` | Minimal backlight device, `_UID 19`, no register writes (WhateverXe drives the PCH PWM itself) |

## Kexts

Lilu 1.7.2 · WhateverXe 0.7.0 (gputicks-bootarg build, source: github.com/Elezorn/WhateverXe-TigerLakeH, branch `gputicks-bootarg`, built with GitHub Actions) · TGLDmic 0.5.0 (Tiger Lake-H port with embedded Intel SOF sof-tgl-h.ri v2.2 firmware) · BrightnessKeys 1.0.3 · AMFIPass 1.4.1 Mod (b00t0x) · VirtualSMC 1.3.8 (+SMCBatteryManager, SMCProcessor, SMCDellSensors) · ECEnabler 1.0.6 · NVMeFix 1.1.3 · USBToolBox 1.2.0 + UTBMap (this model) · AirportItlwm-Tahoe 2.4.0 alpha (laobamac; itlwm 2.3.0 included disabled) · HoRNDIS 9.2 (Android USB tethering) · IntelBluetoothFirmware/IntelBTPatcher 2.5.3 (lshbluesky) · BlueToolFixup 2.7.2 · VoodooPS2Controller 2.3.7 (keyboard plugin only) · VoodooI2C 2.9.1 + VoodooI2CHID · AppleALC 1.9.8 (disabled) · VoodooHDA_BL 3.7.1-alpha (disabled).

## Known issues / notes

- WhateverXe 0.7.0 **stock hangs on Tiger Lake-H GT1** about 16 s into boot (GPU_TICKS register read). The included build adds `-wex-skip-gputicks` (WhateverXe issue #11). If upstream merges it, switch to the official kext.
- 4K over HDMI is 30 Hz (link limit); use USB-C for 4K60.
- External monitors may come up with washed-out colours (YCbCr on CEA modes) → EDID override without the CEA block.
- Logi Options+ needs Input Monitoring for "Logi Options+ Driver Host" to see Logitech devices.
- `hda-gfx = onboard-1` is injected on the IGPU and the HDA controller; harmless with VoodooHDA, needed only for the display-audio work above.
- macOS updates: no root patches are used, but WhateverXe/Graphics are tied to the OS build family (26.7+); check the WhateverXe compatibility table before updating.

## Credits

OpenCore (acidanthera) · Lilu, VirtualSMC, BrightnessKeys, BlueToolFixup, VoodooPS2, VoodooI2C (acidanthera / alexandred) · WhateverXe + WhateverXe Graphics (b00t0x) · gputicks workaround (Elezorn, issue #11) · TGLDmic (labrouss) · Intel SOF firmware (thesofproject) · AirportItlwm-Tahoe (laobamac / OpenIntelWireless) · IntelBluetoothFirmware (OpenIntelWireless, lshbluesky fork) · VoodooHDA (Slice/Zenith432, CloverHackyColor) · USBToolBox (dhinakg) · AMFIPass Mod (b00t0x) · HoRNDIS (jwise).
