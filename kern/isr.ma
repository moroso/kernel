{/*SCRATCH0*/ r20 <- r0; r0 <- long; long 0xdeadbeef /* hardcoded addr */; nop;}
{/*SCRATCH1*/ r21 <- r1; r0 <- *l(r0); nop; nop;}
{r1 <- EPC; p0 -> r0 <- r0 | 1; nop; nop;} // kesp0 is aligned, lol
{p0 <- r1 & 1; nop; nop; nop;}
//stack grows up
{p0 -> *l(r30 + 124) <- r30; !p0 -> *l(r0 + 128) <- r30; p0 -> r30 <- r30 + 128; !p0 -> r30 <- r0 + 128;}
{r0 <- /*SCRATCH0*/r20; p0 <- r0 & 1; r30 <- r30 & long; long 0xFFFFFFFE;}
{r0 <- /*SCRATCH1*/r21; *l(r30 - 124) <- r0; nop; nop;} //r0 now has the original r1 value
{r0 <- EC0; *l(r30 - 120) <- r0; nop; nop;}
{r2 <- EC1; *l(r30 - 116) <- r2; nop; nop;}
{r3 <- EC2; *l(r30 - 112) <- r3; nop; nop;}
{r4 <- EC3; *l(r30 - 108) <- r4; nop; nop;}
{r5 <- EA0; *l(r30 - 104) <- r5; nop; nop;}
{r6 <- EA1; *l(r30 - 100) <- r6; nop; nop;}
{*l(r30 - 96) <- r7; *l(r30 - 92) <- r8; r7 <- 3; nop;}
//once coprocessor regs are in GPRs we can turn interrupts on.
{PFLAGS <- r7; *l(r30 - 88) <- r9; nop; nop;}
{*l(r30 - 84) <- r10; *l(r30 - 80) <- r11; nop; nop;}
{*l(r30 - 76) <- r12; *l(r30 - 72) <- r13; nop; nop;}
{*l(r30 - 68) <- r14; *l(r30 - 64) <- r15; nop; nop;}
{*l(r30 - 60) <- r16; *l(r30 - 56) <- r17; nop; nop;}
{*l(r30 - 52) <- r18; *l(r30 - 48) <- r19; nop; nop;}
{*l(r30 - 44) <- r20; *l(r30 - 40) <- r21; r7 <- 0; nop;}
{*l(r30 - 36) <- r22; *l(r30 - 32) <- r23; p0 -> r7 <- r7 | 0b001; nop;}
{*l(r30 - 28) <- r24; *l(r30 - 24) <- r25; p1 -> r7 <- r7 | 0b010; nop;}
{*l(r30 - 20) <- r26; *l(r30 - 16) <- r27; p2 -> r7 <- r7 | 0b100; nop;}
{*l(r30 - 12) <- r28; *l(r30 - 8) <- r29; nop; nop;}
{*l(r30) <- r31; *l(r30 + 4) <- r7; r30 <- r30 + 8; nop;}
//Might have to do some other setup here to pass the coprocessor registers as arguments
{BL interrupt_routine; *l(r30) <- r1; nop; nop;} // save EPC

//coming back out
//Restore all GPRs but r30, r0, r1

{r0 <- *l(r30 - 4); r1 <- 2; nop; nop;}
//disable interrupts, restore predicate registers
{PFLAGS <- r1; p0 <- r0 & 0b001; p1 <- r0 & 0b010; p2 <- r0 & 0b100;}
{r0 <- *l(r30 - 132); r1 <- *l(r30); nop; nop;}
{EPC <- r1; r1 <- *l(r30 - 128); nop; nop;}
{ERET; r30 <- *l(r30 - 12); nop; nop;}


interrupt_routine:
