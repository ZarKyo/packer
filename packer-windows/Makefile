CHECKPOINT_DISABLE ?= 1
all: winfor

winfor:
	cd winfor && packer build -force -var-file ../variables-winfor.pkrvars.hcl winfor.pkr.hcl

dist-clean:
	rm -rf packer_cache
