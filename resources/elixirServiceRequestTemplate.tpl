{
    #if( $ctx.request.headers.Authorization.startsWith("Bearer ") )
        #set( $authorizationHeader =  $ctx.request.headers.Authorization )
    #else
        #set( $authorizationHeader =  "Bearer $ctx.request.headers.Authorization" )
    #end

    "version": "2018-05-29",
    "method": "${method}",
    "resourcePath": "${path}",
    "params": {
    ${body != null
    ? <<EOF
        "body": ${body},
    EOF
    : ""}
        "headers": {
          "Content-Type": "application/json",
          "Authorization": "$authorizationHeader",
          "X-GlideCloud-Tenant-Id": "$ctx.request.headers['x-glidecloud-tenant-id']"
        }
    }
}

