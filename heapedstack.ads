package GreenAda.HeapedStack is
   
   type Stack_Type is limited private;
   
   type Size_Type is ;
   
   procedure Push
     (Stack: in out StackType;
      Size: in Size_Type;
      Address: out Address_Type
     );
   
   procedure Pop
     (Stack: in out Stack_Type;
      Address: out Address_Type
     );
   
private
   
   type Block_Head is 
      record
         Next : Short_Ptr;
         Prev : Short_Ptr;
         Size : Block_Size_Type;
      end record;
   
   -- in bytes
   Control_Block_Size: constant :=
     4   -- next block
     + 4 -- prev block
     + 2; -- block size
   
   type Size_Array_Index;
   
   Sizes  :=
     (40, 48, 56, 64, ..., 128, -- step 8 | 12
      128 + 16, ..., 256, -- step 16 | 8
      256 + 32, ..., 512, -- step 32 | 8
      512 + 64, ..., 1024, -- step 64 | 8
      1024 + 128, ..., 2048, -- step 128 | 8 
      2048 + 256, ..., 4096, -- step 256 |8
      --- 8K / 512, 16K / 1K, 32K / 2K, 64K (max) / 4K
     ); -- 84 different values, max wasted space < 4K * 84 = 336K
   
   type Size_Array_Type is array Size_Array_Index of Block_Head;
   
   type Stack is
      record
         Local_Ptr : Pointer;
         Global_Ptr: Pointer;
      end record;
   
end GreenAda.HeapedStack;

