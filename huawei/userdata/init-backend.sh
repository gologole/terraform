#!/bin/bash
# 参数
apgw2_ip=$1
aass1_ip=$2
aass2_ip=$3
fmgr1_ip=$4
fmgr2_ip=$5
ecs_pwd=$6
elb_aass_ip=$7
rds_mysql_ip=$8
rds_mysql_pwd=$9
influx_ip=${10}
influx_pwd=${11}
redis_ip=${12}
redis_pwd=${13}
elb_apgw_ip=${14}
eps_id=${15}
domain_id=${16}
ak=${17}
sk=${18}
obs_name=${19}
apgw1_pub_ip=${20}
apgw2_pub_ip=${21}
aass1_pub_ip=${22}
aass2_pub_ip=${23}
servers_ip=("$apgw2_ip" "$aass1_ip" "$aass2_ip" "$fmgr1_ip" "$fmgr2_ip")

# 配置免密登录
mkdir -p /root/.ssh
ssh-keygen -t dsa -P '' -f /root/.ssh/id_dsa
yum install -y expect nc
for ip in "${servers_ip[@]}";do
count=1
while [ $count -le 5 ];do
count=$((count+1))
nc -zv "$ip" 22 > /dev/null 2>&1
if [ $? -eq 0 ];then
/usr/bin/expect <<EOF
spawn ssh-copy-id -i /root/.ssh/id_dsa.pub root@$ip
expect {
"(yes/no)?" {
send "yes\r"
expect "password:"
send "$ecs_pwd\r";
exp_continue
}
"password:" {
send "$ecs_pwd\r"
}
}
expect eof
exit
EOF
break
else
sleep 3
fi
done
done

# 安装go
yum install -y go
export HOME=/root
export GOPATH=$HOME/go
export GOROOT=/usr/lib/golang
export PATH=$PATH:$GOROOT/bin:$GOROOT/bin
export XDG_CONFIG_HOME=$HOME/.config
source /etc/profile
go version

# 编译二进制文件
yum install -y git
mkdir -p /usr/src/gameflexmatch
cd /usr/src/gameflexmatch || exit
git clone https://gitee.com/HuaweiCloudDeveloper/huaweicloud-solution-gameflexmatch-fleetmanager.git
git clone https://gitee.com/HuaweiCloudDeveloper/huaweicloud-solution-gameflexmatch-appgateway.git
git clone https://gitee.com/HuaweiCloudDeveloper/huaweicloud-solution-gameflexmatch-aass.git
git clone https://gitee.com/HuaweiCloudDeveloper/huaweicloud-solution-gameflexmatch-auxproxy.git
git clone https://gitee.com/HuaweiCloudDeveloper/huaweicloud-solution-gameflexmatch.git
# 设置编译的可执行文件的操作系统
go env -w GOOS=linux
# 配置go代理
go env -w GO111MODULE=on
go env -w GOPROXY=https://repo.huaweicloud.com/repository/goproxy/
go env -w GONOSUMDB=*
# 1. fleetmanager
cd /usr/src/gameflexmatch/huaweicloud-solution-gameflexmatch-fleetmanager || exit
# 下载依赖包
go mod tidy
go build ./main.go
# 修改文件名
mv main fleetmanager-v1
# 2. appgateway
cd /usr/src/gameflexmatch/huaweicloud-solution-gameflexmatch-appgateway || exit
go mod tidy
go build ./cmd/application_gateway.go
mv application_gateway appgateway-v1
# 3. aass
cd /usr/src/gameflexmatch/huaweicloud-solution-gameflexmatch-aass || exit
go mod tidy
go build ./cmd/application-auto-scaling-service/application_auto_scaling_service.go
mv application_auto_scaling_service aass-v1
# 4. auxproxy
cd /usr/src/gameflexmatch/huaweicloud-solution-gameflexmatch-auxproxy || exit
go mod tidy
go build ./cmd/auxproxy.go

# cipher加解密
cd /usr/src/gameflexmatch/huaweicloud-solution-gameflexmatch/tools/cipher ||exit
go mod init cipher
go mod tidy
go build

