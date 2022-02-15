param location string = resourceGroup().location

// Create the appInsights workspace
resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2020-10-01' = {
  name: 'cho04workspace'
  location: location
  properties: {
    sku: {
      name: 'Free'
    }
  }
}

resource appInsights 'Microsoft.Insights/components@2020-02-02-preview' = {
  name: 'apiminsights'
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
    WorkspaceResourceId: logAnalyticsWorkspace.id
  }
}

resource apim 'Microsoft.ApiManagement/service@2020-12-01' = {
  name: 'ch04apim'
  location: location
  sku:{
    capacity: 0
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
  name: 'apimlogger'
  properties:{
    resourceId: appInsights.id
    description: 'Application Insights for APIM'
    loggerType: 'applicationInsights'
    credentials:{
      instrumentationKey: {{instrumentationKey}}
    }
  }
}





