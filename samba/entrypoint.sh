if [ -f /etc/krb5.conf ]
then
  echo "File exists! Starting Samba..."
  samba -F
else
  echo "New instance. Provisioning Samba..."
  rm -f /etc/resolv.conf
  echo -e "nameserver 127.0.0.1" | tee /etc/resolv.conf
  rm -f /etc/samba/smb.conf
  samba-tool domain provision --realm $REALM --domain $DOMAIN --admin=$ADMIN_PASSWORD
  ln -s /var/lib/samba/private/krb5.conf /etc
  if [ "$REQUIRE_TLS" == "no" ]
  then
    sed -i 's/\[sysvol\]/\tldap server require strong auth = No\n[sysvol]/' /etc/samba/smb.conf
  fi
  echo "Starting Samba..."
  samba -F
fi
