#!/bin/bash

set -euxo pipefail

# Save installation logs
exec > /var/log/user-data.log 2>&1

# Update Ubuntu package repository
apt-get update

# Install Apache
apt-get install -y apache2

# Create website
cat > /var/www/html/index.html <<'HTML'
<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <title>AWS EC2 Web Server</title>

    <style>
        body {
            font-family: Arial, sans-serif;
            background: #eef2f7;
            text-align: center;
            padding: 70px 20px;
        }

        .container {
            background: white;
            padding: 40px;
            border-radius: 12px;
            max-width: 650px;
            margin: auto;
            box-shadow: 0 4px 15px rgba(0,0,0,0.1);
        }

        h1 {
            color: #232f3e;
        }

        p {
            color: #555;
            font-size: 17px;
        }

        .success {
            color: green;
            font-weight: bold;
        }
    </style>
</head>

<body>

    <div class="container">

        <h1>AWS EC2 Web Server</h1>

        <p class="success">
            Apache Web Server Successfully Deployed!
        </p>

        <p>
            Hosted on an Ubuntu EC2 instance.
        </p>

        <p>
            Infrastructure created using Terraform.
        </p>

        <p>
            Apache installed automatically using Bash.
        </p>

        <p>
            Project: AWS Cloud Infrastructure Automation
        </p>

    </div>

</body>
</html>
HTML

# Enable and start Apache
systemctl enable apache2
systemctl restart apache2

# Verify service
systemctl is-active apache2

echo "Apache installation completed successfully"
