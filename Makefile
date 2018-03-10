# build native or web version of mupen64-plus
# to build web version: 'make web'
# to build native version: 'make native'
# to run web version: 'make run-web'
# to run native version: 'make run-native'
GAMES_DIR ?= ./games
ROM_DIR_NAME ?= roms
ROMS_DIR ?= $(abspath $(ROM_DIR_NAME))
INPUT_ROM ?= m64p_test_rom.v64
PLATFORM ?= web
BIN_DIR ?= $(abspath ./bin/$(PLATFORM))
SCRIPTS_DIR := ./scripts

TARGET_ROM = $(BIN_DIR)/roms/$(INPUT_ROM)
SOURCE_ROM = $(ROMS_DIR)/$(INPUT_ROM)

POSTFIX ?= -web
SO_EXTENSION ?= .js

UI ?= mupen64plus-ui-console
UI_DIR = $(UI)/projects/unix

CORE ?= mupen64plus-core
CORE_DIR = $(CORE)/projects/unix
CORE_LIB = $(CORE)$(POSTFIX)$(SO_EXTENSION)

AUDIO ?= mupen64plus-audio-web
AUDIO_DIR = $(AUDIO)/projects/unix/
AUDIO_LIB = $(AUDIO).js

NATIVE_AUDIO := mupen64plus-audio-sdl
NATIVE_AUDIO_DIR = $(NATIVE_AUDIO)/projects/unix
NATIVE_AUDIO_LIB = $(NATIVE_AUDIO).so

VIDEO ?= mupen64plus-video-glide64mk2
VIDEO_DIR = $(VIDEO)/projects/unix
VIDEO_LIB = $(VIDEO)$(POSTFIX)$(SO_EXTENSION)

RICE = mupen64plus-video-rice
RICE_VIDEO_LIB = $(RICE)$(POSTFIX)$(SO_EXTENSION)
RICE_VIDEO_DIR = $(RICE)/projects/unix/

INPUT ?= mupen64plus-input-sdl
INPUT_DIR = $(INPUT)/projects/unix
INPUT_LIB = $(INPUT)$(POSTFIX)$(SO_EXTENSION)

RSP ?= mupen64plus-rsp-hle
RSP_DIR = $(RSP)/projects/unix
RSP_LIB = $(RSP)$(POSTFIX)$(SO_EXTENSION)

TARGET ?= mupen64plus
PLUGINS_DIR = $(BIN_DIR)/plugins
OUTPUT_ROMS_DIR = $(BIN_DIR)/$(ROMS_DIR)
TARGET_LIB = $(TARGET)$(POSTFIX)$(SO_EXTENSION)
TARGET_HTML ?= index.html
INDEX_TEMPLATE = $(abspath $(SCRIPTS_DIR)/index.template.html)
MODULE_JS = module.js

BOOST_DIR := ./boost_1_59_0
BOOST_LIB_DIR = $(abspath $(BOOST_DIR)/stage/lib)
BOOST_FILESYSTEM_LIB = $(BOOST_LIB_DIR)/libboost_filesystem.a


PLUGINS = $(PLUGINS_DIR)/$(CORE_LIB) \
	$(PLUGINS_DIR)/$(AUDIO_LIB) \
	$(PLUGINS_DIR)/$(VIDEO_LIB) \
	$(PLUGINS_DIR)/$(INPUT_LIB) \
	$(PLUGINS_DIR)/$(RSP_LIB) \
	$(PLUGINS_DIR)/$(RICE_VIDEO_LIB)

INPUT_FILES = \
	$(BIN_DIR)/data/InputAutoCfg.ini \
	$(BIN_DIR)/data/Glide64mk2.ini \
	$(BIN_DIR)/data/RiceVideoLinux.ini \
	$(BIN_DIR)/stats.min.js \
	$(BIN_DIR)/data/mupen64plus.cfg \
	$(BIN_DIR)/data/mupen64plus.ini \
	$(BIN_DIR)/data/mupencheat.txt \
	$(INDEX_TEMPLATE) \
	$(BIN_DIR)/$(MODULE_JS) \

