apt update
apt install git gcc g++ make python3-dev python3-pip libxml2-dev libxslt1-dev zlib1g-dev gettext curl redis-server
curl -sL https://deb.nodesource.com/setup_12.x | sudo -E bash -
apt install nodejs
npm install -g sass postcss-cli postcss autoprefixer
apt update
apt install mariadb-server libmysqlclient-dev
apt install python3.8-venv python3-wheel
# setup database if required, the script wont do it automatically.
cd ../
python3 -m venv siteenv
. siteenv/bin/activate
pip3 install wheel
pip3 install -r requirements.txt
pip3 install mysqlclient
pip3 install django-discord-integration
pip3 install django_select2
pip3 install websocket-client
pip3 install python-memcached
python3 manage.py check