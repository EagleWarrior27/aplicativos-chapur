create or replace PROCEDURE               WEB_LOGIN (
    LOGIN_ IN VARCHAR2,
    PASSWD IN VARCHAR2,
    p_recordset OUT SYS_REFCURSOR
)IS

   V_TAB             CT_WEB_LOGIN := CT_WEB_LOGIN ();
   V_REG             CR_WEB_LOGIN := CR_WEB_LOGIN (NULL, NULL, NULL, NULL,
                                                                   NULL, NULL, NULL, NULL, 
                                                                   NULL, NULL, NULL, NULL,
                                                                   NULL, NULL, NULL, NULL,
                                                                   NULL, NULL, NULL, NULL,
                                                                   NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
   -- Variables OUT
   NUMIDEN           INTEGER;
   NOMBRE            VARCHAR2 (80);
   ULT_CONT          DATE;
   CVETAR            INTEGER;
   TAR_ACTIVO        VARCHAR2 (7);
   FECHA_ALTA        DATE;
   EMAIL             VARCHAR2 (50);
   PREGUNTA          VARCHAR2 (50);
   RESPUESTA_CLAVE   VARCHAR2 (50);
   CV                SMALLINT;
   PROMO             SMALLINT;
   NORECORDAR        SMALLINT;
   IDWEB_PERIODO     INTEGER;
   ESTADO            NUMBER;
   ID_PREGUNTA       SMALLINT;
   MAILPROMO         VARCHAR2 (50);
   NOTIFICACION      SMALLINT;
   FECHAVIGENCIA     DATE;
   PRIVACIDAD        SMALLINT;
   TIPOEMISION       SMALLINT;
   RESULTADO         VARCHAR2 (120);
   FECHA_CORTE       VARCHAR2(20);
   -- Variables de trabajo
   CONTRASENA        VARCHAR2 (50);
   IDTIPOCLIENTE     NUMBER;
   TIPOCLIENTE       VARCHAR2(100);
  NUMERO_TARJETA VARCHAR2(20);
  SITUACION NUMBER;
  CONEKTA_ID VARCHAR2(100);
  FCM_TOKEN VARCHAR2(300);
  NUMCORTE INTEGER;
   --CURSOR ULT_CONTACT
   --UPDATE WEB_USER SET ULTIMO_CONTACTO=SYSDATE WHERE LOGIN=?;
   CURSOR REGISTRA (V1 VARCHAR2) IS
      SELECT B.NUMIDEN,
             B.NOMCOMP,
             A.ULTIMO_CONTACTO,
             A.PASSWD,
             A.CVETAR,
             A.TAR_ACTIVO,
             A.FECHA_ALTA,
             C.EMAILEDOCTA,
             D.PREGUNTA,
             C.EDOEMAILEDOCTA,
             C.EDOEMAILPROMO,
             A.NORECORDAR,
             A.IDWEB_PERIODO,
             A.RESPUESTA_CLAVE,
             A.ESTADO,
             A.ID_PREGUNTA,
             C.EMAILPROMO,
             C.NOTIFICACION,
             A.VIGENCIACLAVE,
             A.PRIVACIDAD,
             E.IDEMIENT,
             TO_CHAR(T.ULTFECHACOR,'YYYY-MM-DD') AS FECHA_CORTE,
             T.IDTIPOCLIENTE,
             (SELECT TIPOCLIENTE FROM VENTAS.CRTIPOCLIENTE WHERE IDTIPOCLIENTE = T.IDTIPOCLIENTE) AS TIPOCLIENTE,
             T.CODIGO_TARJETA AS NUMERO_TARJETA,
             T.SITUACION,
             A.CONEKTA_ID,
             A.FCM_TOKEN,
             T.NUMCORTE
        FROM WEB_USER A
             JOIN PVENFIMO B
                ON B.NUMIDEN = A.NUMIDEN
             JOIN CRTARCLI T
                ON T.NUMIDEN = A.NUMIDEN AND T.CVEBASIC = T.CVETAR
             JOIN CREMISIONEDOCTA E
                ON T.IDEMISION = E.IDEMISION
             LEFT OUTER JOIN CRCLIENTEEMAIL C
                ON C.NUMIDEN = A.NUMIDEN
             LEFT OUTER JOIN WEB_PREGUNTA D
                ON A.ID_PREGUNTA = D.ID_PREG
       WHERE A.LOGIN = V1;
       
BEGIN
   
   OPEN REGISTRA (LOGIN_);
   FETCH REGISTRA INTO NUMIDEN, NOMBRE, ULT_CONT, CONTRASENA, CVETAR, 
                                      TAR_ACTIVO, FECHA_ALTA, EMAIL, PREGUNTA, CV, 
                                      PROMO, NORECORDAR, IDWEB_PERIODO, RESPUESTA_CLAVE,
                                      ESTADO, ID_PREGUNTA, MAILPROMO, NOTIFICACION, 
                                      FECHAVIGENCIA, PRIVACIDAD, TIPOEMISION,FECHA_CORTE,IDTIPOCLIENTE,TIPOCLIENTE,NUMERO_TARJETA,SITUACION,CONEKTA_ID,FCM_TOKEN,
                                      NUMCORTE;

   IF REGISTRA%NOTFOUND THEN
      V_REG.RESULTADO := 'Error: 1001 - No existe nombre de usuario';
    
      V_TAB.EXTEND;
      V_TAB (V_TAB.LAST) := V_REG;

      OPEN p_recordset FOR
            SELECT NUMIDEN, NOMBRE, ULT_CONT, CVETAR, TAR_ACTIVO, 
                        FECHA_ALTA, EMAIL, PREGUNTA, RESPUESTA_CLAVE, CV,
                        PROMO, NORECORDAR, IDWEB_PERIODO, ESTADO, ID_PREGUNTA,
                        MAILPROMO, NOTIFICACION, FECHAVIGENCIA, PRIVACIDAD, TIPOEMISION,
                        RESULTADO,FECHACORTE AS FECHA_CORTE,IDTIPOCLIENTE,TIPOCLIENTE,NUMERO_TARJETA,SITUACION,CONEKTA_ID,FCM_TOKEN,
                        NUMCORTE
           FROM TABLE (CAST (V_TAB AS CT_WEB_LOGIN));
      RETURN;
   END IF;

   IF PASSWD <> CONTRASENA
   THEN
      V_REG.RESULTADO := 'Error: 1002 - Contrase¿a no coincide';

      V_TAB.EXTEND;
      V_TAB (V_TAB.LAST) := V_REG;

      OPEN p_recordset FOR
            SELECT NUMIDEN, NOMBRE, ULT_CONT, CVETAR, TAR_ACTIVO, 
                        FECHA_ALTA, EMAIL, PREGUNTA, RESPUESTA_CLAVE, CV,
                        PROMO, NORECORDAR, IDWEB_PERIODO, ESTADO, ID_PREGUNTA,
                        MAILPROMO, NOTIFICACION, FECHAVIGENCIA, PRIVACIDAD, TIPOEMISION,
                        RESULTADO,FECHACORTE AS FECHA_CORTE,IDTIPOCLIENTE,TIPOCLIENTE,NUMERO_TARJETA,SITUACION,CONEKTA_ID,FCM_TOKEN,
                        NUMCORTE
           FROM TABLE (CAST (V_TAB AS CT_WEB_LOGIN));
      RETURN;
   END IF;

   --OPEN ULT_CONTACT (LOGIN);
   BEGIN
        UPDATE WEB_USER      SET ULTIMO_CONTACTO = SYSDATE    WHERE LOGIN = LOGIN_;
        RESULTADO := 'OK';
        COMMIT;
   EXCEPTION WHEN OTHERS THEN
        RESULTADO := SQLERRM;
   END;

   --EXEC SQL DROP ULT_CONTACT;
   --EXEC SQL DROP REGISTRA;

   V_TAB.EXTEND;
   V_TAB (V_TAB.LAST) := CR_WEB_LOGIN (NUMIDEN, NOMBRE, ULT_CONT, CVETAR,
                                                                TAR_ACTIVO, FECHA_ALTA, EMAIL, PREGUNTA,
                                                                RESPUESTA_CLAVE, CV, PROMO, NORECORDAR,
                                                                IDWEB_PERIODO, ESTADO, ID_PREGUNTA, MAILPROMO,
                                                                NOTIFICACION, FECHAVIGENCIA, PRIVACIDAD, TIPOEMISION,
                                                                RESULTADO,FECHA_CORTE,IDTIPOCLIENTE,TIPOCLIENTE,NUMERO_TARJETA,SITUACION,CONEKTA_ID,FCM_TOKEN,
                                                                NUMCORTE);

   OPEN p_recordset FOR
      SELECT NUMIDEN, NOMBRE, ULT_CONT, CVETAR, TAR_ACTIVO,
                  FECHA_ALTA, EMAIL, PREGUNTA, RESPUESTA_CLAVE, CV,
                  PROMO, NORECORDAR, IDWEB_PERIODO, ESTADO, ID_PREGUNTA,
                  MAILPROMO, NOTIFICACION, FECHAVIGENCIA, PRIVACIDAD, TIPOEMISION,
                  RESULTADO,FECHACORTE AS FECHA_CORTE,IDTIPOCLIENTE,TIPOCLIENTE,NUMERO_TARJETA,SITUACION,CONEKTA_ID,FCM_TOKEN,
                  NUMCORTE
      FROM TABLE (CAST (V_TAB AS CT_WEB_LOGIN));
END;