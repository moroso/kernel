// Kernel-specific compiler prelude

_start:
        // Set up the serial port
        { r1 <- long; long 0x80001000; r2 <- 0b100; }
        { *l(r1) <- r2; }

        { bl _INIT_GLOBALS; r30 <- long; long __STACK_START__; }
        { bl __main; }
        { r30 <- 0; }
        { break 0x1f; }

// TODO: this will fail on hardware. We should make print_int do the
// appropriate printf call or something.
print_int:
        { r1 <- r30; }
        { r30 <- 1; }
        { break 0x1f; }
        { b r31 + 1; r30 <- r1; }

print_char:
        { r1 <- PFLAGS; r2 <- 0b00100; }
        // Check if paging is enabled. The kernel maps peripherals to
        // a different address than their physical one.
        // See kern/consts.mb for the address.
        { p0 <- r1 & 2; p1 <- r0 == 10; }
        { !p0? r1 <- long; long 0x80001000; p0? r1 <- long; long 0x3fff1000; }
        { *l(r1 + 4) <- r2; *l(r1) <- r0; } // clear txc
  uart_write_loop:
          { r0 <- *b(r1 + 4); }
          { p0 <- r0 & 0b1; } // txc
        { !p0? b uart_write_loop; }
        { p1? b print_char; r0 <- 13; }
        { b r31 + 1; }

debug_break:
        { r1 <- r30; r30 <- 3; }
        { break 0x1f; }
        { b r31 + 1; r30 <- r1; }

// TODO: there's room for optimization here.
rt_memcpy: { p1 <- r2 == 0 }
           { p1? b r31 + 1; }
memcpy_loop:
           { r3 <- *b(r1); r2 <- r2 - 1; p0 <- r2 <=s 1; p1 <- r2 == 0; }
           { !p0? b memcpy_loop; !p1? *b(r0) <- r3; r0 <- r0 + 1;
             r1 <- r1 + 1; }
           { p0? b r31 + 1; }

rt_abort:
// TODO: better abort function.
        { b r31 + 1; }
