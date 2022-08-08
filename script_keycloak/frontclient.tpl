{
  "clientId": "_NAME_-frontclient",
  "rootUrl": "https://_URL_",
  "surrogateAuthRequired": false,
  "enabled": true,
  "alwaysDisplayInConsole": false,
  "clientAuthenticatorType": "client-secret",
  "redirectUris": [
    "https://_URL_/*",
    "https://_SSOURL_/*"
  ],
  "webOrigins": [
    "*"
  ],
  "notBefore": 0,
  "bearerOnly": false,
  "consentRequired": false,
  "standardFlowEnabled": true,
  "implicitFlowEnabled": false,
  "directAccessGrantsEnabled": true,
  "serviceAccountsEnabled": false,
  "publicClient": true,
  "frontchannelLogout": false,
  "protocol": "openid-connect",
  "attributes": {
    "access.token.lifespan": "1800",
    "saml.multivalued.roles": "false",
    "saml.force.post.binding": "false",
    "frontchannel.logout.session.required": "true",
    "oauth2.device.authorization.grant.enabled": "false",
    "backchannel.logout.revoke.offline.tokens": "false",
    "saml.server.signature.keyinfo.ext": "false",
    "use.refresh.tokens": "true",
    "oidc.ciba.grant.enabled": "false",
    "backchannel.logout.session.required": "true",
    "client_credentials.use_refresh_token": "false",
    "saml.client.signature": "false",
    "require.pushed.authorization.requests": "false",
    "saml.allow.ecp.flow": "false",
    "saml.assertion.signature": "false",
    "id.token.as.detached.signature": "false",
    "saml.encrypt": "false",
    "saml.server.signature": "false",
    "exclude.session.state.from.auth.response": "false",
    "saml.artifact.binding": "false",
    "saml_force_name_id_format": "false",
    "tls.client.certificate.bound.access.tokens": "false",
    "acr.loa.map": "{}",
    "saml.authnstatement": "false",
    "display.on.consent.screen": "false",
    "token.response.type.bearer.lower-case": "false",
    "saml.onetimeuse.condition": "false"
  },
  "authenticationFlowBindingOverrides": {},
  "fullScopeAllowed": true,
  "nodeReRegistrationTimeout": -1,
  "defaultClientScopes": [
    "web-origins",
    "acr",
    "profile",
    "roles",
    "email"
  ],
  "optionalClientScopes": [
    "address",
    "phone",
    "offline_access",
    "microprofile-jwt"
  ],
  "access": {
    "view": true,
    "configure": true,
    "manage": true
  }
}
