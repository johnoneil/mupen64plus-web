# mupen64plus-web
Emscripten based web port of Mupen64plus N64 Emulator

# Building
If you have the Emscripten SDK installed (https://kripken.github.io/emscripten-site/docs/getting_started/downloads.html) you should be able to build via:
* ```make config=release```

Other roms can be build into web versions by placing the rom in the ```roms``` directory and running make as follows:
* ```make config=release INPUT_ROM=romname.z64```

Debug build config is also available (i.e. ```make config=debug ...```

# Running
Buiilding as above will use the demo game rom in the ```roms``` directory to generate javascript and html for a playable game in the ```games`` directory.
Serve this ```games`` directory via a web server, and open in a webgl enabled browser to play.
