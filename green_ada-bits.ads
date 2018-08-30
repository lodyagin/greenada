--  The operations with bits

package Green_Ada.Bits is

   -- Calculates the number of highest bit in i starting from 1. Returns 0 if i
   -- = 0.
   function GSB1(I: Unsigned_32) return Signed_32
   is (if I /= 0 then I'Size - CLZ(I) else 0);
   
   -- Returns the number of leading 0-bits in x, starting at the most
   -- significant bit position. If x is 0, the result is undefined
   function CLZ(X: in Unsigned_32) return Signed_32;
   pragma Import(Intrinsic, CLZ, "__builtin_clz");
   
end Green_Ada.Bits;
