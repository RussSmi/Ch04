param location string = resourceGroup().location
param prefix string
param apimEmail string

// Create the appInsights workspace
resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2020-10-01' = {
  name: '${prefix}workspace'
  location: location
  properties: {
    sku: {
      name: 'PerGB2018'
    }
  }
}

resource appInsights 'Microsoft.Insights/components@2020-02-02-preview' = {
  name: '${prefix}apiminsights'
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
    WorkspaceResourceId: logAnalyticsWorkspace.id
  }
}

resource apim 'Microsoft.ApiManagement/service@2020-12-01' = {
  name: '${prefix}apim'
  location: location
  sku:{
    capacity: 1
    name: 'Developer'
  }
  identity:{
    type: 'SystemAssigned'
  }
  properties:{
    virtualNetworkType: 'None'
    publisherEmail: apimEmail
    publisherName: 'russ'
  }
}

resource namedValueAppInsightsKey 'Microsoft.ApiManagement/service/namedValues@2021-08-01' = {
  parent: apim
  name: 'instrumentationKey'
  properties: {
    tags: []
    secret: false
    displayName: 'instrumentationKey'
    value: appInsights.properties.InstrumentationKey
  }
}

resource apimLogger 'Microsoft.ApiManagement/service/loggers@2021-08-01' = {
  parent: apim
  name: '${prefix}apimlogger'
  properties:{
    resourceId: appInsights.id
    description: 'Application Insights for APIM'
    loggerType: 'applicationInsights'
    credentials:{
      instrumentationKey: namedValueAppInsightsKey.properties.value
    }
  }
}

// Create API for exisitng apis from challenge 03



resource sohch04apim_newrating 'Microsoft.ApiManagement/service/apis@2021-08-01' = {
  parent: apim
  name: 'newrating'
  properties: {
    displayName: 'NewRating'
    apiRevision: '1'
    description: 'Import from "sohch03-function-app" Function App'
    subscriptionRequired: true
    path: 'rating/create'
    protocols: [
      'https'
    ]
    isCurrent: true
  }
}

resource sohch04apim_products 'Microsoft.ApiManagement/service/apis@2021-08-01' = {
  parent: apim
  name: 'products'
  properties: {
    displayName: 'Products'
    apiRevision: '1'
    subscriptionRequired: true
    serviceUrl: 'https://serverlessohapi.azurewebsites.net/api/'
    path: 'products'
    protocols: [
      'https'
    ]
    isCurrent: true
  }
}

resource sohch04apim_rating 'Microsoft.ApiManagement/service/apis@2021-08-01' = {
  parent: apim
  name: 'rating'
  properties: {
    displayName: 'Rating'
    apiRevision: '1'
    description: 'Import from "sohch03-function-app" Function App'
    subscriptionRequired: true
    path: 'ratingapi'
    protocols: [
      'https'
    ]
    isCurrent: true
  }
}

resource sohch04apim_user 'Microsoft.ApiManagement/service/apis@2021-08-01' = {
  parent: apim
  name: 'user'
  properties: {
    displayName: 'User'
    apiRevision: '1'
    subscriptionRequired: true
    serviceUrl: 'https://serverlessohapi.azurewebsites.net/api/GetUser'
    path: 'user'
    protocols: [
      'https'
    ]
    isCurrent: true
  }
}

resource sohch04apim_sohch03_function_app 'Microsoft.ApiManagement/service/backends@2021-08-01' = {
  parent: apim
  name: 'sohch03-function-app'
  properties: {
    description: 'sohch03-function-app'
    url: 'https://sohch03-function-app.azurewebsites.net/api'
    protocol: 'http'
    resourceId: '${environment().resourceManager}/subscriptions/ca9ae6cf-2ab2-48d0-981d-c1030fd74a64/resourceGroups/rg-open-hack-serverless-ch03/providers/Microsoft.Web/sites/sohch03-function-app'
    credentials: {
      header: {
        'x-functions-key': [
          '{{sohch03-function-app-key}}'
        ]
      }
    }
  }
}

