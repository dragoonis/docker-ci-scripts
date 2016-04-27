docker pull my-registry.com/myapp:${BUILD_NUMBER}

mkdir -p /var/deploys/${BUILD_NUMBER}
cd /var/deploys/${BUILD_NUMBER}

# get ID of container
id=$(docker create my-registry.com/someproject:${BUILD_NUMBER})

# copy pre-baked files out of container to disk
docker cp $id:/var/www/docker-compose.preview.yml ./docker-compose.preview.yml
docker cp $id:/var/www/docker-compose.base.yml ./docker-compose.base.yml
docker cp $id:/var/www/opt ./opt

docker rm -v $id

docker-compose -f docker-compose.preview.yml up -d

# Wait for application to be ready
bash -c 'docker-compose -f docker-compose.preview.yml logs application | { sed "/fpm is running/ q" && kill -PIPE $$ ; }' > /dev/null 2>&1

# generate the new vhost and spin up the containers
(cd ~/pplwebsite-preview-scripts; bin/gen-staging-vhost.php; /usr/local/bin/docker-compose down; /usr/local/bin/docker-compose up -d)

# get port number for this container
port=`/usr/local/bin/docker-compose -f docker-compose.preview.yml ps | grep application | grep -Po ':\d+-' | sed 's/://' | sed 's/-//'`

# hipchat notiication
curl -k -H "Content-Type: application/json" -X POST -d "{\"color\": \"green\", \"message_format\": \"text\", \"message\": \"Release: ${bamboo.planKey}-${bamboo.buildNumber} now available on preview: http://cs-testing-st.uk.company.com:${port} \" }" "https://hipchat.uk.company.com/v2/room/7/notification?auth_token=Pu0eDVH37327340p0mmsWxFrUkJSLm2ALKqsYfjZ"
