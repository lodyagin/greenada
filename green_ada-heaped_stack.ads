package Green_Ada.Heaped_Stack is
   
   package Sizes is
      
      Word_Size : constant := 8;
      
      type Word_Type is mod 2 ** (8 * Word_Size);
      
      -- We use a limited number of predefined sizes. 0 means "not
      --  defined"
      type Index_Type is range 0..110;
      
      -- We assume a frame size is limited by 64K * 8
      type Size_Type is range 0..65536 * Word_Size;
      
      -- 0 means 8 bytes, 65535 means 64K * 8 bytes
      -- NB: not possible to code 0 size.
      type Two_Bytes_Size_Type is range 0..65535;
      
      -- Size to index
      function Index(Size: in Size_Type) return Index_Type;
	
      -- Index to size
      function Size(Index: in Index_Type) return Size_Type;
      
      -- Two_Bytes_Size to size
      function Size
        (Two_Bytes_Size: in Two_Bytes_Size_Type) 
        return Size_Type
        is ((Size_Type(Two_Bytes_Size) + 1) * Word_Size);
      
      function Two_Bytes_Size
        (Size: in Size_Type) 
        return Two_Bytes_Size_Type
        is (Two_Bytes_Size_Type(Size / Word_Size - 1));
	
   end Sizes;
   
   package Segment is
      -- Each frame of a segmented stack has a header
      type Offset_Type is range 0 .. 2**32 - 1;
      type Array_Type is array (Offset_Type) of Sizes.Word_Type;
      type Array_Access is access Array_Type;
   end Segment;
      
   package Frame is
      type Head_Type is 
         record
            Next : Segment.Offset_Type;
            Prev : Segment.Offset_Type;
            Two_Bytes_Size : Sizes.Two_Bytes_Size_Type;
         end record;
   
      -- Check that we don't waste space
      pragma Assert(Check => Head_Type'Size = 10 * 8, 
                    Message => "Head_Type is expected to be 10 bytes");
   
      type Head_Access is access Head_Type;
   
      function Size(Frame_Head: in Head_Type) return Sizes.Size_Type is 
        (Sizes.Size(Frame_Head.Two_Bytes_Size));
   end Frame;
      
   package Free_Blocks is
      type Array_Type is array (Sizes.Index_Type) of Frame.Head_Access;
      type Array_Access is access Array_Type;
   end Free_Blocks;
   
   type Stack_Type is
      record
	 Stack_Segment: Segment.Array_Access := null;
         Local_Pointer : Frame.Head_Access := null;
         Global_Pointer: Frame.Head_Access := null;
	 Free_Blocks_Array: Free_Blocks.Array_Access := null;
      end record;
   
   -- Gets a new frame. 
   --
   -- The frame address will be places into Stack.Local_Pointer
   procedure Reserve_Frame
     (Stack: in out Stack_Type; Size: in Sizes.Size_Type);
   
   -- Leaves a frame.
   --
   -- Stack.Local_Pointer will contain a previous frame
   --  address or null.
   procedure Retract_Frame(Stack: in out Stack_Type);
   
end Green_Ada.Heaped_Stack;

