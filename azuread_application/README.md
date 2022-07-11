
`app_roles.value` and `expose_api.oauth2_perm_scopes.value`
In Azure Active Directory, application roles (app_role) and permission scopes (oauth2_permission_scope) exported by an application share the same namespace and cannot contain duplicate values. Terraform will attempt to detect this during a plan or apply operation.

`required_accesses`
