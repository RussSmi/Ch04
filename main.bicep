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

resource appInsightsComponents 'Microsoft.Insights/components@2020-02-02-preview' = {
  name: 'apiminsights'
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
    WorkspaceResourceId: logAnalyticsWorkspace.id
  }
}

resource apiManagementInstance 'Microsoft.ApiManagement/service@2020-12-01' = {
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






