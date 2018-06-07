DEPOT_TOOLS_PATH := $(shell realpath ./depot_tools)
export PATH := $(DEPOT_TOOLS_PATH):$(PATH)

.PHONY : build32 build64 pull clean

.DEFAULT_GOAL := build64

DIRS=depot_tools gyp Sandboxing_NaCl libjpeg-turbo NASM_NaCl mozilla-release ProcessSandbox libpng_nacl zlib_nacl rlbox-st-test rlbox_api

depot_tools :
	git clone https://chromium.googlesource.com/chromium/tools/depot_tools.git

gyp :
	sudo apt install python-setuptools
	git clone https://chromium.googlesource.com/external/gyp.git
	cd gyp && sudo python setup.py install

Sandboxing_NaCl :
	git clone https://github.com/shravanrn/Sandboxing_NaCl.git

libjpeg-turbo :
	sudo apt install autoconf libtool
	git clone https://github.com/shravanrn/libjpeg-turbo_nacltests.git libjpeg-turbo
	cd libjpeg-turbo && git checkout 1.4.x

libpng_nacl:
	git clone https://github.com/shravanrn/libpng_nacl.git libpng_nacl
	cd libpng_nacl && git checkout 1.6.31

zlib_nacl:
	git clone https://github.com/shravanrn/zlib_nacl.git zlib_nacl

NASM_NaCl :
	git clone https://github.com/shravanrn/NASM_NaCl.git

mozilla-release :
	git clone https://github.com/shravanrn/mozilla_firefox_nacl.git mozilla-release

ProcessSandbox :
	sudo apt install libc6-dev-i386 libseccomp-dev
	git clone https://bitbucket.org/cdisselkoen/sandbox-benchmarking ProcessSandbox

rlbox-st-test:
	git clone https://github.com/PLSysSec/rlbox-st-test.git

rlbox_api:
	git clone https://github.com/shravanrn/rlbox_api.git

build32: $(DIRS)
	cd NASM_NaCl && ./configure
	$(MAKE) -C NASM_NaCl
	$(MAKE) -C Sandboxing_NaCl buildopt32
	$(MAKE) -C libjpeg-turbo/builds build32  # just the builds, not the examples
	$(MAKE) -C ProcessSandbox all32
	$(MAKE) -C libjpeg-turbo/builds all32  # now the examples as well
	$(MAKE) -C zlib_nacl/builds build
	$(MAKE) -C libpng_nacl/builds build
	$(MAKE) -C mozilla-release/builds build32

build64: $(DIRS)
	cd NASM_NaCl && ./configure
	$(MAKE) -C NASM_NaCl
	$(MAKE) -C Sandboxing_NaCl buildopt64 buildopt32
	$(MAKE) -C libjpeg-turbo/builds build64  # just the builds, not the examples
	$(MAKE) -C ProcessSandbox all64
	$(MAKE) -C libjpeg-turbo/builds all64  # now the examples as well
	$(MAKE) -C zlib_nacl/builds build
	$(MAKE) -C libpng_nacl/builds build
	$(MAKE) -C mozilla-release/builds build64

pull: $(DIRS)
	git pull
	cd Sandboxing_NaCl && git pull
	cd libjpeg-turbo && git pull
	cd zlib_nacl && git pull
	cd libpng_nacl && git pull
	cd mozilla-release && git pull
	cd ProcessSandbox && git pull
	cd NASM_NaCl && git pull
	cd rlbox-st-test && git pull
	cd rlbox_api && git pull

clean:
	-$(MAKE) -C Sandboxing_NaCl clean
	-$(MAKE) -C libjpeg-turbo/builds clean
	-$(MAKE) -C zlib_nacl/builds clean
	-$(MAKE) -C libpng_nacl/builds clean
	-$(MAKE) -C mozilla-release/builds clean
	-$(MAKE) -C ProcessSandbox clean
	-$(MAKE) -C NASM_NaCl clean
