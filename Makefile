all: compile exe

compile: 
	/Applications/Mozart2.app/Contents/Resources/bin/ozc -c GUI.oz Input.oz Main.oz Player007Random.oz Player007Improved.oz PlayerManager.oz Player007Real.oz

exe:
	/Applications/Mozart2.app/Contents/Resources/bin/ozengine Main.ozf

clean:
	rm *.ozf
