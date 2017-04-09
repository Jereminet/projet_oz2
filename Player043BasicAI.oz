functor
import
   Input
   OS
   System
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
		 {TreatStream Stream ID Input.maxDamage _ _ 0 0 0 0 null}
	  end
	  Port
   end

   fun{Nth L N}
   	  if N == 1 then L.1
   	  else {Nth L.2 N - 1}
   	  end
   end
   
   proc{TreatStream Stream ID Life CurPos CurDirect AccMissile AccMine AccSonar AccDrone PosMine} % has as many parameters as you want
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
	  []initPosition(Id Position)|T then
		 Id = ID
		 {FindPos X Y}
		 Position.x = X
		 Position.y = Y
		 {TreatStream T ID Life Position surface AccMissile AccMine AccSonar AccDrone PosMine}
	  []isSurface(Id Answer)|T then
		 Id = ID
		 Answer = CurDirect == surface 
		 {TreatStream T ID Life CurPos east AccMissile AccMine AccSonar AccDrone PosMine} % peut etre east/west/...
	  []move(Id Position Direction)|T then
		 Id = ID
		 if CurPos.x == 1 then Position = CurPos Direction = CurDirect
		 else Position.x = CurPos.x - 1
			Position.y = CurPos.y
			Direction = north
		 end
		 {TreatStream T ID Life Position Direction AccMissile AccMine AccSonar AccDrone PosMine}
	  []dive|T then
		 {TreatStream T ID Life CurPos north AccMissile AccMine AccSonar AccDrone PosMine}
	  []saySurface(Id)|T then
		 {TreatStream T ID Life CurPos CurDirect AccMissile AccMine AccSonar AccDrone PosMine}
	  []sayMove(Id Direction)|T then
		 {TreatStream T ID Life CurPos CurDirect AccMissile AccMine AccSonar AccDrone PosMine}
	  []sayCharge(Id KindItem)|T then
		 {TreatStream T ID Life CurPos CurDirect AccMissile AccMine AccSonar AccDrone PosMine}
	  []chargeItem(Id KindItem)|T then
		 Id = ID
		 KindItem = null
		 {TreatStream T ID Life CurPos CurDirect AccMissile AccMine AccSonar AccDrone PosMine} 
	  []fireItem(Id KindFire)|T then
		 Id = ID
		 KindFire = null
		 {TreatStream T ID Life CurPos CurDirect AccMissile AccMine AccSonar AccDrone PosMine}
	  []fireMine(Id Mine)|T then
		 Id = ID
		 Mine = PosMine
		 {TreatStream T ID Life CurPos CurDirect AccMissile AccMine AccSonar AccDrone null}
	  []sayMinePlaced(Id)|T then
		 {TreatStream T ID Life CurPos CurDirect AccMissile AccMine AccSonar AccDrone PosMine}
	  []sayMissileExplode(Id Position Message)|T then
		 {TreatStream T ID Life CurPos CurDirect AccMissile AccMine AccSonar AccDrone PosMine}
	  []sayMineExplode(Id Position Message)|T then
		 {TreatStream T ID Life CurPos CurDirect AccMissile AccMine AccSonar AccDrone PosMine}
	  []sayPassingDrone(Drone Id Message)|T then
		 {TreatStream T ID Life CurPos CurDirect AccMissile AccMine AccSonar AccDrone PosMine}
	  []sayAnswerDrone(Drone Id Answer)|T then
		 {TreatStream T ID Life CurPos CurDirect AccMissile AccMine AccSonar AccDrone PosMine}
	  []sayPassingDrone(Id Answer)|T then
		 {TreatStream T ID Life CurPos CurDirect AccMissile AccMine AccSonar AccDrone PosMine}
	  []sayAnswerSonar(Id Answer)|T then
		 {TreatStream T ID Life CurPos CurDirect AccMissile AccMine AccSonar AccDrone PosMine}
	  []sayDeath(Id)|T then
		 {TreatStream T ID Life CurPos CurDirect AccMissile AccMine AccSonar AccDrone PosMine}
	  []sayDamageTaken(Id Damage LifeLeft)|T then
		 {TreatStream T ID Life CurPos CurDirect AccMissile AccMine AccSonar AccDrone PosMine}
	  end
   end
end