# 获取自签名证书
mkdir -p /home/tlsSecret
cd /home/tlsSecret || exit
openssl genrsa -out tls.key 3072
/usr/bin/expect<<EOF
spawn openssl req -new -key tls.key -out tls.csr
expect "Country Name"
send "CN\r"
expect "State or Province Name"
send "BeiJing\r"
expect "Locality Name"
send "BeiJing\r"
expect "Organization Name"
send "Huawei\r"
expect "Organizational Unit Name"
send "Cloud\r"
expect "Common Name"
send "gameflexmatch\r"
expect "Email Address"
send "gameflexmatch@huawei.com\r"
expect "A challenge password"
send "$ecs_pwd\r"
expect "An optional company name"
send "Huawei\r"
expect eof
exit
EOF
openssl req -in tls.csr -text
openssl x509 -req -days 365 -in tls.csr -signkey tls.key -out tls.crt
openssl x509 -in tls.crt -text

# 获取公钥私钥
cd /home/tlsSecret || exit
openssl genrsa -out rsa_private.pem 2048
openssl rsa -in rsa_private.pem -pubout -out rsa_public.pem

# 安装AppGateway服务组件
mkdir -p /home/appgateway/conf/hmac
cd /home/appgateway/conf/hmac || exit
mv /usr/src/gameflexmatch/huaweicloud-solution-gameflexmatch/doc/build/appgateway/client_hmac_conf.json /home/appgateway/conf/hmac/
mv /usr/src/gameflexmatch/huaweicloud-solution-gameflexmatch/doc/build/appgateway/server_hmac_conf.json /home/appgateway/conf/hmac/
mkdir -p /home/appgateway/bin
cd /home/appgateway/bin || exit
mv /usr/src/gameflexmatch/huaweicloud-solution-gameflexmatch-appgateway/appgateway-v1 /home/appgateway/bin/
mv /usr/src/gameflexmatch/huaweicloud-solution-gameflexmatch/doc/build/appgateway/appgateway_run.sh /home/appgateway/bin/

# GCM加密
# shellcheck disable=SC2002
gcmkey=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9-_' | fold -w 24 | head -n 1)
# shellcheck disable=SC2002
gcmnonce=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9-_' | fold -w 16 | head -n 1)
# shellcheck disable=SC2002
gcmjwtkey=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)
cd /usr/src/gameflexmatch/huaweicloud-solution-gameflexmatch/tools/cipher || exit
gcm_rds_mysql_pwd=$(./cipher -mode encode -str "$rds_mysql_pwd" -key "$gcmkey" -nonce "$gcmnonce"  -cipher-method GCM | tail -1 | awk '{print $NF}')
gcm_influx_pwd=$(./cipher -mode encode -str "$influx_pwd" -key "$gcmkey" -nonce "$gcmnonce"  -cipher-method GCM | tail -1 | awk '{print $NF}')
gcm_redis_pwd=$(./cipher -mode encode -str "$redis_pwd" -key "$gcmkey" -nonce "$gcmnonce"  -cipher-method GCM | tail -1 | awk '{print $NF}')
gcm_ak=$(./cipher -mode encode -str "$ak" -key "$gcmkey" -nonce "$gcmnonce"  -cipher-method GCM | tail -1 | awk '{print $NF}')
gcm_sk=$(./cipher -mode encode -str "$sk" -key "$gcmkey" -nonce "$gcmnonce"  -cipher-method GCM | tail -1 | awk '{print $NF}')

# 创建Influx数据库
wget -P /usr/local/ https://dl.influxdata.com/influxdb/releases/influxdb-1.7.9-static_linux_amd64.tar.gz
tar -xzf /usr/local/influxdb-1.7.9-static_linux_amd64.tar.gz -C /usr/local
cd  /usr/local/influxdb-1.7.9-1/ ||exit
/usr/bin/expect<<EOF
spawn ./influx -ssl -unsafeSsl -username 'rwuser' -password '$influx_pwd' -host $influx_ip -port 8635
expect ">"
send "AUTH rwuser $influx_pwd\r"
expect ">"
send "CREATE DATABASE gameflexmatch\r"
expect ">"
send "SHOW DATABASES\r"
expect eof
exit
EOF