resource sohch04apim_sohch03_function_app_key 'Microsoft.ApiManagement/service/namedValues@2021-08-01' = {
  parent: apim
  name: 'sohch03-function-app-key'
  properties: {
    displayName: 'sohch03-function-app-key'
    tags: [
      'key'
      'function'
      'auto'
    ]
    secret: true
    value: 'JOfi7wbPEcN85RHI48eghCI2uafbWVOjfzM3oMA4rjClKoGRXm77Mw=='
  }
}

resource sohch04apim_external 'Microsoft.ApiManagement/service/products@2021-08-01' = {
  parent: apim
  name: 'external'
  properties: {
    displayName: 'External'
    description: 'External Partners, get products only'
    subscriptionRequired: true
    approvalRequired: false
    state: 'published'
  }
}

resource sohch04apim_internal 'Microsoft.ApiManagement/service/products@2021-08-01' = {
  parent: apim
  name: 'internal'
  properties: {
    displayName: 'Internal'
    description: 'Internal users, get products and get rating'
    subscriptionRequired: true
    approvalRequired: false
    state: 'published'
  }
}

resource sohch04apim_mobile_app 'Microsoft.ApiManagement/service/products@2021-08-01' = {
  parent: apim
  name: 'mobile-app'
  properties: {
    displayName: 'Mobile App'
    description: 'Product for mobile users, unlimited access'
    subscriptionRequired: true
    approvalRequired: false
    state: 'published'
  }
}

resource Microsoft_ApiManagement_service_properties_sohch04apim_sohch03_function_app_key 'Microsoft.ApiManagement/service/properties@2019-01-01' = {
  parent: apim
  name: 'sohch03-function-app-key'
  properties: {
    displayName: 'sohch03-function-app-key'
    value: 'JOfi7wbPEcN85RHI48eghCI2uafbWVOjfzM3oMA4rjClKoGRXm77Mw=='
    tags: [
      'key'
      'function'
      'auto'
    ]
    secret: true
  }
}

resource sohch04apim_newrating_post_createrating 'Microsoft.ApiManagement/service/apis/operations@2021-08-01' = {
  parent: sohch04apim_newrating
  name: 'post-createrating'
  properties: {
    displayName: 'CreateRating'
    method: 'POST'
    urlTemplate: '/CreateRating'
    templateParameters: []
    responses: []
  }
}

resource sohch04apim_products_getproduct 'Microsoft.ApiManagement/service/apis/operations@2021-08-01' = {
  parent: sohch04apim_products
  name: 'getproduct'
  properties: {
    displayName: 'GetProduct'
    method: 'GET'
    urlTemplate: '/GetProduct'
    templateParameters: []
    request: {
      queryParameters: [
        {
          name: 'productId'
          type: 'string'
          required: true
          values: []
        }
      ]
      headers: []
      representations: []
    }
    responses: []
  }
}

resource sohch04apim_products_getproducts 'Microsoft.ApiManagement/service/apis/operations@2021-08-01' = {
  parent: sohch04apim_products
  name: 'getproducts'
  properties: {
    displayName: 'GetProducts'
    method: 'GET'
    urlTemplate: '/GetProducts'
    templateParameters: []
    responses: []
  }
}

resource sohch04apim_rating_get_getrating 'Microsoft.ApiManagement/service/apis/operations@2021-08-01' = {
  parent: sohch04apim_rating
  name: 'get-getrating'
  properties: {
    displayName: 'GetRating'
    method: 'GET'
    urlTemplate: '/rating/{id}'
    templateParameters: [
      {
        name: 'id'
        required: true
        values: []
        type: 'string'
      }
    ]
    responses: []
  }
}

resource sohch04apim_rating_get_getratings 'Microsoft.ApiManagement/service/apis/operations@2021-08-01' = {
  parent: sohch04apim_rating
  name: 'get-getratings'
  properties: {
    displayName: 'GetRatings'
    method: 'GET'
    urlTemplate: '/GetRatings'
    templateParameters: []
    responses: []
  }
}

