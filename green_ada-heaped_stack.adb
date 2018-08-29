package body Green_Ada.Heaped_Stack is
   
   package body Sizes is
      
      --  We use these predefined sizes. The idea is to have a limited
      --  set of sizes to keep memory fragmentation as little as
      --  possible.  The minimal frame size is 40 bytes. It is to use
      --  not more than 25% for control information (the size of
      --  Stack_Type is 10 bytes). On 128G+ RAM computer we can create
      --  10^12 of tasks with frames in range 40..128 bytes with
      --  maximal overhead 17G (size of Block_Header_Type + step(=8
      --  bytes) -1 ).  It is obvious that if we want to have 10^12
      --  tasks they should be optimized for stack usage. So, tasks
      --  which uses more than 128 bytes of stack are expected to be
      --  limited by 10^11 on the same architecture, that's why we use
      --  step=16 to specify possible predefined frame sizes in the
      --  range 128+..256. And so on. We think it is crazy to have
      --  more than 64K of stack per task - this limitation of course
      --  also serves the purpose of having the control block 
      --  as small as possible. That also means that for tasks with
      --  32K+ stack we use step of 4K (because we can't have many of
      --  them and wasting of 4105 bytes per each should not be a
      --  problem).
      
      Predefined_Frame_Sizes_Array is array Index_Type of Size_Type;
      
      Predefined_Frame_Sizes: constant Predefined_Frame_Sizes_Array :=
	(
	 -- no value
	 0,
	 
	 -- 32+8 .. 128
	 32+8,      32+2*8,     32+3*8,     32+4*8,  
	 32+5*8,    32+6*8,     32+7*8,     32+8*8,  
	 32+9*8,    32+10*8,    32+11*8,    32+12*8, 
	 
	 -- 128+16 .. 256
	 128+16,    128+2*16,  128+3*16,  128+4*16,  
	 128+5*16,  128+6*16,  128+7*16,  128+8*16,
	 
	 -- 256+32 .. 512
	 256+32,    256+2*32,  256+3*32,  256+4*32,  
	 256+5*32,  256+6*32,  256+7*32,  256+8*32,
	 
	 -- 512+64 .. 1K
	 512+64,    512+2*64,  512+3*64,  512+4*64,  
	 512+5*64,  512+6*64,  512+7*64,  512+8*64,
	 
	 -- 1K+128 .. 2K
	 1024+128,    1024+2*128,  1024+3*128,  1024+4*128,  
	 1024+5*128,  1024+6*128,  1024+7*128,  1024+8*128,
	 
	 -- 2K+256 .. 4K
	 2048+256,    2048+2*256,  2048+3*256,  2048+4*256,  
	 2048+5*256,  2048+6*256,  2048+7*256,  2048+8*256,
	 
	 -- 4K+512 .. 8K
	 4096+512,    4096+2*512,  4096+3*512,  4096+4*512,  
	 4096+5*512,  4096+6*512,  4096+7*512,  4096+8*512,
	 
	 -- 8K+1K .. 16K
	 8192+1024,    8192+2*1024,  8192+3*1024,  8192+4*1024,  
	 8192+5*1024,  8192+6*1024,  8192+7*1024,  8192+8*1024,
	 
	 -- 16K+2K .. 32K
	 16384+2048,    16384+2*2048,  16384+3*2048,  16384+4*2048,  
	 16384+5*2048,  16384+6*2048,  16384+7*2048,  16384+8*2048,
	 
	 -- 32K+4K .. 64K
	 32768+4096,    32768+2*4096,  32768+3*4096,  32768+4*4096,  
	 32768+5*4096,  32768+6*4096,  32768+7*4096,  32768+8*4096
      );
	 
      
      --  (40, 48, 56, 64, ..., 128, -- step 8 | 12
      --   128 + 16, ..., 256, -- step 16 | 8
      --   256 + 32, ..., 512, -- step 32 | 8
      --   512 + 64, ..., 1024, -- step 64 | 8
      --   1024 + 128, ..., 2048, -- step 128 | 8
      --   2048 + 256, ..., 4096, -- step 256 |8
      --   --- 8K / 512, 16K / 1K, 32K / 2K, 64K (max) / 4K
      --  ); -- 84 different values
      
      -- Size to index
      function Index(Size: in Size_Type) return Index_Type 
      is
	 Up_To_Power: Integer range 7..16;
	 Step_Size: Integer range 8..4096;
	 Step_Number: Integer range 0..15;
      begin
	 
	 Up_To_Power := Max(GSB(Max(Size - 1, 1)) + 1, 7);
	 Step_Size := 2 ** (Up_To_Power - 4);
	 Step_Number := (Up_To - Size) / Step_Size;
	 return Min((Up_To_Power - 6) * 16 + Step_Number - 4, 0);
      end Index;
	
      -- Index to size.
      -- This implementation is ready only for the purposes of testing/logging, 
      -- because array indexing should never be
      -- used during highly optimized program execution 
      -- (memory access is suboptimal on modern CPUs)
      function Size(Index: in Index_Type) return Size_Type 
      is
      begin
	 return Predefined_Frame_Sizes(Index);
      end Size;
   end Sizes;
   
   procedure Reserve_Frame
     (Stack: in out Stack_Type; 
      Size: in Sizes.Size_Type) 
   is
   begin
      -- if the next frame was allocated already
      if Stack.Local_Pointer.Next /= null
      then
	 -- and the size of it is enough (dynamic structs don't consume more)
	 if Size > Stack.Local_Pointer.Next.Size
         then -- it is not enough
	    -- put the next frame into the free frames list
	    Collect_Free_Block(Stack.Free_Blocks.all, Stack.Local_Pointer.Next);
	    
	    declare
	       Size_Index: constant Sizes.Index_Type := Sizes.Index(Size);
	    begin
	       -- we need a new frame
	       Stack.Local_Pointer.Next := Get_Free_Block(Stack.Free_Blocks, Size_Index);
	       if Stack.Local_Pointer.Next = null
	       then
		  -- there is no frame of this size, allocate a new one
		  Stack.Local_Pointer.Next 
		    := Allocate_New_Frame(Stack.Global_Pointer'Access, Size);
	       end if;
	    end;
	    -- connect the new frame
	    Stack.Local_Pointer.Next.Prev := Stack.Local_Pointer;
	    Stack.Local_Pointer.Next.Next := null;
         end if;
      end if;
      
      -- Assertion: Stack.Local_Pointer.Next points to the next frame with enough space
      --            and Next/Prev are valid
      
      -- move the stack pointer
      Stack.Local_Pointer := Stack.Local_Pointer.Next;
   end ReserveFrame;
   
   procedure RetractFrame (Stack: in out Stack_Type) is
   begin
      Stack.Local_Pointer := Stack.Local_Pointer.Prev;
   end RetractFrame;
   
   -- Makes the stack grow, allocates a new frame
   -- NB: only Size is filled (but no Prev/Next)
   function Allocate_New_Frame
     (Last_Block: access Block_Head_Access;
      Size: in Sizes.Size_Type)
   return Block_Head_Access 
   is
      Old_Last_Block: Block_Head_Access;
      New_Last_Block: Block_Head_Access;
   begin
      loop
	 Old_Last_Block := Last_Block.all;
	 New_Last_Block := Down(Old_Last_Block, Size);
	 -- TODO: when the corresponding option is active, checking of stack overflow
	 --       should be placed here
	 exit when CAS(Last_Block, Old_Last_Block, New_Last_Block);
      end loop;
      New_Last_Block.Size := Size;
      return New_Last_Block;
   end Allocate_New_Frame;
   
   procedure Collect_Free_Block
     (Free_Blocks: in out Free_Blocks_Array; 
      Block: Block_Head_Access)
   is
      Old_Block_List: Block_Head_Type;
      Size_Index: constant Sizes.Index_Type := Sizes.Index(Block.Size);
   begin
      loop
	 Old_Block_List := Free_Blocks(Size_Index);
	 exit when CAS(Free_Blocks(Size_Index)'Access, Old_Block_List, Block);
      end loop;
      Block.Next := Old_Block_List;
   end Collect_Free_Block;
   
   function Get_Free_Block
     (Free_Blocks: in out Free_Blocks_Array; 
      Size_Index: in Size_Index_Type)
   return Block_Head_Access 
   is
      Old_Block_List: Block_Head_Type;
      New_Block_List: Block_Head_Type;
   begin
      loop
	 Old_Block_List := Free_Blocks(Size_Index);
	 New_Block_List := Next(Old_Block_List);
	 exit when CAS(Free_Blocks(Size_Index)'Access, Old_Block_List, New_Block_List);
      end loop;
      return Old_Block_List;
   end Get_Free_Block;
   
end GreenAda.HeapedStack;

