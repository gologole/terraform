#!/bin/bash
# 安装配置Node.js
mkdir -p /usr/local/nodejs
cd /usr/local/nodejs || exit
count=1
while [ $count -le 30 ];do
wget https://nodejs.org/download/release/v16.13.1/node-v16.13.1-linux-x64.tar.gz
if [ $? -eq 0 ]; then
break
fi
sleep 10
count=$((count+1))
done
tar xf node-v16.13.1-linux-x64.tar.gz
mv node-v16.13.1-linux-x64 /usr/local/
cat>/etc/profile.d/node.sh<<EOF
#!/bin/bash
export NODE_HOME=/usr/local/node-v16.13.1-linux-x64
export PATH=\${NODE_HOME}/bin:\$PATH
EOF
chmod +x /etc/profile.d/node.sh
source /etc/profile.d/node.sh

# 安装配置Vue
count=1
while [ $count -le 30 ];do
npm install -g @vue/cli
if [ $? -eq 0 ]; then
npm install -g npm@9.8.1
break
fi
sleep 10
count=$((count+1))
done

# 修改配置文件
yum install -y git
cd /usr/local || exit
git clone -b master-dev https://gitee.com/HuaweiCloudDeveloper/huaweicloud-solution-gamebounce-console.git
cd huaweicloud-solution-gamebounce-console || exit
yum install -y expect
# 公钥
count=1
while [ $count -le 30 ];do
if [ -f "/tmp/rsa_public.pem" ];then
break
else
sleep 60
/usr/bin/expect<<EOF
spawn scp root@$1:/home/tlsSecret/rsa_public.pem /tmp/
expect {
"(yes/no)?" {
send "yes\r"
expect "password:"
send "$2\r";
exp_continue
}
"password:" {
send "$2\r"
}
}
expect eof
exit
EOF
fi
count=$((count+1))
done
# 替换公钥
cat>replace_key.py<<EOF
# -*-coding:utf-8 -*-
import io
import os
import commands


key = commands.getoutput("cat /tmp/rsa_public.pem")
def alter(file, old_str, new_str):
    file_data = ""
    with io.open(file, "r", encoding="utf-8") as f:
        for line in f:
            if old_str in line:
                line = line.replace(old_str, new_str)
            file_data += line
    with io.open(file, "w", encoding="utf-8") as f:
        f.write(file_data)


alter("/usr/local/huaweicloud-solution-gamebounce-console/src/api/crypto.ts", "let key = \`\`", "let key = \`%s\`"%key)
EOF
python replace_key.py
# vue
count=1
while [ $count -le 30 ];do
npm install
if [ $? -ne 0 ];then
if [ -d "/usr/local/huaweicloud-solution-gamebounce-console/node_modules" ];then
rm -rf /usr/local/huaweicloud-solution-gamebounce-console/node_modules
fi
sleep 10
else
npm install --save vue-i18n@next
npm run build
break
fi
count=$((count+1))
done

# 安装编译工具及库文件
yum -y install make zlib zlib-devel gcc-c++ libtool  openssl openssl-devel
cd /usr/local/src/ || exit
count=1
while [ $count -le 30 ];do
wget http://downloads.sourceforge.net/project/pcre/pcre/8.35/pcre-8.35.tar.gz
if [ $? -eq 0 ];then
break
fi
count=$((count+1))
done
tar zxvf pcre-8.35.tar.gz
cd pcre-8.35 || exit
./configure
make && make install

# 安装配置 Nginx
cd /usr/local/src/ || exit
count=1
while [ $count -le 30 ];do
wget http://nginx.org/download/nginx-1.7.8.tar.gz
if [ $? -eq 0 ];then
break
fi
count=$((count+1))
done
tar zxvf nginx-1.7.8.tar.gz
cd nginx-1.7.8 || exit
./configure --prefix=/usr/local/webserver/nginx --with-http_stub_status_module --with-http_ssl_module --with-pcre=/usr/local/src/pcre-8.35
make
make install
# Nginx配置文件
cat>/usr/local/webserver/nginx/conf/nginx.conf<<EOF
worker_processes  1;

events {
    worker_connections  1024;
}

http {
    include       mime.types;
    default_type  application/octet-stream;
    sendfile        on;
    keepalive_timeout  300;
    client_max_body_size 6g;
    server {
        listen       80;
        server_name  localhost;

        location /api/ {
            # 修改以下IP为后端服务器IP，把 /api 路径下的请求转发给真正的后端服务器
            proxy_pass https://$3:31002/;
        }

        location / {
                root html;
                try_files \$uri /index.html;  # try_files：检查文件； $uri：监测的文件路径； /index.html：文件不存在重定向的新路径
                index index.html;
        }

        error_page   500 502 503 504  /50x.html;
        location = /50x.html {
            root   html;
        }
    }
}
EOF

mv -f /usr/local/huaweicloud-solution-gamebounce-console/dist/* /usr/local/webserver/nginx/html/
# 配置Nginx开启自启动
cat>/lib/systemd/system/nginx.service<<EOF
[Unit]
Description=nginx service
After=network.target
[Service]
Type=forking
ExecStart=/usr/local/webserver/nginx/sbin/nginx
ExecReload=/usr/local/webserver/nginx/sbin/nginx -s reload
ExecStop=/usr/local/webserver/nginx/sbin/nginx -s quit
PrivateTmp=true
[Install]
WantedBy=multi-user.target
EOF
# 启动服务
chmod a+x /lib/systemd/system/nginx.service
systemctl enable nginx.service
systemctl start nginx.service
rm -rf /usr/local/huaweicloud-solution-gamebounce-console/replace_key.py