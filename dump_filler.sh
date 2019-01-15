#!/bin/bash
test_account=$1
tot_emails=$2
from_account="X$test_account"
dumsper_threshold=3
current_date=$(date)
message_id_base=$(date +%s)

function join_by { local IFS="$1"; shift; echo "$*"; }

mkdir /tmp/fake_emls
for i in $(seq 1 $tot_emails);
do
  dumpster_flag=1
  if [ "$(($i % 100))" -le $dumsper_threshold ]; then
   dumpster_flag=0;
  fi
  cat << EOF > /tmp/fake_emls/fake$i.tmp
Return-Path: <$test_account>
Received: from mta00.zimbra.local (LHLO mta00.zimbra.local) (1.2.3.4) by
    service.zimbra.local with LMTP; $current_date
Received: from localhost (localhost [127.0.0.1])
    by mta00.zimbra.local (Postfix) with ESMTP id 35A12E49D
    for <$test_account>; $current_date
Received: from mta00.zimbra.local ([127.0.0.1])
    by localhost (mta00.zimbra.local [127.0.0.1]) (amavisd-new, port 10026)
    with ESMTP id ty-r3CDV-Uii for <$test_account>; $current_date
Received: from service.zimbra.local (service.zimbra.local [1.2.3.4])
    by mta00.zimbra.local (Postfix) with ESMTP id B8E73E499
    for <$test_account>; $current_date
Date: $(date)
From: $test_account
To: $test_account
DumpsterTest: $dumpster_flag
Message-ID: <$message_id_base.$i.zimbra@filler.local>
Subject: $current_date test move with dumpster enabled  $i
MIME-Version: 1.0
Content-Type: text/plain; charset=utf8
Content-Transfer-Encoding: 7bit
Body of message
EOF
done

echo "executing: zmlmtpinject -r $1 -s $from_account -d /tmp/fake_emls" 
zmlmtpinject -r $1 -s $from_account -d /tmp/fake_emls

echo "searching for message to delete:"
echo "zmmailbox -z -m $1 s -l 999 -t message '#DumpsterTest:1' "
# Perl regexp match \d.+ behind (?<=\. ) and (?=mess)  
id_to_del=$(zmmailbox -z -m $1 s -l 999 -t message "#DumpsterTest:1" | grep -oP "(?<=\. ).+ (?=mess)")

echo "Executing: zmmailbox -z -m $1 mm $(join_by , $id_to_del) Trash"

zmmailbox -z -m $1 mm $(join_by , $id_to_del) Trash

echo "Done!"
