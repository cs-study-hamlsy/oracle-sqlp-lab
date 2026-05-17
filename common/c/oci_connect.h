#ifndef OCI_CONNECT_H
#define OCI_CONNECT_H

#include <oci.h>

typedef struct OracleConnection {
    OCIEnv *envhp;
    OCIError *errhp;
    OCIServer *srvhp;
    OCISvcCtx *svchp;
    OCISession *authp;
} OracleConnection;

int oracle_connect(OracleConnection *connection);
void oracle_disconnect(OracleConnection *connection);
void oracle_print_error(OCIError *errhp, const char *message);

#endif