# 配置appgateway_run.sh
sed -i "s/version={version}/version=v1/" /home/appgateway/bin/appgateway_run.sh
sed -i "s/{aass_host}:{aass_port}/$elb_aass_ip:9091/" /home/appgateway/bin/appgateway_run.sh
sed -i "s/{mysql_host}:{mysql_port}	/$rds_mysql_ip:3306/" /home/appgateway/bin/appgateway_run.sh
sed -i "s/{mysql_appgateway_database}/appgateway/" /home/appgateway/bin/appgateway_run.sh
sed -i "s/{mysql_password}/$gcm_rds_mysql_pwd/" /home/appgateway/bin/appgateway_run.sh
sed -i "s/{mysql_username}/appgateway/" /home/appgateway/bin/appgateway_run.sh
sed -i "s/{influx_host}:{influx_port}/$influx_ip:8635/" /home/appgateway/bin/appgateway_run.sh
sed -i "s/{influx_password}/$gcm_influx_pwd/" /home/appgateway/bin/appgateway_run.sh
sed -i "s/{influx_database}/gameflexmatch/" /home/appgateway/bin/appgateway_run.sh
sed -i "s/{influx_username}/rwuser/" /home/appgateway/bin/appgateway_run.sh
sed -i "s/{redis_host}:{redis_port}/$redis_ip:6379/" /home/appgateway/bin/appgateway_run.sh
sed -i "s/{redis_password}/$gcm_redis_pwd/" /home/appgateway/bin/appgateway_run.sh
sed -i "s/GCM_KEY=\*\*\*\*\*\*\*\*\*\*\*\*\*\*/GCM_KEY=$gcmkey/" /home/appgateway/bin/appgateway_run.sh
sed -i "s/GCM_NONCE=\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*/GCM_NONCE=$gcmnonce/" /home/appgateway/bin/appgateway_run.sh
mv /usr/src/gameflexmatch/huaweicloud-solution-gameflexmatch/doc/build/appgateway/appgateway.service /etc/systemd/system
cd /home/appgateway/bin || exit
chmod 750 appgateway-v1
chmod 750 appgateway_run.sh
systemctl enable appgateway.service
systemctl start appgateway.service
ps -aux | grep appgateway

