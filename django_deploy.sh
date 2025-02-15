#!/bin/bash

# Ensure script is run as root
if [ "$(id -u)" != "0" ]; then
    echo "This script must be run as root. Use sudo." 1>&2
    exit 1
fi

# User Input
read -p "Enter project name (e.g., myproject): " PROJECT_NAME
read -p "Enter GitHub repository URL: " GITHUB_URL
read -p "Enter your domain name (e.g., example.com): " DOMAIN
read -p "Enter server IP address: " SERVER_IP
read -p "Enter PostgreSQL database name: " DB_NAME
read -p "Enter PostgreSQL username: " DB_USER
read -sp "Enter PostgreSQL password: " DB_PASS
echo
read -sp "Enter Django secret key (leave empty to generate): " SECRET_KEY
echo
if [ -z "$SECRET_KEY" ]; then
    SECRET_KEY=$(openssl rand -base64 48)
    echo "Generated Secret Key: $SECRET_KEY"
fi
read -p "Enter email for Let's Encrypt SSL: " EMAIL

# Update System
apt-get update
apt-get upgrade -y

# Install Dependencies
apt-get install -y python3-pip python3-dev libpq-dev postgresql postgresql-contrib nginx curl git
apt-get install -y certbot python3-certbot-nginx

# Configure PostgreSQL
sudo -u postgres psql -c "CREATE DATABASE $DB_NAME;"
sudo -u postgres psql -c "CREATE USER $DB_USER WITH PASSWORD '$DB_PASS';"
sudo -u postgres psql -c "ALTER ROLE $DB_USER SET client_encoding TO 'utf8';"
sudo -u postgres psql -c "ALTER ROLE $DB_USER SET default_transaction_isolation TO 'read committed';"
sudo -u postgres psql -c "ALTER ROLE $DB_USER SET timezone TO 'UTC';"
sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE $DB_NAME TO $DB_USER;"

# Create Project Directory
mkdir -p /var/www/$PROJECT_NAME
chown -R $SUDO_USER:$SUDO_USER /var/www/$PROJECT_NAME

# Clone Repository
sudo -u $SUDO_USER git clone $GITHUB_URL /var/www/$PROJECT_NAME

# Create Virtual Environment
python3 -m venv /var/www/$PROJECT_NAME/venv
source /var/www/$PROJECT_NAME/venv/bin/activate
pip install -r /var/www/$PROJECT_NAME/requirements.txt
pip install psycopg2-binary gunicorn

# Configure Django Settings
SETTINGS_FILE="/var/www/$PROJECT_NAME/$PROJECT_NAME/settings.py"

# Database Configuration
sed -i "s/'ENGINE': 'django.db.backends.sqlite3'/'ENGINE': 'django.db.backends.postgresql'/" $SETTINGS_FILE
sed -i "s/'NAME': BASE_DIR \/ 'db.sqlite3'/'NAME': '$DB_NAME',\n        'USER': '$DB_USER',\n        'PASSWORD': '$DB_PASS',\n        'HOST': 'localhost',\n        'PORT': '5432'/" $SETTINGS_FILE

# Security Settings
sed -i "s/SECRET_KEY = .*/SECRET_KEY = '$SECRET_KEY'/" $SETTINGS_FILE
sed -i "s/DEBUG = True/DEBUG = False/" $SETTINGS_FILE
sed -i "s/ALLOWED_HOSTS = \[\]/ALLOWED_HOSTS = \['$DOMAIN', '$SERVER_IP'\]/" $SETTINGS_FILE

# Static Files
echo "STATIC_ROOT = os.path.join(BASE_DIR, 'static/')" >> $SETTINGS_FILE

# Database Migrations
sudo -u $SUDO_USER /var/www/$PROJECT_NAME/venv/bin/python /var/www/$PROJECT_NAME/manage.py collectstatic --noinput
sudo -u $SUDO_USER /var/www/$PROJECT_NAME/venv/bin/python /var/www/$PROJECT_NAME/manage.py migrate

# Gunicorn Service
cat > /etc/systemd/system/$PROJECT_NAME.service <<EOF
[Unit]
Description=gunicorn daemon for $PROJECT_NAME
After=network.target

[Service]
User=$SUDO_USER
Group=www-data
WorkingDirectory=/var/www/$PROJECT_NAME
ExecStart=/var/www/$PROJECT_NAME/venv/bin/gunicorn \\
    --access-logfile - \\
    --workers 3 \\
    --bind unix:/var/www/$PROJECT_NAME/$PROJECT_NAME.sock \\
    $PROJECT_NAME.wsgi:application

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl start $PROJECT_NAME
systemctl enable $PROJECT_NAME

# Nginx Configuration
cat > /etc/nginx/sites-available/$PROJECT_NAME <<EOF
server {
    listen 80;
    server_name $DOMAIN $SERVER_IP;

    location = /favicon.ico { access_log off; log_not_found off; }
    location /static/ {
        root /var/www/$PROJECT_NAME;
    }

    location / {
        include proxy_params;
        proxy_pass http://unix:/var/www/$PROJECT_NAME/$PROJECT_NAME.sock;
    }
}
EOF

ln -s /etc/nginx/sites-available/$PROJECT_NAME /etc/nginx/sites-enabled/
nginx -t && systemctl restart nginx

# SSL Certificate
certbot --nginx -d $DOMAIN --non-interactive --agree-tos -m $EMAIL

# Firewall
ufw allow 'Nginx Full'
ufw delete allow 'Nginx HTTP'

# Final Restart
systemctl restart $PROJECT_NAME
systemctl restart nginx

echo "Deployment complete! Visit https://$DOMAIN to verify."
