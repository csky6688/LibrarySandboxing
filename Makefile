DEPOT_TOOLS_PATH := $(shell realpath ./depot_tools)
export PATH := $(DEPOT_TOOLS_PATH):$(PATH)

.NOTPARALLEL:
.PHONY : build_deps build pull clean

.DEFAULT_GOAL := build64

DIRS=build_deps depot_tools gyp Sandboxing_NaCl libjpeg-turbo NASM_NaCl mozilla-release mozilla_firefox_stock ProcessSandbox libpng_nacl zlib_nacl libtheora libvpx libvorbis rlbox-st-test rlbox_api web_resource_crawler node.bcrypt.js libmarkdown mod_markdown

builds_deps:
	sudo apt -y install python-setuptools autoconf libtool libseccomp-dev clang llvm cmake ninja-build npm nodejs cloc flex bison git libc6-dev-i386 texinfo gcc-arm-linux-gnueabihf build-essential libtool automake libmarkdown2-dev
	# Need for some of the nacl compile tools
	if [ ! -e "/usr/include/asm-generic" ]; then
		sudo ln -s /usr/include/asm-generic /usr/include/asm
	fi

depot_tools :
	git clone https://chromium.googlesource.com/chromium/tools/depot_tools.git $@

gyp :
	git clone https://chromium.googlesource.com/external/gyp.git $@
	cd gyp && sudo python setup.py install

Sandboxing_NaCl :
	git clone https://github.com/shravanrn/Sandboxing_NaCl.git $@

libjpeg-turbo :
	git clone https://github.com/shravanrn/libjpeg-turbo_nacltests.git $@
	cd libjpeg-turbo && git checkout 1.4.x

libpng_nacl:
	git clone https://github.com/shravanrn/libpng_nacl.git $@
	cd $@ && git checkout 1.6.31

zlib_nacl:
	git clone https://github.com/shravanrn/zlib_nacl.git $@

libtheora:
	git clone https://github.com/shravanrn/libtheora.git $@

libvpx:
	git clone https://github.com/shravanrn/libvpx.git $@
	cd $@ && git checkout ff_custom

libvorbis:
	git clone https://github.com/shravanrn/libvorbis.git $@

NASM_NaCl :
	git clone https://github.com/shravanrn/NASM_NaCl.git $@
	cd $@ && ./configure

mozilla-release :
	git clone https://github.com/shravanrn/mozilla_firefox_nacl.git $@

mozilla_firefox_stock:
	git clone https://github.com/shravanrn/mozilla_firefox_nacl.git $@
	cd $@ && git checkout vanilla

ProcessSandbox :
	git clone https://bitbucket.org/cdisselkoen/sandbox-benchmarking $@

rlbox-st-test:
	git clone https://github.com/PLSysSec/rlbox-st-test.git

rlbox_api:
	git clone https://github.com/shravanrn/rlbox_api.git

web_resource_crawler:
	git clone https://github.com/shravanrn/web_resource_crawler.git

node.bcrypt.js:
	git clone https://github.com/PLSysSec/node.bcrypt.js

libmarkdown:
	git clone https://github.com/PLSysSec/libmarkdown
	cd $@ && ./configure

mod_markdown:
	git clone https://github.com/plsyssec/mod_markdown

build: $(DIRS)
	$(MAKE) -C mozilla-release/builds inithasrun
	$(MAKE) -C NASM_NaCl
	$(MAKE) -C Sandboxing_NaCl buildopt64
	$(MAKE) -C libjpeg-turbo/builds build64  # just the builds, not the examples
	$(MAKE) -C zlib_nacl/builds build
	$(MAKE) -C libpng_nacl/builds build
	$(MAKE) -C libtheora/builds build
	$(MAKE) -C libvpx/builds build
	$(MAKE) -C libvorbis/builds build
	$(MAKE) -C ProcessSandbox all64
	$(MAKE) -C libjpeg-turbo/builds all64  # now the examples as well
	$(MAKE) -C mozilla-release/builds minbuild64
	$(MAKE) -C mozilla_firefox_stock/builds build
	$(MAKE) -C node.bcrypt.js build

pull: $(DIRS)
	git pull
	cd Sandboxing_NaCl && git pull
	cd libjpeg-turbo && git pull
	cd zlib_nacl && git pull
	cd libpng_nacl && git pull
	cd libtheora && git pull
	cd libvpx && git pull
	cd libvorbis && git pull
	cd mozilla-release && git pull
	cd ProcessSandbox && git pull
	cd NASM_NaCl && git pull && ./configure
	cd rlbox-st-test && git pull
	cd rlbox_api && git pull
	cd web_resource_crawler && git pull
	cd node.bcrypt.js && git pull
	cd libmarkdown && git pull && ./configure.sh
	cd mod_markdown && git pull

clean:
	-$(MAKE) -C Sandboxing_NaCl clean
	-$(MAKE) -C libjpeg-turbo/builds clean
	-$(MAKE) -C zlib_nacl/builds clean
	-$(MAKE) -C libpng_nacl/builds clean
	-$(MAKE) -C libtheora/builds clean
	-$(MAKE) -C libvpx/builds clean
	-$(MAKE) -C libvorbis/builds clean
	-$(MAKE) -C mozilla-release/builds clean
	-$(MAKE) -C mozilla_firefox_stock/builds clean
	-$(MAKE) -C ProcessSandbox clean
	-$(MAKE) -C NASM_NaCl clean
	-$(MAKE) -C node.bcrypt.js clean
	-$(MAKE) -C libmarkdown clean
	-$(MAKE) -C mod_markdown clean
