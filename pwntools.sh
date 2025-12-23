#!/bin/bash
set -e

echo "[+] Updating system..."
sudo apt update -y && sudo apt full-upgrade -y

echo "[+] Installing baseline packages..."
sudo apt install -y git curl wget telnet ftp python3 python3-pip pipx nfs-common ruby-full golang ffuf gobuster seclists dirb smbclient cifs-utils locate libssl-dev liblua5.4-dev lua5.4

# Note: The default Parrot nmap install has broken mssql scripts. This reinstalls nmap to fix that.
echo "[+] Reinstalling Nmap to ensure latest scripts (fixed mssql)..."
sudo apt purge -y nmap nmap-common
sudo apt autoremove -y
sudo rm -rf /usr/share/nmap
sudo rm -rf /usr/local/share/nmap
sudo apt update -y
sudo apt install -y nmap nmap-common
sudo nmap --script-updatedb

# I thought this was installed naturally as part of Parrot Security. I swear I used it before, but it appears it stopped working on me.
echo "[+] Installing metasploit..."
curl https://raw.githubusercontent.com/rapid7/metasploit-omnibus/master/config/templates/metasploit-framework-wrappers/msfupdate.erb > msfinstall
chmod 755 msfinstall
sudo ./msfinstall
rm msfinstall

echo "[+] Setting up rust..."
curl https://sh.rustup.rs -sSf | sh -s -- -y
source ~/.cargo/env
echo 'source ~/.cargo/env' >> ~/.bashrc

echo "[+] Creating /opt structure..."
sudo mkdir -p /opt/{SecLists,assetnote-wordlists,fuzzdb,probable-wordlists,dirsearch,reconftw,peass,lse,pspy,PowerSploit,bloodhound,PATT,LinEnum,SUID3NUM,feroxbuster}

echo "[+] Intalling feroxbuster..."
curl -sL https://raw.githubusercontent.com/epi052/feroxbuster/main/install-nix.sh > install-nix.sh
mv install-nix.sh /opt/feroxbuster/install-nix.sh
chmod +x /opt/feroxbuster/install-nix.sh
bash /opt/feroxbuster/install-nix.sh
mv feroxbuster /usr/local/bin/feroxbuster

echo "[+] Installing SecLists..."
sudo rsync -av --ignore-existing /usr/share/seclists/ /opt/SecLists/ || true

echo "[+] Installing Assetnote wordlists..."
sudo git clone https://github.com/assetnote/wordlists.git /opt/assetnote-wordlists || true

echo "[+] Installing FuzzDB..."
sudo git clone https://github.com/fuzzdb-project/fuzzdb.git /opt/fuzzdb || true

echo "[+] Installing Probable Wordlists..."
sudo git clone https://github.com/berzerk0/Probable-Wordlists.git /opt/probable-wordlists || true

echo "[+] Installing dirsearch..."
sudo git clone https://github.com/maurosoria/dirsearch.git /opt/dirsearch || true

echo "[+] Installing ReconFTW..."
sudo git clone https://github.com/six2dez/reconftw.git /opt/reconftw || true

echo "[+] Installing PEASS-ng..."
sudo git clone https://github.com/carlospolop/PEASS-ng.git /opt/peass || true

echo "[+] Installing Linux Smart Enum..."
sudo git clone https://github.com/diego-treitos/linux-smart-enumeration.git /opt/lse || true

echo "[+] Installing pspy..."
sudo git clone https://github.com/DominicBreuker/pspy.git /opt/pspy || true

echo "[+] Installing PowerSploit..."
sudo git clone https://github.com/PowerShellMafia/PowerSploit.git /opt/PowerSploit || true

echo "[+] Installing BloodHound (Collectors)..."
sudo git clone https://github.com/BloodHoundAD/BloodHound.git /opt/bloodhound || true

echo "[+] Installing PayloadAllTheThings..."
sudo git clone https://github.com/swisskyrepo/PayloadsAllTheThings.git /opt/PATT || true

echo "[+] Installing LinEnum..."
sudo git clone https://github.com/rebootuser/LinEnum.git /opt/LinEnum || true

echo "[+] Installing SUID3NUM..."
sudo git clone https://github.com/Anon-Exploiter/SUID3NUM.git /opt/SUID3NUM || true

echo "[+] Installing Evil-WinRM..."
sudo gem install evil-winrm

echo "[+] Installing RustScan..."
cargo install rustscan

echo "[+] Installing Oracle Database tools (ODAT)..."
wget https://download.oracle.com/otn_software/linux/instantclient/214000/instantclient-basic-linux.x64-21.4.0.0.0dbru.zip
wget https://download.oracle.com/otn_software/linux/instantclient/214000/instantclient-sqlplus-linux.x64-21.4.0.0.0dbru.zip
sudo mkdir -p /opt/oracle
sudo unzip -d /opt/oracle instantclient-basic-linux.x64-21.4.0.0.0dbru.zip
sudo unzip -d /opt/oracle instantclient-sqlplus-linux.x64-21.4.0.0.0dbru.zip
export LD_LIBRARY_PATH=/opt/oracle/instantclient_21_4:$LD_LIBRARY_PATH
export PATH=$LD_LIBRARY_PATH:$PATH
source ~/.bashrc
cd ~
git clone https://github.com/quentinhardy/odat.git
cd odat/
pip install --break-system-packages python-libnmap
git submodule init
git submodule update
pip3 install --break-system-packages cx_Oracle
sudo apt-get install python3-scapy -y
sudo pip3 install --break-system-packages colorlog termcolor passlib python-libnmap
sudo apt-get install build-essential libgmp-dev -y
pip3 install --break-system-packages pycryptodome
echo "You may now interact with ODAT using `python3 odat.py -h`"
sudo ln -s /opt/oracle/instantclient_21_4/sqlplus /usr/bin/sqlplus

echo "[+] Installing Kerbrute..."
go install github.com/ropnop/kerbrute@latest

echo "[+] Installing AutoRecon..."
pip3 install --break-system-packages git+https://github.com/Tib3rius/AutoRecon.git

echo "[+] Installing Impacket (latest)..."
pip3 install --break-system-packages git+https://github.com/fortra/impacket.git

echo "[+] Installing CrackMapExec..."
echo "Note: CrackMapExec is obsolete and replaced by 'nxc'"
#pipx install crackmapexec

echo "[+] Installing Nuclei + Templates..."
go install github.com/projectdiscovery/nuclei/v3/cmd/nuclei@latest
nuclei -update-templates || true

echo "[+] Installing Katana..."
go install github.com/projectdiscovery/katana/cmd/katana@latest

echo "[+] Installing Pwntools..."
pip3 install --break-system-packages pwntools

echo "[+] Installing ROPgadget..."
pip3 install --break-system-packages ropgadget

echo "[+] Installing pwndbg..."
cd /opt
sudo git clone https://github.com/pwndbg/pwndbg || true
cd pwndbg && ./setup.sh

echo "[+] Installing SMNP tools..."
sudo apt install -y snmp

echo "[+] Linking MSSQL tools..."
# This was installed with Impacket, but the script is not linked by default
sudo chmod +x /usr/local/bin/mssqlclient.py
sudo ln -s /usr/local/bin/mssqlclient.py /usr/bin/mssqlclient

echo "[+] Cleaning up PATH..."
if ! grep -q "/opt" ~/.bashrc; then
  echo 'export PATH=$PATH:/opt/peass:/opt/LinEnum:/opt/dirsearch:/opt/PATT' >> ~/.bashrc
fi

echo "[+] All done! Reboot or source ~/.bashrc"