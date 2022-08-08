#!/bin/bash
#
# Declaração de variaveis
#
NEW_REALM="$2"
KEYCLOAK_URL="$1"
REALM_URL="$3"
KEYCLOAK_REALM="master"
KEYCLOAK_USER="certisign"
KEYCLOAK_SECRET="Certisign@123"
CURL_CMD='/usr/bin/curl -s --show-error'
REALM_FILE="realm.json"
SCOPES_FILE="client-scopes.json"
CLIENT_FILE="client.json"
CLIENT_FRONT_FILE="frontclient.json"
MAPPER_FILE="mapper.json"
USER_FILE="user.json"
PASS_FILE="user_password.json"

#
# Parametrizando os arquivos json
#
cp realm.tpl $REALM_FILE
cp client-scopes.tpl $SCOPES_FILE
cp client.tpl $CLIENT_FILE
cp frontclient.tpl $CLIENT_FRONT_FILE
cp mapper.tpl $MAPPER_FILE
cp user.tpl $USER_FILE
cp user_password.tpl $PASS_FILE

sed -i "s/_NAME_/$NEW_REALM/g" *.json
sed -i "s/_URL_/$REALM_URL/g" *.json
sed -i "s/_SSOURL_/$KEYCLOAK_URL/g" *.json

#
# Obtendo a chave token
#
ACCESS_TOKEN=$(${CURL_CMD} \
  -X POST \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "username=${KEYCLOAK_USER}" \
  -d "password=${KEYCLOAK_SECRET}" \
  -d "grant_type=password" \
  -d 'client_id=admin-cli' \
  "${KEYCLOAK_URL}/realms/${KEYCLOAK_REALM}/protocol/openid-connect/token"|jq -r '.access_token')

#
# Checando se o realm já existe
#
CHECK_REALM=$(${CURL_CMD} \
  -X GET \
  -H "Accept: application/json" \
  -H "Authorization: Bearer ${ACCESS_TOKEN}" \
  "${KEYCLOAK_URL}/admin/realms/${NEW_REALM}"|jq -r .realm)

#
# Condição para criação do realm
#
if [ "$CHECK_REALM" = "$NEW_REALM" ]
then
  echo "O realm $CHECK_REALM já foi criado"
else
  echo "Criado o realm $NEW_REALM..."
  ${CURL_CMD} \
    -X POST \
    -H "Authorization: Bearer ${ACCESS_TOKEN}" \
    -H "Content-Type: application/json" \
    -d @"${REALM_FILE}" \
    "${KEYCLOAK_URL}/admin/realms"
  CHECK_REALM=$(${CURL_CMD} \
    -X GET \
    -H "Accept: application/json" \
    -H "Authorization: Bearer ${ACCESS_TOKEN}" \
    "${KEYCLOAK_URL}/admin/realms/${NEW_REALM}"|jq -r .realm)
  echo "realm $CHECK_REALM criado com sucesso"
fi

#
# Checando se o client-scopes já existe
#
CHECK_SCOPES=$(${CURL_CMD} \
  -X GET \
  -H "Accept: application/json" \
  -H "Authorization: Bearer ${ACCESS_TOKEN}" \
  "${KEYCLOAK_URL}/admin/realms/${NEW_REALM}/client-scopes/" | jq ".[] | .name" | grep ${NEW_REALM}_audience)

