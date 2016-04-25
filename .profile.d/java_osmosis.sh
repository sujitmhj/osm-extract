export PATH="/app/.apt/usr/bin/:$HOME/.apt/usr/bin:/app/.apt/usr/lib/jvm/java-7-openjdk-amd64/bin:$PATH"
export JAVA_HOME="/app/.apt/usr/lib/jvm/java-7-openjdk-amd64"
cp /home/vcap/app/cf/plexus.conf /app/.apt/etc/osmosis/
cp /home/vcap/app/cf/osmosis /app/.apt/usr/bin/
chmod 700 /app/.apt/usr/bin/osmosis