# 配置第二个appgateway服务器
scp -r /home/tlsSecret/ root@"$apgw2_ip":/home/tlsSecret/
scp -r /home/appgateway/conf/hmac root@"$apgw2_ip":/tmp/hmac/
scp -r /home/appgateway/bin root@"$apgw2_ip":/tmp/bin/
scp /etc/systemd/system/appgateway.service root@"$apgw2_ip":/etc/systemd/system/
ssh -t root@"$apgw2_ip" > /tmp/init-env.log 2>&1 <<EEOOFF
mkdir -p /home/appgateway/{conf/hmac,bin}
mv /tmp/hmac/* /home/appgateway/conf/hmac/
mv /tmp/bin/* /home/appgateway/bin/
rm -rf /tmp/hmac/
rm -rf /tmp/bin/
cd /home/appgateway/bin || exit
chmod 750 appgateway-v1
chmod 750 appgateway_run.sh
systemctl enable appgateway.service
systemctl start appgateway.service
ps -aux | grep appgateway
EEOOFF

# 安装AASS服务组件
# 修改配置文件service_config.json
sed -i "s/{appgateway_host}:{appgateway_port}/$elb_apgw_ip:60003/" /usr/src/gameflexmatch/huaweicloud-solution-gameflexmatch/doc/build/aass/service_config.json
sed -i "s/{enterprise_project}/$eps_id/" /usr/src/gameflexmatch/huaweicloud-solution-gameflexmatch/doc/build/aass/service_config.json
# 修改配置文件aass_run.sh
sed -i "s/version={version}/version=v1/" /usr/src/gameflexmatch/huaweicloud-solution-gameflexmatch/doc/build/aass/aass_run.sh
sed -i "s/{influx_host}:{influx_port}/$influx_ip:8635/" /usr/src/gameflexmatch/huaweicloud-solution-gameflexmatch/doc/build/aass/aass_run.sh
sed -i "s/{influx_pwd}/$gcm_influx_pwd/" /usr/src/gameflexmatch/huaweicloud-solution-gameflexmatch/doc/build/aass/aass_run.sh
sed -i "s/{influx_database}/gameflexmatch/" /usr/src/gameflexmatch/huaweicloud-solution-gameflexmatch/doc/build/aass/aass_run.sh
sed -i "s/{influx_username}/rwuser/" /usr/src/gameflexmatch/huaweicloud-solution-gameflexmatch/doc/build/aass/aass_run.sh
sed -i "s/{mysql_host}:{mysql_port}	/$rds_mysql_ip:3306/" /usr/src/gameflexmatch/huaweicloud-solution-gameflexmatch/doc/build/aass/aass_run.sh
sed -i "s/{mysql_aass_database}/aass/" /usr/src/gameflexmatch/huaweicloud-solution-gameflexmatch/doc/build/aass/aass_run.sh
sed -i "s/{mysql_pwd}/$gcm_rds_mysql_pwd/" /usr/src/gameflexmatch/huaweicloud-solution-gameflexmatch/doc/build/aass/aass_run.sh
sed -i "s/{mysql_username}/aass/" /usr/src/gameflexmatch/huaweicloud-solution-gameflexmatch/doc/build/aass/aass_run.sh
sed -i "s/{ak}/$gcm_ak/" /usr/src/gameflexmatch/huaweicloud-solution-gameflexmatch/doc/build/aass/aass_run.sh
sed -i "s/{sk}/$gcm_sk/" /usr/src/gameflexmatch/huaweicloud-solution-gameflexmatch/doc/build/aass/aass_run.sh
sed -i "s/{managerUser_domain_id}/$domain_id/" /usr/src/gameflexmatch/huaweicloud-solution-gameflexmatch/doc/build/aass/aass_run.sh
sed -i "s/{region}/cn-north-4/g" /usr/src/gameflexmatch/huaweicloud-solution-gameflexmatch/doc/build/aass/aass_run.sh
sed -i "s/{endpoint}/myhuaweicloud.com/g" /usr/src/gameflexmatch/huaweicloud-solution-gameflexmatch/doc/build/aass/aass_run.sh
sed -i "s/GCM_KEY=\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*/GCM_KEY=$gcmkey/" /usr/src/gameflexmatch/huaweicloud-solution-gameflexmatch/doc/build/aass/aass_run.sh
sed -i "s/GCM_NONCE=\*\*\*\*\*\*\*\*\*\*\*\*\*\*/GCM_NONCE=$gcmnonce/" /usr/src/gameflexmatch/huaweicloud-solution-gameflexmatch/doc/build/aass/aass_run.sh
sed -i "s/{redis_host}:{redis_port}/$redis_ip:6379/" /usr/src/gameflexmatch/huaweicloud-solution-gameflexmatch/doc/build/aass/aass_run.sh
sed -i "s/REDIS_PASSWORD=\*\*\*\*\*\*\*\*\*\*\*\*/REDIS_PASSWORD=$gcm_redis_pwd/" /usr/src/gameflexmatch/huaweicloud-solution-gameflexmatch/doc/build/aass/aass_run.sh

# 拷贝文件
aass_sers_ip=("$aass1_ip" "$aass2_ip")
for ip in "${aass_sers_ip[@]}"
do
scp -r /home/tlsSecret/ root@"$ip":/home/tlsSecret/
scp /usr/src/gameflexmatch/huaweicloud-solution-gameflexmatch-aass/aass-v1 root@"$ip":/home/aass-v1
scp /usr/src/gameflexmatch/huaweicloud-solution-gameflexmatch/doc/build/aass/aass.service root@"$ip":/etc/systemd/system/aass.service
scp -r /usr/src/gameflexmatch/huaweicloud-solution-gameflexmatch/doc/build/aass/ root@"$ip":/home/bin/
ssh -t root@"$ip" > /tmp/init-env.log 2>&1 <<EEEOOOFFF
mkdir -p /home/aass/{bin,configmap}
mv /home/aass-v1 /home/aass/bin/
mv /home/bin/server_hmac_conf.json /home/aass/configmap/server_hmac_conf.json
mv /home/bin/service_config.json /home/aass/configmap/service_config.json
mv /home/bin/aass_run.sh /home/aass/bin/
rm -rf /home/bin/
cd /home/aass/bin || exit
chmod 750 aass-v1
chmod 750 aass_run.sh
systemctl enable aass.service
systemctl start aass.service
ps -aux | grep aass
EEEOOOFFF
done

