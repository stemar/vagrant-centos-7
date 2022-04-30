echo '==> Setting time zone to '$TIMEZONE

timedatectl set-timezone $TIMEZONE

echo '==> Resetting yum cache'

yum -q -y clean all
rm -rf /var/cache/yum
yum -q -y makecache

echo '==> Installing Linux tools'

cp /vagrant/config/bashrc /home/vagrant/.bashrc
chown vagrant:vagrant /home/vagrant/.bashrc
yum -q -y install nano tree zip unzip whois

echo '==> Setting Git 2.x repository'

rpm --import --quiet http://opensource.wandisco.com/RPM-GPG-KEY-WANdisco
yum -q -y install http://opensource.wandisco.com/centos/7/git/x86_64/wandisco-git-release-7-2.noarch.rpm

echo '==> Installing Subversion and Git'

yum -q -y install svn git

echo '==> Installing Apache'

yum -q -y install httpd mod_ssl openssl
usermod -a -G apache vagrant
chown -R root:apache /var/log/httpd
cp /vagrant/config/localhost.conf /etc/httpd/conf.d/localhost.conf
cp /vagrant/config/virtualhost.conf /etc/httpd/conf.d/virtualhost.conf
sed -i 's|GUEST_SYNCED_FOLDER|'$GUEST_SYNCED_FOLDER'|' /etc/httpd/conf.d/virtualhost.conf
sed -i 's|FORWARDED_PORT_80|'$FORWARDED_PORT_80'|' /etc/httpd/conf.d/virtualhost.conf

echo '==> Setting MariaDB 10.6 repository'

rpm --import --quiet https://mirror.rackspace.com/mariadb/yum/RPM-GPG-KEY-MariaDB
cp /vagrant/config/MariaDB.repo /etc/yum.repos.d/MariaDB.repo

echo '==> Installing MariaDB'

yum -q -y install MariaDB-server MariaDB-client

echo '==> Setting PHP 7.4 repository'

rpm --import --quiet https://archive.fedoraproject.org/pub/epel/RPM-GPG-KEY-EPEL-7
yum -q -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
rpm --import --quiet https://rpms.remirepo.net/RPM-GPG-KEY-remi
yum -q -y install https://rpms.remirepo.net/enterprise/remi-release-7.rpm
yum-config-manager -q -y --enable remi-php74 > /dev/null
yum -q -y update

echo '==> Installing PHP'

yum -q -y install php php-cli php-common \
    php-bcmath php-devel php-gd php-imap php-intl php-ldap \
    php-mbstring php-pecl-mcrypt php-mysqlnd php-opcache php-pdo php-pear \
    php-pecl-xdebug php-pspell php-soap php-tidy php-xml php-xmlrpc
cp /vagrant/config/php.ini.htaccess /var/www/.htaccess
PHP_ERROR_REPORTING_INT=$(php -r 'echo '"$PHP_ERROR_REPORTING"';')
sed -i 's|PHP_ERROR_REPORTING_INT|'$PHP_ERROR_REPORTING_INT'|' /var/www/.htaccess

echo '==> Installing Adminer'

if [ ! -d /usr/share/adminer ]; then
    mkdir -p /usr/share/adminer
    curl -LsS https://www.adminer.org/latest-en.php -o /usr/share/adminer/adminer.php
    sed -i 's|{if($F=="")return|{if(true)|' /usr/share/adminer/adminer.php
    curl -LsS https://raw.githubusercontent.com/vrana/adminer/master/designs/nicu/adminer.css -o /usr/share/adminer/adminer.css
fi
cp /vagrant/config/adminer.conf /etc/httpd/conf.d/adminer.conf
sed -i 's|FORWARDED_PORT_80|'$FORWARDED_PORT_80'|' /etc/httpd/conf.d/adminer.conf

echo '==> Installing Python 3'

yum -q -y install python3

echo '==> Testing Apache configuration'

apachectl configtest

echo '==> Starting Apache'

systemctl start httpd
systemctl enable httpd

echo '==> Starting MariaDB'

systemctl start mariadb
systemctl enable mariadb
mysqladmin -u root password ""

echo '==> Versions:'

cat /etc/redhat-release
openssl version
curl --version | head -n1 | cut -d '(' -f 1
svn --version | grep svn,
git --version
httpd -V | head -n1 | cut -d ' ' -f 3-
mysql -V
php -v | head -n1
python --version &>/dev/stdout
python3 --version
