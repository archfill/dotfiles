all: init

init:
	bash ./bin/init.sh

termux-setup:
	bash ./bin/termux/init.sh

neovim-install:
	bash ./bin/linux/apps/neovim_install.sh

neovim-uninstall:
	bash ./bin/linux/apps/neovim_uninstall.sh