# 安装FleetManager服务组件
yum install -y zip
cp /usr/src/gameflexmatch/huaweicloud-solution-gameflexmatch-auxproxy/auxproxy /usr/src/gameflexmatch/huaweicloud-solution-gameflexmatch/doc/build/auxproxy
cd /usr/src/gameflexmatch/huaweicloud-solution-gameflexmatch/doc/build/auxproxy || exit
zip -r /tmp/auxproxy.zip ./
# 安装配置obsutil
wget -O /usr/local/obsutil.tar.gz https://obs-community.obs.cn-north-1.myhuaweicloud.com/obsutil/current/obsutil_linux_amd64.tar.gz
mkdir -p /usr/local/obsutil
tar xf /usr/local/obsutil.tar.gz --strip-components 1 -C /usr/local/obsutil
chmod 755 /usr/local/obsutil
/usr/local/obsutil/obsutil config -i="$ak" -k="$sk" -e=obs.cn-north-4.myhuaweicloud.com
# 上传文件到OBS
/usr/local/obsutil/obsutil cp /tmp/auxproxy.zip obs://"$obs_name"/
/usr/local/obsutil/obsutil cp /usr/src/gameflexmatch/huaweicloud-solution-gameflexmatch/doc/build/image_env.sh obs://"$obs_name"/
/usr/local/obsutil/obsutil cp /usr/src/gameflexmatch/huaweicloud-solution-gameflexmatch/doc/build/docker_image_env.sh obs://"$obs_name"/

# 修改配置文件service_config.json
sed -i "s/{region}.{endpoint}/cn-north-4.myhuaweicloud.com/g" /usr/src/gameflexmatch/huaweicloud-solution-gameflexmatch/doc/build/fleetmanager/service_config.json
sed -i "s/{aass_host}:{aass_port}/$elb_aass_ip:9091/" /usr/src/gameflexmatch/huaweicloud-solution-gameflexmatch/doc/build/fleetmanager/service_config.json
sed -i "s/{appgateway_host}:{appgateway_port}/$elb_apgw_ip:60003/g" /usr/src/gameflexmatch/huaweicloud-solution-gameflexmatch/doc/build/fleetmanager/service_config.json
sed -i "s/{appgateway_host}/$apgw2_pub_ip/" /usr/src/gameflexmatch/huaweicloud-solution-gameflexmatch/doc/build/fleetmanager/service_config.json
sed -i "s/{aass_host}/$aass2_pub_ip/" /usr/src/gameflexmatch/huaweicloud-solution-gameflexmatch/doc/build/fleetmanager/service_config.json
sed -i 's/"{region}"/"cn-north-4"/g' /usr/src/gameflexmatch/huaweicloud-solution-gameflexmatch/doc/build/fleetmanager/service_config.json
# 配置公网访问
sed -i "51 i \        {" /usr/src/gameflexmatch/huaweicloud-solution-gameflexmatch/doc/build/fleetmanager/service_config.json
sed -i "52 i \            \"protocol\": \"TCP\"," /usr/src/gameflexmatch/huaweicloud-solution-gameflexmatch/doc/build/fleetmanager/service_config.json
sed -i "53 i \            \"ip_range\": \"$aass1_pub_ip/32\"," /usr/src/gameflexmatch/huaweicloud-solution-gameflexmatch/doc/build/fleetmanager/service_config.json
sed -i "54 i \            \"from_port\": 60001," /usr/src/gameflexmatch/huaweicloud-solution-gameflexmatch/doc/build/fleetmanager/service_config.json
sed -i "55 i \            \"to_port\": 60001" /usr/src/gameflexmatch/huaweicloud-solution-gameflexmatch/doc/build/fleetmanager/service_config.json
sed -i "56 i \        }," /usr/src/gameflexmatch/huaweicloud-solution-gameflexmatch/doc/build/fleetmanager/service_config.json
sed -i "45 i \        {" /usr/src/gameflexmatch/huaweicloud-solution-gameflexmatch/doc/build/fleetmanager/service_config.json
sed -i "46 i \            \"protocol\": \"TCP\"," /usr/src/gameflexmatch/huaweicloud-solution-gameflexmatch/doc/build/fleetmanager/service_config.json
sed -i "47 i \            \"ip_range\": \"$apgw1_pub_ip/32\"," /usr/src/gameflexmatch/huaweicloud-solution-gameflexmatch/doc/build/fleetmanager/service_config.json
sed -i "48 i \            \"from_port\": 60001," /usr/src/gameflexmatch/huaweicloud-solution-gameflexmatch/doc/build/fleetmanager/service_config.json
sed -i "49 i \            \"to_port\": 60001" /usr/src/gameflexmatch/huaweicloud-solution-gameflexmatch/doc/build/fleetmanager/service_config.json
sed -i "50 i \        }," /usr/src/gameflexmatch/huaweicloud-solution-gameflexmatch/doc/build/fleetmanager/service_config.json
# 配置内网访问
sed -i "45 i \        {" /usr/src/gameflexmatch/huaweicloud-solution-gameflexmatch/doc/build/fleetmanager/service_config.json
sed -i "46 i \            \"protocol\": \"TCP\"," /usr/src/gameflexmatch/huaweicloud-solution-gameflexmatch/doc/build/fleetmanager/service_config.json
sed -i "47 i \            \"ip_range\": \"192.168.0.0/16\"," /usr/src/gameflexmatch/huaweicloud-solution-gameflexmatch/doc/build/fleetmanager/service_config.json
sed -i "48 i \            \"from_port\": 60001," /usr/src/gameflexmatch/huaweicloud-solution-gameflexmatch/doc/build/fleetmanager/service_config.json
sed -i "49 i \            \"to_port\": 60001" /usr/src/gameflexmatch/huaweicloud-solution-gameflexmatch/doc/build/fleetmanager/service_config.json
sed -i "50 i \        }," /usr/src/gameflexmatch/huaweicloud-solution-gameflexmatch/doc/build/fleetmanager/service_config.json