resource sohch04apim_user_get 'Microsoft.ApiManagement/service/apis/operations@2021-08-01' = {
  parent: sohch04apim_user
  name: 'get'
  properties: {
    displayName: 'Get'
    method: 'GET'
    urlTemplate: '/'
    templateParameters: []
    request: {
      queryParameters: [
        {
          name: 'userId'
          type: 'string'
          required: true
          values: []
        }
      ]
      headers: []
      representations: []
    }
    responses: []
  }
}

resource sohch04apim_external_policy 'Microsoft.ApiManagement/service/products/policies@2021-08-01' = {
  parent: sohch04apim_external
  name: 'policy'
  properties: {
    value: '<!--\r\n    IMPORTANT:\r\n    - Policy elements can appear only within the <inbound>, <outbound>, <backend> section elements.\r\n    - To apply a policy to the incoming request (before it is forwarded to the backend service), place a corresponding policy element within the <inbound> section element.\r\n    - To apply a policy to the outgoing response (before it is sent back to the caller), place a corresponding policy element within the <outbound> section element.\r\n    - To add a policy, place the cursor at the desired insertion point and select a policy from the sidebar.\r\n    - To remove a policy, delete the corresponding policy statement from the policy document.\r\n    - Position the <base> element within a section element to inherit all policies from the corresponding section element in the enclosing scope.\r\n    - Remove the <base> element to prevent inheriting policies from the corresponding section element in the enclosing scope.\r\n    - Policies are applied in the order of their appearance, from the top down.\r\n    - Comments within policy elements are not supported and may disappear. Place your comments between policy elements or at a higher level scope.\r\n-->\r\n<policies>\r\n  <inbound>\r\n    <base />\r\n    <rate-limit-by-key calls="60" renewal-period="15" counter-key="@(context.Subscription?.Key ?? &quot;anonymous&quot;)" />\r\n  </inbound>\r\n  <backend>\r\n    <base />\r\n  </backend>\r\n  <outbound>\r\n    <base />\r\n  </outbound>\r\n  <on-error>\r\n    <base />\r\n  </on-error>\r\n</policies>'
    format: 'xml'
  }
}

resource sohch04apim_internal_policy 'Microsoft.ApiManagement/service/products/policies@2021-08-01' = {
  parent: sohch04apim_internal
  name: 'policy'
  properties: {
    value: '<!--\r\n    IMPORTANT:\r\n    - Policy elements can appear only within the <inbound>, <outbound>, <backend> section elements.\r\n    - To apply a policy to the incoming request (before it is forwarded to the backend service), place a corresponding policy element within the <inbound> section element.\r\n    - To apply a policy to the outgoing response (before it is sent back to the caller), place a corresponding policy element within the <outbound> section element.\r\n    - To add a policy, place the cursor at the desired insertion point and select a policy from the sidebar.\r\n    - To remove a policy, delete the corresponding policy statement from the policy document.\r\n    - Position the <base> element within a section element to inherit all policies from the corresponding section element in the enclosing scope.\r\n    - Remove the <base> element to prevent inheriting policies from the corresponding section element in the enclosing scope.\r\n    - Policies are applied in the order of their appearance, from the top down.\r\n    - Comments within policy elements are not supported and may disappear. Place your comments between policy elements or at a higher level scope.\r\n-->\r\n<policies>\r\n  <inbound>\r\n    <base />\r\n    <rate-limit-by-key calls="30" renewal-period="10" counter-key="@(context.Subscription?.Key ?? &quot;anonymous&quot;)" />\r\n  </inbound>\r\n  <backend>\r\n    <base />\r\n  </backend>\r\n  <outbound>\r\n    <base />\r\n  </outbound>\r\n  <on-error>\r\n    <base />\r\n  </on-error>\r\n</policies>'
    format: 'xml'
  }
}

