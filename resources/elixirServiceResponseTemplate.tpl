## Raise a GraphQL field error in case of a datasource invocation error
#if($ctx.error)
  $util.error($ctx.error.message, $ctx.error.type)
#end

## If the response is not ${success_code} then return an error. Else return the body's data **
#if($ctx.result.statusCode == ${success_code})
  #set( $body = $util.parseJson($ctx.result.body) )
  $util.toJson($body.data)
#else
  ## First we need to parse the JSON body into a map
  #set( $body = $util.parseJson($ctx.result.body) )

  #set( $errorMessage = "${error_message}" )
  #set( $errorType = "$ctx.result.statusCode" )

  ## Most, if not all, of Elixir Service API errors will contain a root 'error' key
  #if($body.error)
     #set( $errorInfo = $body.error )

  ## Sometimes it might be 'errors' instead - this is just incase
  #elseif($body.errors)
    #set( $errorInfo = $body.errors )
  #else
    ## Otherwise we just set the error to be whatever is in the body
    #set( $errorInfo = $body )
  #end

  ## Raises an error with the error message and type
  ## The $errorInfo, in this case, will describe invalidities in the user-provided fields
  $util.error($errorMessage, $errorType, null, $errorInfo)
#end
