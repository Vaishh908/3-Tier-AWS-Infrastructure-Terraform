# Web Tier

This directory contains the public-facing web-tier files.

- `index.html` provides the registration page.
- `nginx.conf` configures Nginx and forwards `/submit.php` requests to the private application server.

Replace `10.0.11.50` in `nginx.conf` with the private IP of your application server if it changes.
