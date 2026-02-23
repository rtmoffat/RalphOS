with System;
with System.Machine_Code;
with System.Storage_Elements;

procedure Bootloader is
   pragma Export (C, Bootloader, "_start");

   use System;
   use System.Machine_Code;
   use System.Storage_Elements;

   type Vol_U8 is mod 2 ** 8;
   pragma Volatile (Vol_U8);
   package Vol_U8_Conv is new Address_To_Access_Conversions (Vol_U8);

   UART0_BASE    : constant Integer_Address := 16#10000000#;
   UART0_THR     : constant Integer_Address := UART0_BASE + 16#00#;
   UART0_LSR     : constant Integer_Address := UART0_BASE + 16#05#;
   UART_LSR_THRE : constant Vol_U8 := 16#20#;

   Bss_Start : Address;
   pragma Import (C, Bss_Start, "__bss_start");
   Bss_End : Address;
   pragma Import (C, Bss_End, "__bss_end");
   Stack_Top : Address;
   pragma Import (C, Stack_Top, "__stack_top");

   procedure Kernel_Main;
   pragma Import (C, Kernel_Main, "kernel_main");

   package Byte_Conv is new Address_To_Access_Conversions (Storage_Element);

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
begin
   Asm ("csrw mie, zero", Volatile => True);
   Asm ("csrw mstatus, zero", Volatile => True);
   Asm ("la gp, __global_pointer$", Volatile => True);
   Asm ("la sp, __stack_top", Volatile => True);

   -- Clear .bss so the Ada kernel starts with zeroed globals.
   declare
      Start_Addr : Integer_Address := To_Integer (Bss_Start);
      End_Addr   : constant Integer_Address := To_Integer (Bss_End);
      Ptr        : Byte_Conv.Object_Pointer;
   begin
      while Start_Addr < End_Addr loop
         Ptr := Byte_Conv.To_Pointer (To_Address (Start_Addr));
         Ptr.all := 0;
         Start_Addr := Start_Addr + 1;
      end loop;
   end;

   Uart_Puts ("Bootloader: starting" & ASCII.LF);

   Kernel_Main;

   loop
      null;
   end loop;
end Bootloader;
