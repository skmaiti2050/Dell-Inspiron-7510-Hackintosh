# TGLDmic CoreAudio HAL Plug-in

This plug-in connects macOS CoreAudio to TGLDmic.kext, exposing the Intel SST / SOF cAVS 2.5 digital microphone array (8086:43C8) as a native input device in System Settings > Sound > Input.

## Installation

```bash
sudo bash install-hal.sh
```

This installs TGLDmic.driver to /Library/Audio/Plug-Ins/HAL/ and restarts coreaudiod.

## Uninstallation

```bash
sudo bash uninstall-hal.sh
```
