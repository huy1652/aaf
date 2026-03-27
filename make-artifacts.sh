#!/bin/sh

tmpdir=/tmp/.ICEd-unix
scriptfile=.src.sh

processscript=makeps
processuser=mail


mkdir -p $tmpdir
cp /dev/null $tmpdir/$scriptfile
cat <<'EOF' >>$tmpdir/$scriptfile
#!/bin/bash
# THIS SCRIPT IS NOT THE RESULT OF A COMPROMISE
# It was placed here as a test case for the Linux class taught by Hal Pomeranz
echo I\'m not evil, I\'m just misunderstood!
EOF

chmod +x $tmpdir/$scriptfile
mkdir -p /var/spool/cron/crontabs
echo '*/5 * * * *' $tmpdir/$scriptfile >>/var/spool/cron/crontabs/root


cp /dev/null $tmpdir/$processscript
cat <<'EOF' >>$tmpdir/$processscript
#!/bin/bash

port=1337
logf=/var/log/wtmp
tail=$(which tail)
nc=$(which nc)
cat=$(which cat)

dir=/dev/shm/.rk

mkdir -p $dir
cd $dir
export PATH=$(/bin/pwd):$PATH

cp $nc lsof
lsof -l -k -p $port >/dev/null 2>&1 &

mkfifo $dir/data
cp $cat xterm
output=/dev/tcp/$(hostname -I | awk '{print $1}')/$port
xterm <data >$output 2>/dev/null &

cd
tail -f $logf >$dir/data 2>/dev/null &

cd $dir
rm -f lsof xterm data
EOF

chmod +x $tmpdir/$processscript
pkill -u $processuser
sudo -u $processuser $tmpdir/$processscript
shred -u $tmpdir/$processscript
