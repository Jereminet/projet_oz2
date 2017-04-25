functor
import
   Input
   OS
   System
   Tk at 'x-oz://system/Tk.ozf'
export
   portPlayer:StartPlayer
define
   StartPlayer
   TreatStream

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

   %Update un State avec une liste de tuple contenant les valeurs qui ont changees
   % state(a:1 b:2) + [b#3] = state(a:1 b:3)
   Time = 10000

   fun {Nth L A B}
      fun {NthRow L A}
		 if L == nil then 1
		 elseif A == 1 then {NthColumn L.1 B}
		 else {NthRow L.2 A - 1}
		 end
      end

      fun{NthColumn L B}
		 if L == nil then 1
		 elseif B == 1 then L.1
		 else {NthColumn L.2 B - 1}
		 end
      end
   in
      {NthRow L A}
   end

   fun{InitPosition State ID Position}
      proc{FindPos X Y}
		 A B
      in
		 A = ({Abs {OS.rand}} mod Input.nRow) + 1
		 B = ({Abs {OS.rand}} mod Input.nColumn) + 1
		 if {Nth Input.map A B} == 0 then X = A Y = B
		 else {FindPos X Y} end
      end
      X Y W L1 B Unit
   in
      ID = State.id
      {FindPos X Y}
      Position.x = X
      Position.y = Y
	 
	  W = {New Tk.toplevel tkInit(title:'Welcome')}
	  L1 = {New Tk.message tkInit(parent:W
								  text:'Welcome on board captain. Your position on the map is '#X#','#Y#'.\n I recommand you to Keep track of your moves and items on a paper. You can find a map of the ocean in the Input file. This will certainly help you in your fight. You can recuit some crews to help you. Your goal is to destroy all submarines in the ocean without dying. Good luck !'
								 justify:left)}

	  B = {New Tk.button tkInit(parent:W
								text:'OK'
								action:proc{$}
										  {W tkClose}
										  Unit = unit
									   end)}

	  {Tk.send pack(L1 B fill:x padx:4 pady:4)}

	  {Wait Unit}
      {AdjoinList State [curPos#Position id#ID map#{ModMap State.map Position}]}
   end

   fun{ModMap Map Pos}
      fun{ModColumn Map AccY}
		 if AccY == 1 then 1|Map.2
		 else Map.1|{ModColumn Map.2 AccY - 1}
		 end
      end
      fun{ModRow Map AccX AccY}
		 if AccX == 1 then {ModColumn Map.1 AccY}|Map.2
		 else Map.1|{ModRow Map.2 AccX - 1 AccY}
		 end
      end
   in
      {ModRow Map Pos.x Pos.y}
   end
   
   fun{Move State ID Position Direction}
	  proc{ChoseMove}
		 Direct Pos L1 W BNorth BSouth BWest BEast BSurface
	  in
		 W = {New Tk.toplevel tkInit(title:'Moving')}
		 L1 = {New Tk.label tkInit(parent:W
								   text:'Chose your direction')}
		 BNorth = {New Tk.button tkInit(parent:W
										text:'North'
										action:proc{$}
												  Direct = north
												  Pos = pt(x:State.curPos.x - 1 y:State.curPos.y)
											   end)}
		 BSouth = {New Tk.button tkInit(parent:W
										text:'South'
										action:proc{$}
												  Direct = south
												  Pos = pt(x:State.curPos.x + 1 y:State.curPos.y)
											   end)}
		 BWest = {New Tk.button tkInit(parent:W
									   text:'West'
									   action:proc{$}
												 Direct = west
												 Pos = pt(x:State.curPos.x y:State.curPos.y - 1)
											  end)}
		 BEast = {New Tk.button tkInit(parent:W
									   text:'East'
									   action:proc{$}
												 Direct = east
												 Pos = pt(x:State.curPos.x y:State.curPos.y + 1)
											  end)}
		 BSurface = {New Tk.button tkInit(parent:W
										  text:'Surface'
										  action:proc{$}
													Direct = surface
													Pos = pt(x:State.curPos.x y:State.curPos.y)
												 end)}
	  
		 {Tk.send pack(L1 BNorth BSouth BWest BEast BSurface fill:x padx:4 pady:4)}

		 if {Nth State.map Pos.x Pos.y} == 0 orelse Direct == surface then
			{W tkClose}
			Position = Pos
			Direction = Direct
		 else
			{W tkClose}
			{ChoseMove}
		 end
	  end
   in
	  if State.life =< 0 then
		 ID = null
	  else
		 {ChoseMove}
		 ID = State.id
		 if Direction == surface then
			{AdjoinList State [curPos#Position curDir#Direction map#Input.map]}
		 else
			{AdjoinList State [curPos#Position curDir#Direction map#{ModMap State.map Position}]}
		 end
	  end
   end
   
   fun{Dive State}
      {AdjoinList State [curDir#north map#{ModMap State.map State.curPos}]}
   end

   fun{ChargeItem State ID KindItem}
	  W L1 BMissile BMine BSonar BDrone NewState
   in
      ID = State.id
	  W = {New Tk.toplevel tkInit(title:'Charging item')}
	  L1 = {New Tk.label tkInit(parent:W
								text:'Chose the item you want to charge')}
	  BMissile = {New Tk.button tkInit(parent:W
									   text:'Missile'
									   action:proc{$}
												 if State.accMissile + 1 == Input.missile then KindItem = missile
												 else KindItem = null
												 end
												 NewState = {AdjoinList State [accMissile#State.accMissile + 1]}
											  end)}
	  
	  BMine = {New Tk.button tkInit(parent:W
									   text:'Mine'
									   action:proc{$}
												 if State.accMine + 1 == Input.mine then KindItem = mine
												 else KindItem = null
												 end
												 NewState = {AdjoinList State [accMine#State.accMine + 1]}
											  end)}

	  BSonar = {New Tk.button tkInit(parent:W
									   text:'Sonar'
									   action:proc{$}
												 if State.accSonar + 1 == Input.sonar then KindItem = sonar
												 else KindItem = null
												 end
												 NewState = {AdjoinList State [accSonar#State.accSonar + 1]}
											  end)}

	  BDrone = {New Tk.button tkInit(parent:W
									   text:'Drone'
									   action:proc{$}
												 if State.accDrone + 1 == Input.drone then KindItem = drone
												 else KindItem = null
												 end
												 NewState = {AdjoinList State [accDrone#State.accDrone + 1]}
											  end)}

	  {Tk.send pack(L1 BMissile BMine BSonar BDrone fill:x padx:4 pady:4)}

	  {Wait NewState}
	  {W tkClose}
	  NewState
   end

   fun{FireItem State ?ID ?KindFire}
	  fun{CheckDist X Y Kind}
		 case Kind of missile then
			{Abs State.curPos.x - X} + {Abs State.curPos.y - Y} =< Input.maxDistanceMissile andthen {Abs State.curPos.x - X} + {Abs State.curPos.y - Y} >= Input.minDistanceMissile
		 []mine then
			{Abs State.curPos.x - X} + {Abs State.curPos.y - Y} =< Input.maxDistanceMine andthen {Abs State.curPos.x - X} + {Abs State.curPos.y - Y} >= Input.minDistanceMine
		 end
	  end
	  fun{PosFiring Kind}
		 WPos Ex Ey L1 B X Y
	  in
		 {W tkClose}
		 WPos = {New Tk.toplevel tkInit(title:'Position')}
		 Ex = {New Tk.entry tkInit(parent:WPos)}
		 Ey = {New Tk.entry tkInit(parent:WPos)}
		 if Kind == drone then
			L1 = {New Tk.label tkInit(parent:WPos
									  text:'Where do you want to lunch the drone ? (First enter row or column then the number)')}
			B = {New Tk.button tkInit(parent:WPos
									  text:'OK'
									  action:proc{$}
												X = {String.toAtom {Ex tkReturn(get $)}}
												Y = {String.toInt {Ey tkReturn(get $)}}
											 end)}
			{Tk.send pack(L1 Ex Ey B fill:x padx:4 pady:4)}
			if (X == row andthen Y > Input.nRow) orelse (X == column andthen Y > Input.nColumn) orelse Y < 1 then
			   {WPos tkClose}
			   {PosFiring Kind}
			else
			   {WPos tkClose}
			   drone(X Y)
			end
		 else
			L1 = {New Tk.label tkInit(parent:WPos
									  text:'Where do you want to lunch the missile/mine ? (First enter the row then the column)')}
			B = {New Tk.button tkInit(parent:WPos
									  text:'OK'
									  action:proc{$}
												X = {String.toInt {Ex tkReturn(get $)}}
												Y = {String.toInt {Ey tkReturn(get $)}}
											 end)}
			
			{Tk.send pack(L1 Ex Ey B fill:x padx:4 pady:4)}

			if {Nth Input.map X Y} == 0 andthen {CheckDist X Y Kind} then
			   {WPos tkClose}
			   pt(x:X y:Y)
			else
			   {WPos tkClose}
			   {PosFiring Kind}
			end
		 end
	  end
	  W L1 BMissile BMine BSonar BDrone BNull NewState
   in
	  W = {New Tk.toplevel tkInit(title:'Firing')}
	  L1 = {New Tk.label tkInit(parent:W
								text:'Chose the item you want to fire')}
	  BMissile = {New Tk.button tkInit(parent:W
									   text:'Missile'
									   action:proc{$}
												 if State.accMissile >= Input.missile then
													KindFire = missile({PosFiring missile})
													NewState = {AdjoinList State [accMissile#(State.accMissile - Input.missile)]}
												 else
													skip
												 end
											  end)}
	  
	  BMine = {New Tk.button tkInit(parent:W
									text:'Mine'
									action:proc{$}
											  if State.accMine >= Input.mine then
												 KindFire = mine({PosFiring mine})
												 NewState = {AdjoinList State [accMine#(State.accMine - Input.mine) posMine#(KindFire.1|State.posMine)]}
											  else
												 skip
											  end
										   end)}

	  BSonar = {New Tk.button tkInit(parent:W
									 text:'Sonar'
									 action:proc{$}
											   if State.accSonar >= Input.sonar then
												  KindFire = sonar()
												  {W tkClose}
												  NewState = {AdjoinList State [accSonar#(State.accSonar - Input.sonar)]}
											   else
												  skip
											   end
											end)}

	  BDrone = {New Tk.button tkInit(parent:W
									 text:'Drone'
									 action:proc{$}
											   if State.accDrone >= Input.drone then
												  KindFire = {PosFiring drone}
												  NewState = {AdjoinList State [accDrone#(State.accDrone - Input.drone)]}
											   else
												  skip
											   end
											end)}
	  BNull = {New Tk.button tkInit(parent:W
									text:'Nothing'
									action:proc{$}
											  {W tkClose}
											  KindFire = null
											  NewState = State
										   end)}

	  {Tk.send pack(L1 BMissile BMine BSonar BDrone BNull fill:x padx:4 pady:4)}

	  	  
	  {Wait NewState}
      ID = State.id
	  NewState
   end

   fun{FireMine State ID Mine}
	  fun{RemoveMine LMine Mine}
		 case LMine of nil then nil
		 []HMine|TMine then if HMine == Mine then TMine
							else HMine|{RemoveMine TMine Mine}
							end
		 end
	  end

	  fun{ChoseMine}
		 Mine WPos L1 B
	  in
		 WPos = {New Tk.toplevel tkInit(title:'Chose Mine')}
		 L1 = {New Tk.label tkInit(parent:WPos
								   text:'Which one ?')}
		 B = {Map State.posMine
			  fun{$ F}
				 {New Tk.button tkInit(parent:WPos
									   text:F.x#','#F.y
									   action:proc{$}
												 Mine = F
											  end)}
			  end}

		 {Tk.send pack(L1 b(B) fill:x padx:4 pady:4)}

		 {Wait Mine}
		 {WPos tkClose}
		 Mine
	  end
   in
      ID = State.id	  
      if State.posMine == nil then
		 Mine = null
		 State
      else
		 W L1 BYes BNo
	  in
		 W = {New Tk.toplevel tkInit(title:'Explode mine')}
		 L1 = {New Tk.label tkInit(parent:W
								   text:'Do you want to explode a mine ?')}
		 BYes = {New Tk.button tkInit(parent:W
									  text:'Yes'
									  action: proc{$}
												 {W tkClose}
												 Mine = {ChoseMine}
											  end)}
		 
		 BNo = {New Tk.button tkInit(parent:W
									 text:'No'
									 action: proc{$}
												Mine = null
											 end)}
		 
		 {Tk.send pack(L1 BYes BNo fill:x padx:4 pady:4)}

		 if Mine == null then
			{W tkClose}
			State
		 else
			{W tkClose}
			{AdjoinList State [posMine#{RemoveMine State.posMine Mine}]}
		 end
      end
   end

   fun{IsSurface State ?ID ?Answer}
      if State.life =< 0 then
		 ID = null
		 Answer = null
		 State
      else
		 ID = State.id
		 Answer = State.curDir == surface
		 State
      end
   end

   fun{SayMove State ID Direction}
	  W L1
   in
	  W = {New Tk.toplevel tkInit(title:'Move')}
	  L1 = {New Tk.label tkInit(parent:W
								text:ID.color#' has move to the '#Direction)}
	 
	  thread {Delay Time} {W tkClose} end
	  
	  {Tk.send pack(L1 fill:x padx:4 pady:4)}
	  
      State
   end

   fun{SaySurface State ID}
	  W L1
   in
	  W = {New Tk.toplevel tkInit(title:'Surface')}
	  L1 = {New Tk.label tkInit(parent:W
								text:ID.color#' is back to the surface')}
	  
	  thread {Delay Time} {W tkClose} end

	  
	  {Tk.send pack(L1 fill:x padx:4 pady:4)}

      State
   end

   fun{SayCharge State ID KindItem}
	  W L1
   in
	  W = {New Tk.toplevel tkInit(title:'Charge')}
	  L1 = {New Tk.label tkInit(parent:W
								text:ID.color#' '#'has charge a '#KindItem)}

	  thread {Delay Time} {W tkClose} end

	  {Tk.send pack(L1 fill:x padx:4 pady:4)}
	  
      State
   end

   fun{SayMinePlaced State ID}
	  W L1
   in
	  W = {New Tk.toplevel tkInit(title:'Mine')}
	  L1 = {New Tk.label tkInit(parent:W
								text:ID.color#' has place a mine')}

	  thread {Delay Time} {W tkClose} end

	  {Tk.send pack(L1 fill:x padx:4 pady:4)}

      State
   end

   fun{SayMissileExplode State ID Position ?Message}
      Dist in
      Dist = {Abs State.curPos.x - Position.x} + {Abs State.curPos.y - Position.y}
      if State.life =< 0 then
		 Message = null
		 State
      elseif Dist == 0 then
		 if State.life - 2 > 0 then
			Message = sayDamageTaken(State.id 2 State.life - 2)
			{AdjoinList State [life#State.life - 2]}
		 else
			Message = sayDeath(State.id)
			{AdjoinList State [life#0]}
		 end
      elseif Dist == 1 then
		 if State.life - 1 > 0 then
			Message = sayDamageTaken(State.id 1 State.life - 1)
			{AdjoinList State [life#State.life - 1]}
		 else
			Message = sayDeath(State.id)
			{AdjoinList State [life#0]}
		 end
      else
		 Message = null%sayDamageTaken(State.id 0 State.life)
		 State
      end
   end

   fun{SayMineExplode State ID Position Message}
      {SayMissileExplode State ID Position Message}
   end

   fun{SayPassingDrone State Drone ID Answer}
      Type
      X
   in
	  ID = State.id
      drone(Type X) = Drone
      if Type == row then
		 Answer = State.curPos.x == X
      else Answer = State.curPos.y == X
      end
      State
   end

   fun{SayAnswerDrone State Drone ID Answer}
	  W L1 B Unit
   in
	  W = {New Tk.toplevel tkInit(title:'Drone result')}
	  if Answer then 
		 L1 = {New Tk.label tkInit(parent:W
								   text:ID.id#' '#ID.name#' '#ID.color#'       '#'true')}
	  else
		 L1 = {New Tk.label tkInit(parent:W
								   text:ID.id#' '#ID.name#' '#ID.color#'       '#'false')}
	  end

	  B = {New Tk.button tkInit(parent:W
								text:'OK'
								action:proc{$}
										  {W tkClose}
										  Unit = unit
										  end)}

	  {Tk.send pack(L1 B fill:x padx:4 pady:4)}

	  {Wait Unit}
	  State
   end

   fun{SayPassingSonar State ID Answer}
	  ID = State.id
      if {Abs {OS.rand}} mod 2 == 0 then
		 Answer = pt(x:State.curPos.x y:({Abs {OS.rand}} mod Input.nColumn + 1))
      else
		 Answer = pt(x:({Abs {OS.rand}} mod Input.nRow + 1) y:State.curPos.y)
      end
      State
   end

   fun{SayAnswerSonar State ID Answer}
	  W L1 B Unit
   in
	  W = {New Tk.toplevel tkInit(title:'Drone result')}
	  L1 = {New Tk.label tkInit(parent:W
								text:ID.id#' '#ID.name#' '#ID.color#'       '#Answer.x#','#Answer.y)}

	  B = {New Tk.button tkInit(parent:W
								text:'OK'
								action:proc{$}
										  {W tkClose}
										  Unit = unit
									   end)}

	  {Tk.send pack(L1 B fill:x padx:4 pady:4)}

	  {Wait Unit}
      State
   end

   fun{SayDeath State ID}
	  W L1 B Unit
   in
	  W = {New Tk.toplevel tkInit(title:'Death')}
	  L1 = {New Tk.label tkInit(parent:W
								text:ID.color#' died')}

	  B = {New Tk.button tkInit(parent:W
								text:'OK'
								action:proc{$}
										  {W tkClose}
										  Unit = unit
									   end)}

	  {Tk.send pack(L1 B fill:x padx:4 pady:4)}

	  {Wait Unit}
      State
   end

   fun{SayDamageTaken State ID Damage LifeLeft}
	  W L1
   in
	  W = {New Tk.toplevel tkInit(title:'Damage')}
	  L1 = {New Tk.label tkInit(parent:W
								text:ID.color#' has '#LifeLeft#' life left')}
	  
	  thread {Delay Time} {W tkClose} end
	  
	  {Tk.send pack(L1 fill:x padx:4 pady:4)}

      State
   end

in
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   
   fun{StartPlayer Color ID}
      Stream
      Port
      State
   in
      Port = {NewPort Stream}
      State = submarine(curPos:pt(x:_ y:_) curDir:surface accMissile:0 accMine:0 accSonar:0 accDrone:0 posMine:nil timeMine:1 life:Input.maxDamage id:ID map:Input.map)
      thread
		 {TreatStream Stream State}
      end
      Port
   end
   
   proc{TreatStream Stream State}   
      case Stream
      of nil then skip
      []initPosition(ID Position)|S then NewState in
		 NewState = {InitPosition State ID Position}
		 {TreatStream S NewState}
      []move(ID Position Direction)|S then NewState in
		 NewState = {Move State ID Position Direction}
		 {TreatStream S NewState}
      []dive|S then NewState in
		 NewState = {Dive State}
		 {TreatStream S NewState}
      []chargeItem(ID KindItem)|S then NewState in
		 NewState = {ChargeItem State ID KindItem}
		 {TreatStream S NewState}
      []fireItem(ID KindFire)|S then NewState in
		 NewState = {FireItem State ID KindFire}
		 {TreatStream S NewState}
      []fireMine(ID Mine)|S then NewState in
		 NewState = {FireMine State ID Mine}
		 {TreatStream S NewState}
      []isSurface(ID Answer)|S then NewState in
		 NewState = {IsSurface State ID Answer}
		 {TreatStream S NewState}
      []sayMove(ID Direction)|S then NewState in
		 NewState = {SayMove State ID Direction}
		 {TreatStream S NewState}
      []saySurface(ID)|S then NewState in
		 NewState = {SaySurface State ID}
		 {TreatStream S NewState}
      []sayCharge(ID KindItem)|S then NewState in
		 NewState = {SayCharge State ID KindItem}
		 {TreatStream S NewState}
      []sayMinePlaced(ID)|S then NewState in
		 NewState = {SayMinePlaced State ID}
		 {TreatStream S NewState}
      []sayMissileExplode(ID Position Message)|S then NewState in
		 NewState = {SayMissileExplode State ID Position Message}
		 {TreatStream S NewState}
      []sayMineExplode(ID Position Message)|S then NewState in
		 NewState = {SayMineExplode State ID Position Message}
		 {TreatStream S NewState}
      []sayPassingDrone(Drone ID Answer)|S then NewState in
		 NewState = {SayPassingDrone State Drone ID Answer}
		 {TreatStream S NewState}
      []sayAnswerDrone(Drone ID Answer)|S then NewState in
		 NewState = {SayAnswerDrone State Drone ID Answer}
		 {TreatStream S NewState}
      []sayPassingSonar(ID Answer)|S then NewState in
		 NewState = {SayPassingSonar State ID Answer}
		 {TreatStream S NewState}
      []sayAnswerSonar(ID Answer)|S then NewState in
		 NewState = {SayAnswerSonar State ID Answer}
		 {TreatStream S NewState}
      []sayDeath(ID)|S then NewState in
		 NewState = {SayDeath State ID}
		 {TreatStream S NewState}
      []sayDamageTaken(ID Damage LifeLeft)|S then NewState in
		 NewState = {SayDamageTaken State ID Damage LifeLeft}
		 {TreatStream S NewState}
      else
		 skip
      end
   end
end
