CHECKPOINT_DISABLE ?= 1
all: sift remnux dfir ubuntu-2404

sift:
	cd sift && packer build -force -var-file ../variables-sift.pkrvars.hcl sift.pkr.hcl

remnux:
	cd remnux && packer build -force -var-file ../variables-remnux.pkrvars.hcl remnux.pkr.hcl

dfir:
	cd dfir && packer build -force -var-file ../variables-sift.pkrvars.hcl dfir.pkr.hcl

ubuntu-2404:
	cd ubuntu-2404 && packer build -force -var-file ../variables-ubuntu-2404.pkrvars.hcl ubuntu-2404.pkr.hcl

install:
	../bin/install.sh

dist-clean:
	rm -rf packer_cache

test:
	shellcheck -f checkstyle scripts/*.sh > checkstyle.out || true
