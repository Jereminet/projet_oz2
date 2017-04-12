functor
import
   Player042BasicAI
   Player043BasicAI
export
   playerGenerator:PlayerGenerator
define
   PlayerGenerator
in
   fun{PlayerGenerator Kind Color ID}
	  case Kind
	  of player042basicai then {Player042BasicAI.portPlayer Color ID}
	  []player043basicai then {Player042BasicAI.portPlayer Color ID}
	  end
   end
end