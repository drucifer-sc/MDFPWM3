# MDFPWM3
Multiple DFPWM container format for CC:Tweaked

A container format for multiple Dynamic Field Pulse Width Modulation streams to provide stereo audio playback via CC:Tweaked speakers. The format was originally designed for use on Computronics Tapes found on the Minecraft server _SwitchCraft 2_.

Formatting is similar to a RIFF (.WAV) header and data payload handling without a lot of the safety checks to reduce overhead as much as possible. The file begins with a format magic of `MDFPWM\003` (7 bytes), then proceeds with a basic header containing the artist, title, and album (each `s1` formatted), finally followed by a payload length (`I4` formatted). Payload is formatted as 12000 byte chunks, each containing 1 second of DFPWM audio playback at native 48kHz rate for each channel, left channel first. The payload is expected to be chunk oriented and pad the final bytes out to a divisible 6000 byte size for each stream to preserve all original audio data. Playback is achieved by parsing out the header, and then the payload data chunks, streaming the payload to speakers in-game.
