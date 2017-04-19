functor
import
   GUI
   Input
   PlayerManager
   System
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
	  []HPort|TPort then {Send HPort Msg}
	  end
   end

   fun{MakeSurf S N}
	  if N == 0 then S
	  else {MakeSurf {AdjoinList S [N#1]} N - 1}
	  end
   end

   proc{Turn All Round Surf}
	  {Delay 500}
	  case All of nil then {Turn AllPort Round + 1 Surf}
	  []HPort|TPort then {System.show Surf}
		 if Round == 1 then {Send HPort dive}
			{Turn TPort Round Surf}
	  	 else Id Answer in
			{Send HPort isSurface(Id Answer)}
			
	  		if Answer andthen Surf.(Id.id) < Input.turnSurface then {System.show 'je passe mon tour !!!!!!!!!!'}  {Turn TPort Round {AdjoinList Surf [Id.id#Surf.(Id.id) + 1]}} 
			else
			   Position Direction KindCharge KindFire Mine
			in
			   if Surf.(Id.id) == Input.turnSurface then {Send HPort dive}
			   else skip
			   end
			   Position = pt(x:_ y:_)
			   {Send HPort move(Id Position Direction)}
			   if Direction == surface then
				  %{System.show ici}
				  {Broadcast AllPort saySurface(Id)}
				  {Send PortGUI surface(Id)}
			   else
				  {Broadcast AllPort sayMove(Id Direction)}
				  {Send PortGUI movePlayer(Id Position)}
			   end
			   %{Delay 1000}
			   %{System.show Id.color}

			   {Send HPort chargeItem(Id KindCharge)}
			   if KindCharge == null then skip
			   else {Broadcast AllPort sayCharge(Id KindCharge)}
			   end
			   %{System.show Id.name}

			   {Send HPort fireItem(Id KindFire)}
			   case KindFire of null then skip
			   []missile(P) then
			      Msg
			   in
			      {System.show 'Missile'}
			      {System.show P}
			      {Send PortGUI explosion(Id P)}
			      {Broadcast AllPort sayMissileExplode(Id P Msg)}
			      if Msg == null
			      then skip
			      else {Broadcast AllPort Msg}
			      end
			   []mine(P) then
			      {System.show 'Mine'}
			      {System.show P}
			      {Send PortGUI putMine(Id P)}
			      {Broadcast AllPort sayMinePlaced(Id)}
			   end

			   {Send HPort fireMine(Id Mine)}
			   case Mine of null then skip
			   [] P then
			      Msg
			   in
			      {System.show 'Mine Explose'}
			      {System.show P}
			      {Send PortGUI explosion(Id P)}
			      {Send PortGUI removeMine(Id P)}
			      {Broadcast AllPort sayMineExplode(Id P Msg)}
			      case Msg of null then skip
			      [] sayDeath(ID) then
				 {Broadcast AllPort Msg}
				 {Send PortGUI lifeUpdate(ID 0)}
			      [] sayDamageTaken(ID DAM Life) then
				 {System.show 'NewLife'}
				 {System.show Life}
				 {Send PortGUI lifeUpdate(ID Life)}
				 {Broadcast AllPort Msg}
				 
			      end
			   end  
			   
			   %{System.show 'salut'}
			   % KindFire in {Send HPort fireItem(Id KindFire)}
			   % if KindFire == null then skip
			   % else {Broadcast AllPort sayFire(Id KindFire)}
			   % end
			end
			{Turn TPort Round {AdjoinList Surf [(Id.id)#1]}}
		 end
	  end
   end

   %proc{Simultaneous}
   %   notImplemented
   %end
   Surf
in
   Surf = {MakeSurf surf() Input.nbPlayer}
   PortGUI = {GUI.portWindow}
   {Send PortGUI buildWindow}
   AllPort = {PlayerIDInit Input.players Input.colors id(id:1 color:_ name:_)}
   {PlayerPtInit AllPort}%{System.show 'dessiner'}
   if Input.isTurnByTurn then {Turn AllPort 1 Surf} end %else {Simultaneous} end
end