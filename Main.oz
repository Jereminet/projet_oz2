functor
import
   GUI
   Input
   PlayerManager
   System
   OS
define
   
   PortGUI AllPort

   fun{PlayerIDInit LPlay LCol ID}
      case LPlay#LCol
      of (HPlay|TPlay)#(HCol|TCol) then ID.color = HCol ID.name = HPlay
		 {PlayerManager.playerGenerator HPlay HCol ID}|{PlayerIDInit TPlay TCol id(id:ID.id + 1 color:_ name:_)}
      else nil
      end
   end

   proc{PlayerPtInit AllPort}
      Id Position
   in
      Position = pt(x:_ y:_)
      case AllPort of HPort|TPort then
		 {Send HPort initPosition(Id Position)}%{System.show 'playerinti'}
		 {Send PortGUI initPlayer(Id Position)}
		 {PlayerPtInit TPort}
      else skip
      end
   end

   proc{Broadcast LPort Msg}
      case LPort of nil then skip
      []HPort|TPort then
		 {Send HPort Msg}
		 {Broadcast TPort Msg}
      end
   end

   proc{BroadcastM LPort ToCall}
      case LPort of nil then skip
      []HPort|TPort then
		 case ToCall
		 of callSayMissileExplode(Id P) then Msg in
			{Send HPort sayMissileExplode(Id P Msg)}
			case Msg of null then skip
			[] sayDeath(ID) then
			   {Broadcast AllPort Msg}
			   {Send PortGUI removePlayer(ID)}
			   %{System.show '===========================> DEAD TUTUTUUUUU TUTUTU TUTU TUTUUUUU'}
			[] sayDamageTaken(ID DAM Life) then
			   %{System.show 'NewLife <==========================================='}
			   %{System.show Life}
			   {Send PortGUI lifeUpdate(ID Life)}
			   {Broadcast AllPort Msg}			 
			end
		 [] callSayMineExplode(Id P) then Msg in
			{Send HPort sayMineExplode(Id P Msg)}
			case Msg of null then skip
			[] sayDeath(ID) then
			   {Broadcast AllPort Msg}
			   {Send PortGUI removePlayer(ID)}
			   %{System.show '===========================> DEAD TUTUTUUUUU TUTUTU TUTU TUTUUUUU'}
			[] sayDamageTaken(ID DAM Life) then
			   %{System.show 'NewLife <==========================================='}
			   %{System.show Life}
			   {Send PortGUI lifeUpdate(ID Life)}
			   {Broadcast AllPort Msg}			 
			end
		 [] callSayPassingDrone(Drone ToAnswer) then Id Answer in
			{Send HPort sayPassingDrone(Drone Id Answer)}
			{Send ToAnswer sayAnswerDrone(Drone Id Answer)}
		 [] callSayPassingSonar(ToAnswer) then Id Answer in
			{Send HPort sayPassingSonar(Id Answer)}
			{Send ToAnswer sayAnswerSonar(Id Answer)}
		 end
		 {BroadcastM TPort ToCall} 
      end
   end

   fun{MakeSurf S N}
      if N == 0 then S
      else {MakeSurf {AdjoinList S [N#1]} N - 1}
      end
   end

   proc{CanCharge HPort}
	  Id KindCharge
   in
	  {Send HPort chargeItem(Id KindCharge)}
	  if KindCharge == null then skip
	  else {Broadcast AllPort sayCharge(Id KindCharge)}
	  end
   end

   proc{CanFire HPort}
	  Id KindFire
   in
	  {Send HPort fireItem(Id KindFire)}
	  case KindFire of null then skip
	  []missile(P) then
		 %{System.show 'Missile'}
		 %{System.show P}
		 {Send PortGUI explosion(Id P)}
		 {BroadcastM AllPort callSayMissileExplode(Id P)}
	  []mine(P) then
		 %{System.show 'Mine'}
		 %{System.show P}
		 {Send PortGUI putMine(Id P)}
		 {Broadcast AllPort sayMinePlaced(Id)}
	  []drone(Type Coord) then
		 {Send PortGUI drone(Id KindFire)}
		 {BroadcastM AllPort callSayPassingDrone(KindFire HPort)}
	  []sonar then
		 {Send PortGUI sonar(Id)}
		 {BroadcastM AllPort callSayPassingSonar(HPort)}
	  end
   end

   proc{CanMine HPort}
	  Id Mine
   in
	  {Send HPort fireMine(Id Mine)}
	  case Mine of null then skip
	  [] P then
		 %{System.show 'Mine Explose'}
		 %{System.show P}
		 {Send PortGUI explosion(Id P)}
		 {Send PortGUI removeMine(Id P)}
		 {BroadcastM AllPort callSayMineExplode(Id P)}
	  end
   end
   
   proc{Turn All Round Surf CountDead}
      fun{CanPlay HPort ?NewSurf ?Id ?Dead}
		 if Round == 1 then % INITIALISATION
			{Send HPort dive}
		    NewSurf = Surf
		    Dead = 0
			false
		 else
			Answer
		 in
			{Send HPort isSurface(Id Answer)} % on regarde si on est a la surface
			if Id == null then % sub est mort
			   %{System.show 'je suis mort RIP RPZ wouech wouech'}
			   NewSurf = Surf
			   Dead = 1
			   false
			elseif Answer andthen Surf.(Id.id) < Input.turnSurface then % a la surface et on doit y rester encore
			   %{System.show 'je passe mon tour !!!!!!!!!!'}
			   NewSurf = {AdjoinList Surf [Id.id#Surf.(Id.id) + 1]}
			   Dead = 0
			   false
			elseif Answer andthen Surf.(Id.id) == Input.turnSurface then % on peut dive
			   {Send HPort dive}
			   NewSurf = Surf
			   Dead = 0
			   true
			else
			   NewSurf = Surf
			   Dead = 0
			   true
			end
		 end
      end

      proc{CanMove HPort}
		 Id Position Direction
      in
		 {Send HPort move(Id Position Direction)}
		 if Direction == surface then
			{Broadcast AllPort saySurface(Id)}
			{Send PortGUI surface(Id)}
		 else
			{Broadcast AllPort sayMove(Id Direction)}
			{Send PortGUI movePlayer(Id Position)}
		 end
      end
   in
      {Delay 500}
      case All of nil then
	 if CountDead == Input.nbPlayer -1 then {System.show 'FINISH'}
	 else {Turn AllPort Round + 1 Surf 0}
	 end
	 
      []HPort|TPort then
		 NewSurf Id Dead
      in
		 if {CanPlay HPort NewSurf Id Dead} == false then {Turn TPort Round NewSurf CountDead+Dead}
		 else
			{CanMove HPort}
			{CanCharge HPort}
			{CanFire HPort}
			{CanMine HPort}
			{Turn TPort Round {AdjoinList Surf [(Id.id)#1]} CountDead}
		 end
      end
   end

   proc{Thinking}
	  {Delay {Abs {OS.rand}} mod (Input.thinkMax - Input.thinkMin) + Input.thinkMin}
   end

   proc{PlayingSimul HPort}
	  fun{CanMove HPort}
		 Id Position Direction
      in
		 {Send HPort move(Id Position Direction)}
		 if Id == null then
			ignore
		 elseif Direction == surface then
			{Broadcast AllPort saySurface(Id)}
			{Send PortGUI surface(Id)}
			{Delay Input.turnSurface * 1000}
			onSurface
		 else
			{Broadcast AllPort sayMove(Id Direction)}
			{Send PortGUI movePlayer(Id Position)}
			notSurface
		 end
      end
	  Moving
   in
	  {Thinking}
	  Moving = {CanMove HPort}
	  if Moving == onSurface then
		 {Send HPort dive} {PlayingSimul HPort}
	  elseif Moving == notSurface then
		 {Thinking}
		 {CanCharge HPort}
		 {Thinking}
		 {CanFire HPort}
		 {Thinking}
		 {CanMine HPort}
		 {PlayingSimul HPort}
	  else
		 {PlayingSimul HPort}
	  end
   end

   proc{Simultaneous LPort}
	  case LPort of nil then skip
	  []HPort|TPort then
		 thread {Send HPort dive} {PlayingSimul HPort} end
		 {Simultaneous TPort}
	  end
   end

   Surf
in
   Surf = {MakeSurf surf() Input.nbPlayer}
   PortGUI = {GUI.portWindow}
   {Send PortGUI buildWindow}
   AllPort = {PlayerIDInit Input.players Input.colors id(id:1 color:_ name:_)}
   {PlayerPtInit AllPort}%{System.show 'dessiner'}
   if Input.isTurnByTurn then {Turn AllPort 1 Surf 0} else {Simultaneous AllPort} end
end