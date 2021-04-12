echo '==> Setting time zone'

timedatectl set-timezone Canada/Pacific
timedatectl | grep 'Time zone:'

echo '==> Cleaning yum cache'

yum -q -y makecache fast
# yum -q -y clean all
rm -rf /var/cache/yum

echo '==> Installing Linux tools'

cp $VM_CONFIG_PATH/bashrc /home/vagrant/.bashrc
chown vagrant:vagrant /home/vagrant/.bashrc
yum -q -y install nano tree zip unzip whois
yum -q -y update openssl

echo '==> Setting Git 2.x repository'

rpm --import --quiet http://opensource.wandisco.com/RPM-GPG-KEY-WANdisco
yum -q -y install http://opensource.wandisco.com/centos/7/git/x86_64/wandisco-git-release-7-2.noarch.rpm

echo '==> Installing Subversion and Git'

yum -q -y install svn git

echo '==> Installing Apache'

yum -q -y install httpd mod_ssl
usermod -a -G apache vagrant
chown -R root:apache /var/log/httpd
cp $VM_CONFIG_PATH/localhost.conf /etc/httpd/conf.d/localhost.conf
cp $VM_CONFIG_PATH/virtualhost.conf /etc/httpd/conf.d/virtualhost.conf
sed -i 's|GUEST_SYNCED_FOLDER|'$GUEST_SYNCED_FOLDER'|' /etc/httpd/conf.d/virtualhost.conf
sed -i 's|FORWARDED_PORT_80|'$FORWARDED_PORT_80'|' /etc/httpd/conf.d/virtualhost.conf

echo '==> Setting MariaDB 10.3 repository'

rpm --import --quiet https://yum.mariadb.org/RPM-GPG-KEY-MariaDB
cp $VM_CONFIG_PATH/MariaDB.repo /etc/yum.repos.d/MariaDB.repo

echo '==> Installing MariaDB'

yum -q -y install MariaDB-server MariaDB-client

# echo '==> Setting PHP 7.2 repository'

# yum -q -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
# yum -q -y install http://rpms.remirepo.net/enterprise/remi-release-7.rpm
# yum -q -y install yum-utils
# yum-config-manager -q -y --enable remi-php72 > /dev/null
# yum -q -y update

echo '==> Installing PHP'

yum -q -y install php php-common \
    php-bcmath php-devel php-gd php-imap php-intl php-ldap \
    php-mbstring php-pecl-mcrypt php-mysqlnd php-opcache php-pdo php-pear \
    php-pecl-xdebug php-pspell php-soap php-tidy php-xml php-xmlrpc
cp $VM_CONFIG_PATH/php.ini.htaccess /var/www/.htaccess

echo '==> Installing Adminer'

if [ ! -d /usr/share/adminer ]; then
    mkdir -p /usr/share/adminer
    curl -LsS https://www.adminer.org/latest-en.php -o /usr/share/adminer/adminer.php
    curl -LsS https://raw.githubusercontent.com/vrana/adminer/master/designs/nicu/adminer.css -o /usr/share/adminer/adminer.css
fi
cp $VM_CONFIG_PATH/adminer.conf /etc/httpd/conf.d/adminer.conf
sed -i 's|FORWARDED_PORT_80|'$FORWARDED_PORT_80'|' /etc/httpd/conf.d/adminer.conf
sed -i 's|login($we,$F){if($F=="")return|login($we,$F){if(true)|' /usr/share/adminer/adminer.php

echo '==> Starting Apache'

apachectl configtest
systemctl start httpd.service
systemctl enable httpd.service

echo '==> Starting MariaDB'

systemctl start mariadb.service
systemctl enable mariadb.service
mysqladmin -u root password ""

echo '==> Versions:'

cat /etc/redhat-release
echo $(openssl version)
echo $(curl --version | head -n1)
echo $(svn --version | grep svn,)
echo $(git --version)
echo $(httpd -V | head -n1)
echo $(mysql -V)
echo $(php -v | head -n1)
echo $(python --version)