OPT_LEVEL = -O0
DEBUG_LEVEL = -g2

#MEMORY = 524288
MEMORY = 402653184
#MEMORY = 268435456
#MEMORY = 134217728

NATIVE_BIN := bin
NATIVE_PLUGINS := \
		$(NATIVE_BIN)/libmupen64plus.so.2 \
		$(NATIVE_BIN)/mupen64plus-input-sdl.so \
		$(NATIVE_BIN)/mupen64plus-rsp-hle.so \
		$(NATIVE_BIN)/mupen64plus-video-glide64mk2.so \
		$(NATIVE_BIN)/mupen64plus-video-rice.so \
		$(NATIVE_BIN)/mupen64plus-audio-sdl.so \

NATIVE_EXE := $(NATIVE_BIN)/mupen64plus
NATIVE_DEPS := $(NATIVE_PLUGINS) $(NATIVE_EXE)

WEB_DEPS := $(BIN_DIR)/$(TARGET_HTML) $(TARGET_ROM)

ALL_DEPS := $(WEB_DEPS)
ifeq ($(PLATFORM), native)
		ALL_DEPS := $(NATIVE_DEPS)
endif

all: $(ALL_DEPS)

.FORCE:

native: .FORCE
	$(MAKE) PLATFORM=native

web: .FORCE
	$(MAKE) PLATFORM=web

RICE_CFG_DIR := cfg/rice
GLIDE_CFG_DIR := cfg/glide
DATA_DIR := mupen64plus-core/data

CFG_DIR := $(GLIDE_CFG_DIR)
ifdef rice
		CFG_DIR := $(RICE_CFG_DIR)
endif

NATIVE_ARGS ?=

run-native: native
	./$(NATIVE_EXE) $(INPUT_ROM) \
			$(NATIVE_ARGS) \
			--corelib $(NATIVE_BIN)/libmupen64plus.so.2 \
			--configdir $(CFG_DIR) \
			--datadir $(CFG_DIR) \
			$(ROMS_DIR)/$(INPUT_ROM)


# use browser=chromium arg (or chrome etc) to test in broser
# e.g. 'make run-web browser=chromium'
BROWSER ?= firefox
ifeq ($(browser), chromium)
		BROWSER := $(shell which chromium-browser)
endif
EMRUN ?= --emrun

FORWARDSLASH ?= %2F
run-web: web
	emrun $ --browser $(BROWSER) $(BIN_DIR)/index.html --nospeedlimit  $(FORWARDSLASH)$(ROM_DIR_NAME)$(FORWARDSLASH)$(INPUT_ROM)

run: run-web

clean-native:
	cd mupen64plus-ui-console/projects/unix && $(MAKE) clean
	cd $(CORE_DIR) && $(MAKE) clean
	cd $(INPUT_DIR) && $(MAKE) clean
	cd $(RSP_DIR) && $(MAKE) clean
	cd $(VIDEO_DIR) && $(MAKE) clean
	cd $(RICE_VIDEO_DIR) && $(MAKE) clean
	cd $(AUDIO_DIR) && $(MAKE) clean

clean: clean-web clean-native

rebuild: clean all

$(NATIVE_BIN):
	mkdir $(NATIVE_BIN)

$(NATIVE_EXE): $(NATIVE_BIN) mupen64plus-ui-console/projects/unix/mupen64plus
	cp mupen64plus-ui-console/projects/unix/mupen64plus $@

mupen64plus-ui-console/projects/unix/mupen64plus:
	cd mupen64plus-ui-console/projects/unix && $(MAKE) all

$(NATIVE_BIN)/libmupen64plus.so.2: $(NATIVE_BIN) $(CORE_DIR)/libmupen64plus.so.2.0.0
	cp $(CORE_DIR)/libmupen64plus.so.2.0.0 $@

$(CORE_DIR)/libmupen64plus.so.2.0.0:
	cd $(CORE_DIR) && $(MAKE) all

