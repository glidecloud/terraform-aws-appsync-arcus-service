resource "null_resource" "graphql_schema" {
  triggers = {
    # Picks up any changes to the schema.graphql file
    graphql_schema = sha1(file("${path.module}/schema.graphql"))
  }
}

resource "aws_appsync_graphql_api" "graphql-api" {
  name = var.api_name

  # Depend on any changes to the graphql schema file
  # We need to recreate this resource whenever the file changes,
  # which will ensure any new resolvers are created subsequently.
  depends_on = [null_resource.graphql_schema]
  schema     = file("${path.module}/schema.graphql")

  authentication_type = var.authentication_type

  dynamic "log_config" {
    for_each = var.cloudwatch_logs_enabled ? [0] : []

    content {
      cloudwatch_logs_role_arn = "arn:aws:iam::953055471265:role/service-role/appsync-graphqlapi-logs-us-east-2"
      exclude_verbose_content  = true
      field_log_level          = "ALL"
    }
  }
}

resource "aws_appsync_api_key" "graphql-api-key" {
  api_id = aws_appsync_graphql_api.graphql-api.id
  description = "Well-known public API key for GraphQL access"
  expires = "2022-07-01T00:00:00Z"
}

resource "aws_appsync_datasource" "arcus-service" {
  api_id = aws_appsync_graphql_api.graphql-api.id
  name   = "ArcusService"
  type   = "HTTP"

  http_config {
    endpoint = "https://${var.api_hostname}"
  }
}

resource "aws_appsync_resolver" "indexedDocumentDetails" {
  api_id      = aws_appsync_graphql_api.graphql-api.id
  field       = "indexedDocumentDetails"
  type        = "Query"
  data_source = aws_appsync_datasource.arcus-service.name

  request_template = templatefile(local.request_template_path, {
    path   = "${local.arcus_api_path}/indexed-documents/$ctx.args.id"
    method = "GET"
    body   = null
  })

  response_template = templatefile(local.response_template_path, {
    success_code  = 200
    error_message = "Failed to fetch Document"
  })
}

resource "aws_appsync_resolver" "indexedDocumentDetailsMultiGetV1" {
  api_id      = aws_appsync_graphql_api.graphql-api.id
  field       = "indexedDocumentDetailsMultiGetV1"
  type        = "Query"
  data_source = aws_appsync_datasource.arcus-service.name

  request_template = templatefile(local.request_template_path, {
    path = "${local.arcus_api_path}/indexed-documents/multi-get/v1"
    # It's kind-of hard to extract the body from a get request in Elixir
    # so we just make this a POST request, but there are zero side-effects.
    method = "POST"
    body   = <<EOF
      {
         "ids": $util.toJson($ctx.args.ids)
      }
EOF
  })

  response_template = templatefile(local.response_template_path, {
    success_code  = 200
    error_message = "Failed to fetch multiple Documents by ID"
  })
}



resource "aws_appsync_resolver" "indexedDocumentDetailsBySequentialID" {
  api_id      = aws_appsync_graphql_api.graphql-api.id
  field       = "indexedDocumentDetailsBySequentialID"
  type        = "Query"
  data_source = aws_appsync_datasource.arcus-service.name

  request_template = templatefile(local.request_template_path, {
    path   = "${local.arcus_api_path}/indexed-documents/by-sequential-id/$ctx.args.tag/$ctx.args.id"
    method = "GET"
    body   = null
  })

  response_template = templatefile(local.response_template_path, {
    success_code  = 200
    error_message = "Failed to fetch Document $ctx.args.tag/$ctx.args.id"
  })
}

resource "aws_appsync_resolver" "indexedDocumentTags" {
  api_id      = aws_appsync_graphql_api.graphql-api.id
  field       = "indexedDocumentTags"
  type        = "Query"
  data_source = aws_appsync_datasource.arcus-service.name

  request_template = templatefile(local.request_template_path, {
    path   = "${local.arcus_api_path}/indexed-documents/search/v1/tags"
    method = "GET"
    body   = null
  })

  response_template = templatefile(local.response_template_path, {
    success_code  = 200
    error_message = "Failed to fetch tags within specified tenant."
  })
}

resource "aws_appsync_resolver" "indexedDocumentSearchV1" {
  api_id      = aws_appsync_graphql_api.graphql-api.id
  field       = "indexedDocumentSearchV1"
  type        = "Query"
  data_source = aws_appsync_datasource.arcus-service.name

  request_template = templatefile(local.request_template_path, {
    path   = "${local.arcus_api_path}/indexed-documents/search/v1"
    method = "POST"
    body   = <<EOF
      {
         "params": $util.toJson($ctx.args.query)
      }
EOF
  })

  response_template = templatefile(local.response_template_path, {
    success_code  = 200
    error_message = "Failed to fetch Document"
  })
}

resource "aws_appsync_resolver" "indexedDocumentListVersionsFull" {
  api_id      = aws_appsync_graphql_api.graphql-api.id
  field       = "indexedDocumentListVersionsFull"
  type        = "Query"
  data_source = aws_appsync_datasource.arcus-service.name

  request_template = templatefile(local.request_template_path, {
    path   = "${local.arcus_api_path}/indexed-documents/$ctx.args.id/versions/full"
    method = "GET"
    body   = null
  })

  response_template = templatefile(local.response_template_path, {
    success_code  = 200
    error_message = "Failed to fetch Document Versions"
  })
}

resource "aws_appsync_resolver" "indexedDocumentSearchV1DryRun" {
  api_id      = aws_appsync_graphql_api.graphql-api.id
  field       = "indexedDocumentSearchV1DryRun"
  type        = "Query"
  data_source = aws_appsync_datasource.arcus-service.name

  request_template = templatefile(local.request_template_path, {
    path   = "${local.arcus_api_path}/indexed-documents/search/v1/dry-run"
    method = "POST"
    body   = <<EOF
      {
         "params": $util.toJson($ctx.args.query)
      }
EOF
  })

  response_template = templatefile(local.response_template_path, {
    success_code  = 200
    error_message = "Failed to fetch Document"
  })
}

resource "aws_appsync_resolver" "indexedDocumentCreate" {
  api_id      = aws_appsync_graphql_api.graphql-api.id
  field       = "indexedDocumentCreate"
  type        = "Mutation"
  data_source = aws_appsync_datasource.arcus-service.name

  request_template = templatefile(local.request_template_path, {
    path   = "${local.arcus_api_path}/indexed-documents"
    method = "PUT"
    body   = <<EOF
      {
        "document": $util.toJson($ctx.args.input)
      }
EOF
  })

  response_template = templatefile(local.response_template_path, {
    success_code  = 201
    error_message = "Failed to create Document."
  })
}

resource "aws_appsync_resolver" "indexedDocumentUpdate" {
  api_id      = aws_appsync_graphql_api.graphql-api.id
  field       = "indexedDocumentUpdate"
  type        = "Mutation"
  data_source = aws_appsync_datasource.arcus-service.name

  request_template = templatefile(local.request_template_path, {
    path   = "${local.arcus_api_path}/indexed-documents/$ctx.args.id"
    method = "PATCH"
    body   = <<EOF
      {
        "document": $util.toJson($ctx.args.input)
      }
EOF
  })

  response_template = templatefile(local.response_template_path, {
    success_code  = 200
    error_message = "Failed to update Document with ID $ctx.args.id."
  })
}
