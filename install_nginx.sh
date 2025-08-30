#!/bin/bash


sudo apt-get update 
sudo apt install nginx -y
sudo systemctl start nginx
sudo systemctl enable nginx 

echo "</h1> This is Nginx web server installed  
    via automate Terraform shell script </h1>" | sudo tee /var/www/html/index.html