# 修改配置文件fleetmanager_run.sh
sed -i "s/version={version}/version=v1/" /usr/src/gameflexmatch/huaweicloud-solution-gameflexmatch/doc/build/fleetmanager/fleetmanager_run.sh
sed -i "s/{mysql_host}:{mysql_port}	/$rds_mysql_ip:3306/" /usr/src/gameflexmatch/huaweicloud-solution-gameflexmatch/doc/build/fleetmanager/fleetmanager_run.sh
sed -i "s/{mysql_fleetmanager_database}/fleetmanager/" /usr/src/gameflexmatch/huaweicloud-solution-gameflexmatch/doc/build/fleetmanager/fleetmanager_run.sh
sed -i "s/{mysql_pwd}/$gcm_rds_mysql_pwd/" /usr/src/gameflexmatch/huaweicloud-solution-gameflexmatch/doc/build/fleetmanager/fleetmanager_run.sh
sed -i "s/{mysql_user}/fleetmanager/" /usr/src/gameflexmatch/huaweicloud-solution-gameflexmatch/doc/build/fleetmanager/fleetmanager_run.sh
sed -i "s/{redis_host}:{redis_port}/$redis_ip:6379/" /usr/src/gameflexmatch/huaweicloud-solution-gameflexmatch/doc/build/fleetmanager/fleetmanager_run.sh
sed -i "s/{redis_password}/$gcm_redis_pwd/" /usr/src/gameflexmatch/huaweicloud-solution-gameflexmatch/doc/build/fleetmanager/fleetmanager_run.sh
sed -i "s/{ak}/$gcm_ak/" /usr/src/gameflexmatch/huaweicloud-solution-gameflexmatch/doc/build/fleetmanager/fleetmanager_run.sh
sed -i "s/{sk}/$gcm_sk/" /usr/src/gameflexmatch/huaweicloud-solution-gameflexmatch/doc/build/fleetmanager/fleetmanager_run.sh
sed -i "s/{managerUser_domain_id}/$domain_id/" /usr/src/gameflexmatch/huaweicloud-solution-gameflexmatch/doc/build/fleetmanager/fleetmanager_run.sh
sed -i "s/{enterprise_project}/$eps_id/" /usr/src/gameflexmatch/huaweicloud-solution-gameflexmatch/doc/build/fleetmanager/fleetmanager_run.sh
sed -i "s/GCM_KEY=\*\*\*\*\*\*\*\*\*\*\*\*\*\*/GCM_KEY=$gcmkey/" /usr/src/gameflexmatch/huaweicloud-solution-gameflexmatch/doc/build/fleetmanager/fleetmanager_run.sh
sed -i "s/GCM_NONCE=\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*/GCM_NONCE=$gcmnonce/" /usr/src/gameflexmatch/huaweicloud-solution-gameflexmatch/doc/build/fleetmanager/fleetmanager_run.sh
sed -i "s|gameflexmatch/image_env.sh|$obs_name/image_env.sh|" /usr/src/gameflexmatch/huaweicloud-solution-gameflexmatch/doc/build/fleetmanager/fleetmanager_run.sh
sed -i "s|gameflexmatch/docker_image_env.sh|$obs_name/docker_image_env.sh|" /usr/src/gameflexmatch/huaweicloud-solution-gameflexmatch/doc/build/fleetmanager/fleetmanager_run.sh
sed -i "s|gameflexmatch/auxproxy.zip|$obs_name/auxproxy.zip|" /usr/src/gameflexmatch/huaweicloud-solution-gameflexmatch/doc/build/fleetmanager/fleetmanager_run.sh
sed -i "s/{region}/cn-north-4/g" /usr/src/gameflexmatch/huaweicloud-solution-gameflexmatch/doc/build/fleetmanager/fleetmanager_run.sh
sed -i "s/{jwt_token_generate_key}/$gcmjwtkey/" /usr/src/gameflexmatch/huaweicloud-solution-gameflexmatch/doc/build/fleetmanager/fleetmanager_run.sh
sed -i "s/{default_login_password}/$ecs_pwd/" /usr/src/gameflexmatch/huaweicloud-solution-gameflexmatch/doc/build/fleetmanager/fleetmanager_run.sh

