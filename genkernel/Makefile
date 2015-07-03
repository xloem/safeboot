OVERLAY_DIR=/root/safeboot
NEEDED=/bin/getfattr

FILES=$(OVERLAY_DIR)/init $(patsubst ..%,$(OVERLAY_DIR)%,$(wildcard ../scripts/*)) $(addprefix $(OVERLAY_DIR),$(NEEDED)) 
install: install_config install_files
	# Genkernel set up to build safeboot.  Add/adjust key material in $(OVERLAY_DIR)

install_config: genkernel.conf
	-if ! [ -e /etc/$<.bak ]; then mv /etc/$< /etc/$<.bak; fi
	cp -a $< /etc/$<

install_files: $(FILES)

$(OVERLAY_DIR)/bin/%: /bin/% /usr/share/genkernel/gen_initramfs.sh $(OVERLAY_DIR)
	. /usr/share/genkernel/gen_initramfs.sh; copy_binaries $(OVERLAY_DIR) $<
	[ -e $(OVERLAY_DIR)$< ]

$(OVERLAY_DIR)/init: init | $(OVERLAY_DIR)
	cp -a $< $@

$(OVERLAY_DIR)/scripts/%: ../scripts/% | $(OVERLAY_DIR)/scripts
	cp -a $< $@

$(OVERLAY_DIR) $(OVERLAY_DIR)/scripts:
	mkdir -p $@
