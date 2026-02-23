-- Simple kernel for testing bootloader (Ada)
with System;
with System.Storage_Elements;

procedure Kernel_Main is
   use System;
   use System.Storage_Elements;

   type Vol_U8 is mod 2 ** 8;
   pragma Volatile (Vol_U8);
   type Vol_U32 is mod 2 ** 32;
   pragma Volatile (Vol_U32);
   type U64 is mod 2 ** 64;

   package Vol_U8_Conv is new Address_To_Access_Conversions (Vol_U8);
   package Vol_U32_Conv is new Address_To_Access_Conversions (Vol_U32);

   UART0_BASE  : constant Integer_Address := 16#10000000#;
   UART0_THR   : constant Integer_Address := UART0_BASE + 16#00#;
   UART0_LSR   : constant Integer_Address := UART0_BASE + 16#05#;
   UART_LSR_THRE : constant Vol_U8 := 16#20#;

   CLINT_MTIME_LOW  : constant Integer_Address := 16#0200BFF8#;
   CLINT_MTIME_HIGH : constant Integer_Address := 16#0200BFFC#;
   TIMEBASE_HZ      : constant U64 := 10_000_000;

   QEMU_TEST_BASE     : constant Integer_Address := 16#100000#;
   QEMU_TEST_POWEROFF : constant Vol_U32 := 16#5555#;

   function Read_U8 (Addr : Integer_Address) return Vol_U8 is
      Ptr : constant Vol_U8_Conv.Object_Pointer :=
        Vol_U8_Conv.To_Pointer (To_Address (Addr));
   begin
      return Ptr.all;
   end Read_U8;

   procedure Write_U8 (Addr : Integer_Address; Value : Vol_U8) is
      Ptr : constant Vol_U8_Conv.Object_Pointer :=
        Vol_U8_Conv.To_Pointer (To_Address (Addr));
   begin
      Ptr.all := Value;
   end Write_U8;

   function Read_U32 (Addr : Integer_Address) return Vol_U32 is
      Ptr : constant Vol_U32_Conv.Object_Pointer :=
        Vol_U32_Conv.To_Pointer (To_Address (Addr));
   begin
      return Ptr.all;
   end Read_U32;

   procedure Write_U32 (Addr : Integer_Address; Value : Vol_U32) is
      Ptr : constant Vol_U32_Conv.Object_Pointer :=
        Vol_U32_Conv.To_Pointer (To_Address (Addr));
   begin
      Ptr.all := Value;
   end Write_U32;

   procedure Uart_Putc (C : Character) is
      Lsr : Vol_U8;
   begin
      loop
         Lsr := Read_U8 (UART0_LSR);
         exit when (Lsr and UART_LSR_THRE) /= 0;
      end loop;

      Write_U8 (UART0_THR, Vol_U8 (Character'Pos (C)));
   end Uart_Putc;

   procedure Uart_Puts (S : String) is
   begin
      for I in S'Range loop
         if S (I) = ASCII.LF then
            Uart_Putc (ASCII.CR);
         end if;
         Uart_Putc (S (I));
      end loop;
   end Uart_Puts;

   function Read_Mtime return U64 is
      Hi1 : Vol_U32;
      Lo  : Vol_U32;
      Hi2 : Vol_U32;
   begin
      loop
         Hi1 := Read_U32 (CLINT_MTIME_HIGH);
         Lo  := Read_U32 (CLINT_MTIME_LOW);
         Hi2 := Read_U32 (CLINT_MTIME_HIGH);
         exit when Hi1 = Hi2;
      end loop;

      return U64 (Hi1) * 2 ** 32 + U64 (Lo);
   end Read_Mtime;

   procedure Delay_Seconds (Seconds : Vol_U32) is
      Start  : constant U64 := Read_Mtime;
      Target : constant U64 := Start + U64 (Seconds) * TIMEBASE_HZ;
   begin
      while Read_Mtime < Target loop
         null;
      end loop;
   end Delay_Seconds;

   procedure Poweroff is
   begin
      Write_U32 (QEMU_TEST_BASE, QEMU_TEST_POWEROFF);
      loop
         null;
      end loop;
   end Poweroff;

begin
   Uart_Puts ("RalphOS: hello from RV64!" & ASCII.LF);
   Delay_Seconds (10);
   Uart_Puts ("RalphOS: shutting down." & ASCII.LF);
   Poweroff;
end Kernel_Main;

pragma Export (C, Kernel_Main, "kernel_main");
