GODOT=~/dev/game-dev/godot/bin/godot.x11.opt.tools.64.llvm
EXPORT_DIR=export
GAME_DIR=game
LINUX=downtrodden.bin
WINDOWS=downtrodden.exe
MAC=downtrodden.zip
DATA=data.pck
MKDIR_P = mkdir -p

EXPORT_DIR_LINUX = $(EXPORT_DIR)/linux
EXPORT_DIR_WINDOWS = $(EXPORT_DIR)/windows
EXPORT_DIR_MAC = $(EXPORT_DIR)/mac

EXPORT_PATH_LINUX = $(EXPORT_DIR_LINUX)/$(LINUX)
EXPORT_PATH_WINDOWS = $(EXPORT_DIR_WINDOWS)/$(WINDOWS)
EXPORT_PATH_MAC = $(EXPORT_DIR_MAC)/$(MAC)

.PHONY: all
all: linux mac windows

.PHONY: linux
linux: $(EXPORT_PATH_LINUX)

.PHONY: mac
mac: $(EXPORT_PATH_MAC)

.PHONY: windows
windows: $(EXPORT_PATH_WINDOWS)

.PHONY: clean
clean:
	rm -rf export

$(EXPORT_PATH_LINUX): $(GAME_DIR)
	$(MKDIR_P) $(EXPORT_DIR_LINUX)
	$(GODOT) --path $(GAME_DIR) --export "linux-64" "../$(EXPORT_PATH_LINUX)"

$(EXPORT_PATH_MAC): $(GAME_DIR)
	$(MKDIR_P) $(EXPORT_DIR_MAC)
	$(GODOT) --path $(GAME_DIR) --export "mac-fat" "../$(EXPORT_PATH_MAC)"

$(EXPORT_PATH_WINDOWS): $(GAME_DIR)
	$(MKDIR_P) $(EXPORT_DIR_WINDOWS)
	$(GODOT) --path $(GAME_DIR) --export "win-64" "../$(EXPORT_PATH_WINDOWS)"
