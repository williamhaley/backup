build:
	go build -o .build/backup cmd/backup/main.go

install:
	install -m 0755 .build/backup /usr/local/bin/backup
	install -m 0755 backup-cron.sh /usr/local/bin/backup-cron.sh

uninstall:
	rm /usr/local/bin/backup
	rm /usr/local/bin/backup-cron.sh

test:
	go test ./...
