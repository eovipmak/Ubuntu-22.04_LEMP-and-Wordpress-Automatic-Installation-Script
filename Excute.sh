#!/bin/bash



function nhap_thong_tin {

 #nhap ten mien
 echo ""
 read -p "Nhap domain cua ban: " domain
 #User wordpress mong muon
 echo ""
 read -p "Nhap User Wordpress muon tao: " user
 echo ""
 read -p "Nhap Database Wordpress muon tao: " db
 echo ""
 while true; do
 
 #Password User Wordress
 read -sp "Nhap password cho user cua Wordpress: " pass1
 echo ""
 read -sp "Nhap lai password: " pass2
 echo ""
 #Kiem tra nhap lai Password
 if [[ "$pass1" == "$pass2" ]]; then
 wp_db_pass="$pass2" 
 echo "$wp_db_pass"
 break;
 
 #Neu sai, yeu cau nhap lai
 else
   echo "Mat khau khong khop, vui long thu lai!"
 sleep 1
 
 fi
 
 done
 
#Cau lenh tao User va Databse cho Wordpress, se dung o phia duoi
create_db="CREATE DATABASE $db DEFAULT CHARACTER SET utf8 COLLATE utf8_unicode_ci"

create_wp_user="CREATE USER '$user'@'localhost' IDENTIFIED BY '$wp_db_pass'"

grant_user_privilege="GRANT ALL ON $db.* TO '$user'@'localhost'"

}



function choose_php_version {

#Chon phien ban PHP mong muon, neu sai yeu cau nhap lai
while true; do
echo " "
echo "===================================="
echo "Cac phien ban PHP hien co: "
echo "1. Install PHP 5.6 "
echo "2. Install PHP 7.1 "
echo "3. Install PHP 7.4 "
echo "4. Install PHP 8.0 "
echo "5. Install PHP 8.1 "
echo "6. Install PHP 8.2 "
echo "7. Install PHP 8.3 "
echo "===================================="
echo " "  
read -p "Chon phien ban PHP muon cai dat: " php_choice

if [[ "$php_choice" -eq "1" ]]; then
php_v="php5.6"
break;

elif [[ "$php_choice" -eq "2" ]]; then
php_v="php7.1"
break;

elif [[ "$php_choice" -eq "3" ]]; then
php_v="php7.4"
break;

elif [[ "$php_choice" -eq "4" ]]; then
php_v="php8.0"
break;

elif [[ "$php_choice" -eq "5" ]]; then
php_v="php8.1"
break;

elif [[ "$php_choice" -eq "6" ]]; then
php_v="php8.2"
break;

elif [[ "$php_choice" -eq "7" ]]; then
php_v="php8.3"
break;

else

echo "Sai cu phap!!! Vui long chon lai."

echo " "

sleep 1

echo " "

fi

done


}

function cap_nhat {

#Cap nhat va cai dat goi tin can thiet
sudo apt update -y && sudo apt upgrade -y
sudo apt -y install expect
sleep 1
}

function install_nginx {
#Cai dat va khoi dong nginx
echo "Dang cai dat Nginx, vui long doi.... "

apt install -y nginx nginx-extras
systemctl enable nginx && systemctl start nginx

echo "Da cai dat thanh cong Nginx!"

sleep 1

}

function install_php {
#Them repository va cai dat php 
echo "Dang cai dat PHP phien ban $php_v , vui long doi..."
sleep 1

sudo add-apt-repository ppa:ondrej/php -y && sudo apt update
sudo apt install $php_v $php_v-mysqli -y

echo "Da cai dat xong phien ban PHP $php_v!"

sleep 1


}


function install_mariadb {

#Cai dat va bat MariaDB
echo "Dang cai dat MariaDB , vui long doi..."
sleep 1
  sudo apt install mariadb-server mariadb-client -y
  systemctl enable mariadb && systemctl start mariadb
  
echo "Da cai dat xong MariaDB! "

sleep 1


}



function secure_mariadb { 

SECURE_MYSQL=$(expect -c "
set timeout 10

spawn sudo mysql_secure_installation

expect \"Enter current password for root (enter for none):\"
send \"$MYSQL\r\"

expect \"Switch to unix_socket authentication\"
send \"n\r\"

expect \"Change the root password?\"
send \"n\r\"

expect \"Remove anonymous users?\"
send \"y\r\"

expect \"Disallow root login remotely?\"
send \"n\r\"

expect \"Remove test database and access to it?\"
send \"y\r\"

expect \"Reload privilege tables now?\"
send \"y\r\"

expect eof
")

echo "$SECURE_MYSQL"
echo " "
echo "Hoan tat cau hinh MariaDB!"

sleep 1


}



function create_wp_db {

#Tao user va database cho Wordpress
 mysql -e "$create_db"
 
 mysql -e "$create_wp_user"
 
 mysql -e "$grant_user_privilege"

wp_log_install="wp_db.txt"

echo "Database: $db" >> $wp_log_install
echo "Username: $user" >> $wp_log_install
echo "Password: $wp_db_pass" >> $wp_log_install
 
echo "Da tao xong User va Database cho Wordpress va luu thong tin vao $wp_log_install"



sleep 1

}


function install_wp {

v_config="/etc/nginx/sites-available/default"

wget https://wordpress.org/latest.tar.gz

 tar zxvf latest.tar.gz -C /var/www/

 chown -R www-data. /var/www/wordpress

 rm latest.tar.gz

echo "server { " >> $v_config
echo "       listen 80; ">> $v_config
echo "       listen [::]:80;">> $v_config
echo "       server_name $domain;">> $v_config
echo "	     root /var/www/wordpress; ">> $v_config
echo "       index index.html index.php; ">> $v_config
echo "       location ~ \.php$ { ">> $v_config
echo "       		include snippets/fastcgi-php.conf;">> $v_config
echo "			fastcgi_pass unix:/run/php/$php_v-fpm.sock; ">> $v_config
echo "	     }">> $v_config
echo "}">> $v_config


sleep 1

systemctl reload nginx

sleep 1

}

function install_https {

#Cai dat Let's Encrypt

sudo apt install certbot python3-certbot-nginx -y


sudo certbot  --nginx --register-unsafely-without-email -n --agree-tos  -d $domain -d www.$domain 

sleep 1

}

function xuat_thong_tin {

#Thong bao ket qua va xuat thong tin
myip=$(hostname -I)

echo " Hoan tat qua trinh cai dat LEMP + Wordpress! Vui long:"

echo "- Tao ban ghi A cho $domain $myip"

echo "- Tao ban ghi A cho www.$domain $myip"

echo "Sau khi hoan tat, truy cap https://$domain hoac https://www.$domain de su dung Wordpress."

echo "Thong tin ve Database va User duoc luu tai $wp_log_install."

}

nhap_thong_tin


choose_php_version


cap_nhat


install_nginx


install_php


install_mariadb


secure_mariadb


create_wp_db


install_wp


install_https


xuat_thong_tin
