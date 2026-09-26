/*
 * RX 640 (Dell OEM, Lexa 0x6987) connector reorder for legacy-BIOS OptiPlex 780.
 * VBIOS order puts the full-size DP (txmit 0x10, enc 0x00, hpd 3, sense 3) at index 2 -> display pipe 2,
 * whose line buffer never runs after a legacy VBIOS POST. Move it to index 0 (pipe 0) with priority 1.
 * 16-byte legacy ConnectorInfo: type(4) flags(4) features(2) priority(2) txmit(1) enc(1) hotplug(1) sense(1)
 */
DefinitionBlock ("", "SSDT", 2, "OC780", "RX640CON", 0x00001000)
{
    External (_SB_.PCI0.PEG0, DeviceObj)

    Scope (\_SB.PCI0.PEG0)
    {
        Device (GFX0)
        {
            Name (_ADR, Zero)
            Method (_DSM, 4, NotSerialized)
            {
                If ((Arg2 == Zero))
                {
                    Return (Buffer (One) { 0x03 })
                }

                Return (Package ()
                {
                    "model", Buffer () { "AMD Radeon RX 640" },
                    "connector-count", Buffer (0x04) { 0x03, 0x00, 0x00, 0x00 },
                    "connectors", Buffer (0x30)
                    {
                        /* full-size DP -> pipe 0 */
                        0x00, 0x04, 0x00, 0x00, 0x04, 0x03, 0x00, 0x00, 0x00, 0x01, 0x01, 0x00, 0x10, 0x00, 0x03, 0x03,
                        /* mini-DP */
                        0x00, 0x04, 0x00, 0x00, 0x04, 0x03, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x11, 0x02, 0x05, 0x01,
                        /* mini-DP */
                        0x00, 0x04, 0x00, 0x00, 0x04, 0x03, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x21, 0x03, 0x04, 0x02
                    }
                })
            }
        }
    }
}
