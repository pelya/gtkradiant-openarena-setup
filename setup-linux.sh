#!/bin/sh

[ -e bspc/bspc ] || {
	[ -e bspc ] || git clone https://github.com/TTimo/bspc.git || exit 1
	cd bspc
	patch -p1 < ../bspc-32bit-build.patch || exit 1
	make -j4 || exit 1
	cd ..
}

[ -e gtkradiant/install/radiant.bin ] || {
	[ -e gtkradiant ] || git clone https://github.com/TTimo/GtkRadiant.git gtkradiant || exit 1
	cd gtkradiant
	scons config=release -j4 || exit 1
	ln -s ../../bspc-netcat install/bspc
	cd ..
}

[ -e openarena ] || {
	rm -f gtkradiant/install/games/q3.game
	mkdir -p gtkradiant/install/games
	echo '<?xml version="1.0" encoding="iso-8859-1" standalone="yes"?>'                               >> gtkradiant/install/games/q3.game
	echo '<game'                                                                                      >> gtkradiant/install/games/q3.game
	echo '  name="Quake III Arena and mods"'                                                          >> gtkradiant/install/games/q3.game
	echo '  enginepath_linux="'`pwd`/openarena'"'                                                     >> gtkradiant/install/games/q3.game
	echo '  gametools_linux="'`pwd`'/gtkradiant/install/installs/Q3Pack/game"'                        >> gtkradiant/install/games/q3.game
	echo '  prefix=".openarena"'                                                                      >> gtkradiant/install/games/q3.game
	echo '  basegame="baseoa"'                                                                        >> gtkradiant/install/games/q3.game
	echo '/>'                                                                                         >> gtkradiant/install/games/q3.game

	rm -f ~/.radiant/1.6.4
	mkdir -p ~/.radiant/1.6.4
	echo '<?xml version="1.0"?>'                             >> ~/.radiant/1.6.4/global.pref
	echo '<qpref version="1">'                               >> ~/.radiant/1.6.4/global.pref
	echo '  <epair name="gamefile">q3.game</epair>'          >> ~/.radiant/1.6.4/global.pref
	echo '  <epair name="autoload">true</epair>'             >> ~/.radiant/1.6.4/global.pref
	echo '  <epair name="log console">true</epair>'          >> ~/.radiant/1.6.4/global.pref
	echo '</qpref>'                                          >> ~/.radiant/1.6.4/global.pref

	[ -e openarena-0.8.8.zip ] || wget http://download.tuxfamily.org/openarena/rel/088/openarena-0.8.8.zip || exit 1
	unzip openarena-0.8.8.zip || exit 1
	mv -f openarena-0.8.8 openarena
	cp -f gtkradiant/install/installs/Q3Pack/install/baseq3/*.pk3 openarena/baseoa/
	ln -s baseoa openarena/baseq3
	cd openarena/baseoa
	#for f in *.pk3 ; do unzip -o $f ; done
	for f in *.pk3 ; do unzip -o $f scripts/shaderlist.txt ; done
	cd ../..
	mv -f openarena/baseoa/scripts/shaderlist.txt openarena/original-shaderlist.txt
	echo "" >> openarena/original-shaderlist.txt
	rm -f ~/.openarena/baseoa/scripts/shaderlist.txt
}

[ -e ~/.openarena/baseoa/scripts/shaderlist.txt ] || {
	[ -e z_oacmp-volume1-v3.pk3 ] || wget http://sourceforge.net/projects/libsdl-android/files/OpenArena/0.8.8/z_oacmp-volume1-v3.pk3 || exit 1
	mkdir -p ~/.openarena/baseoa
	unzip -d ~/.openarena/baseoa z_oacmp-volume1-v3.pk3
	mv ~/.openarena/baseoa/sources/maps/* ~/.openarena/baseoa/maps/
	rm -rf openarena/baseoa/scripts
	ln -s ~/.openarena/baseoa/scripts openarena/baseoa/scripts
	cp -f openarena/original-shaderlist.txt ~/.openarena/baseoa/scripts/shaderlist.txt
	( cd ~/.openarena/baseoa/scripts/ ; ls *.shader | sed 's/[.]shader$//g' >> shaderlist.txt )
	rm -rf openarena/baseoa/textures
	ln -s ~/.openarena/baseoa/textures openarena/baseoa/textures
	cp gtkradiant/install/installs/Q3Pack/install/baseq3/scripts/default_project.proj ~/.openarena/baseoa/scripts/
}
