#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "oci_connect.h"
#include "../include/oracle_db_config.h"

static const char *read_env_or_default(const char *name, const char *default_value)
{
    const char *value = getenv(name);

    if (value == NULL || value[0] == '\0') {
        return default_value;
    }

    return value;
}

void oracle_print_error(OCIError *errhp, const char *message)
{
    text error_buffer[512];
    sb4 error_code = 0;

    OCIErrorGet(errhp, 1, NULL, &error_code, error_buffer, sizeof(error_buffer), OCI_HTYPE_ERROR);
    fprintf(stderr, "%s\n", message);
    fprintf(stderr, "OCI-%d: %s\n", (int) error_code, error_buffer);
}

int oracle_connect(OracleConnection *connection)
{
    const char *username = read_env_or_default(ORACLE_ENV_USER, NULL);
    const char *password = read_env_or_default(ORACLE_ENV_PASSWORD, NULL);
    const char *connect_string = read_env_or_default(
        ORACLE_ENV_CONNECT_STRING,
        ORACLE_DEFAULT_CONNECT_STRING
    );
    sword status;

    if (connection == NULL) {
        fprintf(stderr, "connection is NULL\n");
        return -1;
    }

    memset(connection, 0, sizeof(*connection));

    if (username == NULL || password == NULL) {
        fprintf(stderr, "Set ORACLE_USER and ORACLE_PASSWORD before running.\n");
        return -1;
    }

    status = OCIEnvCreate(&connection->envhp, OCI_DEFAULT, NULL, NULL, NULL, NULL, 0, NULL);
    if (status != OCI_SUCCESS) {
        fprintf(stderr, "Failed to create OCI environment.\n");
        return -1;
    }

    status = OCIHandleAlloc(connection->envhp, (dvoid **) &connection->errhp, OCI_HTYPE_ERROR, 0, NULL);
    if (status != OCI_SUCCESS) {
        fprintf(stderr, "Failed to allocate OCI error handle.\n");
        oracle_disconnect(connection);
        return -1;
    }

    status = OCIHandleAlloc(connection->envhp, (dvoid **) &connection->srvhp, OCI_HTYPE_SERVER, 0, NULL);
    if (status != OCI_SUCCESS) {
        oracle_print_error(connection->errhp, "Failed to allocate OCI server handle.");
        oracle_disconnect(connection);
        return -1;
    }

    status = OCIServerAttach(
        connection->srvhp,
        connection->errhp,
        (text *) connect_string,
        (sb4) strlen(connect_string),
        OCI_DEFAULT
    );
    if (status != OCI_SUCCESS) {
        oracle_print_error(connection->errhp, "Failed to attach to Oracle server.");
        oracle_disconnect(connection);
        return -1;
    }

    status = OCIHandleAlloc(connection->envhp, (dvoid **) &connection->svchp, OCI_HTYPE_SVCCTX, 0, NULL);
    if (status != OCI_SUCCESS) {
        oracle_print_error(connection->errhp, "Failed to allocate OCI service context.");
        oracle_disconnect(connection);
        return -1;
    }

    status = OCIAttrSet(
        connection->svchp,
        OCI_HTYPE_SVCCTX,
        connection->srvhp,
        0,
        OCI_ATTR_SERVER,
        connection->errhp
    );
    if (status != OCI_SUCCESS) {
        oracle_print_error(connection->errhp, "Failed to bind server to service context.");
        oracle_disconnect(connection);
        return -1;
    }

    status = OCIHandleAlloc(connection->envhp, (dvoid **) &connection->authp, OCI_HTYPE_SESSION, 0, NULL);
    if (status != OCI_SUCCESS) {
        oracle_print_error(connection->errhp, "Failed to allocate OCI session.");
        oracle_disconnect(connection);
        return -1;
    }

    status = OCIAttrSet(
        connection->authp,
        OCI_HTYPE_SESSION,
        (dvoid *) username,
        (ub4) strlen(username),
        OCI_ATTR_USERNAME,
        connection->errhp
    );
    if (status != OCI_SUCCESS) {
        oracle_print_error(connection->errhp, "Failed to set OCI username.");
        oracle_disconnect(connection);
        return -1;
    }

    status = OCIAttrSet(
        connection->authp,
        OCI_HTYPE_SESSION,
        (dvoid *) password,
        (ub4) strlen(password),
        OCI_ATTR_PASSWORD,
        connection->errhp
    );
    if (status != OCI_SUCCESS) {
        oracle_print_error(connection->errhp, "Failed to set OCI password.");
        oracle_disconnect(connection);
        return -1;
    }

    status = OCISessionBegin(
        connection->svchp,
        connection->errhp,
        connection->authp,
        OCI_CRED_RDBMS,
        OCI_DEFAULT
    );
    if (status != OCI_SUCCESS) {
        oracle_print_error(connection->errhp, "Failed to start OCI session.");
        oracle_disconnect(connection);
        return -1;
    }

    status = OCIAttrSet(
        connection->svchp,
        OCI_HTYPE_SVCCTX,
        connection->authp,
        0,
        OCI_ATTR_SESSION,
        connection->errhp
    );
    if (status != OCI_SUCCESS) {
        oracle_print_error(connection->errhp, "Failed to attach session to service context.");
        oracle_disconnect(connection);
        return -1;
    }

    printf("Connected to Oracle with OCI: %s\n", connect_string);
    return 0;
}

void oracle_disconnect(OracleConnection *connection)
{
    if (connection == NULL) {
        return;
    }

    if (connection->svchp != NULL && connection->authp != NULL && connection->errhp != NULL) {
        OCISessionEnd(connection->svchp, connection->errhp, connection->authp, OCI_DEFAULT);
    }

    if (connection->srvhp != NULL && connection->errhp != NULL) {
        OCIServerDetach(connection->srvhp, connection->errhp, OCI_DEFAULT);
    }

    if (connection->authp != NULL) {
        OCIHandleFree(connection->authp, OCI_HTYPE_SESSION);
    }

    if (connection->svchp != NULL) {
        OCIHandleFree(connection->svchp, OCI_HTYPE_SVCCTX);
    }

    if (connection->srvhp != NULL) {
        OCIHandleFree(connection->srvhp, OCI_HTYPE_SERVER);
    }

    if (connection->errhp != NULL) {
        OCIHandleFree(connection->errhp, OCI_HTYPE_ERROR);
    }

    if (connection->envhp != NULL) {
        OCIHandleFree(connection->envhp, OCI_HTYPE_ENV);
    }

    memset(connection, 0, sizeof(*connection));
}
