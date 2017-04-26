functor
import
   Player007Random
   Player007Improved
   Player007Real
export
   playerGenerator:PlayerGenerator
define
   PlayerGenerator
in
   fun{PlayerGenerator Kind Color ID}
	  case Kind
	  of random then {Player007Random.portPlayer Color ID}
	  [] improved then {Player007Improved.portPlayer Color ID}
	  [] real then {Player007Real.portPlayer Color ID}
	  end
   end
end
