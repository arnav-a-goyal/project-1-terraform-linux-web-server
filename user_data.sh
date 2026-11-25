#!/bin/bash
set -euxo pipefail

# Save EC2 initialization logs
exec > /var/log/user-data.log 2>&1

export DEBIAN_FRONTEND=noninteractive

# Update Ubuntu packages
apt-get update

# Install Apache
apt-get install -y apache2

# Create the website
cat > /var/www/html/index.html <<'HTML'
<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport"
          content="width=device-width, initial-scale=1.0">

    <title>AWS EC2 Web Server</title>

    
</head>

<body>

    <main>
        <h1>AWS EC2 Web Server</h1>

        <p class="success">
            Apache Web Server Successfully Deployed!
        </p>

        <p>
            This page is hosted on an Ubuntu EC2 instance.
        </p>

        <p>
            Infrastructure created using Terraform.
        </p>

        <p>
            Apache installed automatically using Bash.
        </p>

        <p>
            Project 1: AWS Cloud Infrastructure Automation
        </p>
    </main>

</body>
</html>
HTML

# Enable and start Apache
systemctl enable --now apache2

# Verify Apache
systemctl is-active --quiet apache2

echo "Apache installation completed successfully."
