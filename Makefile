all:
	curl -L -O https://github.com/Backblaze/B2_Command_Line_Tool/releases/latest/download/b2-linux

install:
	install -Dm 0755 b2-linux /usr/local/bin/backblaze-cli
	install -Dm 0755 backup.sh /usr/local/bin/backup.sh