#!/usr/bin/env bash
set -e

echo "[+] Starting EasyPeasy setup..."

echo

echo "[+] Installing utilities"
apt-get install -y net-tools vim open-vm-tools openssh-server nodejs npm 1> /dev/null
npm install pm2 -g 1> /dev/null

echo "[+] Configuring first vector"

echo "[+] --->Installing VSFTPD"
apt-get install vsftpd 1> /dev/null

echo "[+] --->Creating FTP user: norman, passwd: isabel"
useradd norman && echo 'norman:isabel' | sudo chpasswd

echo "[+] --->Setting up FTP user"
mkdir -p /home/norman/.archives/{logs,config,old}
chmod -R a-w /home/norman/.archives
chmod 644 ftp-files/archive.zip
cp ftp-files/archive.zip /home/norman/.archives/old/.archive.zip
chown nobody:nogroup -R /home/norman/.archives
echo "norman" > /etc/vsftpd.user_list
systemctl start vsftpd
systemctl enable vsftpd

echo "[+] --->Installing Apache and PHP"
apt-get install -y apache2 libapache2-mod-php 1> /dev/null

echo "[+] --->Creating all sites on port 80 and 3000"
tar -xvf vulnerable-sites.tar.gz --directory /var/www/html 1> /dev/null
cd /var/www/html/app && npm install --silent && pm2 --name HomeApp start npm -- start 1> /dev/null

echo "[+] --->Enabling Apache"
systemctl enable apache2
systemctl start apache2

echo "[+] --->Giving www-data permissions to /var/www/html directory"
chown -R www-data:www-data /var/www/html
chmod -R 755 /var/www/html

echo "[+] Configuring second vector"

echo "[+] Configuring firewall"
echo "[+] Installing iptables"
echo "iptables-persistent iptables-persistent/autosave_v4 boolean false" | debconf-set-selections
echo "iptables-persistent iptables-persistent/autosave_v6 boolean false" | debconf-set-selections
apt-get install -y iptables-persistent 1> /dev/null


echo "[+] Applying inbound firewall rules"
iptables -I INPUT 1 -i lo -j ACCEPT
iptables -A INPUT -m conntrack --ctstate NEW,ESTABLISHED,RELATED -j ACCEPT
iptables -A INPUT -p tcp --dport 22 -j ACCEPT
iptables -A INPUT -p tcp --dport 80 -j ACCEPT
iptables -A INPUT -p tcp --dport 20 -j ACCEPT
iptables -A INPUT -p tcp --dport 21 -j ACCEPT
iptables -A INPUT -p tcp --dport 3000 -j ACCEPT
iptables -A INPUT -p icmp --icmp-type echo-request -j ACCEPT
iptables -A INPUT -p icmp --icmp-type echo-reply -j ACCEPT
iptables -A INPUT -j DROP

echo "[+] Applying outbound firewall rules"
iptables -A OUTPUT -o lo -j ACCEPT
iptables -A OUTPUT -p tcp --sport 22 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A OUTPUT -p tcp --dport 53 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A OUTPUT -p udp --dport 53 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A OUTPUT -p tcp --dport 80 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A OUTPUT -p tcp --sport 80 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A OUTPUT -p tcp --dport 3000 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A OUTPUT -p tcp --sport 3000 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A OUTPUT -p tcp --dport 20 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A OUTPUT -p tcp --sport 20 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A OUTPUT -p tcp --dport 21 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A OUTPUT -p tcp --sport 21 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A OUTPUT -p icmp --icmp-type echo-request -j ACCEPT
iptables -A OUTPUT -p icmp --icmp-type echo-reply -j ACCEPT
iptables -A OUTPUT -j DROP

echo "[+] Saving firewall rules"
service netfilter-persistent save

echo "[+] Disabling IPv6"
echo "net.ipv6.conf.all.disable_ipv6 = 1" >> /etc/sysctl.conf
echo "net.ipv6.conf.default.disable_ipv6 = 1" >> /etc/sysctl.conf
sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT=""/GRUB_CMDLINE_LINUX_DEFAULT="ipv6.disable=1"/' /etc/default/grub
sed -i 's/GRUB_CMDLINE_LINUX=""/GRUB_CMDLINE_LINUX="ipv6.disable=1"/' /etc/default/grub
update-grub 1> /dev/null

echo "[+] Configuring hostname"
hostnamectl set-hostname easypeasy
cat << EOF > /etc/hosts
127.0.0.1 localhost
127.0.0.1 easypeasy
EOF

echo "[+] Creating users if they don't already exist"
id -u ellie &>/dev/null || useradd -m ellie

echo "[+] Disabling history files"
ln -sf /dev/null /root/.bash_history
ln -sf /dev/null /home/ellie/.bash_history


echo "[+] Enabling root SSH login"
sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/ssh_config

echo "[+] Prevent FTP user from SSH"
echo "DenyUsers norman" >> /etc/ssh/sshd_config
echo "DenyUsers ellie" >> /etc/ssh/sshd_config

echo "[+] Restart SSH"
service sshd restart

echo "[+] Setting passwords"
echo "root:KingOutlookFederation332" | chpasswd
echo "ellie:CharlesTreePokemon44" | chpasswd

echo "[+] Dropping flags and setting permissions"
echo "b2e7d04a3074a11a612cd9d8dcbf9124" > /root/proof.txt
echo "2b1b3240f33fea7ce207a18a8c8640d4" > /home/ellie/local.txt
chmod 0700 /root/proof.txt
chmod 0644 /home/ellie/local.txt
chown ellie:ellie /home/ellie/local.txt 
chmod 0744 /home/ellie

echo "[+] Give Ellie sudo for pm2"
bash -c 'echo "ellie ALL=(ALL) NOPASSWD: /usr/local/bin/pm2" >> /etc/sudoers.d/ellie'

echo "[+] Cleaning up"
rm -rf /root/build.sh
rm -r /root/ftp-files
rm -rf /root/vulnerable-sites.tar.gz
rm -rf /root/.cache
rm -rf /root/.viminfo
rm -rf /home/ellie/.sudo_as_admin_successful
rm -rf /home/ellie/.cache
rm -rf /home/ellie/.viminfo
find /var/log -type f -exec sh -c "cat /dev/null > {}" \;
