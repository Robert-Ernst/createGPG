# createKeyQuartet
A tool to create a up-to-standard secure SSH and GPG key together


## Usage

Creates a new GPG identity and exports GPG and SSH files
Syntax: createKeyQuartet.sh [options] email "full name"
Example: ./createKeyQuartet.sh foo@bar.com "Hans Meiser"
Output:
   4 different files:
   foo@bar.com_sec.gpg --> GPG secret key
   foo@bar.com_pub.gpg --> GPG public key
   foo@bar.com_ssh     --> SSH private key
   foo@bar.com_ssh.pub --> SSH public key"
   
options:
-h, --help     Print this Help