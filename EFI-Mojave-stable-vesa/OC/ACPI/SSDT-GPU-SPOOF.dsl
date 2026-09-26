/*
 * RX 640 (Lexa 0x6987) -> spoof as Baffin RX 550/560 (0x67FF) so Mojave's AMD drivers attach.
 * ACPI path from ioreg on the OptiPlex 780: \_SB.PCI0.PEG0, GPU at function 0.
 */
DefinitionBlock ("", "SSDT", 2, "OC780", "GPUSPOOF", 0x00001000)
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
                    "device-id", Buffer (0x04) { 0xFF, 0x67, 0x00, 0x00 },
                    "model", Buffer () { "AMD Radeon RX 640" }
                })
            }
        }
    }
}
