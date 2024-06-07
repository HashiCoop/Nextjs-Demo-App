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