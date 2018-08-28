package Lock_Free.List is
   
   procedure Insert
     (List: in out List_Type;
      Block_Head: in Block_Head_Access
     )
   is
   begin
      loop
	 Set_Next(Block_Head.all, List.First);
	 exit when CAS(List.First'Access, Next(Block_Head.all), Block_Head);
      end loop;
   end Insert;
   
   procedure Remove
     (List: in out List_Type;
      Block_Head: out Block_Head_Access
     )
   is
      New_First: Block_Head_Access;
   begin
      loop
	 Block_Head := List.First;
	 New_First := Next(Block_Head.all); -- NB Next(null) = null
	 exit when CAS(List.First'Access, Block_Head, New_First);
      end loop;
   end Remove;
   
   
end Lock_Free.List;
