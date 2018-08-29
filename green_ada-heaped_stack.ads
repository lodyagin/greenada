package Green_Ada.Heaped_Stack is
   
   package Sizes is
      
      -- We use 84 predefined sizes, 1..84. 0 means "not definet"
      type Index_Type is new Integer range 0..84;
      
      -- We assume a frame size is limited by 64K * 8
      type Size_Type is new Integer range 0..65536 * 8;
      
      -- 0 means 8 bytes, 65535 means 64K * 8 bytes
      -- NB: not possible to code 0 size.
      type Two_Bytes_Size_Type is new Integer range 0..65535;
      
      -- Size to index
      function Index(Size: in Size_Type) return Index_Type;
	
      -- Index to size
      function Size(Index: in Index_Type) return Size_Type;
      
      function Two_Bytes_Size(Size: in Size_Type) return Two_Bytes_Size_Type := (Size / 8 - 1);
	
   end Sizes;
   
   -- Each frame of a segmented stack has a header
   type Stack_Segment_Offset is Integer range 0 .. 2**32 - 1;
   
   type Stack_Segment_Type is array Frame_Head_Offset of Word64;
   
   type Stack_Segment_Access is access Stack_Segment_Type;

type Frame_Head_Type is 
      record
         Next : Stack_Segment_Offset;
         Prev : Stack_Segment_Offset;
         Size : Sizes.Two_Bytes_Size_Type;
      end record;
   
   type Size_To_Blocks_Type is array Index_Type of Frame_Head_Access;
   
   type Stack_Type is
      record
	 Stack_Segment: Stack_Segment_Access := null;
         Local_Pointer : Block_Head_Access := null;
         Global_Pointer: Block_Head_Access := null;
	 Free_Blocks: Size_To_Blocks_Type := (others => null);
      end record;
   
   -- FIXME: guarantee the size of Stack_Type record = 10 bytes
   
   -- Gets a new frame. 
   -- The frame address will be places into Stack.Local_Pointer
   procedure Reserve_Frame(Stack: in out Stack_Type; Size: in Sizes.Size_Type);
   
   -- Leaves a frame.
   -- Stack.Local_Pointer will contain a previous frame address or null.
   procedure Retract_Frame(Stack: in out Stack_Type);
   
private
   
   -- in bytes
   Control_Block_Size: constant :=
     4   -- next block
     + 4 -- prev block
     + 2; -- block size
   
   type Size_Array_Index;
   
   
   type Size_Array_Type is array Size_Array_Index of Block_Head;
   type Size_Array_Access is access Size_Array_Type;
   
end GreenAda.HeapedStack;

