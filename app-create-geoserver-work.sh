WORKSPACE_NAME=test4

rhc ssh -- 'env | grep -e ^OPENSHIFT_POSTGRESQL'
env | grep OPENSHIFT

cat <<SKIP_THIS

echo Add workspace
curl -v http://geoserver-ipsius.rhcloud.com/rest/workspaces -XPOST \
-u admin:pw=admin \
-H "Content-type: text/xml" \
-d @- << REQUEST_DATA
<workspace><name>$WORKSPACE_NAME</name></workspace>
REQUEST_DATA





echo Add database
curl -v http://geoserver-ipsius.rhcloud.com/rest/workspaces/test-ipsius/datastores -XPOST \
-u admin:pw=admin \
-H "Content-type: text/xml" \
-d @- << REQUEST_DATA
<dataStore><name>nyc</name><connectionParameters><host>localhost</host><port>5432</port><database>nyc</database><user>bob</user><passwd>postgres</passwd><dbtype>postgis</dbtype></connectionParameters></dataStore>
REQUEST_DATA

SKIP_THIS

