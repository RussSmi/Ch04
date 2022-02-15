param location string = resourceGroup().location
param prefix string

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
    publisherEmail: 'rusmith@microsoft.com'
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
