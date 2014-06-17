{MTC SCRATCH0 <- r0; r0 <- long; .long <hardcoded kesp0 memory addr>; nop;}
{MTC SCRATCH1 <- r1; LW r0 <- [r0]; nop; nop;}
{MFC r1 <- EPC; [p0] r0 <- r0 | #1; nop; nop;} // kesp0 is aligned, lol
{p0 <- r1 CMPBS #1; nop; nop; nop;}
//stack grows up
{[p0] SW [r30 + 124] <- r30; [!p0] SW [r0 + 128] <- r30; [p0] r30 <- r30 + 128; [!p0] r30 <- r0 + 128;}
{MFC r0 <- SCRATCH0; p0 <- r0 CMPBS #1; r30 <- r30 & long; .long 0xFFFFFFFE;}
{MFC r0 <- SCRATCH1; SW [r30 - 124] <- r0; nop; nop;} //r0 now has the original r1 value
{MFC r0 <- EC0; SW [r30 - 120] <- r0; nop; nop;}
{MFC r2 <- EC1; SW [r30 - 116] <- r2; nop; nop;}
{MFC r3 <- EC2; SW [r30 - 112] <- r3; nop; nop;}
{MFC r4 <- EC3; SW [r30 - 108] <- r4; nop; nop;}
{MFC r5 <- EA0; SW [r30 - 104] <- r5; nop; nop;}
{MFC r6 <- EA1; SW [r30 - 100] <- r6; nop; nop;}
{SW [r30 - 96] <- r7; SW [r30 - 92] <- r8; r7 <- #3; nop;}
//once coprocessor regs are in GPRs we can turn interrupts on.
{MTC PFLAGS <- r7; SW [r30 - 88] <- r9; nop; nop;}
{SW [r30 - 84] <- r10; SW [r30 - 80] <- r11; nop; nop;}
{SW [r30 - 76] <- r12; SW [r30 - 72] <- r13; nop; nop;}
{SW [r30 - 68] <- r14; SW [r30 - 64] <- r15; nop; nop;}
{SW [r30 - 60] <- r16; SW [r30 - 56] <- r17; nop; nop;}
{SW [r30 - 52] <- r18; SW [r30 - 48] <- r19; nop; nop;}
{SW [r30 - 44] <- r20; SW [r30 - 40] <- r21; r7 <- #0; nop;}
{SW [r30 - 36] <- r22; SW [r30 - 32] <- r23; [p0] r7 <- r7 | #1; nop;}
{SW [r30 - 28] <- r24; SW [r30 - 24] <- r25; [p1] r7 <- r7 | #2; nop;}
{SW [r30 - 20] <- r26; SW [r30 - 16] <- r27; [p2] r7 <- r7 | #4; nop;}
{SW [r30 - 12] <- r28; SW [r30 - 8] <- r29; nop; nop;}
{SW [r30] <- r31; SW [r30 + 4] <- r7; r30 <- r30 + 8; nop;}
//Might have to do some other setup here to pass the coprocessor registers as arguments
{BL <Mb interrupt routine>; SW [r30] <- r1; nop; nop;} // save EPC

//coming back out
//Restore all GPRs but r30, r0, r1

{r0 <- LW [r30 - 4]; r1 <- #2; nop; nop;}
//disable interrupts, restore predicate registers
{MTC PFLAGS <- r1; p0 <- r0 CMPBS #1; p1 <- r0 CMPBS #2; p2 <- r0 CMPBS <- #4;}
{r0 <- LW [r30 - 132]; r1 <- LW [r30]; nop; nop;}
{MTC EPC <- r1; LW r1 <- [r30 - 128]; nop; nop;}
{ERET; LW r30 <- [r30 - 12]; nop; nop;}
