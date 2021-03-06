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

   %Update un State avec une liste de tuple contenant les valeurs qui ont changees
   % state(a:1 b:2) + [b#3] = state(a:1 b:3)

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
      X Y
   in
      ID = State.id
      {FindPos X Y}
      Position.x = X
      Position.y = Y
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

   fun{FindPos LPos Events}
      fun{TestPos P L}
	 case L
	 of north|T then NewP in
	    NewP = pt(x:P.x+1 y:P.y)
	    if {Nth Input.map NewP.x NewP.y} == 1 then false
	    else {TestPos NewP T}
	    end
	 [] west|T then NewP in
	    NewP = pt(x:P.x y:P.y+1)
	    if {Nth Input.map NewP.x NewP.y} == 1 then false
	    else {TestPos NewP T}
	    end
	 [] south|T then NewP in
	    NewP = pt(x:P.x-1 y:P.y)
	    if {Nth Input.map NewP.x NewP.y} == 1 then false
	    else {TestPos NewP T}
	    end
	 [] east|T then NewP in
	    NewP = pt(x:P.x y:P.y-1)
	    if {Nth Input.map NewP.x NewP.y} == 1 then false
	    else {TestPos NewP T}
	    end
	 [] surface|T then {TestPos P T}
	 [] drone(Type X)|T then
	    if Type == row andthen P.x == X then {TestPos P T}
	    elseif Type == column andthen P.y == X then {TestPos P T}
	    else false
	    end
	 [] pt(x:X y:Y)|T then
	    if P.x == X orelse P.y == Y then {TestPos P T}
	    else false
	    end
	 [] nil then true
	 end
      end

      fun{ParcoursPos P}
	 case P of nil then nil
	 [] H|T then
	    if {TestPos H Events} then H|{ParcoursPos T}
	    else {ParcoursPos T}
	    end
	 end  
      end
   in
      {ParcoursPos LPos}
   end

   fun{MAJPosID State N}
      if N == 0 then State
      elseif N == State.id.id then {MAJPosID State N-1}
      else LPos in
	 LPos = {FindPos State.lPos.(State.id.id) State.info.N}
	 {MAJPosID {AdjoinList State [lPos#{AdjoinList State.lPos [N#LPos]}]} N-1}
      end
   end
   
   fun{Move State ID Position Direction}
      fun{PriorMoveId N}
	 if {Abs State.curPos.x - State.lPos.N.1.x} >= {Abs State.curPos.y - State.lPos.N.1.y} then
	    if State.curPos.x - State.lPos.N.1.x > 0 andthen {Nth State.map State.curPos.x-1 State.curPos.y} == 0 then north
	    elseif State.curPos.x - State.lPos.N.1.x < 0 andthen {Nth State.map State.curPos.x+1 State.curPos.y} == 0 then south
	    elseif State.curPos.y - State.lPos.N.1.y > 0 andthen {Nth State.map State.curPos.x State.curPos.y-1} == 0 then west
	    elseif State.curPos.y - State.lPos.N.1.y < 0 andthen {Nth State.map State.curPos.x State.curPos.y+1} == 0 then east
	    else null
	    end
	 else
	    if State.curPos.y - State.lPos.N.1.y > 0 andthen {Nth State.map State.curPos.x State.curPos.y-1} == 0 then west
	    elseif State.curPos.y - State.lPos.N.1.y < 0 andthen {Nth State.map State.curPos.x State.curPos.y+1} == 0 then east
	    elseif State.curPos.x - State.lPos.N.1.x > 0 andthen {Nth State.map State.curPos.x-1 State.curPos.y} == 0 then north
	    elseif State.curPos.x - State.lPos.N.1.x < 0 andthen {Nth State.map State.curPos.x+1 State.curPos.y} == 0 then south
	    else null
	    end
	 end  
      end

      fun{PriorMove N}
	 if N == 0 then false
	 elseif N == State.id.id orelse State.death.N == dead then {PriorMove N-1}
	 else
	    Direct
	 in
	    case State.lPos.N
	    of Pos|nil then 
	       Direct = {PriorMoveId N}
	       if Direct == null then {PriorMove N-1}
	       else
		  Pos
	       in
		  case Direct
		  of north then Pos = pt(x:State.curPos.x - 1 y:State.curPos.y)
		  [] west then Pos = pt(x:State.curPos.x y:State.curPos.y - 1)
		  [] south then Pos = pt(x:State.curPos.x + 1 y:State.curPos.y)
		  [] east then Pos = pt(x:State.curPos.x y:State.curPos.y + 1)
		  end
		  {System.show 'jarrive bonhomme'#N}
		  Direction = Direct
		  Position = Pos
		  true
	       end
	    else {PriorMove N-1}
	    end
	 end 
      end
      
      proc{NthL L N ?Mem ?Ans}
	 if N == 0 then
	    Ans = L.1
	    Mem = L.2
	 else Ms in
	    Mem = L.1|Ms
	    {NthL L.2 N-1 Ms Ans}
	 end
      end

      fun{PosAleat L N}
	 Mem Pos Direct
      in
	 if N == 0 then false
	 else
	    {NthL L ({Abs {OS.rand}} mod N) Mem Direct}
	    case Direct
	    of north then Pos = pt(x:State.curPos.x - 1 y:State.curPos.y)
	    [] west then Pos = pt(x:State.curPos.x y:State.curPos.y - 1)
	    [] south then Pos = pt(x:State.curPos.x + 1 y:State.curPos.y)
	    [] east then Pos = pt(x:State.curPos.x y:State.curPos.y + 1)
	    end
	    
	    if {Nth State.map Pos.x Pos.y} == 0 then
	       Position = Pos
	       Direction = Direct
	       true
	    else
	       {PosAleat Mem N-1}
	    end
	 end
      end
      NewState
      PriorDir
   in
      ID = State.id
      
      NewState = {MAJPosID State Input.nbPlayer}
      % {System.show 'ATTENTION INFO IMPORTANTE <==================='}
      % for E in 1..Input.nbPlayer do
      % 	 {System.show E}
      % 	 {System.show NewState.lPos.E}
      % end
      % {System.show 'END <==================='}
      
	  %{System.show State.map}
      if {PriorMove Input.nbPlayer} then skip
      elseif {PosAleat [north west south east] 4} then skip
      else
	 Position = NewState.curPos
	 Direction = surface 
      end
      if Direction == surface then
	 {AdjoinList NewState [curPos#Position curDir#Direction map#Input.map]}
      else
	 {AdjoinList NewState [curPos#Position curDir#Direction map#{ModMap NewState.map Position}]}
      end
   end

   fun{Dive State}
      {AdjoinList State [curDir#north map#{ModMap State.map State.curPos}]}
   end

   fun{ChargeItem State ID KindItem}
      fun{AllPosFind N}
	 if N == 0 then {System.show 'je gere de trop je vous ai tous trouve!!!'} true
	 elseif N == ID.id orelse State.death.N == dead then {AllPosFind N-1}
	 else
	    case State.lPos.N
	    of Pos|nil then {AllPosFind N-1}
	    else false
	    end
	 end
      end
      Prior
      AllFounded
   in
      ID = State.id
      
      if State.allFounded then
	 Prior = 1
	 AllFounded = true
      else
	 Prior = 4
	 AllFounded = {AllPosFind Input.nbPlayer}
      end

      case  {Abs {OS.rand}} mod Prior
      of 0 then
	 if State.accMissile + 1 == Input.missile then KindItem = missile
	 else KindItem = null
	 end
	 {AdjoinList State [allFounded#AllFounded accMissile#State.accMissile + 1]}
      [] 1 then
	 if State.accMine + 1 == Input.mine then KindItem = mine
	 else KindItem = null
	 end
	 {AdjoinList State [allFounded#AllFounded accMine#State.accMine + 1]}
      [] 2 then
	 if State.accSonar + 1 == Input.sonar then KindItem = sonar
	 else KindItem = null
	 end
	 {AdjoinList State [allFounded#AllFounded accSonar#State.accSonar + 1]}
      [] 3 then
	 if State.accDrone + 1 == Input.drone then KindItem = drone
	 else KindItem = null
	 end
	 {AdjoinList State [allFounded#AllFounded accDrone#State.accDrone + 1]}
      end
   end

   
   fun{FireItem State ?ID ?KindFire}
      fun{ShouldAttack N Min Max ?Target}
	 if N == 0 then
	    Target = 0
	    false
	 else
	    if State.death.N == alive andthen State.id.id \= N then
	       case State.lPos.N
	       of Pos|nil then
		  if {Abs State.curPos.x - Pos.x} + {Abs State.curPos.y - Pos.y} < Max
		     andthen {Abs State.curPos.x - Pos.x} + {Abs State.curPos.y - Pos.y} > Min then
		     Target = N
		     true
		  else
		     {ShouldAttack N-1 Min Max Target}
		  end
	       else {ShouldAttack N-1 Min Max Target}
	       end
	    else {ShouldAttack N-1 Min Max Target}
	    end
	 end
      end
      
      fun{AleaPos Min Max Type}
	 Pos = pt(x:_ y:_)
      in
	 Pos.x = State.curPos.x - Max  + {Abs {OS.rand}} mod (2 * Max +1)
	 Pos.y =  State.curPos.y - Max  + {Abs {OS.rand}} mod (2 * Max +1)
	 if Pos.x > 0 andthen Pos.x =< Input.nRow andthen
	    Pos.y > 0 andthen Pos.y =< Input.nColumn andthen
	    {Nth Input.map Pos.x Pos.y} == 0 andthen
	    {Abs State.curPos.x - Pos.x} + {Abs State.curPos.y - Pos.y} >= Min andthen
	    {Abs State.curPos.x - Pos.x} + {Abs State.curPos.y - Pos.y} =< Max
	 then
	    if Type == mine orelse
	       {Abs State.curPos.x - Pos.x} + {Abs State.curPos.y - Pos.y} >= 2 then
	       Pos
	    else
	       {AleaPos Min Max Type}
	    end
	 else {AleaPos Min Max Type}
	 end
      end
      % fun{FindDiff L Count}
      % 	 case L
      % 	    of pt(x:X y:Y)|T then 
      % end
      
      Target
   in
      ID = State.id
      if State.accMissile >= Input.missile andthen {ShouldAttack Input.nbPlayer Input.minDistanceMissile Input.maxDistanceMissile Target} then
	 KindFire = missile(State.lPos.Target.1)
	 {System.show 'JE SUIS TROP INTELLIGENT --------------------------- MISSILE---'#KindFire}
	 {AdjoinList State [accMissile#(State.accMissile - Input.missile)]}
      elseif State.accMine >= Input.mine then
	 Pos
      in
	 if {ShouldAttack Input.nbPlayer Input.minDistanceMine Input.maxDistanceMine Target} then
	    Pos = State.lPos.Target.1
	    {System.show 'JE SUIS TROP INTELLIGENT --------------------------- MINE---'#Pos}
	 else Pos = {AleaPos Input.minDistanceMine Input.maxDistanceMine mine}
	 end
	 KindFire = mine(Pos)
	 {AdjoinList State [accMine#(State.accMine - Input.mine) posMine#(Pos|State.posMine)]}
      elseif State.accSonar >= Input.sonar then
	 KindFire = sonar()
	 {AdjoinList State [accSonar#(State.accSonar - Input.sonar)]}
      elseif State.accDrone >= Input.drone then
	 case {Abs {OS.rand}} mod 2
	 of 0 then KindFire = drone(row {Abs {OS.rand} mod Input.nRow +1})
	 [] 1 then KindFire = drone(column {Abs {OS.rand} mod Input.nColumn +1})
	 end
	 {AdjoinList State [accDrone#(State.accDrone - Input.drone)]}
      else
	 KindFire = null
	 State
      end
   end

   fun{FireMine State ID Mine}
      fun{ChooseMine LMine N}
	 if N == 0 then null
	 elseif N == State.id.id orelse State.death.N == dead then {ChooseMine State.posMine N-1}
	 else 
	    case LMine of nil then
	       if N == 1 then null
	       else {ChooseMine State.posMine N-1}
	       end
	    []HMine|TMine then
	       if {Abs State.curPos.x - HMine.x} + {Abs State.curPos.y - HMine.y} >= 2 then
		  case State.lPos.N of Pos|nil then 
		     if {Abs Pos.x - HMine.x} + {Abs Pos.y - HMine.y} < 1 then
			{System.show 'JE SUIS TROP INTELLIGENT --------------------------- MINEFIRE---'#Pos}
			HMine
		     else {ChooseMine TMine N}
		     end
		  else {ChooseMine State.posMine N-1}
		  end
	       else {ChooseMine TMine N}
	       end
	    end
	 end
      end

      fun{RemoveMine LMine Mine}
	 case LMine of nil then nil
	 []HMine|TMine then if HMine == Mine then TMine
			    else HMine|{RemoveMine TMine Mine}
			    end
	 end
      end
      
   in
      ID = State.id
      if State.posMine == nil then
	 Mine = null
	 State
      else
	 Mine = {ChooseMine State.posMine Input.nbPlayer}
	 if Mine == null then
	    State
	 else
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
      {AdjoinList State [info#{AdjoinList State.info [(ID.id)#(Direction|State.info.(ID.id))]}]}
   end

   fun{SaySurface State ID}
      {AdjoinList State [info#{AdjoinList State.info [(ID.id)#(surface|State.info.(ID.id))]}]}
   end

   fun{SayCharge State ID KindItem}
      if ID.id ==2 then
	 {System.show 'charge'#KindItem#ID}
      else skip
      end
      
      State
   end

   fun{SayMinePlaced State ID}
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
      if Answer then {AdjoinList State [info#{AdjoinList State.info [(ID.id)#(Drone|(State.info.(ID.id)))]}]}
      else State
      end
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
      {AdjoinList State [info#{AdjoinList State.info [(ID.id)#(Answer|(State.info.(ID.id)))]}]}
   end

   fun{SayDeath State ID}
      {AdjoinList State [death#{AdjoinList State.death [ID.id#dead]}]}
   end

   fun{SayDamageTaken State ID Damage LifeLeft}
      {System.show 'outch<==========='#ID}
      State
   end

   fun{MakeListID S N ToPut}
      if N == 0 then S
      else {MakeListID {AdjoinList S [N#ToPut]} N - 1 ToPut}
      end
   end

   fun{MakeListPos P}
      if P.x > Input.nRow then {MakeListPos pt(x:1 y:P.y+1)}
      elseif P.y > Input.nColumn then nil
      else P|{MakeListPos pt(x:P.x+1 y:P.y)}
      end
   end

in
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   
   fun{StartPlayer Color ID}
      Stream
      Port
      State
      Id
   in
      Id = id(id:ID color:Color name:basic)
      Port = {NewPort Stream}
      State = submarine(curPos:pt(x:_ y:_) curDir:surface accMissile:0 accMine:0 accSonar:0 accDrone:0 posMine:nil life:Input.maxDamage id:Id map:Input.map
			info:{MakeListID rec() Input.nbPlayer nil} lPos:{MakeListID rec() Input.nbPlayer {MakeListPos pt(x:1 y:1)}} allFounded:false
			death:{MakeListID rec() Input.nbPlayer alive})
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
	 if State.life =< 0 then
	    ID = null
	    Position = null
	    Direction = null
	    {TreatStream S State}
	 else 
	    NewState = {Move State ID Position Direction}
	    {TreatStream S NewState}
	 end
      []dive|S then NewState in
	 NewState = {Dive State}
	 {TreatStream S NewState}
      []chargeItem(ID KindItem)|S then NewState in
	 if State.life =< 0 then
	    ID = null
	    KindItem = null
	    {TreatStream S State}
	 else
	    NewState = {ChargeItem State ID KindItem}
	    {TreatStream S NewState}
	 end
      []fireItem(ID KindFire)|S then NewState in
	 if State.life =< 0 then
	    ID = null
	    KindFire = null
	    {TreatStream S State}
	 else
	    NewState = {FireItem State ID KindFire}
	    {TreatStream S NewState}
	 end
      []fireMine(ID Mine)|S then NewState in
	 if State.life =< 0 then
	    ID = null
	    Mine = null
	    {TreatStream S State}
	 else
	    NewState = {FireMine State ID Mine}
	    {TreatStream S NewState}
	 end
      []isSurface(ID Answer)|S then NewState in
	 if State.life =< 0 then
	    ID = null
	    Answer = null
	    {TreatStream S State}
	 else
	    NewState = {IsSurface State ID Answer}
	    {TreatStream S NewState}
	 end
      []sayMove(ID Direction)|S then NewState in
	 if ID == null then NewState = State
	 else NewState = {SayMove State ID Direction}
	 end
	 {TreatStream S NewState}
      []saySurface(ID)|S then NewState in
	 NewState = {SaySurface State ID}
	 {TreatStream S NewState}
      []sayCharge(ID KindItem)|S then NewState in
	 if ID == null then NewState = State
	 else NewState = {SayCharge State ID KindItem}
	 end
	 {TreatStream S NewState}
      []sayMinePlaced(ID)|S then NewState in
	 if ID == null then NewState = State
	 else NewState = {SayMinePlaced State ID}
	 end
	 {TreatStream S NewState}
      []sayMissileExplode(ID Position Message)|S then NewState in
	 if ID == null then NewState = State
	 else NewState = {SayMissileExplode State ID Position Message}
	 end
	 {TreatStream S NewState}
      []sayMineExplode(ID Position Message)|S then NewState in
	 if ID == null then NewState = State
	 else NewState = {SayMineExplode State ID Position Message}
	 end
	 {TreatStream S NewState}
      []sayPassingDrone(Drone ID Answer)|S then NewState in
	 NewState = {SayPassingDrone State Drone ID Answer}
	 {TreatStream S NewState}
      []sayAnswerDrone(Drone ID Answer)|S then NewState in
	 if ID == null then NewState = State
	 else NewState = {SayAnswerDrone State Drone ID Answer}
	 end
	 {TreatStream S NewState}
      []sayPassingSonar(ID Answer)|S then NewState in
	 NewState = {SayPassingSonar State ID Answer}
	 {TreatStream S NewState}
      []sayAnswerSonar(ID Answer)|S then NewState in
	 if ID == null then NewState = State
	 else NewState = {SayAnswerSonar State ID Answer}
	 end
	 {TreatStream S NewState}
      []sayDeath(ID)|S then NewState in
	 if ID == null then NewState = State
	 else NewState = {SayDeath State ID}
	 end
	 {TreatStream S NewState}
      []sayDamageTaken(ID Damage LifeLeft)|S then NewState in
	 if ID == null then NewState = State
	 else NewState = {SayDamageTaken State ID Damage LifeLeft}
	 end
	 {TreatStream S NewState}
      else
	 skip
      end
   end
end
