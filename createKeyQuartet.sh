#!/bin/bash

this_help()
{
   # Display Help
   echo "Creates a new GPG identity and exports GPG and SSH files"
   echo
   echo "Syntax: createKeyQuartet.sh [options] email \"full name\""
   echo
   echo "Example: ./createKeyQuartet.sh foo@bar.com \"Hans Meiser\""
   echo
   echo "Output:"
   echo "   4 different files:"
   echo "   foo@bar.com_sec.gpg --> GPG secret key"
   echo "   foo@bar.com_pub.gpg --> GPG public key"
   echo "   foo@bar.com_ssh     --> SSH private key"
   echo "   foo@bar.com_ssh.pub --> SSH public key" 
   echo
   echo "options:"
   echo "-h, --help     Print this Help"
   echo
   exit 1
}

# Handle input parameter
if [ $# -eq 0 ]; then
    echo "Error: No arguments provided"
    echo 
    this_help
    exit 1
fi

# TODO simple email regex check
#  [^@ \t\r\n]+@[^@ \t\r\n]+\.[^@ \t\r\n]+ 
# https://ihateregex.io/expr/email/

# https://stackoverflow.com/a/9271406/4666399
_setArgs(){
  while [ "${1:-}" != "" ]; do
    case "$1" in
      "-h" | "--help")
        this_help
        ;;
    esac
    shift
  done
}

FILENAME_PUB+=$EMAIL"_pub.gpg"
FILENAME_SEC+=$EMAIL"_sec.gpg"
FILENAME_SSH+=$EMAIL"_ssh"
FILENAME_SSH_PUB+=$EMAIL"_ssh.pub"

EMAIL=$1
FULLNAME=$2

# Generate Key into gpg

cat >createKeyQuartet.tmp <<EOF
     %echo Generating an ed25519 key
     Key-Type: ed25519
     Key-Length: 4096
     Subkey-Type: ed25519
     Name-Real: $FULLNAME
     Name-Email: $EMAIL
     Expire-Date: 0
     %no-protection
     # Do a commit here, so that we can later print "done" :-)
     %commit
     %echo done
EOF

gpg2 --batch --generate-key createKeyQuartet.tmp

# Create GPG + SSH files

EMAIL=$1
FULLNAME=$2

KEY=$(gpg2 --list-key --with-colons --keyid-format=long $EMAIL | tail -n 5 | grep pub | cut -d ':' -f5)

FILENAME_PUB=$EMAIL"_pub.gpg"
FILENAME_SEC=$EMAIL"_sec.gpg"
FILENAME_SSH=$EMAIL"_ssh"
FILENAME_SSH_PUB=$EMAIL"_ssh.pub"

gpg2 --armor --export $KEY > $FILENAME_PUB
gpg2 --armor --export-secret-keys $KEY > $FILENAME_SEC
gpg2 --export-secret-key $KEY | openpgp2ssh $KEY > $FILENAME_SSH
sudo chmod 400 $FILENAME_SSH && ssh-keygen -y -f $FILENAME_SSH > $FILENAME_SSH_PUB

# Read only permissions for the keys
sudo chmod 400 $FILENAME_PUB $FILENAME_SEC $FILENAME_SSH $FILENAME_SSH_PUB

# Clean up temp file
rm createKeyQuartet.tmp
