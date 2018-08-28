package body GreenAda.HeapedStack is
   
   procedure ReserveBlock
     (Stack: in out StackType;
      Size: in Number_Of_Words_Type;
      Address: out Address_Type
     ) 
   is
      Old_Local_Address: Address_Type := Stack.Local_Pointer;
      Old_Global_Address: Address_Type;
   begin
      
      -- Does it fit into the current block?
      
      -- if the next block exists 
      -- then
      --   if fits into the next block then Put_In_Next end if;
      -- else
      --   if is there a free block of the required size 
      --   then
      --     get the free block
      --   else
      --     allocate the new block
      --   end if
      --   put in the block
      -- end if
      
      
      if Next_Chunk_Pointer(Stack.Local_Pointer) /= null then
         
      
      loop
         Old_Global_Address := Stack.Global_Pointer;
         Stack.Local_Pointer := Stack.Global_Pointer - Size - 2;
         exit when CAS(Stack.Global_Pointer'Access, 
                       Old_Global_Address,
                       Stack.Local_Pointer);
      end loop;
      Prev_Chunk_Pointer(Stack.Local_Pointer).all 
        := Old_Local_Address; 
      -- connects this chunk with the previous chunk
      
      Next_Chunk_Pointer(Old_Local_Address).all 
        := Stack.Local_Pointer;
      -- connects the previous chunk with this chunk
      
      Address := Stack.Local_Pointer + 2;
   end ReserveBlock;
   
   procedure RetractBlock
     (Stack: in out Stack_Type;
      Address: out Address_Type
     ) 
   is
   begin
      -- return the block into the free blocks list
   end RetractBlock;
   
end GreenAda.HeapedStack;

