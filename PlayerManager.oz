functor
import
   Player042BasicAI
   Player043BasicAI
   Player000Real
export
   playerGenerator:PlayerGenerator
define
   PlayerGenerator
in
   fun{PlayerGenerator Kind Color ID}
	  case Kind
	  of player1 then {Player043BasicAI.portPlayer Color ID}
	  []player2 then {Player043BasicAI.portPlayer Color ID}
	  []player3 then {Player043BasicAI.portPlayer Color ID}
	  []player4 then {Player043BasicAI.portPlayer Color ID}
	  end
   end
end