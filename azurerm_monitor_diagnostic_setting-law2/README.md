
#### Problem

│ Error: issuing AzureRM delete request for Log Analytics Workspaces '*': operationalinsights.WorkspacesClient#Delete: Failure sending request: StatusCode=0 -- Original Error: autorest/azure: Service returned an error. Status=<nil> Code="Conflict" Message="The workspace cannot be deleted because it's used by the following solution resources: /subscriptions/*/resourceGroups/*/providers/Microsoft.OperationalInsights/workspaces/*/views/SQLAccessToSensitiveData;/subscriptions/*/resourceGroups/*/providers/Microsoft.OperationalInsights/workspaces/*/views/SQLSecurityInsights"
│

#### Solution

Disable SQL serer -> Audition > to LAW
Delete LAW > Solution > SQL Server