#
# Condição para criação do client-scopes
#
if [ "${CHECK_SCOPES}" = \"${NEW_REALM}_audience\" ]
then
  echo "O client-scopes $CHECK_SCOPES já foi criado"
else
  echo "Criado o client-scopes ${NEW_REALM}_audience..."
  ${CURL_CMD} \
    -X POST \
    -H "Authorization: Bearer ${ACCESS_TOKEN}" \
    -H "Content-Type: application/json" \
    -d @"${SCOPES_FILE}" \
    "${KEYCLOAK_URL}/admin/realms/${NEW_REALM}/client-scopes"
  CHECK_SCOPES=$(${CURL_CMD} \
    -X GET \
    -H "Accept: application/json" \
    -H "Authorization: Bearer ${ACCESS_TOKEN}" \
    "${KEYCLOAK_URL}/admin/realms/${NEW_REALM}/client-scopes/" | jq ".[] | .name" | grep ${NEW_REALM}_audience)
  echo "client-scopes $CHECK_SCOPES criado com sucesso"
fi

#
# Checando se o user já existe
#
CHECK_USER=$(${CURL_CMD} \
  -X GET \
  -H "Accept: application/json" \
  -H "Authorization: Bearer ${ACCESS_TOKEN}" \
  "${KEYCLOAK_URL}/admin/realms/${NEW_REALM}/users/" | jq ".[] | .username" | grep "${NEW_REALM}-user")

#
# Condição para criação do user
#
if [ "$CHECK_USER" = \"${NEW_REALM}-user\" ]
then
  echo "O user $CHECK_USER já foi criado"
else
  echo "Criado o user ${NEW_REALM}-user..."
  ${CURL_CMD} \
    -X POST \
    -H "Authorization: Bearer ${ACCESS_TOKEN}" \
    -H "Content-Type: application/json" \
    -d @"${USER_FILE}" \
    "${KEYCLOAK_URL}/admin/realms/${NEW_REALM}/users"
  CHECK_USER_ID=$(${CURL_CMD} \
    -X GET \
    -H "Accept: application/json" \
    -H "Authorization: Bearer ${ACCESS_TOKEN}" \
    "${KEYCLOAK_URL}/admin/realms/${NEW_REALM}/users/" | jq '.[] | .id + " " + .username' | grep "${NEW_REALM}-user" | awk '{print $1}' | sed 's/\"//')
  ${CURL_CMD} \
    -X PUT \
    -H "Authorization: Bearer ${ACCESS_TOKEN}" \
    -H "Content-Type: application/json" \
    -d @"${PASS_FILE}" \
    "${KEYCLOAK_URL}/admin/realms/${NEW_REALM}/users/${CHECK_USER_ID}/reset-password"
  CHECK_USER=$(${CURL_CMD} \
    -X GET \
    -H "Accept: application/json" \
    -H "Authorization: Bearer ${ACCESS_TOKEN}" \
    "${KEYCLOAK_URL}/admin/realms/${NEW_REALM}/users/" | jq ".[] | .username" | grep "${NEW_REALM}-user")
  echo "user $CHECK_USER criado com sucesso"
fi

#
# Checando se o frontclient já existe
#
CHECK_CLIENT_FRONT=$(${CURL_CMD} \
  -X GET \
  -H "Accept: application/json" \
  -H "Authorization: Bearer ${ACCESS_TOKEN}" \
  "${KEYCLOAK_URL}/admin/realms/${NEW_REALM}/clients/" | jq ".[] | .clientId" | grep "${NEW_REALM}-frontclient")

#
# Condição para criação do frontclient
#
if [ "${CHECK_CLIENT_FRONT}" = \"${NEW_REALM}-frontclient\" ]
then
  echo "O client $CHECK_CLIENT_FRONT já foi criado"
else
  echo "Criado o client ${NEW_REALM}-frontclient..."
  ${CURL_CMD} \
    -X POST \
    -H "Authorization: Bearer ${ACCESS_TOKEN}" \
    -H "Content-Type: application/json" \
    -d @"${CLIENT_FRONT_FILE}" \
    "${KEYCLOAK_URL}/admin/realms/${NEW_REALM}/clients"
  CHECK_CLIENT_FRONT=$(${CURL_CMD} \
    -X GET \
    -H "Accept: application/json" \
    -H "Authorization: Bearer ${ACCESS_TOKEN}" \
    "${KEYCLOAK_URL}/admin/realms/${NEW_REALM}/clients/" | jq ".[] | .clientId" | grep "${NEW_REALM}-frontclient")
  echo "client $CHECK_CLIENT_FRONT criado com sucesso"
fi

#
# Checando se o client já existe
#
CHECK_CLIENT=$(${CURL_CMD} \
  -X GET \
  -H "Accept: application/json" \
  -H "Authorization: Bearer ${ACCESS_TOKEN}" \
  "${KEYCLOAK_URL}/admin/realms/${NEW_REALM}/clients/" | jq ".[] | .clientId" | grep "${NEW_REALM}client")

#
# Condição para criação do client
#
if [ "$CHECK_CLIENT" = \"${NEW_REALM}client\" ]
then
  echo "O client $CHECK_CLIENT já foi criado"
  CHECK_CLIENT_ID=$(${CURL_CMD} \
    -X GET \
    -H "Accept: application/json" \
    -H "Authorization: Bearer ${ACCESS_TOKEN}" \
    "${KEYCLOAK_URL}/admin/realms/${NEW_REALM}/clients/" | jq '.[] | .id + " " + .clientId' | grep "${NEW_REALM}client" | awk '{print $1}' | sed 's/\"//')
  SECRET_CLIENT=$(${CURL_CMD} \
    -X GET \
    -H "Authorization: Bearer ${ACCESS_TOKEN}" \
    -H "Content-Type: application/json" \
    "${KEYCLOAK_URL}/admin/realms/${NEW_REALM}/clients/${CHECK_CLIENT_ID}/client-secret" | jq .value)
  echo $SECRET_CLIENT > ${NEW_REALM}_secret.txt
  echo "Sua secret é: $SECRET_CLIENT"
else
  echo "Criado o client ${NEW_REALM}client..."
  ${CURL_CMD} \
    -X POST \
    -H "Authorization: Bearer ${ACCESS_TOKEN}" \
    -H "Content-Type: application/json" \
    -d @"${CLIENT_FILE}" \
    "${KEYCLOAK_URL}/admin/realms/${NEW_REALM}/clients"
  CHECK_CLIENT_ID=$(${CURL_CMD} \
    -X GET \
    -H "Accept: application/json" \
    -H "Authorization: Bearer ${ACCESS_TOKEN}" \
    "${KEYCLOAK_URL}/admin/realms/${NEW_REALM}/clients/" | jq '.[] | .id + " " + .clientId' | grep "${NEW_REALM}client" | awk '{print $1}' | sed 's/\"//')
  ${CURL_CMD} \
    -X POST \
    -H "Authorization: Bearer ${ACCESS_TOKEN}" \
    -H "Content-Type: application/json" \
    -d @"${MAPPER_FILE}" \
    "${KEYCLOAK_URL}/admin/realms/${NEW_REALM}/clients/${CHECK_CLIENT_ID}/protocol-mappers/models"
  SECRET_CLIENT=$(${CURL_CMD} \
    -X GET \
    -H "Authorization: Bearer ${ACCESS_TOKEN}" \
    -H "Content-Type: application/json" \
    "${KEYCLOAK_URL}/admin/realms/${NEW_REALM}/clients/${CHECK_CLIENT_ID}/client-secret" | jq .value)
  echo $SECRET_CLIENT > ${NEW_REALM}_secret.txt
  CHECK_CLIENT=$(${CURL_CMD} \
    -X GET \
    -H "Accept: application/json" \
    -H "Authorization: Bearer ${ACCESS_TOKEN}" \
    "${KEYCLOAK_URL}/admin/realms/${NEW_REALM}/clients/" | jq ".[] | .clientId" | grep "${NEW_REALM}client")
  echo "client $CHECK_CLIENT criado com sucesso"
  echo "Sua secret é: $SECRET_CLIENT"
fi

#
# Limpando os arquivos
#
rm $REALM_FILE
rm $SCOPES_FILE
rm $CLIENT_FILE
rm $USER_FILE
rm $PASS_FILE
rm $CLIENT_FRONT_FILE
rm $MAPPER_FILE

