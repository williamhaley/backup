build:
	go build -o .build/backup cmd/cli/main.go

install:
	install -m 0755 .build/backup /usr/local/bin/backup

test:
	go test ./...
