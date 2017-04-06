functor
import
   Input
   OS
export
   portPlayer:StartPlayer
define
   StartPlayer
   TreatStream
   Nth
in
   fun{StartPlayer Color ID}
	  Stream
	  Port
   in
	  {NewPort Stream Port}
	  thread
		 {TreatStream Stream ID}
	  end
	  Port
   end

   fun{Nth L N}
   	  if N == 1 then L.1
   	  else {Nth L.2 N - 1}
   	  end
   end
   
   proc{TreatStream Stream ID} % has as many parameters as you want
	  proc{FindPos X Y}
		 A B
	  in
		 A = ({Number.abs {OS.rand}} mod Input.nRow) + 1
		 B = ({Number.abs {OS.rand}} mod Input.nColumn) + 1
		 if {Nth {Nth Input.map A} B} == 0 then X = A Y = B
		 else {FindPos X Y} end
	  end
	  X Y
   in
	  case Stream of nil then skip
	  []initPosition(Id Position)|T then Id = ID
		 {FindPos X Y}
		 Position.x = X
		 Position.y = Y
		 {TreatStream T ID}
	  end
   end
end