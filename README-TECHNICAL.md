# Technical Guide: Understanding the Docker LAMP Environment

This document provides a more detailed explanation of the Docker environment used in this project.

# What is LAMP?

LAMP stands for:

- Linux
- Apache
- MySQL
- PHP

In this project, Docker provides isolated containers that run these services.

# What is Docker?

Docker is a containerization platform that packages software and its dependencies into containers.

Benefits:

- Consistent environments
- Easy setup
- Easy distribution
- Easy reset and cleanup

# Understanding Docker Compose

This project uses three containers:

- lamp-web (Apache + PHP)
- lamp-db (MySQL)
- lamp-pma (phpMyAdmin)

Docker Compose manages all of them together.

# Port Mapping

Apache:

```yaml
ports:
  - "80:80"
```

MySQL:

```yaml
ports:
  - "13306:3306"
```

phpMyAdmin:

```yaml
ports:
  - "8080:80"
```

# Why MySQL Uses Port 13306

Many Windows systems reserve or already use port 3306. Using port 13306 avoids conflicts while still allowing MySQL Workbench connections.

Workbench settings:

```text
Host: localhost
Port: 13306
Username: root
Password: rootpassword
```

# The Dockerfile

```dockerfile
FROM php:8.3-apache
RUN docker-php-ext-install mysqli pdo_mysql
RUN a2enmod rewrite
```

This image includes:

- Apache
- PHP 8.3
- mysqli
- pdo_mysql
- mod_rewrite

# Volumes

The project uses volumes to persist data.

```yaml
- mysql_data:/var/lib/mysql
```

This allows MySQL data to survive container restarts.

Website files are mapped with:

```yaml
- ./www:/var/www/html
```

# How PHP Connects to MySQL

```php
$conn = new mysqli(
    "db",
    "appuser",
    "apppassword",
    "appdb"
);
```

The hostname is `db` because Docker automatically creates internal networking between services.

# Database Initialization

Files inside:

```text
initdb/
```

are executed automatically the first time MySQL creates the database.

The sample project creates a contacts table and inserts several records.

Important: initialization scripts only run when the database volume is first created.

# Resetting the Database

To completely rebuild the environment:

```bash
docker compose down -v
docker compose up -d --build
```

Warning: this deletes all database data.

# Useful Commands

View containers:

```bash
docker ps
```

View logs:

```bash
docker compose logs
```

View database logs:

```bash
docker compose logs db
```

Restart services:

```bash
docker compose restart
```

# Troubleshooting

## Connection Refused

Possible causes:

- MySQL is still starting.
- The database container is not running.
- Credentials are incorrect.

## Table Doesn't Exist

Possible causes:

- Initialization scripts did not run.
- Existing database volume was reused.

Fix:

```bash
docker compose down -v
docker compose up -d --build
```

## Port Already In Use

Choose a different host port.

Example:

```yaml
13306:3306
```

# Concepts Demonstrated

This project demonstrates:

- Docker
- Docker Compose
- Apache
- PHP
- MySQL
- phpMyAdmin
- Container networking
- Volumes
- Port mapping
- Database initialization scripts
- PHP database connectivity

These concepts provide a foundation for building database-driven web applications.
