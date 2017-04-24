functor
import
   Player042BasicAI
   Player000Real
export
   playerGenerator:PlayerGenerator
define
   PlayerGenerator
in
   fun{PlayerGenerator Kind Color ID}
	  case Kind
	  of player042basicai then {Player000Real.portPlayer Color ID}
	  []player043basicai then {Player042BasicAI.portPlayer Color ID}
	  []player044basicai then {Player042BasicAI.portPlayer Color ID}
	  []player045basicai then {Player042BasicAI.portPlayer Color ID}
	  end
   end
end