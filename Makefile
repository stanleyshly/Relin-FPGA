# Forward build commands while keeping source-relative paths in HBM_interface.
.DEFAULT_GOAL := help
.PHONY: help build build-status host run run_prepare sim clean open_vivado_project create_project check_project continue-dcp continue-bit aved-python
help build build-status host run run_prepare sim clean open_vivado_project create_project check_project continue-dcp continue-bit aved-python:
	+$(MAKE) -C HBM_interface $@
