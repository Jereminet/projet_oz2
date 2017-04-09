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

   proc{Turn All Round}
	  {Delay 500}
	  case All of nil then {Turn AllPort Round + 1}
	  []HPort|TPort then
	  	 if Round == 1 then {Send HPort dive}
	  	 else Id Answer in
	  		{Send HPort isSurface(Id Answer)}
	  		if Answer then {Turn TPort Round}
			else Position Direction KindCharge KindFire in
			   Position = pt(x:_ y:_)
			   {Send HPort move(Id Position Direction)}
			   if Direction == surface then
				  {Broadcast AllPort saySurface(Id)}
				  {Send PortGUI surface(Id)}
			   else
				  {Broadcast AllPort sayMove(Id Direction)}
				  {Send PortGUI movePlayer(Id Position)}
			   end
			   %{Delay 1000}
			   %{System.show 'charge'}

			   {Send HPort chargeItem(Id KindCharge)}
			   if KindCharge == null then skip
			   else {Broadcast AllPort sayCharge(Id KindCharge)}
			   end
			   {System.show 'coucou'}

			   % {Send HPort fireItem(Id KindFire)}
			   % case KindFire of null then skip
			   % 	  []missile(P) then {Broadcast AllPort sayMissileExplode(
			   % end
			   {System.show 'salut'}
			   % KindFire in {Send HPort fireItem(Id KindFire)}
			   % if KindFire == null then skip
			   % else {Broadcast AllPort sayFire(Id KindFire)}
			   % end
			end
		 end
		 {Turn TPort Round}
	  end
   end

   %proc{Simultaneous}
   %   notImplemented
   %end
in
   PortGUI = {GUI.portWindow}
   {Send PortGUI buildWindow}
   AllPort = {PlayerIDInit Input.players Input.colors id(id:1 color:_ name:_)}
   {PlayerPtInit AllPort}%{System.show 'dessiner'}
   if Input.isTurnByTurn then {Turn AllPort 1} end %else {Simultaneous} end
end