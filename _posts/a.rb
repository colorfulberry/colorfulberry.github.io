[Unit]
Description=Puma HTTP Forking Server
After=network.target

[Service]
# Background process configuration (use with —daemon in ExecStart)
Type=simple
Environment="RAILS_ENV=production"
User=ec2-user

WorkingDirectory=/var/apps/prima_production/current/

ExecStart=/usr/local/rvm/wrappers/ruby-2.4.5@prima_production/bundle exec puma -C /var/apps/prima_production/shared/puma.rb

ExecStop=/usr/local/rvm/wrappers/ruby-2.4.5@prima_production/bundle exec pumactl -S /var/apps/prima_production/shared/tmp/pids/puma.state stop

PIDFile=/var/apps/prima_production/shared/tmp/pids/puma.pid

Restart=always
[Install]
WantedBy=multi-user.target
