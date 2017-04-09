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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

   %Update un State avec une liste de tuple contenant les valeurs qui ont changÃ©
   % state(a:1 b:2) + [b#3] = state(a:1 b:3)
   fun{UpdateState State L}
      {AdjoinList State L}
   end

   fun{InitPosition State ID Position}
	  proc{FindPos X Y}
		 A B
	  in
		 A = ({Abs {OS.rand}} mod Input.nRow) + 1
		 B = ({Abs {OS.rand}} mod Input.nColumn) + 1
		 if {Nth {Nth Input.map A} B} == 0 then X = A Y = B
		 else {FindPos X Y} end
	  end
	  X Y
   in
	  ID = State.id
	  {FindPos X Y}
	  Position.x = X
	  Position.y = Y
	  {AdjoinList State [curPos#Position id#ID]}
   end

   fun{Move State ID Position Direction}
      ID = State.id
	  if State.curPos.x == 1 then State
	  else Position.x = State.curPos.x - 1
		 Position.y = State.curPos.y
		 Direction = north
		% {System.show Position}
		 {AdjoinList State [curPos#Position curDir#Direction]}
	  end
   end

   fun{Dive State}
      {AdjoinList State [curDir#north]}
   end

   fun{ChargeItem State ID KindItem}
      ID = State.id
	  if State.accMissile < Input.missile then
		 if State.accMissile + 1 == Input.missile then KindItem = missile
		 else KindItem = null
		 end
		 {AdjoinList State [accMissile#State.accMissile + 1]} 
	  elseif State.accMine < Input.mine then
		 if State.accMine + 1 == Input.mine then KindItem = mine
		 else KindItem = null
		 end
		 {AdjoinList State [accMine#State.accMine + 1]}
	  elseif State.accSonar < Input.sonar then
		 if State.accSonar + 1 == Input.sonar then KindItem = sonar
		 else KindItem = null
		 end
		 {AdjoinList State [accSonar#State.accSonar + 1]}
	  elseif State.accDrone < Input.drone then
		 if State.accDrone + 1 == Input.drone then KindItem = drone
		 else KindItem = null
		 end
		 {AdjoinList State [accDrone#State.accDrone + 1]}
	  end
   end

   fun{FireItem State ID KindFire}
      ID = State.id
	  if State.accMissile == Input.missile then
		 KindFire = missile(pt(x:State.curPos.x y:State.curPos.y + 2))
		 {AdjoinList State [accMissile#0]}
	  else
		 KindFire = null
		 State
	  end
   end

   fun{FireMine State ID Mine}
      ID = State.id
	  Mine = State.posMine
	  {AdjoinList State [posMine#null]}
   end

   fun{IsSurface State ID Answer}
      ID = State.id
	  Answer = State.curDir == surface
	  State
   end

   fun{SayMove State ID Direction}
	  {System.show Direction}
      State
   end

   fun{SaySurface State ID}
	  {System.show 'Surface'}
      State
   end

   fun{SayCharge State ID KindItem}
	  {System.show KindItem}
      State
   end

   fun{SayMinePlaced State ID}
	  {System.show 'Mine Placed'}
      State
   end

   fun{SayMissileExplode State ID Position Message}
	  {System.show Position}
      Dist in
	  Dist = {Abs State.curPos.x - Position.x} + {Abs State.curPos.y - Position.y}
	  if Dist == 0 then
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
		 Message = sayDamageTaken(State.id 0 State.life)
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
      drone(Type X) = Drone
	  if Type == row then
		 Answer = State.curPos.x == X
	  else Answer = State.curPos.y == X
	  end
	  State
   end

   fun{SayAnswerDrone State Drone ID Answer}
      State
   end

   fun{SayPassingSonar State ID Answer}
	  if {Abs {OS.rand}} mod 2 == 0 then
		 Answer = pt(x:State.curPos.x y:{Abs {OS.rand}} mod Input.nColumn + 1)
	  else
		 Answer = pt(x:{Abs {OS.rand}} mod Input.nRow + 1 y:State.curPos.y)
	  end	 
   end

   fun{SayAnswerSonar State ID Answer}
      State
   end

   fun{SayDeath State ID}
      State
   end

   fun{SayDamageTaken State ID Damage LifeLeft}
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
	  State = submarine(curPos:pt(x:_ y:_) curDir:surface accMissile:0 accMine:0 accSonar:0 accDrone:0 posMine:null life:Input.maxDamage id:ID )
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
