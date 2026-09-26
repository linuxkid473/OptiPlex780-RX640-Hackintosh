/*
 * Intel ACPI Component Architecture
 * AML/ASL+ Disassembler version 20200925 (64-bit version)
 * Copyright (c) 2000 - 2020 Intel Corporation
 * 
 * Disassembling to symbolic ASL+ operators
 *
 * Disassembly of dsdt.aml, Sat Sep 26 12:21:41 2026
 *
 * Original Table Header:
 *     Signature        "DSDT"
 *     Length           0x00005244 (21060)
 *     Revision         0x01 **** 32-bit table (V1), no 64-bit math support
 *     Checksum         0x43
 *     OEM ID           "DELL"
 *     OEM Table ID     "dt_ex"
 *     OEM Revision     0x00001000 (4096)
 *     Compiler ID      "INTL"
 *     Compiler Version 0x20190108 (538509576)
 */
DefinitionBlock ("", "DSDT", 1, "DELL", "dt_ex", 0x00001000)
{
    Method (DTGP, 5, NotSerialized)
    {
        If ((Arg0 == ToUUID ("a0b5b7c6-1318-441c-b0c9-fe695eaf949b") /* Unknown UUID */))
        {
            If ((Arg1 == One))
            {
                If ((Arg2 == Zero))
                {
                    Arg4 = Buffer (One)
                        {
                             0x03                                             // .
                        }
                    Return (One)
                }

                If ((Arg2 == One))
                {
                    Return (One)
                }
            }
        }

        Arg4 = Buffer (One)
            {
                 0x00                                             // .
            }
        Return (Zero)
    }

    Method (DBIN, 0, NotSerialized)
    {
        Noop
    }

    Scope (\)
    {
        Device (_SB.VBTN)
        {
            Name (_CID, EisaId ("PNP0C0C") /* Power Button Device */)  // _CID: Compatible ID
            Name (_PRW, Package (0x02)  // _PRW: Power Resources for Wake
            {
                One, 
                0x04
            })
        }

        OperationRegion (SSTS, SystemIO, 0x0828, One)
        Field (SSTS, ByteAcc, NoLock, WriteAsZeros)
        {
            TSTS,   1
        }

        OperationRegion (SACT, SystemIO, 0x082A, One)
        Field (SACT, ByteAcc, NoLock, WriteAsZeros)
        {
                ,   2, 
            TPOL,   1
        }
    }

    Scope (_GPE)
    {
        Method (_L00, 0, NotSerialized)  // _Lxx: Level-Triggered GPE, xx=0x00-0xFF
        {
            TPOL = Zero
            TSTS = One
            Notify (\_SB.VBTN, 0x02) // Device Wake
        }
    }

    Scope (_SB)
    {
        Method (_INI, 0, NotSerialized)  // _INI: Initialize
        {
            If (CondRefOf (_OSI, Local0))
            {
                If (_OSI ("Windows 2001"))
                {
                    MSOS = 0x04
                }
            }
        }
    }

    Scope (\)
    {
        Name (MSOS, Zero)
        Mutex (MTX, 0x01)
        Method (CMRD, 1, NotSerialized)
        {
            Acquire (SMIM, 0xFFFF)
            Local0 = Arg0
            Local0 &= 0x7F
            SMID = Local0
            SMIC = 0x84
            SMIC = 0x85
            Local0 = SMID /* \SMID */
            Release (SMIM)
            Return (Local0)
        }

        Method (CMWR, 2, NotSerialized)
        {
            Acquire (SMIM, 0xFFFF)
            Local0 = Arg0
            Local0 |= 0x80
            SMID = Local0
            SMIC = 0x84
            SMID = Arg1
            SMIC = 0x85
            Release (SMIM)
        }

        Method (GCKB, 0, NotSerialized)
        {
            Return ((0x20 & CMRD (0x26)))
        }

        Method (GCMS, 0, NotSerialized)
        {
            Return ((0x40 & CMRD (0x6F)))
        }

        Method (GCON, 0, NotSerialized)
        {
            Return ((0x04 & CMRD (0x55)))
        }

        Method (GCUC, 0, NotSerialized)
        {
            Local0 = (One & CMRD (0x22))
            Return ((One ^ Local0))
        }

        Method (GCS1, 0, NotSerialized)
        {
            Return ((0x03 & CMRD (0x25)))
        }

        Method (GCS2, 0, NotSerialized)
        {
            Return ((0x0C & CMRD (0x25)))
        }

        Method (GCFD, 0, NotSerialized)
        {
            Return ((0x18 & CMRD (0x55)))
        }

        Method (GCPP, 0, NotSerialized)
        {
            Return ((0x70 & CMRD (0x23)))
        }

        Method (GCTP, 0, NotSerialized)
        {
            Return ((0x40 & CMRD (0x22)))
        }

        Method (GCNC, 0, NotSerialized)
        {
            Return ((0x03 & CMRD (0x59)))
        }

        Method (HACK, 0, NotSerialized)
        {
            Local0 = CMRD (0x6F)
            Local0 |= 0x04
            CMWR (0x6F, Local0)
            Return (One)
        }

        Method (ISLI, 0, NotSerialized)
        {
            If (CondRefOf (_OSI, Local0))
            {
                If (_OSI ("Linux"))
                {
                    Return (One)
                }
                Else
                {
                    Return (Zero)
                }
            }
            Else
            {
                Return (Zero)
            }
        }
    }

    Scope (_SB)
    {
    }

    OperationRegion (CMS, SystemIO, 0x70, 0x02)
    Field (CMS, ByteAcc, NoLock, Preserve)
    {
        CMSI,   8, 
        CMSD,   8
    }

    OperationRegion (SMIR, SystemIO, 0xB2, 0x02)
    Field (SMIR, ByteAcc, NoLock, Preserve)
    {
        SMIC,   8, 
        SMID,   8
    }

    OperationRegion (STON, SystemIO, 0x84, One)
    Field (STON, ByteAcc, NoLock, Preserve)
    {
        MGIC,   8
    }

    OperationRegion (SIO, SystemIO, 0x2E, 0x02)
    Field (SIO, ByteAcc, NoLock, Preserve)
    {
        SIOI,   8, 
        SIOD,   8
    }

    OperationRegion (PM1R, SystemIO, 0x0800, 0x04)
    Field (PM1R, ByteAcc, NoLock, Preserve)
    {
        PMS1,   8, 
        PMS2,   8, 
        PME1,   8, 
        PME2,   8
    }

    OperationRegion (GPST, SystemIO, 0x0820, One)
    Field (GPST, ByteAcc, NoLock, Preserve)
    {
        GST0,   8
    }

    OperationRegion (GLBC, SystemIO, 0x0828, 0x06)
    Field (GLBC, ByteAcc, NoLock, Preserve)
    {
        THRP,   8, 
        GLBT,   8, 
        EOS,    8, 
        LIDP,   8, 
        THME,   8, 
        RIEN,   8
    }

    OperationRegion (GPEC, SystemIO, 0x0842, One)
    Field (GPEC, ByteAcc, NoLock, Preserve)
    {
        THPL,   1, 
        SWGP,   1, 
        Offset (0x01)
    }

    OperationRegion (PMES, SystemIO, 0x0C00, One)
    Field (PMES, ByteAcc, NoLock, Preserve)
    {
        GSTS,   8
    }

    Mutex (SMIM, 0x01)
    Mutex (SMIX, 0x01)
    Name (SXX0, Buffer (0x0100){})
    Name (SXX1, Buffer (0x08){})
    CreateWordField (SXX1, Zero, SXX2)
    CreateWordField (SXX1, 0x04, SXX3)
    Method (SMI, 2, NotSerialized)
    {
        Acquire (SMIM, 0xFFFF)
        SMID = Arg1
        SMIC = Arg0
        Local0 = MGIC /* \MGIC */
        Local1 = SMID /* \SMID */
        Release (SMIM)
        Return (Local1)
    }

    Method (SMI1, 1, NotSerialized)
    {
        Acquire (SMIM, 0xFFFF)
        SMIC = Arg0
        Local0 = MGIC /* \MGIC */
        Local0 = SMID /* \SMID */
        Release (SMIM)
        Return (Local0)
    }

    Method (SMI2, 1, NotSerialized)
    {
        Acquire (SMIM, 0xFFFF)
        SMIC = Arg0
        Local0 = MGIC /* \MGIC */
        Local1 = SMIC /* \SMIC */
        Local0 = SMID /* \SMID */
        Local0 <<= 0x08
        Local0 += Local1
        Release (SMIM)
        Return (Local0)
    }

    Method (SMI4, 1, NotSerialized)
    {
        Local0 = (Arg0 + One)
        Local2 = SMI2 (Arg0)
        Local1 = SMI2 (Local0)
        Local1 <<= 0x10
        Local0 = (Local1 + Local2)
        Return (Local0)
    }

    Method (GTMR, 0, NotSerialized)
    {
        Return (SMI4 (0x78))
    }

    Method (GTML, 0, NotSerialized)
    {
        Return (SMI4 (0x74))
    }

    Method (GTMH, 0, NotSerialized)
    {
        Return (SMI4 (0x76))
    }

    Method (GTOM, 0, NotSerialized)
    {
        Return (SMI4 (0x81))
    }

    Method (GUSB, 0, NotSerialized)
    {
        If (ISLI ())
        {
            Return (Zero)
        }
        Else
        {
            Return (SMI2 (0xBA))
        }
    }

    Method (GTPM, 0, NotSerialized)
    {
        Return (SMI (0x9B, Zero))
    }

    Method (SX10, 0, NotSerialized)
    {
        Acquire (SMIX, 0xFFFF)
        SXX2 = Zero
    }

    Method (SX30, 1, NotSerialized)
    {
        Local0 = SXX2 /* \SXX2 */
        Local0++
        If ((Local0 <= SizeOf (SXX0)))
        {
            CreateByteField (SXX0, SXX2, SX20)
            SX20 = Arg0
            SXX2 = Local0
        }
    }

    Method (SX33, 2, NotSerialized)
    {
        If ((Arg1 < SizeOf (Arg0)))
        {
            CreateByteField (Arg0, Arg1, SX20)
            SX30 (SX20)
        }
    }

    Method (SX34, 2, NotSerialized)
    {
        Local0 = Zero
        While ((Local0 < Arg1))
        {
            SX33 (Arg0, Local0)
            Local0++
        }
    }

    Method (SXX6, 2, NotSerialized)
    {
        SMID = Arg1
        SMIC = Arg0
        Local0 = SMIC /* \SMIC */
        While ((Local0 != Zero))
        {
            Local0 = SMIC /* \SMIC */
        }

        Return (SMID) /* \SMID */
    }

    Method (SXX5, 2, NotSerialized)
    {
        If ((Arg1 < SizeOf (Arg0)))
        {
            CreateByteField (Arg0, Arg1, SX20)
            SXX6 (0x98, SX20)
        }
    }

    Method (SXX4, 0, NotSerialized)
    {
        SXX6 (0x96, Zero)
        Local0 = Zero
        While ((Local0 < SXX2))
        {
            SXX5 (SXX0, Local0)
            Local0++
        }
    }

    Method (SXX8, 2, NotSerialized)
    {
        If ((Arg1 < SizeOf (Arg0)))
        {
            CreateByteField (Arg0, Arg1, SX20)
            SX20 = SXX6 (0x97, Zero)
        }
    }

    Method (SXX7, 0, NotSerialized)
    {
        Local0 = Zero
        While ((Local0 < SXX3))
        {
            Local1 = (SXX2 + Local0)
            SXX8 (SXX0, Local1)
            Local0++
        }
    }

    Method (SX11, 0, NotSerialized)
    {
        SXX4 ()
        SXX3 = SXX6 (0x99, Zero)
        Local0 = (SXX2 + SXX3) /* \SXX3 */
        If ((SizeOf (SXX0) < Local0))
        {
            Local0 = SizeOf (SXX0)
            Local0 -= SXX2 /* \SXX2 */
            SXX3 = Local0
        }

        SXX7 ()
    }

    Method (SX40, 0, NotSerialized)
    {
        Local0 = SXX2 /* \SXX2 */
        Local0++
        If ((Local0 <= SizeOf (SXX0)))
        {
            CreateByteField (SXX0, SXX2, SX20)
            SXX2 = Local0
            Return (SX20) /* \SX40.SX20 */
        }

        Return (Zero)
    }

    Method (SX42, 0, NotSerialized)
    {
        Local0 = SXX2 /* \SXX2 */
        Local0 += 0x04
        If ((Local0 <= SizeOf (SXX0)))
        {
            CreateDWordField (SXX0, SXX2, SX22)
            SXX2 = Local0
            Return (SX22) /* \SX42.SX22 */
        }

        Return (Zero)
    }

    Method (SX43, 2, NotSerialized)
    {
        If ((Arg1 < SizeOf (Arg0)))
        {
            CreateByteField (Arg0, Arg1, SX20)
            SX20 = SX40 ()
        }
    }

    Method (SX44, 2, NotSerialized)
    {
        Local0 = Zero
        While ((Local0 < Arg1))
        {
            SX43 (Arg0, Local0)
            Local0++
        }
    }

    Method (SX12, 0, NotSerialized)
    {
        Release (SMIX)
    }

    Method (GMMI, 0, NotSerialized)
    {
        Local0 = SMI2 (0xD0)
        Local0 <<= 0x10
        Return (Local0)
    }

    Method (GMMX, 0, NotSerialized)
    {
        Local0 = SMI2 (0xD1)
        Local0 <<= 0x10
        If ((Local0 != Zero))
        {
            Local0 |= 0xFFFF
        }

        Return (Local0)
    }

    Method (GIOB, 0, NotSerialized)
    {
        Local0 = SMI2 (0xD2)
        Local0 &= 0xFFFF
        Return (Local0)
    }

    Method (GIOX, 0, NotSerialized)
    {
        Local0 = SMI2 (0xD3)
        Local0 &= 0xFFFF
        Return (Local0)
    }

    Scope (_PR)
    {
        Processor (CPU0, 0x01, 0x00000810, 0x06){}
        Processor (CPU1, 0x02, 0x00000000, 0x00){}
        Processor (CPU2, 0x03, 0x00000000, 0x00){}
        Processor (CPU3, 0x04, 0x00000000, 0x00){}
    }

    Scope (_PR.CPU0)
    {
        Method (_PSS, 0, NotSerialized)  // _PSS: Performance Supported States
        {
            Return (Package (0x04)
            {
                Package (0x06)
                {
                    Zero, 
                    Zero, 
                    0x0A, 
                    0x0A, 
                    0x0922, 
                    Zero
                }, 

                Package (0x06)
                {
                    Zero, 
                    Zero, 
                    0x0A, 
                    0x0A, 
                    0x081E, 
                    One
                }, 

                Package (0x06)
                {
                    Zero, 
                    Zero, 
                    0x0A, 
                    0x0A, 
                    0x071A, 
                    0x02
                }, 

                Package (0x06)
                {
                    Zero, 
                    Zero, 
                    0x0A, 
                    0x0A, 
                    0x0616, 
                    0x03
                }
            })
        }

        Method (_CST, 0, NotSerialized)  // _CST: C-States
        {
            Return (Package (0x04)
            {
                0x03, 
                Package (0x04)
                {
                    ResourceTemplate ()
                    {
                        Register (FFixedHW, 
                            0x01,               // Bit Width
                            0x02,               // Bit Offset
                            0x0000000000000000, // Address
                            ,)
                    }, 

                    One, 
                    Zero, 
                    0x03E8
                }, 

                Package (0x04)
                {
                    ResourceTemplate ()
                    {
                        Register (FFixedHW, 
                            0x08,               // Bit Width
                            0x00,               // Bit Offset
                            0x0000000000000414, // Address
                            ,)
                    }, 

                    0x02, 
                    One, 
                    0x01F4
                }, 

                Package (0x04)
                {
                    ResourceTemplate ()
                    {
                        Register (FFixedHW, 
                            0x08,               // Bit Width
                            0x00,               // Bit Offset
                            0x0000000000000415, // Address
                            ,)
                    }, 

                    0x03, 
                    0x55, 
                    0xFA
                }
            })
        }
    }

    Scope (_PR.CPU1)
    {
        Method (_PSS, 0, NotSerialized)  // _PSS: Performance Supported States
        {
            Return (^^CPU0._PSS ())
        }

        Method (_CST, 0, NotSerialized)  // _CST: C-States
        {
            Return (Package (0x04)
            {
                0x03, 
                Package (0x04)
                {
                    ResourceTemplate ()
                    {
                        Register (FFixedHW, 
                            0x01,               // Bit Width
                            0x02,               // Bit Offset
                            0x0000000000000000, // Address
                            ,)
                    }, 

                    One, 
                    Zero, 
                    0x03E8
                }, 

                Package (0x04)
                {
                    ResourceTemplate ()
                    {
                        Register (FFixedHW, 
                            0x08,               // Bit Width
                            0x00,               // Bit Offset
                            0x0000000000000414, // Address
                            ,)
                    }, 

                    0x02, 
                    One, 
                    0x01F4
                }, 

                Package (0x04)
                {
                    ResourceTemplate ()
                    {
                        Register (FFixedHW, 
                            0x08,               // Bit Width
                            0x00,               // Bit Offset
                            0x0000000000000415, // Address
                            ,)
                    }, 

                    0x03, 
                    0x55, 
                    0xFA
                }
            })
        }
    }

    Scope (_PR.CPU2)
    {
        Method (_PSS, 0, NotSerialized)  // _PSS: Performance Supported States
        {
            Return (^^CPU0._PSS ())
        }

        Method (_CST, 0, NotSerialized)  // _CST: C-States
        {
            Return (Package (0x04)
            {
                0x03, 
                Package (0x04)
                {
                    ResourceTemplate ()
                    {
                        Register (FFixedHW, 
                            0x01,               // Bit Width
                            0x02,               // Bit Offset
                            0x0000000000000000, // Address
                            ,)
                    }, 

                    One, 
                    Zero, 
                    0x03E8
                }, 

                Package (0x04)
                {
                    ResourceTemplate ()
                    {
                        Register (FFixedHW, 
                            0x08,               // Bit Width
                            0x00,               // Bit Offset
                            0x0000000000000414, // Address
                            ,)
                    }, 

                    0x02, 
                    One, 
                    0x01F4
                }, 

                Package (0x04)
                {
                    ResourceTemplate ()
                    {
                        Register (FFixedHW, 
                            0x08,               // Bit Width
                            0x00,               // Bit Offset
                            0x0000000000000415, // Address
                            ,)
                    }, 

                    0x03, 
                    0x55, 
                    0xFA
                }
            })
        }
    }

    Scope (_PR.CPU3)
    {
        Method (_PSS, 0, NotSerialized)  // _PSS: Performance Supported States
        {
            Return (^^CPU0._PSS ())
        }

        Method (_CST, 0, NotSerialized)  // _CST: C-States
        {
            Return (Package (0x04)
            {
                0x03, 
                Package (0x04)
                {
                    ResourceTemplate ()
                    {
                        Register (FFixedHW, 
                            0x01,               // Bit Width
                            0x02,               // Bit Offset
                            0x0000000000000000, // Address
                            ,)
                    }, 

                    One, 
                    Zero, 
                    0x03E8
                }, 

                Package (0x04)
                {
                    ResourceTemplate ()
                    {
                        Register (FFixedHW, 
                            0x08,               // Bit Width
                            0x00,               // Bit Offset
                            0x0000000000000414, // Address
                            ,)
                    }, 

                    0x02, 
                    One, 
                    0x01F4
                }, 

                Package (0x04)
                {
                    ResourceTemplate ()
                    {
                        Register (FFixedHW, 
                            0x08,               // Bit Width
                            0x00,               // Bit Offset
                            0x0000000000000415, // Address
                            ,)
                    }, 

                    0x03, 
                    0x55, 
                    0xFA
                }
            })
        }
    }

    Scope (\)
    {
        Name (SSTX, Zero)
        Method (_PTS, 1, NotSerialized)  // _PTS: Prepare To Sleep
        {
            If ((Arg0 == 0x05))
            {
                SLPE = Zero
                Sleep (0x10)
            }
        }
    }

    Device (AMW0)
    {
        Mutex (WMIX, 0x01)
        Name (_HID, "PNP0C14" /* Windows Management Instrumentation Device */)  // _HID: Hardware ID
        Name (_UID, Zero)  // _UID: Unique ID
        Method (STBY, 3, NotSerialized)
        {
            CreateByteField (Arg0, Arg1, TMP)
            TMP = Arg2
        }

        Method (STWD, 3, NotSerialized)
        {
            CreateWordField (Arg0, Arg1, TMP)
            TMP = Arg2
        }

        Method (STDW, 3, NotSerialized)
        {
            CreateDWordField (Arg0, Arg1, TMP)
            TMP = Arg2
        }

        Method (CLBY, 1, NotSerialized)
        {
            Local0 = Zero
            While ((Local0 < SizeOf (Arg0)))
            {
                STBY (Arg0, Local0, Zero)
                Local0++
            }
        }

        Name (_WDG, Buffer (0x64)
        {
            /* 0000 */  0xBC, 0xDC, 0x9D, 0x8D, 0x97, 0xA9, 0xDA, 0x11,  // ........
            /* 0008 */  0xB0, 0x12, 0xB6, 0x22, 0xA1, 0xEF, 0x54, 0x92,  // ..."..T.
            /* 0010 */  0x41, 0x41, 0x01, 0x00, 0xCE, 0x93, 0x05, 0xA8,  // AA......
            /* 0018 */  0x97, 0xA9, 0xDA, 0x11, 0xB0, 0x12, 0xB6, 0x22,  // ......."
            /* 0020 */  0xA1, 0xEF, 0x54, 0x92, 0x42, 0x41, 0x01, 0x02,  // ..T.BA..
            /* 0028 */  0x94, 0x59, 0xBB, 0x9D, 0x97, 0xA9, 0xDA, 0x11,  // .Y......
            /* 0030 */  0xB0, 0x12, 0xB6, 0x22, 0xA1, 0xEF, 0x54, 0x92,  // ..."..T.
            /* 0038 */  0xD0, 0x00, 0x01, 0x08, 0xE0, 0x6C, 0x77, 0xA3,  // .....lw.
            /* 0040 */  0x88, 0x1E, 0xDB, 0x11, 0xA9, 0x8B, 0x08, 0x00,  // ........
            /* 0048 */  0x20, 0x0C, 0x9A, 0x66, 0x42, 0x43, 0x01, 0x00,  //  ..fBC..
            /* 0050 */  0x21, 0x12, 0x90, 0x05, 0x66, 0xD5, 0xD1, 0x11,  // !...f...
            /* 0058 */  0xB2, 0xF0, 0x00, 0xA0, 0xC9, 0x06, 0x29, 0x10,  // ......).
            /* 0060 */  0x4D, 0x4F, 0x01, 0x00                           // MO..
        })
        Name (INFO, Buffer (0x80){})
        Name (ECD0, Zero)
        Method (WED0, 1, NotSerialized)
        {
            ECD0 = Arg0
            Return (Zero)
        }

        Method (WCAA, 1, NotSerialized)
        {
            Return (Zero)
        }

        Method (WQAA, 1, NotSerialized)
        {
            Acquire (WMIX, 0xFFFF)
            CLBY (INFO)
            If ((Arg0 != Zero))
            {
                Local1 = INFO /* \AMW0.INFO */
            }
            Else
            {
                STDW (INFO, Zero, 0x4C4C4544)
                STDW (INFO, 0x04, 0x494D5720)
                STDW (INFO, 0x08, One)
                STDW (INFO, 0x0C, 0x1000)
                Local1 = INFO /* \AMW0.INFO */
            }

            Release (WMIX)
            Return (Local1)
        }

        Method (WSAA, 2, NotSerialized)
        {
            Return (Arg1)
        }

        Method (WMBA, 3, NotSerialized)
        {
            CreateDWordField (Arg2, 0x28, WBUF)
            Local1 = (WBUF + 0x2C)
            If ((Local1 <= 0x1000))
            {
                Local0 = WMI (Arg2, Local1)
            }

            Return (Local0)
        }

        Method (_WED, 1, NotSerialized)  // _Wxx: Wake Event, xx=0x00-0xFF
        {
            Acquire (WMIX, 0xFFFF)
            CLBY (INFO)
            If (((Arg0 != 0xD0) || (ECD0 == Zero)))
            {
                Local1 = INFO /* \AMW0.INFO */
            }
            Else
            {
                SX10 ()
                SX30 (One)
                SX11 ()
                Local0 = SX42 ()
                SX12 ()
                STDW (INFO, Zero, Local0)
                Local1 = INFO /* \AMW0.INFO */
            }

            Release (WMIX)
            Return (Local1)
        }

        Name (WQMO, Buffer (0x0572)
        {
            /* 0000 */  0x46, 0x4F, 0x4D, 0x42, 0x01, 0x00, 0x00, 0x00,  // FOMB....
            /* 0008 */  0x62, 0x05, 0x00, 0x00, 0x88, 0x1C, 0x00, 0x00,  // b.......
            /* 0010 */  0x44, 0x53, 0x00, 0x01, 0x1A, 0x7D, 0xDA, 0x54,  // DS...}.T
            /* 0018 */  0x18, 0xD5, 0x8D, 0x00, 0x01, 0x06, 0x18, 0x42,  // .......B
            /* 0020 */  0x10, 0x0F, 0x10, 0x22, 0x21, 0x04, 0x12, 0x01,  // ..."!...
            /* 0028 */  0xA1, 0xC8, 0x2C, 0x0C, 0x86, 0x10, 0x38, 0x2E,  // ..,...8.
            /* 0030 */  0x84, 0x1C, 0x40, 0x48, 0x1C, 0x14, 0x4A, 0x08,  // ..@H..J.
            /* 0038 */  0x84, 0xFA, 0x13, 0xC8, 0xAF, 0x00, 0x84, 0x0E,  // ........
            /* 0040 */  0x05, 0xC8, 0x14, 0x60, 0x50, 0x80, 0x53, 0x04,  // ...`P.S.
            /* 0048 */  0x11, 0xF4, 0x2A, 0xC0, 0xA6, 0x00, 0x93, 0x02,  // ..*.....
            /* 0050 */  0x2C, 0x0A, 0xD0, 0x2E, 0xC0, 0xB2, 0x00, 0xDD,  // ,.......
            /* 0058 */  0x02, 0xA4, 0xC3, 0x12, 0x91, 0xE0, 0x28, 0x31,  // ......(1
            /* 0060 */  0xE0, 0x28, 0x9D, 0xD8, 0xC2, 0x0D, 0x1B, 0xBC,  // .(......
            /* 0068 */  0x50, 0x14, 0xCD, 0x20, 0x4A, 0x82, 0xCA, 0x05,  // P.. J...
            /* 0070 */  0xF8, 0x46, 0x10, 0x78, 0xB9, 0x02, 0x24, 0x4F,  // .F.x..$O
            /* 0078 */  0x40, 0x9A, 0x05, 0x18, 0x16, 0x60, 0x5D, 0x80,  // @....`].
            /* 0080 */  0xEC, 0x21, 0x50, 0xA9, 0x43, 0x40, 0xC9, 0x19,  // .!P.C@..
            /* 0088 */  0x02, 0x6A, 0x00, 0xAD, 0x4E, 0x40, 0xF8, 0x95,  // .j..N@..
            /* 0090 */  0x4E, 0x09, 0x49, 0x10, 0xCE, 0x58, 0xC5, 0xE3,  // N.I..X..
            /* 0098 */  0x6B, 0x16, 0x4D, 0xCF, 0x49, 0xCE, 0x31, 0xE4,  // k.M.I.1.
            /* 00A0 */  0x78, 0x5C, 0xE8, 0x41, 0xF0, 0x40, 0x0A, 0x40,  // x\.A.@.@
            /* 00A8 */  0x58, 0x78, 0x08, 0x45, 0x80, 0x41, 0x49, 0x18,  // Xx.E.AI.
            /* 00B0 */  0x0B, 0x75, 0x31, 0x6A, 0xD4, 0x48, 0xD9, 0x80,  // .u1j.H..
            /* 00B8 */  0x0C, 0x51, 0xDA, 0xA8, 0xD1, 0x03, 0x3A, 0xBF,  // .Q....:.
            /* 00C0 */  0x23, 0x39, 0xBB, 0xA3, 0x3B, 0x92, 0x04, 0x46,  // #9..;..F
            /* 00C8 */  0x3D, 0xA6, 0x63, 0x2C, 0x6C, 0x46, 0x42, 0x8D,  // =.c,lFB.
            /* 00D0 */  0xD1, 0x1C, 0x14, 0x81, 0xC6, 0x0D, 0xDA, 0x12,  // ........
            /* 00D8 */  0x61, 0x35, 0xAE, 0xD8, 0x67, 0x66, 0xE1, 0xC3,  // a5..gf..
            /* 00E0 */  0x12, 0xC6, 0x11, 0x1C, 0x58, 0x82, 0x46, 0xD1,  // ....X.F.
            /* 00E8 */  0x34, 0xC7, 0xB3, 0x0D, 0x91, 0xE0, 0x20, 0x42,  // 4..... B
            /* 00F0 */  0x63, 0x64, 0x40, 0xC8, 0xF3, 0xB0, 0x05, 0x7A,  // cd@....z
            /* 00F8 */  0xE4, 0x09, 0xEC, 0x1E, 0x51, 0x0A, 0x11, 0x34,  // ....Q..4
            /* 0100 */  0xDF, 0x13, 0xA9, 0x51, 0x80, 0x36, 0x0C, 0xD9,  // ...Q.6..
            /* 0108 */  0x3A, 0x1B, 0x68, 0xA8, 0xB1, 0x1A, 0x43, 0x11,  // :.h...C.
            /* 0110 */  0x44, 0x84, 0xA0, 0x51, 0x0C, 0x16, 0x21, 0x54,  // D..Q..!T
            /* 0118 */  0x88, 0xFF, 0x7F, 0x94, 0xA8, 0xA7, 0x14, 0x24,  // .......$
            /* 0120 */  0x6A, 0x65, 0x20, 0x42, 0x0B, 0x66, 0x04, 0x66,  // je B.f.f
            /* 0128 */  0x7F, 0x10, 0x24, 0xC6, 0x99, 0x41, 0x87, 0x05,  // ..$..A..
            /* 0130 */  0xCB, 0x00, 0x91, 0x11, 0x41, 0xA3, 0x61, 0x67,  // ....A.ag
            /* 0138 */  0x01, 0x0F, 0xC7, 0x33, 0x69, 0x7E, 0x62, 0x1A,  // ...3i~b.
            /* 0140 */  0x9C, 0x09, 0xC6, 0x86, 0x90, 0x06, 0x08, 0x89,  // ........
            /* 0148 */  0x3A, 0x38, 0x50, 0x02, 0x4B, 0x19, 0x38, 0xB1,  // :8P.K.8.
            /* 0150 */  0x3D, 0x2E, 0x8D, 0xEF, 0x8C, 0xA3, 0x86, 0x38,  // =......8
            /* 0158 */  0xF5, 0x33, 0xF3, 0x3F, 0xC2, 0x5B, 0xF0, 0x11,  // .3.?.[..
            /* 0160 */  0x80, 0x8F, 0xC1, 0x83, 0x3D, 0x84, 0x80, 0x47,  // ....=..G
            /* 0168 */  0xC8, 0xCE, 0x00, 0x06, 0xC4, 0x7B, 0x9F, 0x34,  // .....{.4
            /* 0170 */  0x99, 0x8B, 0xCF, 0x02, 0x30, 0x86, 0x0F, 0xD7,  // ....0...
            /* 0178 */  0xF8, 0x28, 0x34, 0x1E, 0x76, 0x3E, 0x60, 0xE3,  // .(4.v>`.
            /* 0180 */  0xE2, 0xF0, 0x3E, 0x14, 0x9C, 0x70, 0xB1, 0x20,  // ..>..p. 
            /* 0188 */  0x0A, 0x00, 0x21, 0x59, 0xE7, 0x03, 0xF4, 0xAC,  // ..!Y....
            /* 0190 */  0x8F, 0x2D, 0xE0, 0xC3, 0x40, 0xB3, 0x77, 0x08,  // .-..@.w.
            /* 0198 */  0x42, 0xF0, 0x22, 0xE0, 0xA3, 0x83, 0x8F, 0x1B,  // B.".....
            /* 01A0 */  0x1E, 0xF7, 0xF3, 0x06, 0x18, 0x0E, 0x07, 0x1E,  // ........
            /* 01A8 */  0x8E, 0x4F, 0x1B, 0xC0, 0x65, 0x04, 0x5C, 0xDA,  // .O..e.\.
            /* 01B0 */  0x93, 0xC2, 0x04, 0x92, 0xFC, 0x04, 0x90, 0x18,  // ........
            /* 01B8 */  0x18, 0xD4, 0x81, 0xC0, 0x07, 0x0B, 0xB8, 0x92,  // ........
            /* 01C0 */  0xE0, 0x50, 0xC3, 0xF3, 0xC4, 0x1E, 0x10, 0xFE,  // .P......
            /* 01C8 */  0xFF, 0x47, 0x79, 0x22, 0x2F, 0x06, 0x9E, 0xFE,  // .Gy"/...
            /* 01D0 */  0x63, 0x00, 0x8C, 0x03, 0x82, 0xA7, 0x75, 0x52,  // c.....uR
            /* 01D8 */  0xBE, 0x79, 0x3C, 0x48, 0x78, 0x50, 0x61, 0x12,  // .y<HxPa.
            /* 01E0 */  0xF8, 0x94, 0xC0, 0xD0, 0xF8, 0x71, 0x03, 0xAC,  // .....q..
            /* 01E8 */  0xA3, 0xC6, 0x1F, 0x10, 0xE0, 0x9D, 0x24, 0xCE,  // ......$.
            /* 01F0 */  0xAF, 0xCF, 0x01, 0xE8, 0xD0, 0x70, 0x8A, 0x0C,  // .....p..
            /* 01F8 */  0xE4, 0x35, 0xE0, 0xA4, 0x4F, 0xC9, 0xE3, 0x4B,  // .5..O..K
            /* 0200 */  0xE0, 0x33, 0x07, 0xEC, 0xBB, 0xC1, 0x61, 0x1C,  // .3....a.
            /* 0208 */  0x4C, 0x88, 0x08, 0xEF, 0x01, 0x4F, 0x1D, 0xBE,  // L....O..
            /* 0210 */  0x6B, 0x3C, 0x0A, 0x04, 0x8A, 0xD0, 0xDB, 0x99,  // k<......
            /* 0218 */  0x83, 0x9E, 0x42, 0x8C, 0x12, 0xED, 0xAC, 0xC2,  // ..B.....
            /* 0220 */  0x3C, 0x70, 0x44, 0xF1, 0x91, 0xC3, 0x08, 0xEF,  // <pD.....
            /* 0228 */  0x1E, 0xBE, 0x13, 0x3C, 0x80, 0xB4, 0x36, 0x39,  // ...<..69
            /* 0230 */  0xE1, 0x06, 0x7A, 0xE6, 0x60, 0xD1, 0xCE, 0x2C,  // ..z.`..,
            /* 0238 */  0xB2, 0x00, 0xA2, 0x48, 0xA3, 0x41, 0x9D, 0x11,  // ...H.A..
            /* 0240 */  0x7C, 0x1A, 0xF0, 0xB4, 0x9E, 0x62, 0x7C, 0x94,  // |....b|.
            /* 0248 */  0x30, 0xC8, 0x19, 0x1E, 0xD8, 0x73, 0xC2, 0x63,  // 0....s.c
            /* 0250 */  0x80, 0x07, 0xCC, 0xEE, 0x07, 0x3E, 0x4E, 0xF8,  // .....>N.
            /* 0258 */  0x5C, 0x80, 0x77, 0x0D, 0xA8, 0x19, 0xFA, 0xB0,  // \.w.....
            /* 0260 */  0x01, 0xE7, 0xD0, 0x81, 0x3F, 0x4D, 0xE0, 0x0F,  // ....?M..
            /* 0268 */  0x16, 0xF8, 0xF1, 0xF8, 0x9A, 0xC3, 0x26, 0x9C,  // ......&.
            /* 0270 */  0xC0, 0xF2, 0x07, 0x81, 0x1A, 0x99, 0xA1, 0x3D,  // .......=
            /* 0278 */  0xCB, 0xD3, 0x7A, 0x0D, 0xF0, 0x69, 0xC7, 0x04,  // ..z..i..
            /* 0280 */  0x3E, 0x6F, 0xF8, 0xFF, 0xFF, 0xCF, 0xF1, 0x78,  // >o.....x
            /* 0288 */  0xC0, 0xAF, 0xF8, 0x74, 0x41, 0xEE, 0x0A, 0x9E,  // ...tA...
            /* 0290 */  0xAF, 0xCF, 0x2E, 0xCC, 0xC6, 0x78, 0x50, 0xA3,  // .....xP.
            /* 0298 */  0xF0, 0x01, 0x07, 0x77, 0x76, 0xF1, 0x11, 0xC0,  // ...wv...
            /* 02A0 */  0x67, 0x17, 0xE0, 0x39, 0x89, 0x67, 0x09, 0xF0,  // g..9.g..
            /* 02A8 */  0x1E, 0x02, 0x7C, 0x22, 0x89, 0xF7, 0xB0, 0x05,  // ..|"....
            /* 02B0 */  0x63, 0xC4, 0x78, 0xC8, 0x33, 0xAE, 0x7A, 0x18,  // c.x.3.z.
            /* 02B8 */  0xBA, 0x08, 0x58, 0xDD, 0x7D, 0x05, 0x75, 0xF4,  // ..X.}.u.
            /* 02C0 */  0x02, 0x13, 0xD4, 0x6B, 0x06, 0xEE, 0xF4, 0x02,  // ...k....
            /* 02C8 */  0x7C, 0x4E, 0x59, 0xF0, 0xFE, 0xFF, 0xA7, 0x2C,  // |NY....,
            /* 02D0 */  0xE0, 0x7E, 0x55, 0xE0, 0x47, 0x14, 0x30, 0x40,  // .~U.G.0@
            /* 02D8 */  0x76, 0x76, 0x3A, 0x11, 0xC2, 0x7B, 0xC9, 0x73,  // vv:..{.s
            /* 02E0 */  0x88, 0x6F, 0x57, 0x3E, 0x98, 0x04, 0x79, 0x0E,  // .oW>..y.
            /* 02E8 */  0x88, 0xF0, 0x94, 0xC5, 0xEF, 0x03, 0x51, 0x62,  // ......Qb
            /* 02F0 */  0x1E, 0x50, 0xA4, 0x28, 0x46, 0x0C, 0xF2, 0x84,  // .P.(F...
            /* 02F8 */  0xE5, 0xEB, 0x49, 0x0C, 0x43, 0x07, 0x0B, 0x17,  // ..I.C...
            /* 0300 */  0x3E, 0xC2, 0x53, 0x16, 0x60, 0xF1, 0x92, 0x85,  // >.S.`...
            /* 0308 */  0x39, 0x65, 0xC1, 0x7C, 0x1B, 0xF8, 0x94, 0x05,  // 9e.|....
            /* 0310 */  0x8E, 0xFF, 0xFF, 0x29, 0x0B, 0x5C, 0xE3, 0x7E,  // ...).\.~
            /* 0318 */  0xCA, 0x02, 0x66, 0xD2, 0x9F, 0x02, 0x3E, 0xD5,  // ..f...>.
            /* 0320 */  0xF8, 0x09, 0xA0, 0xE8, 0x07, 0x0B, 0x0A, 0xE3,  // ........
            /* 0328 */  0x53, 0x16, 0xE0, 0x4A, 0xDE, 0x01, 0x01, 0x34,  // S..J...4
            /* 0330 */  0x67, 0x27, 0xDF, 0x16, 0x0C, 0x76, 0xCC, 0xBE,  // g'...v..
            /* 0338 */  0x64, 0xF8, 0x94, 0x08, 0x86, 0x43, 0x86, 0xEF,  // d....C..
            /* 0340 */  0x54, 0x87, 0xF2, 0xC8, 0xF1, 0x14, 0xE0, 0x23,  // T......#
            /* 0348 */  0x16, 0xD8, 0xE3, 0x1C, 0x03, 0x74, 0x5C, 0xF1,  // .....t\.
            /* 0350 */  0x11, 0xCB, 0xFF, 0xFF, 0x23, 0x16, 0xC0, 0x8D,  // ....#...
            /* 0358 */  0x03, 0x08, 0xFE, 0xD4, 0x01, 0xEB, 0x1E, 0x10,  // ........
            /* 0360 */  0xD6, 0x87, 0x0E, 0xE0, 0x21, 0xFB, 0x21, 0xA0,  // ....!.!.
            /* 0368 */  0x33, 0x8C, 0x25, 0x83, 0xC8, 0xC6, 0xB9, 0x86,  // 3.%.....
            /* 0370 */  0x8E, 0xD1, 0xE2, 0x17, 0xAA, 0x9B, 0x42, 0xEC,  // ......B.
            /* 0378 */  0x83, 0xE1, 0xB2, 0x81, 0x04, 0xEA, 0xE1, 0x5A,  // .......Z
            /* 0380 */  0x30, 0x85, 0x44, 0xD1, 0x68, 0x34, 0x06, 0x26,  // 0.D.h4.&
            /* 0388 */  0x30, 0x82, 0x33, 0x88, 0x01, 0x9D, 0x11, 0x42,  // 0.3....B
            /* 0390 */  0x87, 0x32, 0x9C, 0x8A, 0xF3, 0x10, 0xEA, 0xFF,  // .2......
            /* 0398 */  0x4F, 0x30, 0xD4, 0x8D, 0x89, 0xCE, 0xCE, 0xF3,  // O0......
            /* 03A0 */  0xE7, 0xB7, 0x11, 0x9F, 0x08, 0x0C, 0xEC, 0x2B,  // .......+
            /* 03A8 */  0xC4, 0x5B, 0x06, 0x58, 0x86, 0xE5, 0xC5, 0x3D,  // .[.X...=
            /* 03B0 */  0x01, 0x1C, 0xE3, 0x49, 0x26, 0xA8, 0xE6, 0x58,  // ...I&..X
            /* 03B8 */  0x83, 0x9A, 0x83, 0xAF, 0x02, 0x6F, 0x64, 0x26,  // .....od&
            /* 03C0 */  0xF0, 0x15, 0x0C, 0x6C, 0xA7, 0x19, 0x8C, 0xBE,  // ...l....
            /* 03C8 */  0x3B, 0x01, 0x28, 0x80, 0x7C, 0x14, 0xF0, 0x7D,  // ;.(.|..}
            /* 03D0 */  0xF9, 0x6D, 0x80, 0xCD, 0xE2, 0x95, 0xD9, 0x68,  // .m.....h
            /* 03D8 */  0x3E, 0x7F, 0x22, 0x86, 0x8E, 0x12, 0x33, 0x74,  // >."...3t
            /* 03E0 */  0x0A, 0xE2, 0xA1, 0x3B, 0xE8, 0xD0, 0xD1, 0xC7,  // ...;....
            /* 03E8 */  0x01, 0x9F, 0xAC, 0x70, 0xC1, 0x0E, 0x5F, 0xD0,  // ...p.._.
            /* 03F0 */  0x26, 0x77, 0xB4, 0x27, 0xE6, 0x59, 0x78, 0x9E,  // &w.'.Yx.
            /* 03F8 */  0xB8, 0xB9, 0x83, 0xE9, 0x88, 0x04, 0x63, 0xF0,  // ......c.
            /* 0400 */  0x98, 0xC9, 0x83, 0x59, 0xE0, 0xE4, 0x41, 0xF1,  // ...Y..A.
            /* 0408 */  0xFF, 0x9F, 0x3C, 0x4C, 0x78, 0x4C, 0xD8, 0xC3,  // ..<LxL..
            /* 0410 */  0x21, 0x3D, 0x74, 0x78, 0x64, 0x7C, 0x9C, 0x3E,  // !=txd|.>
            /* 0418 */  0xFD, 0x30, 0xEC, 0xD3, 0x39, 0x97, 0xA2, 0x67,  // .0..9..g
            /* 0420 */  0xA4, 0x3B, 0xC6, 0x33, 0x17, 0x06, 0xD6, 0x23,  // .;.3...#
            /* 0428 */  0xE7, 0xB0, 0x46, 0x0B, 0x7B, 0xC0, 0xCF, 0x21,  // ..F.{..!
            /* 0430 */  0xBE, 0xC3, 0xF8, 0xC0, 0xC3, 0x60, 0x7D, 0x7A,  // .....`}z
            /* 0438 */  0x01, 0xC7, 0xF1, 0x0B, 0xFE, 0x69, 0x00, 0x3C,  // .....i.<
            /* 0440 */  0x07, 0x10, 0x8F, 0xE1, 0x05, 0x84, 0x1F, 0x5F,  // ......._
            /* 0448 */  0x74, 0xFE, 0xA5, 0x42, 0x17, 0x27, 0x79, 0x30,  // t..B.'y0
            /* 0450 */  0xA8, 0xD3, 0x14, 0xE0, 0xEA, 0xF4, 0x06, 0x9E,  // ........
            /* 0458 */  0xAB, 0x3E, 0xEE, 0x2C, 0x85, 0xFB, 0xFF, 0x9F,  // .>.,....
            /* 0460 */  0xA5, 0x60, 0x1C, 0x7E, 0x7D, 0x81, 0xF7, 0x5D,  // .`.~}..]
            /* 0468 */  0xCA, 0x08, 0x07, 0xF2, 0x2C, 0x05, 0xF6, 0xD8,  // ....,...
            /* 0470 */  0xCF, 0x10, 0x1D, 0x02, 0x7C, 0x96, 0x02, 0xF8,  // ....|...
            /* 0478 */  0xF1, 0xFA, 0xF0, 0x79, 0x06, 0x6E, 0xE0, 0xD3,  // ...y.n..
            /* 0480 */  0x2F, 0xD0, 0xFA, 0xFF, 0x9F, 0x42, 0xC0, 0x7F,  // /....B..
            /* 0488 */  0x8C, 0xF0, 0x11, 0x07, 0x77, 0xB6, 0x01, 0xEF,  // ....w...
            /* 0490 */  0xD1, 0x17, 0x1C, 0x07, 0x63, 0x7E, 0xC6, 0xC0,  // ....c~..
            /* 0498 */  0x1D, 0xC7, 0x80, 0xC7, 0xC9, 0x19, 0x77, 0x9A,  // ......w.
            /* 04A0 */  0xF0, 0x10, 0xF8, 0x00, 0x5A, 0x9D, 0x1E, 0x39,  // ....Z..9
            /* 04A8 */  0xF5, 0x9C, 0x12, 0xEE, 0x38, 0xC0, 0xA7, 0x84,  // ....8...
            /* 04B0 */  0x1B, 0x00, 0x26, 0xC0, 0x19, 0x13, 0x50, 0xF5,  // ..&...P.
            /* 04B8 */  0xFF, 0x3F, 0x63, 0x02, 0x63, 0x90, 0x08, 0xEF,  // .?c.c...
            /* 04C0 */  0x0A, 0x51, 0xDF, 0x91, 0x0D, 0xF1, 0x8C, 0xCC,  // .Q......
            /* 04C8 */  0x70, 0xDE, 0x1A, 0x1E, 0x5F, 0x9E, 0x91, 0xC1,  // p..._...
            /* 04D0 */  0x79, 0xC6, 0x04, 0xF8, 0xF3, 0xFF, 0x3F, 0xD2,  // y.....?.
            /* 04D8 */  0x63, 0x6F, 0x0A, 0xC1, 0x9F, 0x42, 0x80, 0x89,  // co...B..
            /* 04E0 */  0xF8, 0x33, 0x26, 0x15, 0x7E, 0xC6, 0x84, 0x36,  // .3&.~..6
            /* 04E8 */  0x17, 0x4F, 0xDB, 0x67, 0x4C, 0x80, 0x7B, 0xFF,  // .O.gL.{.
            /* 04F0 */  0xFF, 0x33, 0x26, 0xE0, 0x3B, 0xF2, 0x19, 0x13,  // .3&.;...
            /* 04F8 */  0xD0, 0x73, 0xA4, 0xC2, 0x9D, 0x31, 0xC1, 0x30,  // .s...1.0
            /* 0500 */  0xCE, 0xF7, 0x27, 0x83, 0x3C, 0x8F, 0xF8, 0x40,  // ..'.<..@
            /* 0508 */  0xE0, 0xA3, 0x0C, 0x53, 0x68, 0xD3, 0xA7, 0x46,  // ...Sh..F
            /* 0510 */  0xA3, 0x56, 0x0D, 0xCA, 0xD4, 0x28, 0xD3, 0xA0,  // .V...(..
            /* 0518 */  0x56, 0x9F, 0x4A, 0x8D, 0x19, 0x3B, 0x3A, 0x59,  // V.J..;:Y
            /* 0520 */  0xC4, 0x5A, 0x35, 0x58, 0x87, 0x5A, 0xAF, 0x40,  // .Z5X.Z.@
            /* 0528 */  0x2C, 0xE9, 0x89, 0x21, 0x10, 0xFF, 0xFF, 0x45,  // ,..!...E
            /* 0530 */  0x79, 0x00, 0x61, 0x71, 0x4D, 0x80, 0x30, 0xE1,  // y.aqM.0.
            /* 0538 */  0xAB, 0x12, 0x88, 0x63, 0x83, 0x50, 0xB1, 0x3A,  // ...c.P.:
            /* 0540 */  0x20, 0x1A, 0x19, 0xA2, 0x41, 0x04, 0xE4, 0x10,  //  ...A...
            /* 0548 */  0x3E, 0x80, 0x58, 0x24, 0x10, 0x81, 0x13, 0x25,  // >.X$...%
            /* 0550 */  0xA0, 0xD4, 0x09, 0x08, 0x13, 0xBA, 0x16, 0x81,  // ........
            /* 0558 */  0x58, 0x9E, 0x17, 0x10, 0x16, 0x0E, 0x84, 0x4A,  // X......J
            /* 0560 */  0x32, 0x03, 0xCE, 0xF4, 0x81, 0x08, 0xC8, 0x52,  // 2......R
            /* 0568 */  0x5F, 0x21, 0x02, 0xB2, 0x70, 0x10, 0x01, 0xF9,  // _!..p...
            /* 0570 */  0xFF, 0x0F                                       // ..
        })
    }

    Mutex (WMIS, 0x01)
    Name (WM00, Zero)
    Method (WM02, 0, NotSerialized)
    {
        SX10 ()
        SX30 (Zero)
        SX11 ()
        WM00 = SX42 ()
        SX12 ()
    }

    Method (WM03, 3, NotSerialized)
    {
        OperationRegion (WWPR, SystemMemory, Arg0, One)
        Field (WWPR, ByteAcc, Lock, Preserve)
        {
            MEMW,   8
        }

        CreateByteField (Arg1, Arg2, WVAL)
        MEMW = WVAL /* \WM03.WVAL */
    }

    Method (WM05, 3, NotSerialized)
    {
        OperationRegion (WWPR, SystemMemory, Arg0, 0x04)
        Field (WWPR, ByteAcc, Lock, Preserve)
        {
            MW32,   32
        }

        CreateDWordField (Arg1, Arg2, WVAL)
        MW32 = WVAL /* \WM05.WVAL */
    }

    Method (WM04, 3, NotSerialized)
    {
        OperationRegion (WRPR, SystemMemory, Arg0, One)
        Field (WRPR, ByteAcc, Lock, Preserve)
        {
            MEMR,   8
        }

        CreateByteField (Arg1, Arg2, WVAL)
        WVAL = MEMR /* \WM04.MEMR */
        MEMR = Zero
    }

    Method (WM06, 3, NotSerialized)
    {
        OperationRegion (WRPR, SystemMemory, Arg0, 0x04)
        Field (WRPR, ByteAcc, Lock, Preserve)
        {
            MR32,   32
        }

        CreateDWordField (Arg1, Arg2, WVAL)
        WVAL = MR32 /* \WM06.MR32 */
        MR32 = Zero
    }

    Method (WM07, 2, NotSerialized)
    {
        If ((Arg1 <= 0x0100))
        {
            Local0 = WM00 /* \WM00 */
            Local1 = Zero
            While ((Local1 < Arg1))
            {
                WM05 (Local0, Arg0, Local1)
                Local0 += 0x04
                Local1 += 0x04
            }

            SXX6 (0x9A, Zero)
            Local0 = WM00 /* \WM00 */
            Local1 = Zero
            While ((Local1 < Arg1))
            {
                WM06 (Local0, Arg0, Local1)
                Local0 += 0x04
                Local1 += 0x04
            }
        }

        Return (Arg0)
    }

    Method (WMI, 2, NotSerialized)
    {
        Acquire (WMIS, 0xFFFF)
        If ((WM00 == Zero))
        {
            WM02 ()
        }

        WM07 (Arg0, Arg1)
        Release (WMIS)
        Return (Arg0)
    }

    OperationRegion (GIC1, SystemIO, 0x088C, 0x04)
    Field (GIC1, ByteAcc, NoLock, Preserve)
    {
        GI00,   8, 
        GI08,   8, 
        GI16,   8, 
        GI24,   8
    }

    OperationRegion (GIC2, SystemIO, 0x08B8, 0x04)
    Field (GIC2, ByteAcc, NoLock, Preserve)
    {
        GI32,   8, 
        GI40,   8, 
        GI48,   8, 
        GI56,   8
    }

    Mutex (BAYM, 0x01)
    Mutex (STSM, 0x01)
    Mutex (EVTM, 0x01)
    Mutex (FOOM, 0x01)
    Name (GTMT, Buffer (0x14)
    {
        /* 0000 */  0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,  // ........
        /* 0008 */  0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,  // ........
        /* 0010 */  0x11, 0x00, 0x00, 0x00                           // ....
    })
    CreateDWordField (GTMT, Zero, PIO0)
    CreateDWordField (GTMT, 0x04, DMA0)
    CreateDWordField (GTMT, 0x08, PIO1)
    CreateDWordField (GTMT, 0x0C, DMA1)
    CreateDWordField (GTMT, 0x10, IFLG)
    Method (_GPE._L06, 0, Serialized)  // _Lxx: Level-Triggered GPE, xx=0x00-0xFF
    {
        \_SB.PCI0.GRFX.GSCI ()
    }

    Method (_GPE._L1A, 0, NotSerialized)  // _Lxx: Level-Triggered GPE, xx=0x00-0xFF
    {
        LIDP ^= 0x04
        PME2 |= One
        Notify (\_SB.PCI0.PCI5, 0x02) // Device Wake
    }

    Method (_GPE._L1B, 0, NotSerialized)  // _Lxx: Level-Triggered GPE, xx=0x00-0xFF
    {
        LIDP ^= 0x08
        PME2 |= One
        Notify (\_SB.PCI0.PCI1, 0x02) // Device Wake
    }

    Method (_GPE._L1D, 0, NotSerialized)  // _Lxx: Level-Triggered GPE, xx=0x00-0xFF
    {
        LIDP ^= 0x20
        PME2 |= One
        Notify (\_SB.PCI0.PCI2, 0x02) // Device Wake
    }

    Method (_GPE._L08, 0, NotSerialized)  // _Lxx: Level-Triggered GPE, xx=0x00-0xFF
    {
        GPKM ()
        Alias (WEN3, MBEN)
        Alias (WST3, MBST)
        Alias (WST0, MPME)
        Acquire (EVTM, 0xFFFF)
        Local0 = MBST /* \_GPE._L08.MBST */
        Local0 &= 0x02
        If (Local0)
        {
            Local1 = CMRD (0x21)
            Local1 &= 0x60
            If (Local1)
            {
                Local1 = 0x64
                Local3 = Zero
                While ((Local0 || Local3))
                {
                    BAYE ()
                    Local0 = MBST /* \_GPE._L08.MBST */
                    Local0 &= 0x02
                    Local3 = GI40 /* \GI40 */
                    Local3 &= One
                    Local1--
                    If ((Local1 == Zero))
                    {
                        Local0 = Zero
                        Local3 = Zero
                    }
                }
            }
        }

        Release (EVTM)
        Local0 = MBST /* \_GPE._L08.MBST */
        Local0 &= 0x02
        MBST = Local0
        Local0 = MPME /* \_GPE._L08.MPME */
        Local0 &= One
        MPME = Local0
        If (~(SSTX == One))
        {
            Notify (\_SB.VBTN, 0x02) // Device Wake
        }

        Notify (\_SB.PCI0.ISA.KBD, 0x02) // Device Wake
    }

    Method (_WAK, 1, NotSerialized)  // _WAK: Wake
    {
        If ((Arg0 == 0x04))
        {
            GUSB ()
        }
        ElseIf ((Arg0 == 0x03))
        {
            If ((0x20 & CMRD (0x49)))
            {
                GUSB ()
            }
        }

        CMWR (0x49, (0xDF & CMRD (0x49)))
        Alias (WEN3, MBEN)
        Alias (WST3, MBST)
        If (((Arg0 == 0x03) | (Arg0 == 0x04)))
        {
            If ((MSOS == 0x04))
            {
                Notify (\_SB.PCI0.SATA.PRT1, Zero) // Bus Check
            }
            Else
            {
            }
        }

        Local0 = MBEN /* \_WAK.MBEN */
        MBEN = (Local0 | 0x02)
        If (((PMS2 & One) | ((!HACK () & (GLBT & 
            0x11)) | (!HACK () & (THRP & 0x18)))))
        {
            Notify (\_SB.VBTN, 0x02) // Device Wake
        }

        Return (Package (0x02)
        {
            Zero, 
            Zero
        })
    }

    Method (BAYE, 0, NotSerialized)
    {
        Alias (WEN3, MBEN)
        Alias (WST3, MBST)
        Acquire (MTX, 0xFFFF)
        Local1 = MBST /* \BAYE.MBST */
        Local1 &= 0x02
        Local0 = 0x2710
        While (Local1)
        {
            MBST = Local1
            Sleep (0x64)
            Local1 = MBST /* \BAYE.MBST */
            Local1 &= 0x02
            Local0--
            If ((Local0 == Zero))
            {
                Local1 = Zero
            }
        }

        If (Local0)
        {
            Local0 = SGP2 /* \SGP2 */
            Local0 &= 0x02
            If (Local0)
            {
                Acquire (STSM, 0xFFFF)
                Local1 = CMRD (0x2C)
                Local1 &= 0x04
                Release (STSM)
                If (Local1)
                {
                    IDER ()
                    Local1 = CMRD (0x3B)
                    Local1 |= 0x20
                    CMWR (0x3B, Local1)
                }

                Local0 = GI48 /* \GI48 */
                GI48 = (Local0 & 0xF7)
            }
            Else
            {
                Local0 = GI40 /* \GI40 */
                Local0 &= One
                If (Local0)
                {
                    Local1 = CMRD (0x21)
                    Local1 &= 0x20
                    If ((Local1 == Zero))
                    {
                        Local0 = GI48 /* \GI48 */
                        GI48 = (Local0 & 0xF7)
                    }

                    IDER ()
                }
                Else
                {
                    Local0 = CMRD (0x21)
                    Local0 &= 0x40
                    If (Local0)
                    {
                        IDEA ()
                        Local1 = CMRD (0x3B)
                        Local1 |= 0x20
                        CMWR (0x3B, Local1)
                    }
                }
            }
        }

        Release (MTX)
    }

    Method (IDEA, 0, NotSerialized)
    {
        Acquire (BAYM, 0xFFFF)
        Acquire (SMIM, 0xFFFF)
        SMID = Zero
        Release (SMIM)
        MBAY ()
        Acquire (STSM, 0xFFFF)
        Acquire (SMIM, 0xFFFF)
        Local0 = SMID /* \SMID */
        Release (SMIM)
        Release (STSM)
        Acquire (STSM, 0xFFFF)
        If (Local0)
        {
            If ((MSOS == 0x04))
            {
                Notify (\_SB.PCI0.SATA, Zero) // Bus Check
            }
            Else
            {
            }
        }

        Release (STSM)
        Release (BAYM)
    }

    Method (IDER, 0, NotSerialized)
    {
        Acquire (BAYM, 0xFFFF)
        Acquire (STSM, 0xFFFF)
        PIO0 = Ones
        DMA0 = Ones
        Acquire (SMIM, 0xFFFF)
        SMID = Zero
        Release (SMIM)
        MBAY ()
        Release (STSM)
        Acquire (STSM, 0xFFFF)
        If ((MSOS == 0x04))
        {
            Notify (\_SB.PCI0.SATA.PRT1, One) // Device Check
        }
        Else
        {
        }

        Release (STSM)
        Release (BAYM)
    }

    Method (MBAY, 0, NotSerialized)
    {
        Acquire (SMIM, 0xFFFF)
        SMIC = 0x86
        Local0 = SMIC /* \SMIC */
        Release (SMIM)
    }

    Scope (_SI)
    {
        Method (_SST, 1, NotSerialized)  // _SST: System Status
        {
            SSTX = Arg0
            If ((Arg0 == 0x03))
            {
                LED2 &= 0xFD
            }

            If ((Arg0 == One))
            {
                LED2 |= 0x02
            }
        }
    }

    Scope (_SB)
    {
        Device (PCI0)
        {
            Name (_HID, EisaId ("PNP0A03") /* PCI Bus */)  // _HID: Hardware ID
            Name (_UID, 0x04)  // _UID: Unique ID
            Name (_ADR, Zero)  // _ADR: Address
            Name (_PRW, Package (0x02)  // _PRW: Power Resources for Wake
            {
                0x0D, 
                0x05
            })
            Method (_S1D, 0, NotSerialized)  // _S1D: S1 Device State
            {
                Return (One)
            }

            Method (_S3D, 0, NotSerialized)  // _S3D: S3 Device State
            {
                If (HACK ())
                {
                    Return (0x03)
                }
                Else
                {
                    Return (0x02)
                }
            }

            Device (PEG0)
            {
                Name (_ADR, 0x00010000)  // _ADR: Address
                Device (HDAU)
                {
                    Name (_ADR, One)  // _ADR: Address
                    Method (_DSM, 4, NotSerialized)  // _DSM: Device-Specific Method
                    {
                        Local0 = Package (0x02)
                            {
                                "hda-gfx", 
                                Buffer (0x0A)
                                {
                                    "onboard-1"
                                }
                            }
                        DTGP (Arg0, Arg1, Arg2, Arg3, RefOf (Local0))
                        Return (Local0)
                    }
                }
            }

            Device (GRFX)
            {
                Name (_ADR, 0x00020000)  // _ADR: Address
                Method (_S1D, 0, NotSerialized)  // _S1D: S1 Device State
                {
                    Return (0x03)
                }

                Scope (^^PCI0)
                {
                    OperationRegion (MCHP, PCI_Config, 0x40, 0xC0)
                    Field (MCHP, AnyAcc, NoLock, Preserve)
                    {
                        Offset (0x60), 
                        TASM,   10, 
                        Offset (0x62)
                    }
                }

                OperationRegion (IGDP, PCI_Config, 0x40, 0xC0)
                Field (IGDP, AnyAcc, NoLock, Preserve)
                {
                    Offset (0x12), 
                        ,   1, 
                    GIVD,   1, 
                        ,   2, 
                    GUMA,   3, 
                    Offset (0x14), 
                        ,   4, 
                    GMFN,   1, 
                    Offset (0x18), 
                    Offset (0xA8), 
                    GSSE,   1, 
                    GSSB,   14, 
                    GSES,   1, 
                    Offset (0xB0), 
                        ,   4, 
                    GCDC,   3, 
                    Offset (0xBC), 
                    ASLS,   32
                }

                Method (GSCI, 0, NotSerialized)
                {
                    OperationRegion (IGDM, SystemMemory, ASLS, 0x2000)
                    Field (IGDM, AnyAcc, NoLock, Preserve)
                    {
                        SIGN,   128, 
                        SIZE,   32, 
                        OVER,   32, 
                        SVER,   256, 
                        VVER,   128, 
                        GVER,   128, 
                        MBOX,   32, 
                        Offset (0x200), 
                        SCIE,   1, 
                        GEFC,   4, 
                        GXFC,   3, 
                        GESF,   8, 
                        Offset (0x204), 
                        PARM,   32
                    }

                    Method (GBDA, 0, NotSerialized)
                    {
                        If ((GESF == Zero))
                        {
                            PARM = 0x41
                            GXFC = One
                            Return (Zero)
                        }

                        If ((GESF == One))
                        {
                            PARM = Zero
                            GXFC = One
                            Return (Zero)
                        }

                        If ((GESF == 0x04))
                        {
                            GXFC = 0x04
                            Return (Zero)
                        }

                        If ((GESF == 0x05))
                        {
                            GXFC = 0x04
                            Return (Zero)
                        }

                        If ((GESF == 0x06))
                        {
                            GXFC = 0x04
                            Return (Zero)
                        }

                        If ((GESF == 0x07))
                        {
                            PARM |= GIVD /* \_SB_.PCI0.GRFX.GIVD */
                            PARM ^= One
                            PARM |= (GMFN << One)
                            PARM |= 0x1000
                            If ((TASM < 0x08))
                            {
                                PARM |= 0x00020000
                            }
                            ElseIf ((TASM < 0x10))
                            {
                                PARM |= 0x00040000
                            }
                            Else
                            {
                                PARM |= 0x00060000
                            }

                            PARM |= 0x3E800000
                            GXFC = One
                            Return (Zero)
                        }

                        If ((GESF == 0x0A))
                        {
                            GXFC = 0x04
                            Return (Zero)
                        }

                        GXFC = 0x04
                        Return (Zero)
                    }

                    Method (SBCB, 0, NotSerialized)
                    {
                        If ((GESF == Zero))
                        {
                            PARM = Zero
                            GXFC = One
                            Return (Zero)
                        }

                        If ((GESF == One))
                        {
                            GXFC = 0x04
                            Return (Zero)
                        }

                        If ((GESF == 0x03))
                        {
                            GXFC = 0x04
                            Return (Zero)
                        }

                        If ((GESF == 0x04))
                        {
                            GXFC = 0x04
                            Return (Zero)
                        }

                        If ((GESF == 0x05))
                        {
                            GXFC = 0x04
                            Return (Zero)
                        }

                        If ((GESF == 0x06))
                        {
                            GXFC = 0x04
                            Return (Zero)
                        }

                        If ((GESF == 0x07))
                        {
                            GXFC = 0x04
                            Return (Zero)
                        }

                        If ((GESF == 0x08))
                        {
                            GXFC = 0x04
                            Return (Zero)
                        }

                        If ((GESF == 0x09))
                        {
                            GXFC = 0x04
                            Return (Zero)
                        }

                        If ((GESF == 0x0A))
                        {
                            GXFC = 0x04
                            Return (Zero)
                        }

                        If ((GESF == 0x0B))
                        {
                            GXFC = 0x04
                            Return (Zero)
                        }

                        If ((GESF == 0x10))
                        {
                            GXFC = 0x04
                            Return (Zero)
                        }

                        If ((GESF == 0x11))
                        {
                            GXFC = 0x04
                            Return (Zero)
                        }

                        If ((GESF == 0x12))
                        {
                            GXFC = 0x04
                            Return (Zero)
                        }

                        If ((GESF == 0x13))
                        {
                            GXFC = 0x04
                            Return (Zero)
                        }

                        GXFC = 0x04
                        Return (Zero)
                    }

                    If ((GEFC == 0x04))
                    {
                        GBDA ()
                    }

                    If ((GEFC == 0x06))
                    {
                        SBCB ()
                    }

                    SCIS = One
                    GESF = Zero
                    GSSE = Zero
                    SCIE = Zero
                    Return (Zero)
                }

                OperationRegion (TCOI, SystemIO, 0x0860, 0x08)
                Field (TCOI, WordAcc, NoLock, Preserve)
                {
                    Offset (0x04), 
                        ,   9, 
                    SCIS,   1, 
                    Offset (0x06)
                }
            }

            Device (SATA)
            {
                Name (_ADR, 0x001F0002)  // _ADR: Address
                Name (_SUN, One)  // _SUN: Slot User Number
                Device (PRT0)
                {
                    Name (_ADR, Zero)  // _ADR: Address
                    Method (_GTF, 0, NotSerialized)  // _GTF: Get Task File
                    {
                        Name (PIB0, Buffer (0x07)
                        {
                             0x00, 0x00, 0x00, 0x00, 0x00, 0xA0, 0xF5         // .......
                        })
                        Return (PIB0) /* \_SB_.PCI0.SATA.PRT0._GTF.PIB0 */
                    }

                    Method (_DSM, 4, NotSerialized)  // _DSM: Device-Specific Method
                    {
                        Local0 = Package (0x02)
                            {
                                "io-device-location", 
                                Buffer (0x06)
                                {
                                    "Bay 1"
                                }
                            }
                        DTGP (Arg0, Arg1, Arg2, Arg3, RefOf (Local0))
                        Return (Local0)
                    }
                }

                Device (PRT1)
                {
                    Name (_ADR, One)  // _ADR: Address
                    Method (_GTF, 0, NotSerialized)  // _GTF: Get Task File
                    {
                        Name (PIB1, Buffer (0x07)
                        {
                             0x00, 0x00, 0x00, 0x00, 0x00, 0xB0, 0xF5         // .......
                        })
                        Return (PIB1) /* \_SB_.PCI0.SATA.PRT1._GTF.PIB1 */
                    }

                    Method (_DSM, 4, NotSerialized)  // _DSM: Device-Specific Method
                    {
                        Local0 = Package (0x02)
                            {
                                "io-device-location", 
                                Buffer (0x06)
                                {
                                    "Bay 2"
                                }
                            }
                        DTGP (Arg0, Arg1, Arg2, Arg3, RefOf (Local0))
                        Return (Local0)
                    }
                }

                Method (_DSM, 4, NotSerialized)  // _DSM: Device-Specific Method
                {
                    Local0 = Package (0x02)
                        {
                            "device-id", 
                            Buffer (0x04)
                            {
                                 0x22, 0x3A, 0x00, 0x00                           // ":..
                            }
                        }
                    DTGP (Arg0, Arg1, Arg2, Arg3, RefOf (Local0))
                    Return (Local0)
                }
            }

            Device (PCI4)
            {
                Method (_S1D, 0, NotSerialized)  // _S1D: S1 Device State
                {
                    Return (One)
                }

                Method (_S3D, 0, NotSerialized)  // _S3D: S3 Device State
                {
                    If (HACK ())
                    {
                        Return (0x03)
                    }
                    Else
                    {
                        Return (0x02)
                    }
                }

                Method (_ADR, 0, NotSerialized)  // _ADR: Address
                {
                    Local0 = 0x001E0000
                    Return (Local0)
                }

                Name (_UID, 0x07)  // _UID: Unique ID
                Name (_PRW, Package (0x02)  // _PRW: Power Resources for Wake
                {
                    0x0B, 
                    0x05
                })
                Method (_PRT, 0, NotSerialized)  // _PRT: PCI Routing Table
                {
                    Local0 = API4 /* \_SB_.PCI0.PCI4.API4 */
                    If (!PICF)
                    {
                        Local0 = PIC4 /* \_SB_.PCI0.PCI4.PIC4 */
                    }

                    Return (Local0)
                }
            }

            Device (PCI2)
            {
                Method (_S1D, 0, NotSerialized)  // _S1D: S1 Device State
                {
                    Return (One)
                }

                Method (_S3D, 0, NotSerialized)  // _S3D: S3 Device State
                {
                    If (HACK ())
                    {
                        Return (0x03)
                    }
                    Else
                    {
                        Return (0x02)
                    }
                }

                Method (_ADR, 0, NotSerialized)  // _ADR: Address
                {
                    Local0 = 0x001C0000
                    Return (Local0)
                }

                Name (_UID, 0x16)  // _UID: Unique ID
                Name (_PRW, Package (0x02)  // _PRW: Power Resources for Wake
                {
                    0x1D, 
                    0x05
                })
                OperationRegion (RSTS, PCI_Config, 0x60, 0x04)
                Field (RSTS, ByteAcc, NoLock, Preserve)
                {
                    PID0,   8, 
                    PID1,   8, 
                    PMXS,   8, 
                    PNUS,   8
                }

                Method (_PRT, 0, NotSerialized)  // _PRT: PCI Routing Table
                {
                    Local0 = API2 /* \_SB_.PCI0.PCI2.API2 */
                    If (!PICF)
                    {
                        Local0 = PIC2 /* \_SB_.PCI0.PCI2.PIC2 */
                    }

                    Return (Local0)
                }
            }

            Device (PCI3)
            {
                Method (_S1D, 0, NotSerialized)  // _S1D: S1 Device State
                {
                    Return (One)
                }

                Method (_S3D, 0, NotSerialized)  // _S3D: S3 Device State
                {
                    If (HACK ())
                    {
                        Return (0x03)
                    }
                    Else
                    {
                        Return (0x02)
                    }
                }

                Method (_ADR, 0, NotSerialized)  // _ADR: Address
                {
                    Local0 = 0x001C0001
                    Return (Local0)
                }

                Name (_UID, 0x18)  // _UID: Unique ID
                Name (_PRW, Package (0x02)  // _PRW: Power Resources for Wake
                {
                    0x1E, 
                    0x05
                })
                OperationRegion (RSTS, PCI_Config, 0x60, 0x04)
                Field (RSTS, ByteAcc, NoLock, Preserve)
                {
                    PID0,   8, 
                    PID1,   8, 
                    PMXS,   8, 
                    PNUS,   8
                }

                Method (_PRT, 0, NotSerialized)  // _PRT: PCI Routing Table
                {
                    Local0 = API3 /* \_SB_.PCI0.PCI3.API3 */
                    If (!PICF)
                    {
                        Local0 = PIC3 /* \_SB_.PCI0.PCI3.PIC3 */
                    }

                    Return (Local0)
                }
            }

            Device (PCI1)
            {
                Method (_S1D, 0, NotSerialized)  // _S1D: S1 Device State
                {
                    Return (One)
                }

                Method (_S3D, 0, NotSerialized)  // _S3D: S3 Device State
                {
                    If (HACK ())
                    {
                        Return (0x03)
                    }
                    Else
                    {
                        Return (0x02)
                    }
                }

                Method (_ADR, 0, NotSerialized)  // _ADR: Address
                {
                    Local0 = 0x00010000
                    Return (Local0)
                }

                Name (_UID, 0x19)  // _UID: Unique ID
                Name (_PRW, Package (0x02)  // _PRW: Power Resources for Wake
                {
                    0x1B, 
                    0x05
                })
                OperationRegion (RSTS, PCI_Config, 0xC0, 0x04)
                Field (RSTS, ByteAcc, NoLock, Preserve)
                {
                    PID0,   8, 
                    PID1,   8, 
                    PMXS,   8, 
                    PNUS,   8
                }

                Method (_PRT, 0, NotSerialized)  // _PRT: PCI Routing Table
                {
                    Local0 = API1 /* \_SB_.PCI0.PCI1.API1 */
                    If (!PICF)
                    {
                        Local0 = PIC1 /* \_SB_.PCI0.PCI1.PIC1 */
                    }

                    Return (Local0)
                }
            }

            Device (PCI5)
            {
                Method (_S1D, 0, NotSerialized)  // _S1D: S1 Device State
                {
                    Return (One)
                }

                Method (_S3D, 0, NotSerialized)  // _S3D: S3 Device State
                {
                    If (HACK ())
                    {
                        Return (0x03)
                    }
                    Else
                    {
                        Return (0x02)
                    }
                }

                Method (_ADR, 0, NotSerialized)  // _ADR: Address
                {
                    Local0 = 0x001C0004
                    Return (Local0)
                }

                Name (_UID, 0x20)  // _UID: Unique ID
                Name (_PRW, Package (0x02)  // _PRW: Power Resources for Wake
                {
                    0x1A, 
                    0x05
                })
                OperationRegion (RSTS, PCI_Config, 0x60, 0x04)
                Field (RSTS, ByteAcc, NoLock, Preserve)
                {
                    PID0,   8, 
                    PID1,   8, 
                    PMXS,   8, 
                    PNUS,   8
                }

                Method (_PRT, 0, NotSerialized)  // _PRT: PCI Routing Table
                {
                    Local0 = API5 /* \_SB_.PCI0.PCI5.API5 */
                    If (!PICF)
                    {
                        Local0 = PIC5 /* \_SB_.PCI0.PCI5.PIC5 */
                    }

                    Return (Local0)
                }
            }

            Device (PCI6)
            {
                Method (_S1D, 0, NotSerialized)  // _S1D: S1 Device State
                {
                    Return (One)
                }

                Method (_S3D, 0, NotSerialized)  // _S3D: S3 Device State
                {
                    If (HACK ())
                    {
                        Return (0x03)
                    }
                    Else
                    {
                        Return (0x02)
                    }
                }

                Method (_ADR, 0, NotSerialized)  // _ADR: Address
                {
                    Local0 = 0x001C0005
                    Return (Local0)
                }

                Name (_UID, 0x21)  // _UID: Unique ID
                Name (_PRW, Package (0x02)  // _PRW: Power Resources for Wake
                {
                    0x1A, 
                    0x05
                })
                OperationRegion (RSTS, PCI_Config, 0x60, 0x04)
                Field (RSTS, ByteAcc, NoLock, Preserve)
                {
                    PID0,   8, 
                    PID1,   8, 
                    PMXS,   8, 
                    PNUS,   8
                }

                Method (_PRT, 0, NotSerialized)  // _PRT: PCI Routing Table
                {
                    Local0 = API6 /* \_SB_.PCI0.PCI6.API6 */
                    If (!PICF)
                    {
                        Local0 = PIC6 /* \_SB_.PCI0.PCI6.PIC6 */
                    }

                    Return (Local0)
                }
            }

            Device (HDEF)
            {
                Name (_ADR, 0x001B0000)  // _ADR: Address
                Method (_DSM, 4, NotSerialized)  // _DSM: Device-Specific Method
                {
                    Local0 = Package (0x08)
                        {
                            "built-in", 
                            Buffer (One)
                            {
                                 0x00                                             // .
                            }, 

                            "layout-id", 
                            Buffer (0x04)
                            {
                                 0x0D, 0x00, 0x00, 0x00                           // ....
                            }, 

                            "PinConfigurations", 
                            Buffer (Zero){}, 
                            "hda-gfx", 
                            Buffer (0x0A)
                            {
                                "onboard-1"
                            }
                        }
                    DTGP (Arg0, Arg1, Arg2, Arg3, RefOf (Local0))
                    Return (Local0)
                }
            }
        }
    }

    Device (PNLF)
    {
        Name (_HID, EisaId ("APP0002"))  // _HID: Hardware ID
        Name (_CID, "backlight")  // _CID: Compatible ID
        Name (_UID, 0x0A)  // _UID: Unique ID
        Name (_STA, 0x0B)  // _STA: Status
        Method (_BCL, 0, NotSerialized)  // _BCL: Brightness Control Levels
        {
            Return (Package (0x13)
            {
                0x64, 
                0x32, 
                Zero, 
                0x06, 
                0x0C, 
                0x12, 
                0x18, 
                0x1E, 
                0x24, 
                0x2A, 
                0x30, 
                0x36, 
                0x3C, 
                0x42, 
                0x48, 
                0x4E, 
                0x54, 
                0x5A, 
                0x64
            })
        }
    }

    Scope (_SB.PCI0)
    {
        Name (PIC0, Package (0x1D)
        {
            Package (0x04)
            {
                0x0001FFFF, 
                Zero, 
                LNKA, 
                Zero
            }, 

            Package (0x04)
            {
                0x0001FFFF, 
                One, 
                LNKB, 
                Zero
            }, 

            Package (0x04)
            {
                0x0001FFFF, 
                0x02, 
                LNKC, 
                Zero
            }, 

            Package (0x04)
            {
                0x0001FFFF, 
                0x03, 
                LNKD, 
                Zero
            }, 

            Package (0x04)
            {
                0x0002FFFF, 
                Zero, 
                LNKA, 
                Zero
            }, 

            Package (0x04)
            {
                0x0002FFFF, 
                One, 
                LNKB, 
                Zero
            }, 

            Package (0x04)
            {
                0x0002FFFF, 
                0x02, 
                LNKC, 
                Zero
            }, 

            Package (0x04)
            {
                0x0002FFFF, 
                0x03, 
                LNKD, 
                Zero
            }, 

            Package (0x04)
            {
                0x0003FFFF, 
                Zero, 
                LNKA, 
                Zero
            }, 

            Package (0x04)
            {
                0x0003FFFF, 
                One, 
                LNKB, 
                Zero
            }, 

            Package (0x04)
            {
                0x0003FFFF, 
                0x02, 
                LNKC, 
                Zero
            }, 

            Package (0x04)
            {
                0x0003FFFF, 
                0x03, 
                LNKD, 
                Zero
            }, 

            Package (0x04)
            {
                0x001AFFFF, 
                Zero, 
                LNKA, 
                Zero
            }, 

            Package (0x04)
            {
                0x001AFFFF, 
                One, 
                LNKB, 
                Zero
            }, 

            Package (0x04)
            {
                0x001AFFFF, 
                0x02, 
                LNKG, 
                Zero
            }, 

            Package (0x04)
            {
                0x001AFFFF, 
                0x03, 
                LNKD, 
                Zero
            }, 

            Package (0x04)
            {
                0x001BFFFF, 
                Zero, 
                LNKA, 
                Zero
            }, 

            Package (0x04)
            {
                0x001CFFFF, 
                Zero, 
                LNKA, 
                Zero
            }, 

            Package (0x04)
            {
                0x001CFFFF, 
                One, 
                LNKB, 
                Zero
            }, 

            Package (0x04)
            {
                0x001CFFFF, 
                0x02, 
                LNKC, 
                Zero
            }, 

            Package (0x04)
            {
                0x001CFFFF, 
                0x03, 
                LNKD, 
                Zero
            }, 

            Package (0x04)
            {
                0x001DFFFF, 
                Zero, 
                LNKH, 
                Zero
            }, 

            Package (0x04)
            {
                0x001DFFFF, 
                One, 
                LNKB, 
                Zero
            }, 

            Package (0x04)
            {
                0x001DFFFF, 
                0x02, 
                LNKC, 
                Zero
            }, 

            Package (0x04)
            {
                0x001DFFFF, 
                0x03, 
                LNKD, 
                Zero
            }, 

            Package (0x04)
            {
                0x001FFFFF, 
                Zero, 
                LNKA, 
                Zero
            }, 

            Package (0x04)
            {
                0x001FFFFF, 
                One, 
                LNKB, 
                Zero
            }, 

            Package (0x04)
            {
                0x001FFFFF, 
                0x02, 
                LNKC, 
                Zero
            }, 

            Package (0x04)
            {
                0x0019FFFF, 
                Zero, 
                LNKF, 
                Zero
            }
        })
        Name (API0, Package (0x1D)
        {
            Package (0x04)
            {
                0x0001FFFF, 
                Zero, 
                Zero, 
                0x10
            }, 

            Package (0x04)
            {
                0x0001FFFF, 
                One, 
                Zero, 
                0x11
            }, 

            Package (0x04)
            {
                0x0001FFFF, 
                0x02, 
                Zero, 
                0x12
            }, 

            Package (0x04)
            {
                0x0001FFFF, 
                0x03, 
                Zero, 
                0x13
            }, 

            Package (0x04)
            {
                0x0002FFFF, 
                Zero, 
                Zero, 
                0x10
            }, 

            Package (0x04)
            {
                0x0002FFFF, 
                One, 
                Zero, 
                0x11
            }, 

            Package (0x04)
            {
                0x0002FFFF, 
                0x02, 
                Zero, 
                0x12
            }, 

            Package (0x04)
            {
                0x0002FFFF, 
                0x03, 
                Zero, 
                0x13
            }, 

            Package (0x04)
            {
                0x0003FFFF, 
                Zero, 
                Zero, 
                0x10
            }, 

            Package (0x04)
            {
                0x0003FFFF, 
                One, 
                Zero, 
                0x11
            }, 

            Package (0x04)
            {
                0x0003FFFF, 
                0x02, 
                Zero, 
                0x12
            }, 

            Package (0x04)
            {
                0x0003FFFF, 
                0x03, 
                Zero, 
                0x13
            }, 

            Package (0x04)
            {
                0x001AFFFF, 
                Zero, 
                Zero, 
                0x10
            }, 

            Package (0x04)
            {
                0x001AFFFF, 
                One, 
                Zero, 
                0x11
            }, 

            Package (0x04)
            {
                0x001AFFFF, 
                0x02, 
                Zero, 
                0x16
            }, 

            Package (0x04)
            {
                0x001AFFFF, 
                0x03, 
                Zero, 
                0x13
            }, 

            Package (0x04)
            {
                0x001BFFFF, 
                Zero, 
                Zero, 
                0x10
            }, 

            Package (0x04)
            {
                0x001CFFFF, 
                Zero, 
                Zero, 
                0x10
            }, 

            Package (0x04)
            {
                0x001CFFFF, 
                One, 
                Zero, 
                0x11
            }, 

            Package (0x04)
            {
                0x001CFFFF, 
                0x02, 
                Zero, 
                0x12
            }, 

            Package (0x04)
            {
                0x001CFFFF, 
                0x03, 
                Zero, 
                0x13
            }, 

            Package (0x04)
            {
                0x001DFFFF, 
                Zero, 
                Zero, 
                0x17
            }, 

            Package (0x04)
            {
                0x001DFFFF, 
                One, 
                Zero, 
                0x11
            }, 

            Package (0x04)
            {
                0x001DFFFF, 
                0x02, 
                Zero, 
                0x12
            }, 

            Package (0x04)
            {
                0x001DFFFF, 
                0x03, 
                Zero, 
                0x13
            }, 

            Package (0x04)
            {
                0x001FFFFF, 
                Zero, 
                Zero, 
                0x10
            }, 

            Package (0x04)
            {
                0x001FFFFF, 
                One, 
                Zero, 
                0x11
            }, 

            Package (0x04)
            {
                0x001FFFFF, 
                0x02, 
                Zero, 
                0x12
            }, 

            Package (0x04)
            {
                0x0019FFFF, 
                Zero, 
                Zero, 
                0x15
            }
        })
    }

    Scope (_SB.PCI0.PCI1)
    {
        Name (PIC1, Package (0x04)
        {
            Package (0x04)
            {
                0xFFFF, 
                Zero, 
                LNKA, 
                Zero
            }, 

            Package (0x04)
            {
                0xFFFF, 
                One, 
                LNKB, 
                Zero
            }, 

            Package (0x04)
            {
                0xFFFF, 
                0x02, 
                LNKC, 
                Zero
            }, 

            Package (0x04)
            {
                0xFFFF, 
                0x03, 
                LNKD, 
                Zero
            }
        })
        Name (API1, Package (0x04)
        {
            Package (0x04)
            {
                0xFFFF, 
                Zero, 
                Zero, 
                0x10
            }, 

            Package (0x04)
            {
                0xFFFF, 
                One, 
                Zero, 
                0x11
            }, 

            Package (0x04)
            {
                0xFFFF, 
                0x02, 
                Zero, 
                0x12
            }, 

            Package (0x04)
            {
                0xFFFF, 
                0x03, 
                Zero, 
                0x13
            }
        })
    }

    Scope (_SB.PCI0.PCI2)
    {
        Name (PIC2, Package (0x00){})
        Name (API2, Package (0x00){})
    }

    Scope (_SB.PCI0.PCI3)
    {
        Name (PIC3, Package (0x04)
        {
            Package (0x04)
            {
                0xFFFF, 
                Zero, 
                LNKB, 
                Zero
            }, 

            Package (0x04)
            {
                0xFFFF, 
                One, 
                LNKC, 
                Zero
            }, 

            Package (0x04)
            {
                0xFFFF, 
                0x02, 
                LNKD, 
                Zero
            }, 

            Package (0x04)
            {
                0xFFFF, 
                0x03, 
                LNKA, 
                Zero
            }
        })
        Name (API3, Package (0x04)
        {
            Package (0x04)
            {
                0xFFFF, 
                Zero, 
                Zero, 
                0x11
            }, 

            Package (0x04)
            {
                0xFFFF, 
                One, 
                Zero, 
                0x12
            }, 

            Package (0x04)
            {
                0xFFFF, 
                0x02, 
                Zero, 
                0x13
            }, 

            Package (0x04)
            {
                0xFFFF, 
                0x03, 
                Zero, 
                0x10
            }
        })
    }

    Scope (_SB.PCI0.PCI4)
    {
        Name (PIC4, Package (0x0C)
        {
            Package (0x04)
            {
                0x0001FFFF, 
                Zero, 
                LNKB, 
                Zero
            }, 

            Package (0x04)
            {
                0x0001FFFF, 
                One, 
                LNKC, 
                Zero
            }, 

            Package (0x04)
            {
                0x0001FFFF, 
                0x02, 
                LNKD, 
                Zero
            }, 

            Package (0x04)
            {
                0x0001FFFF, 
                0x03, 
                LNKA, 
                Zero
            }, 

            Package (0x04)
            {
                0xFFFF, 
                Zero, 
                LNKA, 
                Zero
            }, 

            Package (0x04)
            {
                0xFFFF, 
                One, 
                LNKB, 
                Zero
            }, 

            Package (0x04)
            {
                0xFFFF, 
                0x02, 
                LNKC, 
                Zero
            }, 

            Package (0x04)
            {
                0xFFFF, 
                0x03, 
                LNKD, 
                Zero
            }, 

            Package (0x04)
            {
                0x0002FFFF, 
                Zero, 
                LNKC, 
                Zero
            }, 

            Package (0x04)
            {
                0x0002FFFF, 
                One, 
                LNKD, 
                Zero
            }, 

            Package (0x04)
            {
                0x0002FFFF, 
                0x02, 
                LNKA, 
                Zero
            }, 

            Package (0x04)
            {
                0x0002FFFF, 
                0x03, 
                LNKB, 
                Zero
            }
        })
        Name (API4, Package (0x0C)
        {
            Package (0x04)
            {
                0x0001FFFF, 
                Zero, 
                Zero, 
                0x11
            }, 

            Package (0x04)
            {
                0x0001FFFF, 
                One, 
                Zero, 
                0x12
            }, 

            Package (0x04)
            {
                0x0001FFFF, 
                0x02, 
                Zero, 
                0x13
            }, 

            Package (0x04)
            {
                0x0001FFFF, 
                0x03, 
                Zero, 
                0x10
            }, 

            Package (0x04)
            {
                0xFFFF, 
                Zero, 
                Zero, 
                0x10
            }, 

            Package (0x04)
            {
                0xFFFF, 
                One, 
                Zero, 
                0x11
            }, 

            Package (0x04)
            {
                0xFFFF, 
                0x02, 
                Zero, 
                0x12
            }, 

            Package (0x04)
            {
                0xFFFF, 
                0x03, 
                Zero, 
                0x13
            }, 

            Package (0x04)
            {
                0x0002FFFF, 
                Zero, 
                Zero, 
                0x12
            }, 

            Package (0x04)
            {
                0x0002FFFF, 
                One, 
                Zero, 
                0x13
            }, 

            Package (0x04)
            {
                0x0002FFFF, 
                0x02, 
                Zero, 
                0x10
            }, 

            Package (0x04)
            {
                0x0002FFFF, 
                0x03, 
                Zero, 
                0x11
            }
        })
    }

    Scope (_SB.PCI0.PCI5)
    {
        Name (PIC5, Package (0x00){})
        Name (API5, Package (0x00){})
    }

    Scope (_SB.PCI0.PCI6)
    {
        Name (PIC6, Package (0x00){})
        Name (API6, Package (0x00){})
    }

    Scope (\)
    {
        Name (PICM, Zero)
        Name (PRWP, Package (0x02)
        {
            Zero, 
            Zero
        })
        Method (GPRW, 2, NotSerialized)
        {
            PRWP [Zero] = Arg0
            PRWP [One] = Arg1
            Return (PRWP) /* \PRWP */
        }

        Method (_GPE._L03, 0, NotSerialized)  // _Lxx: Level-Triggered GPE, xx=0x00-0xFF
        {
            If (~(SSTX == One))
            {
                Notify (\_SB.VBTN, 0x02) // Device Wake
            }

            Sleep (0x14)
            THRP ^= 0x08
            PME2 |= One
            Notify (\_SB.PCI0.USB0, 0x02) // Device Wake
        }

        Method (_GPE._L04, 0, NotSerialized)  // _Lxx: Level-Triggered GPE, xx=0x00-0xFF
        {
            If (~(SSTX == One))
            {
                Notify (\_SB.VBTN, 0x02) // Device Wake
            }

            Sleep (0x14)
            THRP ^= 0x10
            PME2 |= One
            Notify (\_SB.PCI0.USB1, 0x02) // Device Wake
        }

        Method (_GPE._L0C, 0, NotSerialized)  // _Lxx: Level-Triggered GPE, xx=0x00-0xFF
        {
            If (~(SSTX == One))
            {
                Notify (\_SB.VBTN, 0x02) // Device Wake
            }

            Sleep (0x14)
            GLBT ^= 0x10
            PME2 |= One
            Notify (\_SB.PCI0.USB2, 0x02) // Device Wake
        }

        Method (_GPE._L0E, 0, NotSerialized)  // _Lxx: Level-Triggered GPE, xx=0x00-0xFF
        {
            If (~(SSTX == One))
            {
                Notify (\_SB.VBTN, 0x02) // Device Wake
            }

            Sleep (0x14)
            GLBT ^= 0x40
            PME2 |= One
            Notify (\_SB.PCI0.USB3, 0x02) // Device Wake
        }

        Method (_GPE._L05, 0, NotSerialized)  // _Lxx: Level-Triggered GPE, xx=0x00-0xFF
        {
            If (~(SSTX == One))
            {
                Notify (\_SB.VBTN, 0x02) // Device Wake
            }

            Sleep (0x14)
            THRP ^= 0x20
            PME2 |= One
            Notify (\_SB.PCI0.USB4, 0x02) // Device Wake
        }

        Method (_GPE._L20, 0, NotSerialized)  // _Lxx: Level-Triggered GPE, xx=0x00-0xFF
        {
            If (~(SSTX == One))
            {
                Notify (\_SB.VBTN, 0x02) // Device Wake
            }

            Sleep (0x14)
            THRP ^= 0x20
            PME2 |= One
            Notify (\_SB.PCI0.USB5, 0x02) // Device Wake
        }

        Method (_GPE._L0D, 0, NotSerialized)  // _Lxx: Level-Triggered GPE, xx=0x00-0xFF
        {
            Sleep (0x14)
            GLBT ^= 0x20
            PME2 |= One
            Notify (\_SB.PCI0, 0x02) // Device Wake
        }

        Method (_GPE._L0B, 0, NotSerialized)  // _Lxx: Level-Triggered GPE, xx=0x00-0xFF
        {
            GLBT ^= 0x08
            PME2 |= One
            Notify (\_SB.PCI0.PCI4, 0x02) // Device Wake
        }
    }

    Scope (_SB.PCI0)
    {
        Device (SBUS)
        {
            Name (_ADR, 0x001F0003)  // _ADR: Address
            Method (_DSM, 4, NotSerialized)  // _DSM: Device-Specific Method
            {
                Local0 = Package (0x04)
                    {
                        "name", 
                        "pci8086,3a30", 
                        "device-id", 
                        Buffer (0x04)
                        {
                             0x60, 0x3A, 0x00, 0x00                           // `:..
                        }
                    }
                DTGP (Arg0, Arg1, Arg2, Arg3, RefOf (Local0))
                Return (Local0)
            }
        }

        Device (ISA)
        {
            Name (_ADR, 0x001F0000)  // _ADR: Address
            Name (_UID, 0x0A)  // _UID: Unique ID
            OperationRegion (P40C, PCI_Config, 0x60, 0x04)
            OperationRegion (P41C, PCI_Config, 0x68, 0x04)
            Device (MBIO)
            {
                Name (_HID, EisaId ("PNP0C01") /* System Board */)  // _HID: Hardware ID
                Name (_UID, 0x0B)  // _UID: Unique ID
                Method (_CRS, 0, NotSerialized)  // _CRS: Current Resource Settings
                {
                    Name (MIO1, ResourceTemplate ()
                    {
                        IO (Decode16,
                            0x0062,             // Range Minimum
                            0x0062,             // Range Maximum
                            0x01,               // Alignment
                            0x02,               // Length
                            )
                        IO (Decode16,
                            0x0065,             // Range Minimum
                            0x0065,             // Range Maximum
                            0x01,               // Alignment
                            0x0B,               // Length
                            )
                        IO (Decode16,
                            0x00E0,             // Range Minimum
                            0x00E0,             // Range Maximum
                            0x01,               // Alignment
                            0x10,               // Length
                            )
                        IO (Decode16,
                            0x0800,             // Range Minimum
                            0x0800,             // Range Maximum
                            0x01,               // Alignment
                            0x60,               // Length
                            )
                        IO (Decode16,
                            0x0C00,             // Range Minimum
                            0x0C00,             // Range Maximum
                            0x01,               // Alignment
                            0x80,               // Length
                            )
                        IO (Decode16,
                            0x0860,             // Range Minimum
                            0x0860,             // Range Maximum
                            0x01,               // Alignment
                            0xA0,               // Length
                            )
                    })
                    Name (MIO2, ResourceTemplate ()
                    {
                        IO (Decode16,
                            0x0060,             // Range Minimum
                            0x0060,             // Range Maximum
                            0x01,               // Alignment
                            0x01,               // Length
                            )
                        IO (Decode16,
                            0x0064,             // Range Minimum
                            0x0064,             // Range Maximum
                            0x01,               // Alignment
                            0x01,               // Length
                            )
                        IO (Decode16,
                            0x0062,             // Range Minimum
                            0x0062,             // Range Maximum
                            0x01,               // Alignment
                            0x02,               // Length
                            )
                        IO (Decode16,
                            0x0065,             // Range Minimum
                            0x0065,             // Range Maximum
                            0x01,               // Alignment
                            0x0B,               // Length
                            )
                        IO (Decode16,
                            0x00E0,             // Range Minimum
                            0x00E0,             // Range Maximum
                            0x01,               // Alignment
                            0x10,               // Length
                            )
                        IO (Decode16,
                            0x0800,             // Range Minimum
                            0x0800,             // Range Maximum
                            0x01,               // Alignment
                            0x60,               // Length
                            )
                        IO (Decode16,
                            0x0C00,             // Range Minimum
                            0x0C00,             // Range Maximum
                            0x01,               // Alignment
                            0x80,               // Length
                            )
                        IO (Decode16,
                            0x0860,             // Range Minimum
                            0x0860,             // Range Maximum
                            0x01,               // Alignment
                            0xA0,               // Length
                            )
                    })
                    If ((GCKB () | GCMS ()))
                    {
                        Return (MIO1) /* \_SB_.PCI0.ISA_.MBIO._CRS.MIO1 */
                    }
                    Else
                    {
                        Return (MIO2) /* \_SB_.PCI0.ISA_.MBIO._CRS.MIO2 */
                    }
                }
            }

            Method (_DSM, 4, NotSerialized)  // _DSM: Device-Specific Method
            {
                Local0 = Package (0x08)
                    {
                        "device-id", 
                        Buffer (0x04)
                        {
                             0x18, 0x3A, 0x00, 0x00                           // .:..
                        }, 

                        "compatible", 
                        Buffer (0x0D)
                        {
                            "pci8086,3a18"
                        }, 

                        "IOName", 
                        Buffer (0x0D)
                        {
                            "pci8086,3a18"
                        }, 

                        "name", 
                        Buffer (0x0D)
                        {
                            "pci8086,3a18"
                        }
                    }
                DTGP (Arg0, Arg1, Arg2, Arg3, RefOf (Local0))
                Return (Local0)
            }
        }
    }

    Scope (_SB.PCI0)
    {
        Device (USB0)
        {
            Name (_ADR, 0x001D0000)  // _ADR: Address
            Name (_UID, 0x05)  // _UID: Unique ID
            Name (_PRW, Package (0x02)  // _PRW: Power Resources for Wake
            {
                0x03, 
                0x03
            })
            OperationRegion (UPC1, PCI_Config, 0xC1, One)
            Field (UPC1, ByteAcc, NoLock, Preserve)
            {
                LEGK,   8
            }

            Method (_INI, 0, NotSerialized)  // _INI: Initialize
            {
                If (HACK ()){}
                Else
                {
                    Local0 = LEGK /* \_SB_.PCI0.USB0.LEGK */
                    Local0 &= 0x60
                    Local0 |= 0x20
                    LEGK = Local0
                }

                GUSB ()
            }

            Method (_STA, 0, NotSerialized)  // _STA: Status
            {
                If (GCUC ())
                {
                    Return (0x0F)
                }
                Else
                {
                    Return (Zero)
                }
            }

            Method (_S1D, 0, NotSerialized)  // _S1D: S1 Device State
            {
                Return (One)
            }

            Method (_S3D, 0, NotSerialized)  // _S3D: S3 Device State
            {
                If (HACK ())
                {
                    Return (0x03)
                }
                Else
                {
                    Return (0x02)
                }
            }

            Method (_DSM, 4, NotSerialized)  // _DSM: Device-Specific Method
            {
                Local0 = Package (0x06)
                    {
                        "device-id", 
                        Buffer (0x04)
                        {
                             0x34, 0x3A, 0x00, 0x00                           // 4:..
                        }, 

                        "built-in", 
                        Buffer (One)
                        {
                             0x00                                             // .
                        }, 

                        "device_type", 
                        Buffer (0x05)
                        {
                            "UHCI"
                        }
                    }
                DTGP (Arg0, Arg1, Arg2, Arg3, RefOf (Local0))
                Return (Local0)
            }
        }

        Device (USB1)
        {
            Name (_ADR, 0x001D0001)  // _ADR: Address
            Name (_UID, 0x06)  // _UID: Unique ID
            Name (_PRW, Package (0x02)  // _PRW: Power Resources for Wake
            {
                0x04, 
                0x03
            })
            OperationRegion (UPC1, PCI_Config, 0xC1, One)
            Field (UPC1, ByteAcc, NoLock, Preserve)
            {
                LEGK,   8
            }

            Method (_INI, 0, NotSerialized)  // _INI: Initialize
            {
                If (HACK ()){}
                Else
                {
                    Local0 = LEGK /* \_SB_.PCI0.USB1.LEGK */
                    Local0 &= 0x60
                    Local0 |= 0x20
                    LEGK = Local0
                }
            }

            Method (_STA, 0, NotSerialized)  // _STA: Status
            {
                If (GCUC ())
                {
                    Return (0x0F)
                }
                Else
                {
                    Return (Zero)
                }
            }

            Method (_S1D, 0, NotSerialized)  // _S1D: S1 Device State
            {
                Return (One)
            }

            Method (_S3D, 0, NotSerialized)  // _S3D: S3 Device State
            {
                If (HACK ())
                {
                    Return (0x03)
                }
                Else
                {
                    Return (0x02)
                }
            }

            Method (_DSM, 4, NotSerialized)  // _DSM: Device-Specific Method
            {
                Local0 = Package (0x06)
                    {
                        "device-id", 
                        Buffer (0x04)
                        {
                             0x35, 0x3A, 0x00, 0x00                           // 5:..
                        }, 

                        "built-in", 
                        Buffer (One)
                        {
                             0x00                                             // .
                        }, 

                        "device_type", 
                        Buffer (0x05)
                        {
                            "UHCI"
                        }
                    }
                DTGP (Arg0, Arg1, Arg2, Arg3, RefOf (Local0))
                Return (Local0)
            }
        }

        Device (USB2)
        {
            Name (_ADR, 0x001D0002)  // _ADR: Address
            Name (_UID, 0x14)  // _UID: Unique ID
            Name (_PRW, Package (0x02)  // _PRW: Power Resources for Wake
            {
                0x0C, 
                0x03
            })
            OperationRegion (UPC1, PCI_Config, 0xC1, One)
            Field (UPC1, ByteAcc, NoLock, Preserve)
            {
                LEGK,   8
            }

            Method (_INI, 0, NotSerialized)  // _INI: Initialize
            {
                If (HACK ()){}
                Else
                {
                    Local0 = LEGK /* \_SB_.PCI0.USB2.LEGK */
                    Local0 &= 0x60
                    Local0 |= 0x20
                    LEGK = Local0
                }
            }

            Method (_STA, 0, NotSerialized)  // _STA: Status
            {
                If (GCUC ())
                {
                    Return (0x0F)
                }
                Else
                {
                    Return (Zero)
                }
            }

            Method (_S1D, 0, NotSerialized)  // _S1D: S1 Device State
            {
                Return (One)
            }

            Method (_S3D, 0, NotSerialized)  // _S3D: S3 Device State
            {
                If (HACK ())
                {
                    Return (0x03)
                }
                Else
                {
                    Return (0x02)
                }
            }

            Method (_DSM, 4, NotSerialized)  // _DSM: Device-Specific Method
            {
                Local0 = Package (0x06)
                    {
                        "device-id", 
                        Buffer (0x04)
                        {
                             0x36, 0x3A, 0x00, 0x00                           // 6:..
                        }, 

                        "built-in", 
                        Buffer (One)
                        {
                             0x00                                             // .
                        }, 

                        "device_type", 
                        Buffer (0x05)
                        {
                            "UHCI"
                        }
                    }
                DTGP (Arg0, Arg1, Arg2, Arg3, RefOf (Local0))
                Return (Local0)
            }
        }

        Device (USB3)
        {
            Name (_ADR, 0x001A0000)  // _ADR: Address
            Name (_UID, 0x15)  // _UID: Unique ID
            Name (_PRW, Package (0x02)  // _PRW: Power Resources for Wake
            {
                0x0E, 
                0x03
            })
            OperationRegion (UPC1, PCI_Config, 0xC1, One)
            Field (UPC1, ByteAcc, NoLock, Preserve)
            {
                LEGK,   8
            }

            Method (_INI, 0, NotSerialized)  // _INI: Initialize
            {
                If (HACK ()){}
                Else
                {
                    Local0 = LEGK /* \_SB_.PCI0.USB3.LEGK */
                    Local0 &= 0x60
                    Local0 |= 0x20
                    LEGK = Local0
                }
            }

            Method (_STA, 0, NotSerialized)  // _STA: Status
            {
                If (GCUC ())
                {
                    Return (0x0F)
                }
                Else
                {
                    Return (Zero)
                }
            }

            Method (_S1D, 0, NotSerialized)  // _S1D: S1 Device State
            {
                Return (One)
            }

            Method (_S3D, 0, NotSerialized)  // _S3D: S3 Device State
            {
                If (HACK ())
                {
                    Return (0x03)
                }
                Else
                {
                    Return (0x02)
                }
            }

            Method (_DSM, 4, NotSerialized)  // _DSM: Device-Specific Method
            {
                Local0 = Package (0x06)
                    {
                        "device-id", 
                        Buffer (0x04)
                        {
                             0x37, 0x3A, 0x00, 0x00                           // 7:..
                        }, 

                        "built-in", 
                        Buffer (One)
                        {
                             0x00                                             // .
                        }, 

                        "device_type", 
                        Buffer (0x05)
                        {
                            "UHCI"
                        }
                    }
                DTGP (Arg0, Arg1, Arg2, Arg3, RefOf (Local0))
                Return (Local0)
            }
        }

        Device (USB4)
        {
            Name (_ADR, 0x001A0001)  // _ADR: Address
            Name (_UID, 0x16)  // _UID: Unique ID
            Name (_PRW, Package (0x02)  // _PRW: Power Resources for Wake
            {
                0x05, 
                0x03
            })
            OperationRegion (UPC1, PCI_Config, 0xC1, One)
            Field (UPC1, ByteAcc, NoLock, Preserve)
            {
                LEGK,   8
            }

            Method (_INI, 0, NotSerialized)  // _INI: Initialize
            {
                If (HACK ()){}
                Else
                {
                    Local0 = LEGK /* \_SB_.PCI0.USB4.LEGK */
                    Local0 &= 0x60
                    Local0 |= 0x20
                    LEGK = Local0
                }
            }

            Method (_STA, 0, NotSerialized)  // _STA: Status
            {
                If (GCUC ())
                {
                    Return (0x0F)
                }
                Else
                {
                    Return (Zero)
                }
            }

            Method (_S1D, 0, NotSerialized)  // _S1D: S1 Device State
            {
                Return (One)
            }

            Method (_S3D, 0, NotSerialized)  // _S3D: S3 Device State
            {
                If (HACK ())
                {
                    Return (0x03)
                }
                Else
                {
                    Return (0x02)
                }
            }

            Method (_DSM, 4, NotSerialized)  // _DSM: Device-Specific Method
            {
                Local0 = Package (0x06)
                    {
                        "device-id", 
                        Buffer (0x04)
                        {
                             0x38, 0x3A, 0x00, 0x00                           // 8:..
                        }, 

                        "built-in", 
                        Buffer (One)
                        {
                             0x00                                             // .
                        }, 

                        "device_type", 
                        Buffer (0x05)
                        {
                            "UHCI"
                        }
                    }
                DTGP (Arg0, Arg1, Arg2, Arg3, RefOf (Local0))
                Return (Local0)
            }
        }

        Device (USB5)
        {
            Name (_ADR, 0x001A0002)  // _ADR: Address
            Name (_UID, 0x1A)  // _UID: Unique ID
            Name (_PRW, Package (0x02)  // _PRW: Power Resources for Wake
            {
                0x20, 
                0x03
            })
            OperationRegion (UPC1, PCI_Config, 0xC1, One)
            Field (UPC1, ByteAcc, NoLock, Preserve)
            {
                LEGK,   8
            }

            Method (_INI, 0, NotSerialized)  // _INI: Initialize
            {
                If (HACK ()){}
                Else
                {
                    Local0 = LEGK /* \_SB_.PCI0.USB5.LEGK */
                    Local0 &= 0x60
                    Local0 |= 0x20
                    LEGK = Local0
                }
            }

            Method (_STA, 0, NotSerialized)  // _STA: Status
            {
                If (GCUC ())
                {
                    Return (0x0F)
                }
                Else
                {
                    Return (Zero)
                }
            }

            Method (_S1D, 0, NotSerialized)  // _S1D: S1 Device State
            {
                Return (One)
            }

            Method (_S3D, 0, NotSerialized)  // _S3D: S3 Device State
            {
                If (HACK ())
                {
                    Return (0x03)
                }
                Else
                {
                    Return (0x02)
                }
            }

            Method (_DSM, 4, NotSerialized)  // _DSM: Device-Specific Method
            {
                Local0 = Package (0x06)
                    {
                        "device-id", 
                        Buffer (0x04)
                        {
                             0x39, 0x3A, 0x00, 0x00                           // 9:..
                        }, 

                        "built-in", 
                        Buffer (One)
                        {
                             0x00                                             // .
                        }, 

                        "device_type", 
                        Buffer (0x05)
                        {
                            "UHCI"
                        }
                    }
                DTGP (Arg0, Arg1, Arg2, Arg3, RefOf (Local0))
                Return (Local0)
            }
        }
    }

    Scope (\)
    {
        Name (PICF, Zero)
        Method (_PIC, 1, NotSerialized)  // _PIC: Interrupt Model
        {
            PICF = Arg0
        }
    }

    Scope (_SB.PCI0)
    {
        Method (_PRT, 0, NotSerialized)  // _PRT: PCI Routing Table
        {
            Local0 = API0 /* \_SB_.PCI0.API0 */
            If (!PICF)
            {
                Local0 = PIC0 /* \_SB_.PCI0.PIC0 */
            }

            Return (Local0)
        }

        Method (_CRS, 0, NotSerialized)  // _CRS: Current Resource Settings
        {
            OperationRegion (ORMF, SystemMemory, 0x000FFF6C, 0x04)
            Field (ORMF, WordAcc, NoLock, Preserve)
            {
                ORGP,   16, 
                ORND,   16
            }

            Name (MEMP, ResourceTemplate ()
            {
                WordBusNumber (ResourceProducer, MinFixed, MaxFixed, PosDecode,
                    0x0000,             // Granularity
                    0x0000,             // Range Minimum
                    0x00FF,             // Range Maximum
                    0x0000,             // Translation Offset
                    0x0100,             // Length
                    ,, )
                IO (Decode16,
                    0x0CF8,             // Range Minimum
                    0x0CF8,             // Range Maximum
                    0x01,               // Alignment
                    0x08,               // Length
                    )
                WordIO (ResourceProducer, MinFixed, MaxFixed, PosDecode, EntireRange,
                    0x0000,             // Granularity
                    0x0000,             // Range Minimum
                    0x0CF7,             // Range Maximum
                    0x0000,             // Translation Offset
                    0x0CF8,             // Length
                    ,, , TypeStatic, DenseTranslation)
                WordIO (ResourceProducer, MinNotFixed, MaxNotFixed, PosDecode, EntireRange,
                    0x0000,             // Granularity
                    0x0D00,             // Range Minimum
                    0xFFFF,             // Range Maximum
                    0x0000,             // Translation Offset
                    0xF300,             // Length
                    ,, , TypeStatic, DenseTranslation)
                DWordMemory (ResourceProducer, PosDecode, MinFixed, MaxFixed, Cacheable, ReadWrite,
                    0x00000000,         // Granularity
                    0x000A0000,         // Range Minimum
                    0x000BFFFF,         // Range Maximum
                    0x00000000,         // Translation Offset
                    0x00020000,         // Length
                    ,, , AddressRangeMemory, TypeStatic)
                DWordMemory (ResourceProducer, PosDecode, MinFixed, MaxFixed, Cacheable, ReadWrite,
                    0x00000000,         // Granularity
                    0x000C8000,         // Range Minimum
                    0x000DFFFF,         // Range Maximum
                    0x00000000,         // Translation Offset
                    0x00018000,         // Length
                    ,, _Y00, AddressRangeMemory, TypeStatic)
                DWordMemory (ResourceProducer, PosDecode, MinFixed, MaxFixed, Cacheable, ReadWrite,
                    0x00000000,         // Granularity
                    0x000E0000,         // Range Minimum
                    0x000FFFFF,         // Range Maximum
                    0x00000000,         // Translation Offset
                    0x00020000,         // Length
                    ,, _Y01, AddressRangeMemory, TypeStatic)
                DWordMemory (ResourceProducer, PosDecode, MinFixed, MaxFixed, NonCacheable, ReadWrite,
                    0x00000000,         // Granularity
                    0xF0000000,         // Range Minimum
                    0xFEC00000,         // Range Maximum
                    0x00000000,         // Translation Offset
                    0x0EC00001,         // Length
                    ,, , AddressRangeMemory, TypeStatic)
                DWordMemory (ResourceProducer, PosDecode, MinNotFixed, MaxNotFixed, NonCacheable, ReadWrite,
                    0x00000000,         // Granularity
                    0x00000000,         // Range Minimum
                    0xDFFFFFFF,         // Range Maximum
                    0x00000000,         // Translation Offset
                    0x00000000,         // Length
                    ,, _Y02, AddressRangeMemory, TypeStatic)
                DWordMemory (ResourceProducer, PosDecode, MinNotFixed, MaxFixed, NonCacheable, ReadWrite,
                    0x00000000,         // Granularity
                    0x00000000,         // Range Minimum
                    0xEFFFFFFF,         // Range Maximum
                    0x00000000,         // Translation Offset
                    0x00000000,         // Length
                    ,, , AddressRangeMemory, TypeStatic)
                DWordMemory (ResourceProducer, PosDecode, MinNotFixed, MaxNotFixed, NonCacheable, ReadWrite,
                    0x00000000,         // Granularity
                    0xFF980000,         // Range Minimum
                    0xFF980FFF,         // Range Maximum
                    0x00000000,         // Translation Offset
                    0x00001000,         // Length
                    ,, _Y03, AddressRangeMemory, TypeStatic)
                DWordMemory (ResourceProducer, PosDecode, MinNotFixed, MaxFixed, NonCacheable, ReadWrite,
                    0x00000000,         // Granularity
                    0xFF97C000,         // Range Minimum
                    0xFF97FFFF,         // Range Maximum
                    0x00000000,         // Translation Offset
                    0x00000000,         // Length
                    ,, , AddressRangeMemory, TypeStatic)
                DWordMemory (ResourceProducer, PosDecode, MinFixed, MaxFixed, NonCacheable, ReadWrite,
                    0x00000000,         // Granularity
                    0xFED20000,         // Range Minimum
                    0xFED9FFFF,         // Range Maximum
                    0x00000000,         // Translation Offset
                    0x00080000,         // Length
                    ,, , AddressRangeMemory, TypeStatic)
                DWordMemory (ResourceProducer, PosDecode, MinFixed, MaxFixed, NonCacheable, ReadWrite,
                    0x00000000,         // Granularity
                    0xFEDA7000,         // Range Minimum
                    0xFEDA7FFF,         // Range Maximum
                    0x00000000,         // Translation Offset
                    0x00001000,         // Length
                    ,, , AddressRangeMemory, TypeStatic)
            })
            CreateDWordField (MEMP, \_SB.PCI0._CRS._Y00._MIN, PMIN)  // _MIN: Minimum Base Address
            CreateDWordField (MEMP, \_SB.PCI0._CRS._Y00._MAX, PMAX)  // _MAX: Maximum Base Address
            CreateDWordField (MEMP, \_SB.PCI0._CRS._Y00._LEN, PLEN)  // _LEN: Length
            CreateDWordField (MEMP, \_SB.PCI0._CRS._Y01._MIN, BMIN)  // _MIN: Minimum Base Address
            CreateDWordField (MEMP, \_SB.PCI0._CRS._Y01._LEN, BLEN)  // _LEN: Length
            BMIN = (ORGP << 0x04)
            BLEN = (0x00100000 - BMIN) /* \_SB_.PCI0._CRS.BMIN */
            PMIN = 0x000C0000
            PMAX = (BMIN - One)
            PLEN = (BMIN - PMIN) /* \_SB_.PCI0._CRS.PMIN */
            CreateDWordField (MEMP, \_SB.PCI0._CRS._Y02._MIN, MEMM)  // _MIN: Minimum Base Address
            CreateDWordField (MEMP, \_SB.PCI0._CRS._Y02._MAX, MEMA)  // _MAX: Maximum Base Address
            CreateDWordField (MEMP, \_SB.PCI0._CRS._Y02._LEN, MEML)  // _LEN: Length
            MEMM = GTOM ()
            MEML = (MEMA - MEMM) /* \_SB_.PCI0._CRS.MEMM */
            MEML++
            CreateDWordField (MEMP, \_SB.PCI0._CRS._Y03._MIN, UMIN)  // _MIN: Minimum Base Address
            CreateDWordField (MEMP, \_SB.PCI0._CRS._Y03._MAX, UMAX)  // _MAX: Maximum Base Address
            CreateDWordField (MEMP, \_SB.PCI0._CRS._Y03._LEN, ULEN)  // _LEN: Length
            If (GCUC ()){}
            Else
            {
                UMIN = Zero
                UMAX = Zero
                ULEN = Zero
            }

            Return (MEMP) /* \_SB_.PCI0._CRS.MEMP */
        }
    }

    Scope (_SB.PCI0.ISA)
    {
        Device (DMA)
        {
            Name (_HID, EisaId ("PNP0200") /* PC-class DMA Controller */)  // _HID: Hardware ID
            Method (_CRS, 0, NotSerialized)  // _CRS: Current Resource Settings
            {
                Name (DMAB, ResourceTemplate ()
                {
                    IO (Decode16,
                        0x0080,             // Range Minimum
                        0x0080,             // Range Maximum
                        0x01,               // Alignment
                        0x20,               // Length
                        )
                    IO (Decode16,
                        0x0000,             // Range Minimum
                        0x0000,             // Range Maximum
                        0x01,               // Alignment
                        0x20,               // Length
                        )
                    IO (Decode16,
                        0x00C0,             // Range Minimum
                        0x00C0,             // Range Maximum
                        0x01,               // Alignment
                        0x20,               // Length
                        )
                    DMA (Compatibility, NotBusMaster, Transfer16, )
                        {4}
                })
                Return (DMAB) /* \_SB_.PCI0.ISA_.DMA_._CRS.DMAB */
            }
        }
    }

    Scope (_SB.PCI0.ISA)
    {
        Device (FPU)
        {
            Name (_HID, EisaId ("PNP0C04") /* x87-compatible Floating Point Processing Unit */)  // _HID: Hardware ID
            Method (_CRS, 0, NotSerialized)  // _CRS: Current Resource Settings
            {
                Name (FPUB, ResourceTemplate ()
                {
                    IO (Decode16,
                        0x00F0,             // Range Minimum
                        0x00F0,             // Range Maximum
                        0x01,               // Alignment
                        0x10,               // Length
                        )
                    IRQNoFlags ()
                        {13}
                })
                Return (FPUB) /* \_SB_.PCI0.ISA_.FPU_._CRS.FPUB */
            }
        }
    }

    Scope (_SB.PCI0.ISA)
    {
        Device (PIC)
        {
            Name (_HID, EisaId ("PNP0000") /* 8259-compatible Programmable Interrupt Controller */)  // _HID: Hardware ID
            Method (_CRS, 0, NotSerialized)  // _CRS: Current Resource Settings
            {
                Name (PICB, ResourceTemplate ()
                {
                    IO (Decode16,
                        0x0020,             // Range Minimum
                        0x0020,             // Range Maximum
                        0x00,               // Alignment
                        0x02,               // Length
                        )
                    IO (Decode16,
                        0x00A0,             // Range Minimum
                        0x00A0,             // Range Maximum
                        0x00,               // Alignment
                        0x02,               // Length
                        )
                })
                Return (PICB) /* \_SB_.PCI0.ISA_.PIC_._CRS.PICB */
            }
        }
    }

    Scope (_SB.PCI0.ISA)
    {
        Device (SPK)
        {
            Name (_HID, EisaId ("PNP0800") /* Microsoft Sound System Compatible Device */)  // _HID: Hardware ID
            Method (_CRS, 0, NotSerialized)  // _CRS: Current Resource Settings
            {
                Name (SPKB, ResourceTemplate ()
                {
                    IO (Decode16,
                        0x0061,             // Range Minimum
                        0x0061,             // Range Maximum
                        0x01,               // Alignment
                        0x01,               // Length
                        )
                })
                Return (SPKB) /* \_SB_.PCI0.ISA_.SPK_._CRS.SPKB */
            }
        }
    }

    Scope (_SB.PCI0.ISA)
    {
        Device (RTC)
        {
            Name (_HID, EisaId ("PNP0B00") /* AT Real-Time Clock */)  // _HID: Hardware ID
            Method (_CRS, 0, NotSerialized)  // _CRS: Current Resource Settings
            {
                Name (RTCB, ResourceTemplate ()
                {
                    IO (Decode16,
                        0x0070,             // Range Minimum
                        0x0070,             // Range Maximum
                        0x00,               // Alignment
                        0x02,               // Length
                        )
                })
                Return (RTCB) /* \_SB_.PCI0.ISA_.RTC_._CRS.RTCB */
            }
        }
    }

    Scope (_SB.PCI0.ISA)
    {
        Device (TMR)
        {
            Name (_HID, EisaId ("PNP0100") /* PC-class System Timer */)  // _HID: Hardware ID
            Method (_CRS, 0, NotSerialized)  // _CRS: Current Resource Settings
            {
                Name (TMRB, ResourceTemplate ()
                {
                    IO (Decode16,
                        0x0040,             // Range Minimum
                        0x0040,             // Range Maximum
                        0x01,               // Alignment
                        0x04,               // Length
                        )
                    IO (Decode16,
                        0x0050,             // Range Minimum
                        0x0050,             // Range Maximum
                        0x01,               // Alignment
                        0x04,               // Length
                        )
                })
                Return (TMRB) /* \_SB_.PCI0.ISA_.TMR_._CRS.TMRB */
            }
        }
    }

    Scope (_SB)
    {
        Field (PCI0.ISA.P40C, ByteAcc, NoLock, Preserve)
        {
            PRQ0,   8, 
            PRQ1,   8, 
            PRQ2,   8, 
            PRQ3,   8
        }

        Field (PCI0.ISA.P41C, ByteAcc, NoLock, Preserve)
        {
            PRQ4,   8, 
            PRQ5,   8, 
            PRQ6,   8, 
            PRQ7,   8
        }

        Device (LNKA)
        {
            Name (_HID, EisaId ("PNP0C0F") /* PCI Interrupt Link Device */)  // _HID: Hardware ID
            Name (_UID, 0x0C)  // _UID: Unique ID
            Name (_PRS, ResourceTemplate ()  // _PRS: Possible Resource Settings
            {
                IRQ (Level, ActiveLow, Shared, )
                    {3,4,5,6,7,9,10,11,12,15}
            })
            Method (_STA, 0, NotSerialized)  // _STA: Status
            {
                Local0 = 0x0B
                If (Local1 = (0x80 & PRQ0) /* \_SB_.PRQ0 */)
                {
                    Local0 = 0x09
                }

                Return (Local0)
            }

            Method (_DIS, 0, NotSerialized)  // _DIS: Disable Device
            {
                PRQ0 |= 0x80
            }

            Method (_CRS, 0, NotSerialized)  // _CRS: Current Resource Settings
            {
                Name (PRR0, ResourceTemplate ()
                {
                    IRQ (Level, ActiveLow, Shared, )
                        {4}
                })
                CreateWordField (PRR0, One, IQR)
                Local0 = PRQ0 /* \_SB_.PRQ0 */
                If ((Local0 >= 0x80))
                {
                    IQR = Zero
                }
                Else
                {
                    IQR = (One << Local0)
                }

                Return (PRR0) /* \_SB_.LNKA._CRS.PRR0 */
            }

            Method (_SRS, 1, NotSerialized)  // _SRS: Set Resource Settings
            {
                CreateWordField (Arg0, One, IQR)
                FindSetRightBit (IQR, Local0)
                Local0--
                PRQ0 = Local0
            }
        }

        Device (LNKB)
        {
            Name (_HID, EisaId ("PNP0C0F") /* PCI Interrupt Link Device */)  // _HID: Hardware ID
            Name (_UID, 0x0D)  // _UID: Unique ID
            Name (_PRS, ResourceTemplate ()  // _PRS: Possible Resource Settings
            {
                IRQ (Level, ActiveLow, Shared, )
                    {3,4,5,6,7,9,10,11,12,15}
            })
            Method (_STA, 0, NotSerialized)  // _STA: Status
            {
                Local0 = 0x0B
                If (Local1 = (0x80 & PRQ1) /* \_SB_.PRQ1 */)
                {
                    Local0 = 0x09
                }

                Return (Local0)
            }

            Method (_DIS, 0, NotSerialized)  // _DIS: Disable Device
            {
                PRQ1 |= 0x80
            }

            Method (_CRS, 0, NotSerialized)  // _CRS: Current Resource Settings
            {
                Name (PRR1, ResourceTemplate ()
                {
                    IRQ (Level, ActiveLow, Shared, )
                        {4}
                })
                CreateWordField (PRR1, One, IQR)
                Local0 = PRQ1 /* \_SB_.PRQ1 */
                If ((Local0 >= 0x80))
                {
                    IQR = Zero
                }
                Else
                {
                    IQR = (One << Local0)
                }

                Return (PRR1) /* \_SB_.LNKB._CRS.PRR1 */
            }

            Method (_SRS, 1, NotSerialized)  // _SRS: Set Resource Settings
            {
                CreateWordField (Arg0, One, IQR)
                FindSetRightBit (IQR, Local0)
                Local0--
                PRQ1 = Local0
            }
        }

        Device (LNKC)
        {
            Name (_HID, EisaId ("PNP0C0F") /* PCI Interrupt Link Device */)  // _HID: Hardware ID
            Name (_UID, 0x0E)  // _UID: Unique ID
            Name (_PRS, ResourceTemplate ()  // _PRS: Possible Resource Settings
            {
                IRQ (Level, ActiveLow, Shared, )
                    {3,4,5,6,7,9,10,11,12,15}
            })
            Method (_STA, 0, NotSerialized)  // _STA: Status
            {
                Local0 = 0x0B
                If (Local1 = (0x80 & PRQ2) /* \_SB_.PRQ2 */)
                {
                    Local0 = 0x09
                }

                Return (Local0)
            }

            Method (_DIS, 0, NotSerialized)  // _DIS: Disable Device
            {
                PRQ2 |= 0x80
            }

            Method (_CRS, 0, NotSerialized)  // _CRS: Current Resource Settings
            {
                Name (PRR2, ResourceTemplate ()
                {
                    IRQ (Level, ActiveLow, Shared, )
                        {4}
                })
                CreateWordField (PRR2, One, IQR)
                Local0 = PRQ2 /* \_SB_.PRQ2 */
                If ((Local0 >= 0x80))
                {
                    IQR = Zero
                }
                Else
                {
                    IQR = (One << Local0)
                }

                Return (PRR2) /* \_SB_.LNKC._CRS.PRR2 */
            }

            Method (_SRS, 1, NotSerialized)  // _SRS: Set Resource Settings
            {
                CreateWordField (Arg0, One, IQR)
                FindSetRightBit (IQR, Local0)
                Local0--
                PRQ2 = Local0
            }
        }

        Device (LNKD)
        {
            Name (_HID, EisaId ("PNP0C0F") /* PCI Interrupt Link Device */)  // _HID: Hardware ID
            Name (_UID, 0x0F)  // _UID: Unique ID
            Name (_PRS, ResourceTemplate ()  // _PRS: Possible Resource Settings
            {
                IRQ (Level, ActiveLow, Shared, )
                    {3,4,5,6,7,9,10,11,12,15}
            })
            Method (_STA, 0, NotSerialized)  // _STA: Status
            {
                Local0 = 0x0B
                If (Local1 = (0x80 & PRQ3) /* \_SB_.PRQ3 */)
                {
                    Local0 = 0x09
                }

                Return (Local0)
            }

            Method (_DIS, 0, NotSerialized)  // _DIS: Disable Device
            {
                PRQ3 |= 0x80
            }

            Method (_CRS, 0, NotSerialized)  // _CRS: Current Resource Settings
            {
                Name (PRR3, ResourceTemplate ()
                {
                    IRQ (Level, ActiveLow, Shared, )
                        {4}
                })
                CreateWordField (PRR3, One, IQR)
                Local0 = PRQ3 /* \_SB_.PRQ3 */
                If ((Local0 >= 0x80))
                {
                    IQR = Zero
                }
                Else
                {
                    IQR = (One << Local0)
                }

                Return (PRR3) /* \_SB_.LNKD._CRS.PRR3 */
            }

            Method (_SRS, 1, NotSerialized)  // _SRS: Set Resource Settings
            {
                CreateWordField (Arg0, One, IQR)
                FindSetRightBit (IQR, Local0)
                Local0--
                PRQ3 = Local0
            }
        }

        Device (LNKE)
        {
            Name (_HID, EisaId ("PNP0C0F") /* PCI Interrupt Link Device */)  // _HID: Hardware ID
            Name (_UID, 0x10)  // _UID: Unique ID
            Name (_PRS, ResourceTemplate ()  // _PRS: Possible Resource Settings
            {
                IRQ (Level, ActiveLow, Shared, )
                    {3,4,5,6,7,9,10,11,12,15}
            })
            Method (_STA, 0, NotSerialized)  // _STA: Status
            {
                Local0 = 0x0B
                If (Local1 = (0x80 & PRQ4) /* \_SB_.PRQ4 */)
                {
                    Local0 = 0x09
                }

                Return (Local0)
            }

            Method (_DIS, 0, NotSerialized)  // _DIS: Disable Device
            {
                PRQ4 |= 0x80
            }

            Method (_CRS, 0, NotSerialized)  // _CRS: Current Resource Settings
            {
                Name (PRR4, ResourceTemplate ()
                {
                    IRQ (Level, ActiveLow, Shared, )
                        {4}
                })
                CreateWordField (PRR4, One, IQR)
                Local0 = PRQ4 /* \_SB_.PRQ4 */
                If ((Local0 >= 0x80))
                {
                    IQR = Zero
                }
                Else
                {
                    IQR = (One << Local0)
                }

                Return (PRR4) /* \_SB_.LNKE._CRS.PRR4 */
            }

            Method (_SRS, 1, NotSerialized)  // _SRS: Set Resource Settings
            {
                CreateWordField (Arg0, One, IQR)
                FindSetRightBit (IQR, Local0)
                Local0--
                PRQ4 = Local0
            }
        }

        Device (LNKF)
        {
            Name (_HID, EisaId ("PNP0C0F") /* PCI Interrupt Link Device */)  // _HID: Hardware ID
            Name (_UID, 0x11)  // _UID: Unique ID
            Name (_PRS, ResourceTemplate ()  // _PRS: Possible Resource Settings
            {
                IRQ (Level, ActiveLow, Shared, )
                    {3,4,5,6,7,9,10,11,12,15}
            })
            Method (_STA, 0, NotSerialized)  // _STA: Status
            {
                Local0 = 0x0B
                If (Local1 = (0x80 & PRQ5) /* \_SB_.PRQ5 */)
                {
                    Local0 = 0x09
                }

                Return (Local0)
            }

            Method (_DIS, 0, NotSerialized)  // _DIS: Disable Device
            {
                PRQ5 |= 0x80
            }

            Method (_CRS, 0, NotSerialized)  // _CRS: Current Resource Settings
            {
                Name (PRR5, ResourceTemplate ()
                {
                    IRQ (Level, ActiveLow, Shared, )
                        {4}
                })
                CreateWordField (PRR5, One, IQR)
                Local0 = PRQ5 /* \_SB_.PRQ5 */
                If ((Local0 >= 0x80))
                {
                    IQR = Zero
                }
                Else
                {
                    IQR = (One << Local0)
                }

                Return (PRR5) /* \_SB_.LNKF._CRS.PRR5 */
            }

            Method (_SRS, 1, NotSerialized)  // _SRS: Set Resource Settings
            {
                CreateWordField (Arg0, One, IQR)
                FindSetRightBit (IQR, Local0)
                Local0--
                PRQ5 = Local0
            }
        }

        Device (LNKG)
        {
            Name (_HID, EisaId ("PNP0C0F") /* PCI Interrupt Link Device */)  // _HID: Hardware ID
            Name (_UID, 0x12)  // _UID: Unique ID
            Name (_PRS, ResourceTemplate ()  // _PRS: Possible Resource Settings
            {
                IRQ (Level, ActiveLow, Shared, )
                    {3,4,5,6,7,9,10,11,12,15}
            })
            Method (_STA, 0, NotSerialized)  // _STA: Status
            {
                Local0 = 0x0B
                If (Local1 = (0x80 & PRQ6) /* \_SB_.PRQ6 */)
                {
                    Local0 = 0x09
                }

                Return (Local0)
            }

            Method (_DIS, 0, NotSerialized)  // _DIS: Disable Device
            {
                PRQ6 |= 0x80
            }

            Method (_CRS, 0, NotSerialized)  // _CRS: Current Resource Settings
            {
                Name (PRR6, ResourceTemplate ()
                {
                    IRQ (Level, ActiveLow, Shared, )
                        {4}
                })
                CreateWordField (PRR6, One, IQR)
                Local0 = PRQ6 /* \_SB_.PRQ6 */
                If ((Local0 >= 0x80))
                {
                    IQR = Zero
                }
                Else
                {
                    IQR = (One << Local0)
                }

                Return (PRR6) /* \_SB_.LNKG._CRS.PRR6 */
            }

            Method (_SRS, 1, NotSerialized)  // _SRS: Set Resource Settings
            {
                CreateWordField (Arg0, One, IQR)
                FindSetRightBit (IQR, Local0)
                Local0--
                PRQ6 = Local0
            }
        }

        Device (LNKH)
        {
            Name (_HID, EisaId ("PNP0C0F") /* PCI Interrupt Link Device */)  // _HID: Hardware ID
            Name (_UID, 0x13)  // _UID: Unique ID
            Name (_PRS, ResourceTemplate ()  // _PRS: Possible Resource Settings
            {
                IRQ (Level, ActiveLow, Shared, )
                    {3,4,5,6,7,9,10,11,12,15}
            })
            Method (_STA, 0, NotSerialized)  // _STA: Status
            {
                Local0 = 0x0B
                If (Local1 = (0x80 & PRQ7) /* \_SB_.PRQ7 */)
                {
                    Local0 = 0x09
                }

                Return (Local0)
            }

            Method (_DIS, 0, NotSerialized)  // _DIS: Disable Device
            {
                PRQ7 |= 0x80
            }

            Method (_CRS, 0, NotSerialized)  // _CRS: Current Resource Settings
            {
                Name (PRR7, ResourceTemplate ()
                {
                    IRQ (Level, ActiveLow, Shared, )
                        {4}
                })
                CreateWordField (PRR7, One, IQR)
                Local0 = PRQ7 /* \_SB_.PRQ7 */
                If ((Local0 >= 0x80))
                {
                    IQR = Zero
                }
                Else
                {
                    IQR = (One << Local0)
                }

                Return (PRR7) /* \_SB_.LNKH._CRS.PRR7 */
            }

            Method (_SRS, 1, NotSerialized)  // _SRS: Set Resource Settings
            {
                CreateWordField (Arg0, One, IQR)
                FindSetRightBit (IQR, Local0)
                Local0--
                PRQ7 = Local0
            }
        }
    }

    Scope (_SB)
    {
        Device (HPET)
        {
            Name (_HID, EisaId ("PNP0103") /* HPET System Timer */)  // _HID: Hardware ID
            Method (_CRS, 0, NotSerialized)  // _CRS: Current Resource Settings
            {
                Name (HBAB, ResourceTemplate ()
                {
                    IRQNoFlags ()
                        {0}
                    IRQNoFlags ()
                        {8}
                    Memory32Fixed (ReadOnly,
                        0xFED00000,         // Address Base
                        0x00000400,         // Address Length
                        )
                })
                Return (HBAB) /* \_SB_.HPET._CRS.HBAB */
            }
        }
    }

    Scope (\)
    {
        OperationRegion (WENX, SystemIO, 0x0C0A, 0x06)
        Field (WENX, ByteAcc, NoLock, Preserve)
        {
            WEN1,   8, 
            WEN2,   8, 
            WEN3,   8, 
            WEN4,   8, 
            WEN5,   8, 
            WEN6,   8
        }

        OperationRegion (WSTX, SystemIO, 0x0C00, 0x0A)
        Field (WSTX, ByteAcc, NoLock, Preserve)
        {
            WST0,   8, 
            PMEJ,   8, 
            PENA,   8, 
            PENJ,   8, 
            WST1,   8, 
            WST2,   8, 
            WST3,   8, 
            WST4,   8, 
            WST5,   8, 
            WST6,   8
        }

        OperationRegion (SGPX, SystemIO, 0x0C4B, 0x06)
        Field (SGPX, ByteAcc, NoLock, Preserve)
        {
            SGP1,   8, 
            SGP2,   8, 
            SGP3,   8, 
            SGP4,   8, 
            SGP5,   8, 
            SGP6,   8
        }

        OperationRegion (LEDX, SystemIO, 0x0C5D, 0x02)
        Field (LEDX, ByteAcc, NoLock, Preserve)
        {
            LED1,   8, 
            LED2,   8
        }

        Method (PSKM, 1, NotSerialized)
        {
            If (((Arg0 == 0x03) | (Arg0 == One)))
            {
                SIOI = 0x55
                SIOI = 0x07
                SIOD = 0x07
                SIOI = 0xF0
                Local0 = SIOD /* \SIOD */
                SIOD = (Local0 | 0x60)
                SIOI = 0xAA
                Local0 = WST1 /* \WST1 */
                WST1 = (Local0 & 0x18)
                Local0 = GSTS /* \GSTS */
                GSTS = (Local0 & One)
            }
        }

        Method (GPKM, 0, NotSerialized)
        {
            Local0 = WEN1 /* \WEN1 */
            WEN1 = (Local0 & 0xE7)
            Local0 = WST1 /* \WST1 */
            WST1 = (Local0 & 0x18)
            Local0 = GSTS /* \GSTS */
            GSTS = (Local0 & One)
        }
    }

    Scope (_SB.PCI0.ISA)
    {
        OperationRegion (NSIO, SystemIO, 0x2E, 0x02)
        Field (NSIO, ByteAcc, NoLock, Preserve)
        {
            INDX,   8, 
            DATA,   8
        }

        IndexField (INDX, DATA, ByteAcc, NoLock, Preserve)
        {
            Offset (0x02), 
            CFG,    8, 
            Offset (0x07), 
            LDN,    8, 
            Offset (0x20), 
            SIID,   8, 
            Offset (0x30), 
            ACTR,   8, 
            Offset (0x60), 
            IOAH,   8, 
            IOAL,   8, 
            Offset (0x70), 
            INTR,   8, 
            Offset (0x74), 
            DMCH,   8, 
            Offset (0xF0), 
            OPT1,   8, 
            OPT2,   8, 
            OPT3,   8
        }

        OperationRegion (COM, PCI_Config, 0x80, One)
        Field (COM, ByteAcc, NoLock, Preserve)
        {
            NSCA,   3, 
                ,   1, 
            NSCB,   3, 
            Offset (0x01)
        }

        OperationRegion (FDPA, PCI_Config, 0x81, One)
        Field (FDPA, ByteAcc, NoLock, Preserve)
        {
            LPTO,   2, 
                ,   2, 
            FDDC,   1, 
            Offset (0x01)
        }

        Mutex (MTX, 0x01)
        Method (SIOD, 1, NotSerialized)
        {
            CSIO (0x55)
            LDN = Arg0
            CSIO (0xAA)
        }

        Method (CSIO, 1, NotSerialized)
        {
            INDX = Arg0
        }

        Device (FDC)
        {
            Name (_HID, EisaId ("PNP0700"))  // _HID: Hardware ID
            Method (_STA, 0, NotSerialized)  // _STA: Status
            {
                Name (RET, Zero)
                Acquire (MTX, 0xFFFF)
                SIOD (Zero)
                If (GCFD ())
                {
                    CSIO (0x55)
                    If (ACTR)
                    {
                        Local0 = CMRD (0x10)
                        Local0 &= 0x40
                        If (Local0)
                        {
                            Local0 &= 0x02
                            If (Local0)
                            {
                                Local0 = CMRD (0x10)
                                Local0 &= 0x0F
                                CMWR (0x10, Local0)
                            }
                        }

                        CSIO (0xAA)
                        RET = 0x0F
                    }
                    Else
                    {
                        CSIO (0xAA)
                        RET = 0x0D
                    }
                }
                Else
                {
                    CSIO (0xAA)
                    RET = Zero
                }

                Release (MTX)
                Return (RET) /* \_SB_.PCI0.ISA_.FDC_._STA.RET_ */
            }

            Method (_DIS, 0, NotSerialized)  // _DIS: Disable Device
            {
                Acquire (MTX, 0xFFFF)
                SIOD (Zero)
                CSIO (0x55)
                INTR = Zero
                ACTR = Zero
                CSIO (0xAA)
                Release (MTX)
            }

            Method (_CRS, 0, NotSerialized)  // _CRS: Current Resource Settings
            {
                Name (FDB0, ResourceTemplate ()
                {
                    IO (Decode16,
                        0x03F0,             // Range Minimum
                        0x03F0,             // Range Maximum
                        0x08,               // Alignment
                        0x06,               // Length
                        _Y04)
                    IO (Decode16,
                        0x03F7,             // Range Minimum
                        0x03F7,             // Range Maximum
                        0x01,               // Alignment
                        0x01,               // Length
                        _Y05)
                    IRQNoFlags (_Y06)
                        {6}
                    DMA (Compatibility, NotBusMaster, Transfer8, _Y07)
                        {2}
                })
                CreateByteField (FDB0, \_SB.PCI0.ISA.FDC._CRS._Y04._MIN, IOL0)  // _MIN: Minimum Base Address
                CreateByteField (FDB0, 0x03, IOH0)
                CreateByteField (FDB0, \_SB.PCI0.ISA.FDC._CRS._Y04._MAX, IOL1)  // _MAX: Maximum Base Address
                CreateByteField (FDB0, 0x05, IOH1)
                CreateByteField (FDB0, \_SB.PCI0.ISA.FDC._CRS._Y05._MIN, I2L0)  // _MIN: Minimum Base Address
                CreateByteField (FDB0, 0x0B, I2H0)
                CreateByteField (FDB0, \_SB.PCI0.ISA.FDC._CRS._Y05._MAX, I2L1)  // _MAX: Maximum Base Address
                CreateByteField (FDB0, 0x0D, I2H1)
                CreateWordField (FDB0, \_SB.PCI0.ISA.FDC._CRS._Y06._INT, IQR)  // _INT: Interrupts
                CreateByteField (FDB0, \_SB.PCI0.ISA.FDC._CRS._Y07._DMA, DAM)  // _DMA: Direct Memory Access
                Acquire (MTX, 0xFFFF)
                SIOD (Zero)
                CSIO (0x55)
                IOH0 = IOAH /* \_SB_.PCI0.ISA_.IOAH */
                IOH1 = IOAH /* \_SB_.PCI0.ISA_.IOAH */
                IOL0 = IOAL /* \_SB_.PCI0.ISA_.IOAL */
                IOL1 = IOAL /* \_SB_.PCI0.ISA_.IOAL */
                I2H0 = IOAH /* \_SB_.PCI0.ISA_.IOAH */
                I2H1 = IOAH /* \_SB_.PCI0.ISA_.IOAH */
                I2L0 = (IOAL + 0x07)
                I2L1 = (IOAL + 0x07)
                IQR = (One << INTR) /* \_SB_.PCI0.ISA_.INTR */
                DAM = (One << DMCH) /* \_SB_.PCI0.ISA_.DMCH */
                CSIO (0xAA)
                Release (MTX)
                Return (FDB0) /* \_SB_.PCI0.ISA_.FDC_._CRS.FDB0 */
            }

            Method (_PRS, 0, NotSerialized)  // _PRS: Possible Resource Settings
            {
                Name (FDB1, ResourceTemplate ()
                {
                    StartDependentFnNoPri ()
                    {
                        IO (Decode16,
                            0x03F0,             // Range Minimum
                            0x03F0,             // Range Maximum
                            0x08,               // Alignment
                            0x06,               // Length
                            )
                        IO (Decode16,
                            0x03F7,             // Range Minimum
                            0x03F7,             // Range Maximum
                            0x01,               // Alignment
                            0x01,               // Length
                            )
                        IRQNoFlags ()
                            {6}
                        DMA (Compatibility, NotBusMaster, Transfer8, )
                            {2}
                    }
                    StartDependentFnNoPri ()
                    {
                        IO (Decode16,
                            0x03F0,             // Range Minimum
                            0x03F0,             // Range Maximum
                            0x08,               // Alignment
                            0x06,               // Length
                            )
                        IO (Decode16,
                            0x03F7,             // Range Minimum
                            0x03F7,             // Range Maximum
                            0x01,               // Alignment
                            0x01,               // Length
                            )
                        IRQNoFlags ()
                            {3,4,5,6,7,12}
                        DMA (Compatibility, NotBusMaster, Transfer8, )
                            {1,2,3}
                    }
                    StartDependentFnNoPri ()
                    {
                        IO (Decode16,
                            0x0370,             // Range Minimum
                            0x0370,             // Range Maximum
                            0x08,               // Alignment
                            0x06,               // Length
                            )
                        IO (Decode16,
                            0x0377,             // Range Minimum
                            0x0377,             // Range Maximum
                            0x01,               // Alignment
                            0x01,               // Length
                            )
                        IRQNoFlags ()
                            {3,4,5,6,7,12}
                        DMA (Compatibility, NotBusMaster, Transfer8, )
                            {1,2,3}
                    }
                    EndDependentFn ()
                })
                Return (FDB1) /* \_SB_.PCI0.ISA_.FDC_._PRS.FDB1 */
            }

            Method (_SRS, 1, NotSerialized)  // _SRS: Set Resource Settings
            {
                CreateByteField (Arg0, 0x02, IOLO)
                CreateByteField (Arg0, 0x03, IOHI)
                CreateWordField (Arg0, 0x11, IQR)
                CreateByteField (Arg0, 0x14, DAM)
                Acquire (MTX, 0xFFFF)
                SIOD (Zero)
                CSIO (0x55)
                IOAL = IOLO /* \_SB_.PCI0.ISA_.FDC_._SRS.IOLO */
                IOAH = IOHI /* \_SB_.PCI0.ISA_.FDC_._SRS.IOHI */
                CSIO (0xAA)
                If ((IOLO == 0x70))
                {
                    FDDC = One
                }

                If ((IOLO == 0xF0))
                {
                    FDDC = Zero
                }

                CSIO (0x55)
                FindSetRightBit (IQR, Local0)
                INTR = (Local0 - One)
                FindSetRightBit (DAM, Local0)
                DMCH = (Local0 - One)
                ACTR = One
                CSIO (0xAA)
                Release (MTX)
            }

            Method (_FDE, 0, NotSerialized)  // _FDE: Floppy Disk Enumerate
            {
                Name (FDEB, Buffer (0x14){})
                CreateDWordField (FDEB, Zero, FDE0)
                CreateDWordField (FDEB, 0x04, FDE1)
                CreateDWordField (FDEB, 0x08, FDE2)
                CreateDWordField (FDEB, 0x0C, FDE3)
                CreateDWordField (FDEB, 0x10, FDE4)
                FDE0 = Zero
                FDE1 = Zero
                FDE2 = Zero
                FDE3 = Zero
                FDE4 = 0x02
                Local0 = CMRD (0x10)
                Local0 &= 0x40
                If (Local0)
                {
                    FDE0 = One
                }

                Return (FDEB) /* \_SB_.PCI0.ISA_.FDC_._FDE.FDEB */
            }

            Name (FINF, Package (0x10)
            {
                Zero, 
                0x04, 
                0x4F, 
                0x12, 
                One, 
                0xAF, 
                0x02, 
                0x25, 
                0x02, 
                0x12, 
                0x1B, 
                0xFF, 
                0x6C, 
                0xF6, 
                0x0F, 
                0x08
            })
            Method (_FDI, 0, NotSerialized)  // _FDI: Floppy Drive Information
            {
                FINF [Zero] = Zero
                Return (FINF) /* \_SB_.PCI0.ISA_.FDC_.FINF */
            }

            Device (FDCA)
            {
                Name (_ADR, Zero)  // _ADR: Address
                Method (_EJ0, 1, NotSerialized)  // _EJx: Eject Device, x=0-9
                {
                    Local0 = GI48 /* \GI48 */
                    GI48 = (Local0 & 0xF7)
                    Return (Zero)
                }

                Method (_STA, 0, NotSerialized)  // _STA: Status
                {
                    Local0 = GI32 /* \GI32 */
                    Local0 = (GI32 & 0x70)
                    If ((Local0 != 0x30))
                    {
                        Local1 = Zero
                        Return (Local1)
                    }
                    Else
                    {
                        Acquire (STSM, 0xFFFF)
                        Acquire (FOOM, 0xFFFF)
                        Local0 = CMRD (0x10)
                        Local0 &= 0x40
                        Release (FOOM)
                        Acquire (FOOM, 0xFFFF)
                        If (Local0)
                        {
                            Local1 = 0x0F
                        }
                        Else
                        {
                            Local1 = Zero
                        }

                        Release (FOOM)
                        Release (STSM)
                        Return (Local1)
                    }
                }
            }
        }

        Device (KBD)
        {
            Name (_HID, EisaId ("PNP0303") /* IBM Enhanced Keyboard (101/102-key, PS/2 Mouse) */)  // _HID: Hardware ID
            Method (_STA, 0, NotSerialized)  // _STA: Status
            {
                Name (RET, Zero)
                RET = Zero
                If (GCKB ())
                {
                    RET = 0x0F
                }

                Return (RET) /* \_SB_.PCI0.ISA_.KBD_._STA.RET_ */
            }

            Method (_CRS, 0, NotSerialized)  // _CRS: Current Resource Settings
            {
                Name (KBDB, ResourceTemplate ()
                {
                    IO (Decode16,
                        0x0060,             // Range Minimum
                        0x0060,             // Range Maximum
                        0x01,               // Alignment
                        0x01,               // Length
                        )
                    IO (Decode16,
                        0x0064,             // Range Minimum
                        0x0064,             // Range Maximum
                        0x01,               // Alignment
                        0x01,               // Length
                        )
                    IRQNoFlags ()
                        {1}
                })
                Return (KBDB) /* \_SB_.PCI0.ISA_.KBD_._CRS.KBDB */
            }
        }

        Device (MOU)
        {
            Name (_HID, EisaId ("PNP0F13") /* PS/2 Mouse */)  // _HID: Hardware ID
            Method (_STA, 0, NotSerialized)  // _STA: Status
            {
                Name (RET, Zero)
                RET = Zero
                If (GCON ())
                {
                    If (GCMS ())
                    {
                        RET = 0x0F
                    }
                }

                Return (RET) /* \_SB_.PCI0.ISA_.MOU_._STA.RET_ */
            }

            Method (_CRS, 0, NotSerialized)  // _CRS: Current Resource Settings
            {
                Name (MOUB, ResourceTemplate ()
                {
                    IRQNoFlags ()
                        {12}
                })
                Name (MOKB, ResourceTemplate ()
                {
                    IO (Decode16,
                        0x0060,             // Range Minimum
                        0x0060,             // Range Maximum
                        0x01,               // Alignment
                        0x01,               // Length
                        )
                    IO (Decode16,
                        0x0064,             // Range Minimum
                        0x0064,             // Range Maximum
                        0x01,               // Alignment
                        0x01,               // Length
                        )
                    IRQNoFlags ()
                        {12}
                })
                If (GCKB ())
                {
                    Return (MOUB) /* \_SB_.PCI0.ISA_.MOU_._CRS.MOUB */
                }
                Else
                {
                    Return (MOKB) /* \_SB_.PCI0.ISA_.MOU_._CRS.MOKB */
                }
            }
        }

        Device (PRT)
        {
            Name (_HID, EisaId ("PNP0401") /* ECP Parallel Port */)  // _HID: Hardware ID
            Method (_STA, 0, NotSerialized)  // _STA: Status
            {
                Name (RET, Zero)
                Acquire (MTX, 0xFFFF)
                SIOD (0x03)
                If (GCPP ())
                {
                    CSIO (0x55)
                    If (ACTR)
                    {
                        CSIO (0xAA)
                        RET = 0x0F
                    }
                    Else
                    {
                        CSIO (0xAA)
                        RET = 0x0D
                    }
                }
                Else
                {
                    CSIO (0xAA)
                    RET = Zero
                }

                Release (MTX)
                Return (RET) /* \_SB_.PCI0.ISA_.PRT_._STA.RET_ */
            }

            Method (_DIS, 0, NotSerialized)  // _DIS: Disable Device
            {
                Acquire (MTX, 0xFFFF)
                SIOD (0x03)
                CSIO (0x55)
                INTR = Zero
                DMCH = 0x04
                ACTR = Zero
                CSIO (0xAA)
                Release (MTX)
            }

            Method (_CRS, 0, NotSerialized)  // _CRS: Current Resource Settings
            {
                Name (PTB0, ResourceTemplate ()
                {
                    IO (Decode16,
                        0x0378,             // Range Minimum
                        0x0378,             // Range Maximum
                        0x08,               // Alignment
                        0x08,               // Length
                        _Y08)
                    IO (Decode16,
                        0x0778,             // Range Minimum
                        0x0778,             // Range Maximum
                        0x08,               // Alignment
                        0x08,               // Length
                        _Y09)
                    IRQNoFlags (_Y0A)
                        {7}
                    DMA (Compatibility, NotBusMaster, Transfer8, _Y0B)
                        {}
                })
                CreateByteField (PTB0, \_SB.PCI0.ISA.PRT._CRS._Y08._MIN, IOL0)  // _MIN: Minimum Base Address
                CreateByteField (PTB0, 0x03, IOH0)
                CreateByteField (PTB0, \_SB.PCI0.ISA.PRT._CRS._Y08._MAX, IOL1)  // _MAX: Maximum Base Address
                CreateByteField (PTB0, 0x05, IOH1)
                CreateByteField (PTB0, \_SB.PCI0.ISA.PRT._CRS._Y08._ALN, LALN)  // _ALN: Alignment
                CreateByteField (PTB0, \_SB.PCI0.ISA.PRT._CRS._Y08._LEN, LLEN)  // _LEN: Length
                CreateByteField (PTB0, \_SB.PCI0.ISA.PRT._CRS._Y09._MIN, I2L0)  // _MIN: Minimum Base Address
                CreateByteField (PTB0, 0x0B, I2H0)
                CreateByteField (PTB0, \_SB.PCI0.ISA.PRT._CRS._Y09._MAX, I2L1)  // _MAX: Maximum Base Address
                CreateByteField (PTB0, 0x0D, I2H1)
                CreateByteField (PTB0, \_SB.PCI0.ISA.PRT._CRS._Y09._ALN, HALN)  // _ALN: Alignment
                CreateByteField (PTB0, \_SB.PCI0.ISA.PRT._CRS._Y09._LEN, HLEN)  // _LEN: Length
                CreateWordField (PTB0, \_SB.PCI0.ISA.PRT._CRS._Y0A._INT, IQR)  // _INT: Interrupts
                CreateByteField (PTB0, \_SB.PCI0.ISA.PRT._CRS._Y0B._DMA, DAM)  // _DMA: Direct Memory Access
                Acquire (MTX, 0xFFFF)
                SIOD (0x03)
                CSIO (0x55)
                IOH0 = IOAH /* \_SB_.PCI0.ISA_.IOAH */
                IOH1 = IOAH /* \_SB_.PCI0.ISA_.IOAH */
                IOL0 = IOAL /* \_SB_.PCI0.ISA_.IOAL */
                IOL1 = IOAL /* \_SB_.PCI0.ISA_.IOAL */
                I2H0 = (IOAH + 0x04)
                I2H1 = (IOAH + 0x04)
                I2L0 = IOAL /* \_SB_.PCI0.ISA_.IOAL */
                I2L1 = IOAL /* \_SB_.PCI0.ISA_.IOAL */
                IQR = (One << INTR) /* \_SB_.PCI0.ISA_.INTR */
                DAM = (One << DMCH) /* \_SB_.PCI0.ISA_.DMCH */
                If ((IOL0 == 0xBC))
                {
                    LALN = 0x04
                    LLEN = 0x04
                    HALN = 0x04
                    HLEN = 0x04
                }

                If ((DMCH == 0x04))
                {
                    DAM = Zero
                }

                If ((INTR == Zero))
                {
                    IQR = Zero
                }

                CSIO (0xAA)
                Release (MTX)
                Return (PTB0) /* \_SB_.PCI0.ISA_.PRT_._CRS.PTB0 */
            }

            Method (_PRS, 0, NotSerialized)  // _PRS: Possible Resource Settings
            {
                Name (PTB1, ResourceTemplate ()
                {
                    StartDependentFnNoPri ()
                    {
                        IO (Decode16,
                            0x0378,             // Range Minimum
                            0x0378,             // Range Maximum
                            0x08,               // Alignment
                            0x08,               // Length
                            )
                        IO (Decode16,
                            0x0778,             // Range Minimum
                            0x0778,             // Range Maximum
                            0x08,               // Alignment
                            0x08,               // Length
                            )
                        IRQNoFlags ()
                            {7}
                        DMA (Compatibility, NotBusMaster, Transfer8, )
                            {}
                    }
                    StartDependentFnNoPri ()
                    {
                        IO (Decode16,
                            0x0278,             // Range Minimum
                            0x0278,             // Range Maximum
                            0x08,               // Alignment
                            0x08,               // Length
                            )
                        IO (Decode16,
                            0x0678,             // Range Minimum
                            0x0678,             // Range Maximum
                            0x08,               // Alignment
                            0x08,               // Length
                            )
                        IRQNoFlags ()
                            {5}
                        DMA (Compatibility, NotBusMaster, Transfer8, )
                            {}
                    }
                    StartDependentFnNoPri ()
                    {
                        IO (Decode16,
                            0x0378,             // Range Minimum
                            0x0378,             // Range Maximum
                            0x08,               // Alignment
                            0x08,               // Length
                            )
                        IO (Decode16,
                            0x0778,             // Range Minimum
                            0x0778,             // Range Maximum
                            0x08,               // Alignment
                            0x08,               // Length
                            )
                        IRQNoFlags ()
                            {3,4,5,6,7,12}
                        DMA (Compatibility, NotBusMaster, Transfer8, )
                            {}
                    }
                    StartDependentFnNoPri ()
                    {
                        IO (Decode16,
                            0x0378,             // Range Minimum
                            0x0378,             // Range Maximum
                            0x08,               // Alignment
                            0x08,               // Length
                            )
                        IO (Decode16,
                            0x0778,             // Range Minimum
                            0x0778,             // Range Maximum
                            0x08,               // Alignment
                            0x08,               // Length
                            )
                        IRQNoFlags ()
                            {3,4,5,6,7,12}
                        DMA (Compatibility, NotBusMaster, Transfer8, )
                            {1,2,3}
                    }
                    StartDependentFnNoPri ()
                    {
                        IO (Decode16,
                            0x0278,             // Range Minimum
                            0x0278,             // Range Maximum
                            0x08,               // Alignment
                            0x08,               // Length
                            )
                        IO (Decode16,
                            0x0678,             // Range Minimum
                            0x0678,             // Range Maximum
                            0x08,               // Alignment
                            0x08,               // Length
                            )
                        IRQNoFlags ()
                            {3,4,5,6,7,12}
                        DMA (Compatibility, NotBusMaster, Transfer8, )
                            {}
                    }
                    StartDependentFnNoPri ()
                    {
                        IO (Decode16,
                            0x0278,             // Range Minimum
                            0x0278,             // Range Maximum
                            0x08,               // Alignment
                            0x08,               // Length
                            )
                        IO (Decode16,
                            0x0678,             // Range Minimum
                            0x0678,             // Range Maximum
                            0x08,               // Alignment
                            0x08,               // Length
                            )
                        IRQNoFlags ()
                            {3,4,5,6,7,12}
                        DMA (Compatibility, NotBusMaster, Transfer8, )
                            {1,2,3}
                    }
                    StartDependentFnNoPri ()
                    {
                        IO (Decode16,
                            0x0378,             // Range Minimum
                            0x0378,             // Range Maximum
                            0x08,               // Alignment
                            0x08,               // Length
                            )
                        IO (Decode16,
                            0x0778,             // Range Minimum
                            0x0778,             // Range Maximum
                            0x08,               // Alignment
                            0x08,               // Length
                            )
                        IRQNoFlags ()
                            {}
                        DMA (Compatibility, NotBusMaster, Transfer8, )
                            {}
                    }
                    StartDependentFnNoPri ()
                    {
                        IO (Decode16,
                            0x0278,             // Range Minimum
                            0x0278,             // Range Maximum
                            0x08,               // Alignment
                            0x08,               // Length
                            )
                        IO (Decode16,
                            0x0678,             // Range Minimum
                            0x0678,             // Range Maximum
                            0x08,               // Alignment
                            0x08,               // Length
                            )
                        IRQNoFlags ()
                            {}
                        DMA (Compatibility, NotBusMaster, Transfer8, )
                            {}
                    }
                    StartDependentFnNoPri ()
                    {
                        IO (Decode16,
                            0x03BC,             // Range Minimum
                            0x03BC,             // Range Maximum
                            0x04,               // Alignment
                            0x04,               // Length
                            )
                        IO (Decode16,
                            0x07BC,             // Range Minimum
                            0x07BC,             // Range Maximum
                            0x04,               // Alignment
                            0x04,               // Length
                            )
                        IRQNoFlags ()
                            {}
                        DMA (Compatibility, NotBusMaster, Transfer8, )
                            {}
                    }
                    StartDependentFnNoPri ()
                    {
                        IO (Decode16,
                            0x03BC,             // Range Minimum
                            0x03BC,             // Range Maximum
                            0x04,               // Alignment
                            0x04,               // Length
                            )
                        IO (Decode16,
                            0x07BC,             // Range Minimum
                            0x07BC,             // Range Maximum
                            0x04,               // Alignment
                            0x04,               // Length
                            )
                        IRQNoFlags ()
                            {7}
                        DMA (Compatibility, NotBusMaster, Transfer8, )
                            {}
                    }
                    EndDependentFn ()
                })
                Return (PTB1) /* \_SB_.PCI0.ISA_.PRT_._PRS.PTB1 */
            }

            Method (_SRS, 1, NotSerialized)  // _SRS: Set Resource Settings
            {
                CreateByteField (Arg0, 0x02, IOLO)
                CreateByteField (Arg0, 0x03, IOHI)
                CreateWordField (Arg0, 0x11, IQR)
                CreateByteField (Arg0, 0x14, DAM)
                Acquire (MTX, 0xFFFF)
                SIOD (0x03)
                CSIO (0x55)
                IOAL = IOLO /* \_SB_.PCI0.ISA_.PRT_._SRS.IOLO */
                IOAH = IOHI /* \_SB_.PCI0.ISA_.PRT_._SRS.IOHI */
                If ((IOLO == 0xBC))
                {
                    LPTO = 0x02
                }

                If ((IOLO == 0x78))
                {
                    If ((IOHI == 0x02))
                    {
                        LPTO = One
                    }

                    If ((IOHI == 0x03))
                    {
                        LPTO = Zero
                    }
                }

                If ((IQR == Zero))
                {
                    INTR = Zero
                }
                Else
                {
                    FindSetRightBit (IQR, Local0)
                    INTR = (Local0 - One)
                }

                If ((DAM == Zero))
                {
                    DMCH = 0x04
                }
                Else
                {
                    FindSetRightBit (DAM, Local0)
                    DMCH = (Local0 - One)
                }

                ACTR = One
                CSIO (0xAA)
                Release (MTX)
            }
        }

        Device (COMA)
        {
            Name (_HID, EisaId ("PNP0501") /* 16550A-compatible COM Serial Port */)  // _HID: Hardware ID
            Name (_UID, One)  // _UID: Unique ID
            Method (_STA, 0, NotSerialized)  // _STA: Status
            {
                Name (RET, Zero)
                Acquire (MTX, 0xFFFF)
                SIOD (0x04)
                If (GCS1 ())
                {
                    CSIO (0x55)
                    If (ACTR)
                    {
                        CSIO (0xAA)
                        RET = 0x0F
                    }
                    Else
                    {
                        CSIO (0xAA)
                        RET = 0x0D
                    }
                }
                Else
                {
                    CSIO (0xAA)
                    RET = Zero
                }

                Release (MTX)
                Return (RET) /* \_SB_.PCI0.ISA_.COMA._STA.RET_ */
            }

            Method (_DIS, 0, NotSerialized)  // _DIS: Disable Device
            {
                Acquire (MTX, 0xFFFF)
                SIOD (0x04)
                CSIO (0x55)
                INTR = Zero
                ACTR = Zero
                CSIO (0xAA)
                Release (MTX)
            }

            Method (_CRS, 0, NotSerialized)  // _CRS: Current Resource Settings
            {
                Name (CMA0, ResourceTemplate ()
                {
                    IO (Decode16,
                        0x03F8,             // Range Minimum
                        0x03F8,             // Range Maximum
                        0x08,               // Alignment
                        0x08,               // Length
                        _Y0C)
                    IRQNoFlags (_Y0D)
                        {4}
                })
                CreateByteField (CMA0, \_SB.PCI0.ISA.COMA._CRS._Y0C._MIN, IOL0)  // _MIN: Minimum Base Address
                CreateByteField (CMA0, 0x03, IOH0)
                CreateByteField (CMA0, \_SB.PCI0.ISA.COMA._CRS._Y0C._MAX, IOL1)  // _MAX: Maximum Base Address
                CreateByteField (CMA0, 0x05, IOH1)
                CreateWordField (CMA0, \_SB.PCI0.ISA.COMA._CRS._Y0D._INT, IQR)  // _INT: Interrupts
                Acquire (MTX, 0xFFFF)
                SIOD (0x04)
                CSIO (0x55)
                IOL0 = IOAL /* \_SB_.PCI0.ISA_.IOAL */
                IOL1 = IOAL /* \_SB_.PCI0.ISA_.IOAL */
                IOH0 = IOAH /* \_SB_.PCI0.ISA_.IOAH */
                IOH1 = IOAH /* \_SB_.PCI0.ISA_.IOAH */
                IQR = (One << INTR) /* \_SB_.PCI0.ISA_.INTR */
                CSIO (0xAA)
                Release (MTX)
                Return (CMA0) /* \_SB_.PCI0.ISA_.COMA._CRS.CMA0 */
            }

            Method (_PRS, 0, NotSerialized)  // _PRS: Possible Resource Settings
            {
                Name (CMA1, ResourceTemplate ()
                {
                    StartDependentFnNoPri ()
                    {
                        IO (Decode16,
                            0x03F8,             // Range Minimum
                            0x03F8,             // Range Maximum
                            0x08,               // Alignment
                            0x08,               // Length
                            )
                        IRQNoFlags ()
                            {4}
                    }
                    StartDependentFnNoPri ()
                    {
                        IO (Decode16,
                            0x03E8,             // Range Minimum
                            0x03E8,             // Range Maximum
                            0x08,               // Alignment
                            0x08,               // Length
                            )
                        IRQNoFlags ()
                            {4}
                    }
                    StartDependentFnNoPri ()
                    {
                        IO (Decode16,
                            0x02F8,             // Range Minimum
                            0x02F8,             // Range Maximum
                            0x08,               // Alignment
                            0x08,               // Length
                            )
                        IRQNoFlags ()
                            {3}
                    }
                    StartDependentFnNoPri ()
                    {
                        IO (Decode16,
                            0x02E8,             // Range Minimum
                            0x02E8,             // Range Maximum
                            0x08,               // Alignment
                            0x08,               // Length
                            )
                        IRQNoFlags ()
                            {3}
                    }
                    EndDependentFn ()
                })
                Return (CMA1) /* \_SB_.PCI0.ISA_.COMA._PRS.CMA1 */
            }

            Method (_SRS, 1, NotSerialized)  // _SRS: Set Resource Settings
            {
                CreateByteField (Arg0, 0x02, IOLO)
                CreateByteField (Arg0, 0x03, IOHI)
                CreateWordField (Arg0, 0x09, IQR)
                Acquire (MTX, 0xFFFF)
                SIOD (0x04)
                CSIO (0x55)
                IOAL = IOLO /* \_SB_.PCI0.ISA_.COMA._SRS.IOLO */
                IOAH = IOHI /* \_SB_.PCI0.ISA_.COMA._SRS.IOHI */
                FindSetRightBit (IQR, Local0)
                INTR = (Local0 - One)
                If ((IOHI == 0x03))
                {
                    If ((IOLO == 0xF8))
                    {
                        NSCA = Zero
                    }

                    If ((IOLO == 0xE8))
                    {
                        NSCA = 0x07
                    }
                }

                If ((IOHI == 0x02))
                {
                    If ((IOLO == 0xF8))
                    {
                        NSCA = One
                    }

                    If ((IOLO == 0xE8))
                    {
                        NSCA = 0x05
                    }
                }

                ACTR = One
                CSIO (0xAA)
                Release (MTX)
            }
        }

        Device (COMB)
        {
            Name (_HID, EisaId ("PNP0501") /* 16550A-compatible COM Serial Port */)  // _HID: Hardware ID
            Name (_UID, 0x02)  // _UID: Unique ID
            Method (_STA, 0, NotSerialized)  // _STA: Status
            {
                Name (RET, Zero)
                Acquire (MTX, 0xFFFF)
                SIOD (0x05)
                If (GCS2 ())
                {
                    CSIO (0x55)
                    If (ACTR)
                    {
                        CSIO (0xAA)
                        RET = 0x0F
                    }
                    Else
                    {
                        CSIO (0xAA)
                        RET = 0x0D
                    }
                }
                Else
                {
                    CSIO (0xAA)
                    RET = Zero
                }

                Release (MTX)
                Return (RET) /* \_SB_.PCI0.ISA_.COMB._STA.RET_ */
            }

            Method (_DIS, 0, NotSerialized)  // _DIS: Disable Device
            {
                Acquire (MTX, 0xFFFF)
                SIOD (0x05)
                CSIO (0x55)
                INTR = Zero
                Local0 = OPT1 /* \_SB_.PCI0.ISA_.OPT1 */
                Local0 |= 0x20
                OPT1 = Local0
                ACTR = Zero
                CSIO (0xAA)
                Release (MTX)
            }

            Method (_CRS, 0, NotSerialized)  // _CRS: Current Resource Settings
            {
                Name (CMB0, ResourceTemplate ()
                {
                    IO (Decode16,
                        0x03F8,             // Range Minimum
                        0x03F8,             // Range Maximum
                        0x08,               // Alignment
                        0x08,               // Length
                        _Y0E)
                    IRQNoFlags (_Y0F)
                        {4}
                })
                CreateByteField (CMB0, \_SB.PCI0.ISA.COMB._CRS._Y0E._MIN, IOL0)  // _MIN: Minimum Base Address
                CreateByteField (CMB0, 0x03, IOH0)
                CreateByteField (CMB0, \_SB.PCI0.ISA.COMB._CRS._Y0E._MAX, IOL1)  // _MAX: Maximum Base Address
                CreateByteField (CMB0, 0x05, IOH1)
                CreateWordField (CMB0, \_SB.PCI0.ISA.COMB._CRS._Y0F._INT, IQR)  // _INT: Interrupts
                Acquire (MTX, 0xFFFF)
                SIOD (0x05)
                CSIO (0x55)
                IOL0 = IOAL /* \_SB_.PCI0.ISA_.IOAL */
                IOL1 = IOAL /* \_SB_.PCI0.ISA_.IOAL */
                IOH0 = IOAH /* \_SB_.PCI0.ISA_.IOAH */
                IOH1 = IOAH /* \_SB_.PCI0.ISA_.IOAH */
                IQR = (One << INTR) /* \_SB_.PCI0.ISA_.INTR */
                CSIO (0xAA)
                Release (MTX)
                Return (CMB0) /* \_SB_.PCI0.ISA_.COMB._CRS.CMB0 */
            }

            Method (_PRS, 0, NotSerialized)  // _PRS: Possible Resource Settings
            {
                Name (CMB1, ResourceTemplate ()
                {
                    StartDependentFnNoPri ()
                    {
                        IO (Decode16,
                            0x02F8,             // Range Minimum
                            0x02F8,             // Range Maximum
                            0x08,               // Alignment
                            0x08,               // Length
                            )
                        IRQNoFlags ()
                            {3}
                    }
                    StartDependentFnNoPri ()
                    {
                        IO (Decode16,
                            0x02E8,             // Range Minimum
                            0x02E8,             // Range Maximum
                            0x08,               // Alignment
                            0x08,               // Length
                            )
                        IRQNoFlags ()
                            {3}
                    }
                    StartDependentFnNoPri ()
                    {
                        IO (Decode16,
                            0x03F8,             // Range Minimum
                            0x03F8,             // Range Maximum
                            0x08,               // Alignment
                            0x08,               // Length
                            )
                        IRQNoFlags ()
                            {4}
                    }
                    StartDependentFnNoPri ()
                    {
                        IO (Decode16,
                            0x03E8,             // Range Minimum
                            0x03E8,             // Range Maximum
                            0x08,               // Alignment
                            0x08,               // Length
                            )
                        IRQNoFlags ()
                            {4}
                    }
                    EndDependentFn ()
                })
                Return (CMB1) /* \_SB_.PCI0.ISA_.COMB._PRS.CMB1 */
            }

            Method (_SRS, 1, NotSerialized)  // _SRS: Set Resource Settings
            {
                CreateByteField (Arg0, 0x02, IOLO)
                CreateByteField (Arg0, 0x03, IOHI)
                CreateWordField (Arg0, 0x09, IQR)
                Acquire (MTX, 0xFFFF)
                SIOD (0x05)
                CSIO (0x55)
                IOAL = IOLO /* \_SB_.PCI0.ISA_.COMB._SRS.IOLO */
                IOAH = IOHI /* \_SB_.PCI0.ISA_.COMB._SRS.IOHI */
                FindSetRightBit (IQR, Local0)
                INTR = (Local0 - One)
                If ((IOHI == 0x03))
                {
                    If ((IOLO == 0xF8))
                    {
                        NSCB = Zero
                    }

                    If ((IOLO == 0xE8))
                    {
                        NSCB = 0x07
                    }
                }

                If ((IOHI == 0x02))
                {
                    If ((IOLO == 0xF8))
                    {
                        NSCB = One
                    }

                    If ((IOLO == 0xE8))
                    {
                        NSCB = 0x05
                    }
                }

                ACTR = One
                Local0 = OPT1 /* \_SB_.PCI0.ISA_.OPT1 */
                Local0 &= 0xDF
                OPT1 = Local0
                CSIO (0xAA)
                Release (MTX)
            }
        }
    }

    Scope (_SB.PCI0.ISA)
    {
        Device (TPM)
        {
            Method (_HID, 0, NotSerialized)  // _HID: Hardware ID
            {
                If (GTPM ())
                {
                    Return (0x0435CF4D)
                }
                Else
                {
                    Return (0x0012AF4D)
                }
            }

            Name (_CID, EisaId ("PNP0C31"))  // _CID: Compatible ID
            Method (_STA, 0, NotSerialized)  // _STA: Status
            {
                If (GCTP ())
                {
                    Return (0x0F)
                }
                Else
                {
                    Return (Zero)
                }
            }

            Method (_CRS, 0, NotSerialized)  // _CRS: Current Resource Settings
            {
                If (GCTP ())
                {
                    Return (ResourceTemplate ()
                    {
                        Memory32Fixed (ReadWrite,
                            0xFED40000,         // Address Base
                            0x00005000,         // Address Length
                            )
                        IO (Decode16,
                            0x0CB0,             // Range Minimum
                            0x0CB0,             // Range Maximum
                            0x08,               // Alignment
                            0x10,               // Length
                            )
                    })
                }
                Else
                {
                    Return (Buffer (One)
                    {
                         0x00                                             // .
                    })
                }
            }

            Method (_DSM, 4, NotSerialized)  // _DSM: Device-Specific Method
            {
                If ((ToBuffer (Arg0) == ToUUID ("3dddfaa6-361b-4eb4-a424-8d10089d1653") /* Physical Presence Interface */))
                {
                    Name (T_0, Zero)
                    T_0 = ToInteger (Arg2)
                    If ((T_0 == Zero))
                    {
                        Return (Buffer (One)
                        {
                             0x3F                                             // ?
                        })
                    }
                    ElseIf ((T_0 == One))
                    {
                        Return ("1.0")
                    }
                    ElseIf ((T_0 == 0x02))
                    {
                        Local0 = ToInteger (Arg3)
                        Local0 &= 0x0F
                        CMWR (0x7E, Local0)
                        Return (Zero)
                    }
                    ElseIf ((T_0 == 0x03))
                    {
                        Local0 = CMRD (0x7E)
                        Local0 &= 0x0F
                        Return (PPR2 (Local0))
                    }
                    ElseIf ((T_0 == 0x04))
                    {
                        Return (0x02)
                    }
                    ElseIf ((T_0 == 0x05))
                    {
                        Local0 = CMRD (0x7E)
                        Local0 >>= 0x04
                        Local1 = CMRD (0x7F)
                        Local1 &= 0x7F
                        Return (PPR3 (Local0, Local1))
                    }
                    ElseIf ((T_0 == 0x06))
                    {
                        Name (T_1, "")
                        T_1 = ToString (Arg3, Ones)
                        If ((T_1 == "en"))
                        {
                            Return (Zero)
                        }
                        Else
                        {
                            Return (One)
                        }
                    }
                    Else
                    {
                        Return (Buffer (One)
                        {
                             0x00                                             // .
                        })
                    }
                }

                If ((ToBuffer (Arg0) == ToUUID ("376054ed-cc13-4675-901c-4756d7f2d45d") /* Unknown UUID */))
                {
                    Name (T_2, Zero)
                    T_2 = ToInteger (Arg2)
                    If ((T_2 == Zero))
                    {
                        Return (Buffer (One)
                        {
                             0x01                                             // .
                        })
                    }
                    ElseIf ((T_2 == One))
                    {
                        Local1 = SMI (0xBC, (ToInteger (Arg3) & One))
                        Return (ToInteger (Local1))
                    }
                }

                Return (Buffer (One)
                {
                     0x00                                             // .
                })
            }

            Method (PPR2, 1, NotSerialized)
            {
                Name (T_0, Zero)
                T_0 = ToInteger (Arg0)
                If ((T_0 == Zero))
                {
                    Return (Package (0x02)
                    {
                        Zero, 
                        Zero
                    })
                }
                ElseIf ((T_0 == One))
                {
                    Return (Package (0x02)
                    {
                        Zero, 
                        One
                    })
                }
                ElseIf ((T_0 == 0x02))
                {
                    Return (Package (0x02)
                    {
                        Zero, 
                        0x02
                    })
                }
                ElseIf ((T_0 == 0x03))
                {
                    Return (Package (0x02)
                    {
                        Zero, 
                        0x03
                    })
                }
                ElseIf ((T_0 == 0x04))
                {
                    Return (Package (0x02)
                    {
                        Zero, 
                        0x04
                    })
                }
                ElseIf ((T_0 == 0x05))
                {
                    Return (Package (0x02)
                    {
                        Zero, 
                        0x05
                    })
                }
                ElseIf ((T_0 == 0x06))
                {
                    Return (Package (0x02)
                    {
                        Zero, 
                        0x06
                    })
                }
                ElseIf ((T_0 == 0x07))
                {
                    Return (Package (0x02)
                    {
                        Zero, 
                        0x07
                    })
                }
                ElseIf ((T_0 == 0x08))
                {
                    Return (Package (0x02)
                    {
                        Zero, 
                        0x08
                    })
                }
                ElseIf ((T_0 == 0x09))
                {
                    Return (Package (0x02)
                    {
                        Zero, 
                        0x09
                    })
                }
                ElseIf ((T_0 == 0x0A))
                {
                    Return (Package (0x02)
                    {
                        Zero, 
                        0x0A
                    })
                }
                ElseIf ((T_0 == 0x0B))
                {
                    Return (Package (0x02)
                    {
                        Zero, 
                        0x0B
                    })
                }
                ElseIf ((T_0 == 0x0C))
                {
                    Return (Package (0x02)
                    {
                        Zero, 
                        0x0C
                    })
                }
                ElseIf ((T_0 == 0x0D))
                {
                    Return (Package (0x02)
                    {
                        Zero, 
                        0x0D
                    })
                }
                ElseIf ((T_0 == 0x0E))
                {
                    Return (Package (0x02)
                    {
                        Zero, 
                        0x0E
                    })
                }

                Return (Package (0x02)
                {
                    One, 
                    Zero
                })
            }

            Method (PPR3, 2, NotSerialized)
            {
                If ((Arg1 == Zero))
                {
                    Name (T_0, Zero)
                    T_0 = ToInteger (Arg0)
                    If ((T_0 == Zero))
                    {
                        Return (Package (0x03)
                        {
                            Zero, 
                            Zero, 
                            Zero
                        })
                    }
                    ElseIf ((T_0 == One))
                    {
                        Return (Package (0x03)
                        {
                            Zero, 
                            One, 
                            Zero
                        })
                    }
                    ElseIf ((T_0 == 0x02))
                    {
                        Return (Package (0x03)
                        {
                            Zero, 
                            0x02, 
                            Zero
                        })
                    }
                    ElseIf ((T_0 == 0x03))
                    {
                        Return (Package (0x03)
                        {
                            Zero, 
                            0x03, 
                            Zero
                        })
                    }
                    ElseIf ((T_0 == 0x04))
                    {
                        Return (Package (0x03)
                        {
                            Zero, 
                            0x04, 
                            Zero
                        })
                    }
                    ElseIf ((T_0 == 0x05))
                    {
                        Return (Package (0x03)
                        {
                            Zero, 
                            0x05, 
                            Zero
                        })
                    }
                    ElseIf ((T_0 == 0x06))
                    {
                        Return (Package (0x03)
                        {
                            Zero, 
                            0x06, 
                            Zero
                        })
                    }
                    ElseIf ((T_0 == 0x07))
                    {
                        Return (Package (0x03)
                        {
                            Zero, 
                            0x07, 
                            Zero
                        })
                    }
                    ElseIf ((T_0 == 0x08))
                    {
                        Return (Package (0x03)
                        {
                            Zero, 
                            0x08, 
                            Zero
                        })
                    }
                    ElseIf ((T_0 == 0x09))
                    {
                        Return (Package (0x03)
                        {
                            Zero, 
                            0x09, 
                            Zero
                        })
                    }
                    ElseIf ((T_0 == 0x0A))
                    {
                        Return (Package (0x03)
                        {
                            Zero, 
                            0x0A, 
                            Zero
                        })
                    }
                    ElseIf ((T_0 == 0x0B))
                    {
                        Return (Package (0x03)
                        {
                            Zero, 
                            0x0B, 
                            Zero
                        })
                    }
                    ElseIf ((T_0 == 0x0C))
                    {
                        Return (Package (0x03)
                        {
                            Zero, 
                            0x0C, 
                            Zero
                        })
                    }
                    ElseIf ((T_0 == 0x0D))
                    {
                        Return (Package (0x03)
                        {
                            Zero, 
                            0x0D, 
                            Zero
                        })
                    }
                    ElseIf ((T_0 == 0x0E))
                    {
                        Return (Package (0x03)
                        {
                            Zero, 
                            0x0E, 
                            Zero
                        })
                    }

                    Return (Package (0x03)
                    {
                        One, 
                        Zero, 
                        Zero
                    })
                }
                Else
                {
                    Name (T_1, Zero)
                    T_1 = ToInteger (Arg0)
                    If ((T_1 == Zero))
                    {
                        Return (Package (0x03)
                        {
                            Zero, 
                            Zero, 
                            0xFFFFFFF0
                        })
                    }
                    ElseIf ((T_1 == One))
                    {
                        Return (Package (0x03)
                        {
                            Zero, 
                            One, 
                            0xFFFFFFF0
                        })
                    }
                    ElseIf ((T_1 == 0x02))
                    {
                        Return (Package (0x03)
                        {
                            Zero, 
                            0x02, 
                            0xFFFFFFF0
                        })
                    }
                    ElseIf ((T_1 == 0x03))
                    {
                        Return (Package (0x03)
                        {
                            Zero, 
                            0x03, 
                            0xFFFFFFF0
                        })
                    }
                    ElseIf ((T_1 == 0x04))
                    {
                        Return (Package (0x03)
                        {
                            Zero, 
                            0x04, 
                            0xFFFFFFF0
                        })
                    }
                    ElseIf ((T_1 == 0x05))
                    {
                        Return (Package (0x03)
                        {
                            Zero, 
                            0x05, 
                            0xFFFFFFF0
                        })
                    }
                    ElseIf ((T_1 == 0x06))
                    {
                        Return (Package (0x03)
                        {
                            Zero, 
                            0x06, 
                            0xFFFFFFF0
                        })
                    }
                    ElseIf ((T_1 == 0x07))
                    {
                        Return (Package (0x03)
                        {
                            Zero, 
                            0x07, 
                            0xFFFFFFF0
                        })
                    }
                    ElseIf ((T_1 == 0x08))
                    {
                        Return (Package (0x03)
                        {
                            Zero, 
                            0x08, 
                            0xFFFFFFF0
                        })
                    }
                    ElseIf ((T_1 == 0x09))
                    {
                        Return (Package (0x03)
                        {
                            Zero, 
                            0x09, 
                            0xFFFFFFF0
                        })
                    }
                    ElseIf ((T_1 == 0x0A))
                    {
                        Return (Package (0x03)
                        {
                            Zero, 
                            0x0A, 
                            0xFFFFFFF0
                        })
                    }
                    ElseIf ((T_1 == 0x0B))
                    {
                        Return (Package (0x03)
                        {
                            Zero, 
                            0x0B, 
                            0xFFFFFFF0
                        })
                    }
                    ElseIf ((T_1 == 0x0C))
                    {
                        Return (Package (0x03)
                        {
                            Zero, 
                            0x0C, 
                            0xFFFFFFF0
                        })
                    }
                    ElseIf ((T_1 == 0x0D))
                    {
                        Return (Package (0x03)
                        {
                            Zero, 
                            0x0D, 
                            0xFFFFFFF0
                        })
                    }
                    ElseIf ((T_1 == 0x0E))
                    {
                        Return (Package (0x03)
                        {
                            Zero, 
                            0x0E, 
                            0xFFFFFFF0
                        })
                    }

                    Return (Package (0x03)
                    {
                        One, 
                        Zero, 
                        Zero
                    })
                }
            }
        }

        Device (TCM)
        {
            Name (_HID, EisaId ("ZIC0101"))  // _HID: Hardware ID
            Method (_STA, 0, NotSerialized)  // _STA: Status
            {
                If (!GTPM ())
                {
                    Return (Zero)
                }

                If (GCTP ())
                {
                    Return (0x0F)
                }
                Else
                {
                    Return (Zero)
                }
            }

            Method (_CRS, 0, NotSerialized)  // _CRS: Current Resource Settings
            {
                If ((GTPM () && GCTP ()))
                {
                    Return (ResourceTemplate ()
                    {
                        Memory32Fixed (ReadWrite,
                            0xFED40000,         // Address Base
                            0x00005000,         // Address Length
                            )
                    })
                }
                Else
                {
                    Return (Buffer (One)
                    {
                         0x00                                             // .
                    })
                }
            }
        }
    }

    OperationRegion (PMRS, SystemIO, 0x0430, One)
    Field (PMRS, ByteAcc, NoLock, Preserve)
    {
            ,   4, 
        SLPE,   1
    }

    Debug = "hdef0-add_dsdt/HDEF-1.txt_v2.0 dsdt edits, github.com/toleda"
}