$(NATIVE_BIN)/mupen64plus-input-sdl.so: $(NATIVE_BIN) $(INPUT_DIR)/mupen64plus-input-sdl.so
	cp $(INPUT_DIR)/mupen64plus-input-sdl.so $@

$(INPUT_DIR)/mupen64plus-input-sdl.so:
	cd $(INPUT_DIR) && $(MAKE) all

$(RSP_DIR)/mupen64plus-rsp-hle.so:
	cd $(RSP_DIR) && $(MAKE) all

$(NATIVE_BIN)/mupen64plus-rsp-hle.so: $(NATIVE_BIN) $(RSP_DIR)/mupen64plus-rsp-hle.so
	cp $(RSP_DIR)/mupen64plus-rsp-hle.so $@

$(VIDEO_DIR)/mupen64plus-video-glide64mk2.so:
	cd $(VIDEO_DIR) && $(MAKE) all

$(NATIVE_BIN)/mupen64plus-video-glide64mk2.so: $(NATIVE_BIN) $(VIDEO_DIR)/mupen64plus-video-glide64mk2.so
	cp $(VIDEO_DIR)/mupen64plus-video-glide64mk2.so $@

$(RICE_VIDEO_DIR)/mupen64plus-video-rice.so:
	cd $(RICE_VIDEO_DIR) && $(MAKE) all

$(NATIVE_BIN)/mupen64plus-video-rice.so: $(NATIVE_BIN) $(RICE_VIDEO_DIR)/mupen64plus-video-rice.so
	cp $(RICE_VIDEO_DIR)/mupen64plus-video-rice.so $@

$(NATIVE_AUDIO_DIR)/mupen64plus-audio-sdl.so:
	cd $(NATIVE_AUDIO_DIR) && $(MAKE) all

$(NATIVE_BIN)/mupen64plus-audio-sdl.so: $(NATIVE_BIN) $(NATIVE_AUDIO_DIR)/mupen64plus-audio-sdl.so
	cp $(NATIVE_AUDIO_DIR)/mupen64plus-audio-sdl.so $@


ifeq ($(config), debug)

OPT_LEVEL = -O0
DEBUG_LEVEL = -g2 -s ASSERTIONS=1

else

OPT_LEVEL = -O3 -s AGGRESSIVE_VARIABLE_ELIMINATION=1

endif

#$(PLUGINS_DIR)/%.js : %/projects/unix/%.js
#	cp "$<" "$@"

# libmupen64plus.so.2 deviates from standard naming
$(PLUGINS_DIR)/$(CORE_LIB) : $(CORE_DIR)/$(CORE_LIB)
	mkdir -p $(PLUGINS_DIR)
	cp "$<" "$@"

$(PLUGINS_DIR)/$(AUDIO_LIB) : $(AUDIO_DIR)/$(AUDIO_LIB)
	mkdir -p $(PLUGINS_DIR)
	cp "$<" "$@"

$(PLUGINS_DIR)/$(VIDEO_LIB) : $(VIDEO_DIR)/$(VIDEO_LIB)
	mkdir -p $(PLUGINS_DIR)
	cp "$<" "$@"

$(PLUGINS_DIR)/$(RICE_VIDEO_LIB) : $(RICE_VIDEO_DIR)/$(RICE_VIDEO_LIB)
		mkdir -p $(PLUGINS_DIR)
		cp -f "$<" "$@"

$(PLUGINS_DIR)/$(INPUT_LIB) : $(INPUT_DIR)/$(INPUT_LIB)
	mkdir -p $(PLUGINS_DIR)
	cp "$<" "$@"

$(PLUGINS_DIR)/$(RSP_LIB) : $(RSP_DIR)/$(RSP_LIB)
	mkdir -p $(PLUGINS_DIR)
	cp "$<" "$@"

