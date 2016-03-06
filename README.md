# mupen64plus-web
Emscripten based web port of Mupen64plus N64 Emulator

![demo image of mupen64plus in browser](https://raw.githubusercontent.com/johnoneil/mupen64plus-web/master/img/Screenshot%20from%202015-12-19%2016%3A02%3A03.png)

# Building
If you have the Emscripten SDK installed (https://kripken.github.io/emscripten-site/docs/getting_started/downloads.html) you should be able to build via:
* ```make config=release```

Other roms can be build into web versions by placing the rom in the ```roms``` directory and running make as follows:
* ```make config=release INPUT_ROM=romname.z64```

Debug build config is also available (i.e. ```make config=debug ...```

# Running
Buiilding as above will use the demo game rom in the ```roms``` directory to generate javascript and html for a playable game in the ```games`` directory.
Serve this directory via a web server, and open in a webgl enabled browser to play.

# Status
* Build scripts and project setup still primitive. Needs a new "UI" type module specifically for the web (not a port of the command line version).
* Recently made some changes which turned on the cached interpreter, greatly improving framerate. It's possible the dynamic recompiler may improve it further, but the demo rom now runs at solid 60 FPS in the browser. Most games seem to do a solid 30 FPS, which may be fine.
* Sound is still not optimal. Firefox and Chrome sound has both buffer underruns (at low framerates) and overruns (at high frame rates). Still for some games like SuperMario64 and Ocarina of time the sound is fairly good.
* Glade Mk2 plugin has z-fighting and performance issues. The newer port of the rice plugin seems to work better, but does not support quite as many games.

Still, in the light of those issues listed above I'm very pleased at how well many games play.
