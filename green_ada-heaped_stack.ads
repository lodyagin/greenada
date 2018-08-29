package Green_Ada.Heaped_Stack is
   
   package Sizes is
      
      -- We use 84 predefined sizes, 1..84. 0 means "not definet"
      type Index_Type is Integer range 0..84;
      
      -- We assume a frame size is limited by 64K
      type Size_Type is Integer range 0..65536;
      
      -- Size to index
      function Index(Size: in Size_Type) return Index_Type;
	
      -- Index to size
      function Size(Index: in Index_Type) return Size_Type;
	
   end Sizes;
   
   type Frame_Head_Offset is Integer range 0 .. 2 ** 32 - 1;
   
   -- Each frame of a segmented stack has a header
   type Frame_Head_Type is 
      record
         Next : Frame_Head_Offset;
         Prev : Frame_Head_Offset;
         Size : Sizes.Size_Type;
      end record;
   
   type Size_To_Blocks_Type is array Index_Type of Frame_Head_Access;
   
   type Stack_Type is
      record
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

