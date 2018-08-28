generic
   type Block_Head_Type is (<>);
   type Block_Head_Access is access Block_Head;
   with function  Next(Block_Head: in Block_Head_Type) return Block_Head_Access;
   with procedure Set_Next(Block_Head: in out Block_Head_Type, Next: in Block_Head_Access);
package Lock_Free.List is
   
   type List_Type is private;
   
   procedure Insert
     (List: in out List_Type;
      Block_Head: in Block_Head_Access
      );
   
   procedure Remove
     (List: in out List_Type;
      Block_Head: out Block_Head_Access
     );
   
private
   type List_Type is 
      record
	 First Block_Head_Access := null;
      end record;
   
   
end Lock_Free.List;
