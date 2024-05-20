#! /usr/bin/env bash

# Mac aliases

#####################################################
# If not running interactively, skip remaining code #
#####################################################
[[ $- != *i* ]] && return

alias ele-db-select="go run \$HOME/Desktop/scripts/db-select/main.go"
alias .i="cd \$DOTFILE_PATH"

alias pdfret="echo return \&bytes.Buffer\{\}, nil"
alias qhub="psql -U postgres -d hub -c"
alias qhubtest="psql -U postgres -d hub_test -c"
alias qmember="psql -U postgres -d member -c"
alias qmembertest="psql -U postgres -d member_test -c"
alias sqlqa="echo renamed to qahub and qamember"
alias qahub="PGPASSWORD=\$(gcloud auth print-access-token) psql -U thom.ribeiro@eleanorhealth.com -d hub -h /home/vacation/.eleanor_sql_sockets/ele-qa-436057:us-east1:eleanor-postgres"
alias qamember="PGPASSWORD=\$(gcloud auth print-access-token) psql -U thom.ribeiro@eleanorhealth.com -d member -h /home/vacation/.eleanor_sql_sockets/ele-qa-436057:us-east1:eleanor-postgres"
alias kb="kubectl"
alias deploy="make release ENV=prod"
alias tableplus="LD_LIBRARY_PATH=/opt/tableplus/lib tableplus"
alias golint="golangci-lint run --timeout 20s --tests=false"
alias gen='find . -name "mock_*" -exec rm -f {} \; && godotenv -f .env go generate ./...'
alias golint="golangci-lint run --timeout 20s --tests=false"
alias ehvpn="gcloud alpha cloud-shell ssh --project=ele-qa-436057 --authorize-session -- -D 31337 -CNq; echo configure firefox to use SOCKS proxy v5 on port 31337"
alias chromevpn='/Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome --proxy-server="socks5://localhost:31337"'
alias act="act --container-architecture linux/amd64"
