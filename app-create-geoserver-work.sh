rhc ssh -- 'env | grep -e ^OPENSHIFT_POSTGRESQL_DB'
# and how are we going to get these locally?

# skipping till ready to configure geoserver
cat <<SKIP_THIS >/dev/null

WORKSPACE_NAME=test4

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