# 配置服务器
fmgr_sers_ip=("$fmgr1_ip" "$fmgr2_ip")
for ip in "${fmgr_sers_ip[@]}"
do
scp -r /home/tlsSecret/ root@"$ip":/home/tlsSecret/
scp -r /usr/src/gameflexmatch/huaweicloud-solution-gameflexmatch/doc/build/fleetmanager/ root@"$ip":/tmp/fleetmanager/
scp /usr/src/gameflexmatch/huaweicloud-solution-gameflexmatch-fleetmanager/fleetmanager-v1 root@"$ip":/tmp/fleetmanager/
scp /usr/src/gameflexmatch/huaweicloud-solution-gameflexmatch/doc/build/fleetmanager/fleetmanager.service root@"$ip":/etc/systemd/system/fleetmanager.service
ssh -t root@"$ip" > /tmp/init-env.log 2>&1 <<EEEEOOOOFFFF
mkdir -p /home/fleetmanager/{configmap,bin/conf/workflow}
mv /tmp/fleetmanager/service_config.json /home/fleetmanager/configmap
mv /tmp/fleetmanager/* /home/fleetmanager/bin/conf/workflow
mv /home/fleetmanager/bin/conf/workflow/fleetmanager-v1 /home/fleetmanager/bin/fleetmanager-v1
mv /home/fleetmanager/bin/conf/workflow/fleetmanager_run.sh /home/fleetmanager/bin/
rm -rf /home/fleetmanager/bin/conf/workflow/fleetmanager.service
rm -rf /tmp/fleetmanager/
cd /home/fleetmanager/bin || exit
chmod 750 fleetmanager-v1
chmod 750 fleetmanager_run.sh
systemctl enable fleetmanager.service
systemctl start fleetmanager.service
ps -aux | grep fleetmanager
EEEEOOOOFFFF
done

rm -rf /usr/src/gameflexmatch/huaweicloud-solution-gameflexmatch-fleetmanager
rm -rf /usr/src/gameflexmatch/huaweicloud-solution-gameflexmatch-appgateway
rm -rf /usr/src/gameflexmatch/huaweicloud-solution-gameflexmatch-aass
rm -rf /usr/src/gameflexmatch/huaweicloud-solution-gameflexmatch-auxproxy