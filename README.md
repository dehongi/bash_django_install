# Bash Django Install

This repository contains a bash script to automate the deployment of a Django application on an Ubuntu server using PostgreSQL, Gunicorn, and Nginx. The script simplifies the setup process by handling dependency installation, database configuration, and server setup.

## Features

- Automates the deployment of Django projects on Ubuntu.
- Configures PostgreSQL as the database backend.
- Sets up Gunicorn as the application server.
- Configures Nginx as a reverse proxy.
- Secures the application with Let's Encrypt SSL.
- Handles user input for project-specific configurations.

## Prerequisites

- An Ubuntu server (tested on Ubuntu 20.04/22.04).
- A Django project hosted on a GitHub repository.
- A domain name pointed to your server's IP address.
- SSH access to the server with sudo privileges.

## Usage

### 1. Clone the Repository

Clone this repository to your local machine or directly to your server:

```bash
git clone https://github.com/dehongi/bash_django_install.git
cd bash_django_install
```

### 2. Make the Script Executable

Ensure the script is executable:

```bash
chmod +x deploy_django.sh
```

### 3. Run the Script

Execute the script with `sudo`:

```bash
sudo ./deploy_django.sh
```

The script will prompt you for the following information:

- **Project Name**: The name of your Django project (e.g., `myproject`).
- **GitHub Repository URL**: The URL of your Django project's GitHub repository.
- **Domain Name**: The domain name for your application (e.g., `example.com`).
- **Server IP Address**: The IP address of your server.
- **PostgreSQL Database Name**: The name of the PostgreSQL database.
- **PostgreSQL Username**: The username for the PostgreSQL database.
- **PostgreSQL Password**: The password for the PostgreSQL database.
- **Django Secret Key**: (Optional) Your Django secret key. If left empty, a secure key will be generated.
- **Email for Let's Encrypt**: Your email address for Let's Encrypt SSL certificate.

### 4. Follow the Prompts

The script will automatically:

1. Install required dependencies (Python, PostgreSQL, Nginx, etc.).
2. Configure PostgreSQL and create a database.
3. Clone your Django project from GitHub.
4. Set up a virtual environment and install dependencies.
5. Configure Django settings (database, secret key, allowed hosts, etc.).
6. Set up Gunicorn as a systemd service.
7. Configure Nginx as a reverse proxy.
8. Secure the application with Let's Encrypt SSL.
9. Restart services and finalize the setup.

### 5. Verify Deployment

Once the script completes, visit your domain (e.g., `https://example.com`) to verify the deployment.

---

## Customization

If your Django project has specific requirements or configurations, you may need to modify the script:

- **Environment Variables**: If your project uses environment variables for sensitive data, update the script to include them.
- **Static and Media Files**: Ensure your Django project is configured to serve static and media files correctly.
- **Additional Dependencies**: Add any additional dependencies to the `requirements.txt` file in your Django project.

---

## Example

Here’s an example of running the script:

```bash
$ sudo ./deploy_django.sh
Enter project name (e.g., myproject): myawesomeproject
Enter GitHub repository URL: https://github.com/username/myawesomeproject.git
Enter your domain name (e.g., example.com): myawesomeproject.com
Enter server IP address: 192.168.1.100
Enter PostgreSQL database name: myawesomeproject_db
Enter PostgreSQL username: myawesomeproject_user
Enter PostgreSQL password: ********
Enter Django secret key (leave empty to generate): 
Enter email for Let's Encrypt SSL: admin@myawesomeproject.com
```

---

## Contributing

Contributions are welcome! If you find any issues or have suggestions for improvements, please open an issue or submit a pull request.

---

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

---

## Acknowledgments

- Inspired by [Bastakiss's Django Deployment Guide](https://bastakiss.com/blog/django-6/deploy-django-on-ubuntu-using-postgresql-gunicorn-nginx-174).
- Thanks to the Django, PostgreSQL, Gunicorn, and Nginx communities for their excellent documentation.

---

## Support

If you encounter any issues or have questions, feel free to open an issue in this repository.

---

Enjoy deploying your Django projects with ease! 🚀

---
