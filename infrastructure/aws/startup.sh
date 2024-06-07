#!/bin/bash

echo '
[Unit]
Description="HashiCorp Vault - Agent"
Documentation=https://www.vaultproject.io/docs/
Requires=network-online.target
After=network-online.target
ConditionFileNotEmpty=/etc/vault.d/vault.hcl
StartLimitIntervalSec=60
StartLimitBurst=3
Wants=consul.service

[Service]
EnvironmentFile=/etc/vault.d/vault.env
User=vault
Group=vault
ProtectSystem=full
ProtectHome=read-only
PrivateDevices=yes
SecureBits=keep-caps
AmbientCapabilities=CAP_IPC_LOCK
CapabilityBoundingSet=CAP_SYSLOG CAP_IPC_LOCK
NoNewPrivileges=yes
ExecStart=/usr/bin/vault agent -config=/etc/vault.d/config.hcl
WorkingDirectory=/var/tmp/
ExecReload=/bin/kill --signal HUP $MAINPID
KillMode=process
KillSignal=SIGINT
Restart=on-failure
RestartSec=5
TimeoutStopSec=30
StartLimitIntervalSec=60
StartLimitBurst=3
LimitNOFILE=65536
LimitMEMLOCK=infinity

[Install]
WantedBy=multi-user.target
' > /lib/systemd/system/vault-agent.service

echo '
vault {
  address = "https://vault-cluster-public-vault-fcbc1a73.d087f7bf.z1.hashicorp.cloud:8200/"
  namespace = "admin"
}

auto_auth {
  method "aws" {
    config = {
        type= "iam"
        role = "nextjs-demo-app"
    }
  }
}

template_config {
   static_secret_render_interval = "5m"
   exit_on_retry_failure         = true
}

env_template "POSTGRES_URL" {
   contents = "{{ with secret \"postgres/creds/dynamic-role\" }}postgresql://{{ .Data.username }}:{{ .Data.password }}@nextjs-test-db.crkbohspa2nk.us-west-2.rds.amazonaws.com:5432/postgres{{ end }}"
   error_on_missing_key = true
}

exec {
   command                   = ["docker", "run" , "-p", "80:3000", "-e", "POSTGRES_URL", "hashicoop/nextjs-demo-app"]
   restart_on_secret_changes = "always"
   restart_stop_signal       = "SIGTERM"
}
' > /etc/vault.d/config.hcl

sudo chmod 666 /var/run/docker.sock
systemctl start vault-agent 