$(TARGET_ROM): $(SOURCE_ROM)
	mkdir -p $(@D)
	rm -f $(OUTPUT_ROMS_DIR)/*
	cp "$<" "$@"

$(BIN_DIR) :
	#Creating output directory
	mkdir -p $(BIN_DIR)

$(BOOST_FILESYSTEM_LIB):
	cd $(BOOST_DIR) && ./bootstrap.sh && ./b2 --test-config=user-config.jam toolset=emscripten link=static

$(RICE_VIDEO_DIR)/$(RICE_VIDEO_LIB):
	cd $(RICE_VIDEO_DIR) && \
			emmake $(MAKE) \
			CROSS_COMPILE="" \
			POSTFIX=-web\
			UNAME=Linux \
			USE_FRAMESKIPPER=1 \
			EMSCRIPTEN=1 \
			SO_EXTENSION="js" \
			USE_GLES=1 NO_ASM=1 \
			ZLIB_CFLAGS="-s USE_ZLIB=1" \
			PKG_CONFIG="" \
			LIBPNG_CFLAGS="-s USE_LIBPNG=1" \
			SDL_CFLAGS="-s USE_SDL=2" \
			FREETYPE2_CFLAGS="-s USE_FREETYPE=1" \
			GL_CFLAGS="" \
			GLU_CFLAGS="" \
			V=1 \
			LOADLIBES="../../../boost_1_59_0/stage/lib/libboost_filesystem.a ../../../boost_1_59_0/stage/lib/libboost_system.a" \
			OPTFLAGS="$(OPT_LEVEL) $(DEBUG_LEVEL) -s FULL_ES2=1 -s 'EXTRA_EXPORTED_RUNTIME_METHODS=[\"ccall\", \"cwrap\"]' -s SIDE_MODULE=1 -I../../../boost_1_59_0 -DEMSCRIPTEN=1 -DNO_FILTER_THREAD=1 -DUSE_FRAMESKIPPER=1" \
			all

# input files helpers
$(BIN_DIR)/data/InputAutoCfg.ini: $(CFG_DIR)/InputAutoCfg.ini
	mkdir -p $(@D)
	cp $< $@

$(BIN_DIR)/data/Glide64mk2.ini: $(GLIDE_CFG_DIR)/Glide64mk2.ini
	mkdir -p $(@D)
	cp $< $@

$(BIN_DIR)/data/RiceVideoLinux.ini: $(RICE_CFG_DIR)/RiceVideoLinux.ini
	mkdir -p $(@D)
	cp $< $@

$(BIN_DIR)/$(MODULE_JS): $(SCRIPTS_DIR)/$(MODULE_JS)
	mkdir -p $(@D)
	cp $< $@

$(BIN_DIR)/stats.min.js: $(SCRIPTS_DIR)/stats.min.js
	cp $< $@

$(BIN_DIR)/data/mupen64plus.cfg: $(CFG_DIR)/mupen64plus-web.cfg .FORCE
	cp $< $@

$(BIN_DIR)/data/mupen64plus.ini: $(CFG_DIR)/mupen64plus.ini .FORCE
	cp $< $@

$(BIN_DIR)/data/mupencheat.txt: $(CFG_DIR)/mupencheat.txt
	cp $< $@

$(BIN_DIR)/$(TARGET_HTML): $(INDEX_TEMPLATE) $(PLUGINS) $(INPUT_FILES) Makefile
	@mkdir -p $(BIN_DIR)
	rm -f $@
	# building UI (program entry point)
	cd $(UI_DIR) && \
			EMCC_FORCE_STDLIBS=1 emmake make \
			POSTFIX=-web \
			TARGET=$(BIN_DIR)/$(TARGET_HTML) \
			UNAME=Linux \
			EMSCRIPTEN=1 \
			EXEEXT=".html" \
			USE_GLES=1 NO_ASM=1 \
			ZLIB_CFLAGS="-s USE_ZLIB=1" \
			PKG_CONFIG="" \
			LIBPNG_CFLAGS="-s USE_LIBPNG=1" \
			SDL_CFLAGS="-s USE_SDL=2" \
			FREETYPE2_CFLAGS="-s USE_FREETYPE=1" \
			GL_CFLAGS="" \
			GLU_CFLAGS="" \
			V=1 \
			OPTFLAGS="$(OPT_LEVEL) $(DEBUG_LEVEL) -s MAIN_MODULE=1 \
			--preload-file $(BIN_DIR)/plugins@plugins \
			--preload-file $(BIN_DIR)/data@data  \
			--shell-file $(INDEX_TEMPLATE) \
			-s TOTAL_MEMORY=$(MEMORY) \
			-s USE_ZLIB=1 \
			-s USE_SDL=2 \
			-s 'EXTRA_EXPORTED_RUNTIME_METHODS=[\"ccall\", \"cwrap\"]' \
			-s USE_LIBPNG=1 \
			-s FULL_ES2=1 \
			-DEMSCRIPTEN=1 -DINPUT_ROM=$(INPUT_ROM) $(EMRUN)" \
			all

$(CORE_DIR)/$(CORE_LIB) :
	cd $(CORE_DIR) && \
	emmake make \
		POSTFIX=-web \
		UNAME=Linux \
		EMSCRIPTEN=1 \
		TARGET="$(CORE_LIB)" \
		SONAME="" \
		USE_GLES=1 NO_ASM=1 \
		ZLIB_CFLAGS="-s USE_ZLIB=1" \
		PKG_CONFIG="" \
		LIBPNG_CFLAGS="-s USE_LIBPNG=1" \
		SDL_CFLAGS="-s USE_SDL=2" \
		FREETYPE2_CFLAGS="-s USE_FREETYPE=1" \
		GL_CFLAGS="" \
		GLU_CFLAGS="" \
		V=1 \
		OPTFLAGS="$(OPT_LEVEL) $(DEBUG_LEVEL) -s SIDE_MODULE=1 -s 'EXTRA_EXPORTED_RUNTIME_METHODS=[\"ccall\", \"cwrap\"]' -DEMSCRIPTEN=1 -DONSCREEN_FPS=1" \
		all

$(AUDIO_DIR)/$(AUDIO_LIB) :
	cd $(AUDIO_DIR) && \
		emmake make \
		POSTFIX=-web \
		UNAME="Linux" \
		EMSCRIPTEN=1 \
		NO_SRC=1 \
		NO_SPEEX=1 \
		NO_OSS=1 \
		SO_EXTENSION="js" \
		USE_GLES=1 NO_ASM=1 \
		ZLIB_CFLAGS="-s USE_ZLIB=1" \
		PKG_CONFIG="" \
		LIBPNG_CFLAGS="-s USE_LIBPNG=1" \
		SDL_CFLAGS="-s USE_SDL=2" \
		FREETYPE2_CFLAGS="-s USE_FREETYPE=1" \
		GL_CFLAGS="" \
		GLU_CFLAGS="" \
		V=1 \
		OPTFLAGS="$(OPT_LEVEL) $(DEBUG_LEVEL) -s SIDE_MODULE=1 -s 'EXTRA_EXPORTED_RUNTIME_METHODS=[\"ccall\", \"cwrap\"]' -DEMSCRIPTEN=1 -DNO_FILTER_THREAD=1" \
		all

$(VIDEO_DIR)/$(VIDEO_LIB) : $(BOOST_FILESYSTEM_LIB)
	cd $(VIDEO_DIR) && \
	emmake make \
		POSTFIX=-web \
		USE_FRAMESKIPPER=1 \
		EMSCRIPTEN=1 \
		SO_EXTENSION="js" \
		USE_GLES=1 NO_ASM=1 \
		ZLIB_CFLAGS="-s USE_ZLIB=1" \
		PKG_CONFIG="" \
		LIBPNG_CFLAGS="-s USE_LIBPNG=1" \
		SDL_CFLAGS="-s USE_SDL=2" \
		FREETYPE2_CFLAGS="-s USE_FREETYPE=1" \
		GL_CFLAGS="" \
		GLU_CFLAGS="" \
		V=1 \
		LOADLIBES="../../../boost_1_59_0/stage/lib/libboost_filesystem.a ../../../boost_1_59_0/stage/lib/libboost_system.a" \
		OPTFLAGS="$(OPT_LEVEL) $(DEBUG_LEVEL) -s SIDE_MODULE=1 -s 'EXTRA_EXPORTED_RUNTIME_METHODS=[\"ccall\", \"cwrap\"]' -DUSE_FRAMESKIPPER=1\
		-I../../../boost_1_59_0 \
		-DEMSCRIPTEN=1 -DNO_FILTER_THREAD=1" \
		all

$(INPUT_DIR)/$(INPUT_LIB) : $(BOOST_FILESYSTEM_LIB)
	cd $(INPUT_DIR) && \
	emmake make \
		POSTFIX=-web \
		UNAME="Linux" \
		EMSCRIPTEN=1 \
		SO_EXTENSION="js" \
		USE_GLES=1 NO_ASM=1 \
		ZLIB_CFLAGS="-s USE_ZLIB=1" \
		PKG_CONFIG="" \
		LIBPNG_CFLAGS="-s USE_LIBPNG=1" \
		SDL_CFLAGS="-s USE_SDL=2" \
		FREETYPE2_CFLAGS="-s USE_FREETYPE=1" \
		GL_CFLAGS="" \
		GLU_CFLAGS="" \
		V=1 \
		OPTFLAGS="$(OPT_LEVEL) $(DEBUG_LEVEL) -s SIDE_MODULE=1 -I../../../boost_1_59_0 -s 'EXTRA_EXPORTED_RUNTIME_METHODS=[\"ccall\", \"cwrap\"]' -DEMSCRIPTEN=1 -DNO_FILTER_THREAD=1" \
		all

$(RSP_DIR)/$(RSP_LIB) :
	cd $(RSP_DIR)&& \
	emmake make \
		POSTFIX=-web \
		UNAME=Linux \
		EMSCRIPTEN=1 \
		SO_EXTENSION="js" \
		USE_GLES=1 NO_ASM=1 NO_OSS=1 NO_SRC=1 NO_SPEEX=1\
		ZLIB_CFLAGS="-s USE_ZLIB=1" \
		PKG_CONFIG="" \
		LIBPNG_CFLAGS="-s USE_LIBPNG=1" \
		SDL_CFLAGS="-s USE_SDL=2" \
		FREETYPE2_CFLAGS="-s USE_FREETYPE=1" \
		GL_CFLAGS="" \
		GLU_CFLAGS="" \
		V=1 \
		OPTFLAGS="$(OPT_LEVEL) $(DEBUG_LEVEL) -s SIDE_MODULE=1  -s 'EXTRA_EXPORTED_RUNTIME_METHODS=[\"ccall\", \"cwrap\"]' -DEMSCRIPTEN=1 -DVIDEO_HLE_ALLOWED=1" \
		all


clean-web:
	rm -fr $(BIN_DIR)
	rm -f $(CORE_DIR)/$(CORE_LIB)
	rm -fr $(CORE_DIR)/_obj$(POSTFIX)
	rm -f $(AUDIO_DIR)/$(AUDIO_LIB)
	rm -fr $(AUDIO_DIR)/_obj$(POSTFIX)
	rm -f $(VIDEO_DIR)/$(VIDEO_LIB)
	rm -fr $(VIDEO_DIR)/_obj$(POSTFIX)
	rm -f $(INPUT_DIR)/$(INPUT_LIB)
	rm -fr $(INPUT_DIR)/_obj$(POSTFIX)
	rm -f $(RSP_DIR)/$(RSP_LIB)
	rm -fr $(RSP_DIR)/_obj$(POSTFIX)
	rm -f $(RICE_VIDEO_DIR)/$(RICE_VIDEO_LIB)
	rm -fr $(RICE_VIDEO_DIR)/_obj$(POSTFIX)
