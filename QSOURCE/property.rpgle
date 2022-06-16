**FREE



// Compile parameters
CTL-OPT NOMAIN;



// Internal definitions and prototypes
DCL-S pFile POINTER TEMPLATE;

DCL-PR fOpen LIKE(pFile) EXTPROC('_C_IFS_fopen');
    Filename POINTER VALUE OPTIONS(*STRING);
    Mode     POINTER VALUE OPTIONS(*STRING);
END-PR;

DCL-PR fGets POINTER EXTPROC('_C_IFS_fgets');
    String POINTER VALUE;
    Size   INT(10) VALUE;
    Stream LIKE(pFile) VALUE;
END-PR;

DCL-PR fClose INT(10) EXTPROC('_C_IFS_fclose');
    Stream LIKE(pFile) VALUE;
END-PR;



// Properties data structure
//     This contains the parsed .properties file
DCL-DS Properties DIM(1000) QUALIFIED;
    Key   VARCHAR(100);
    Value VARCHAR(100);
END-DS;

DCL-S NumProperties INT(10);



//------------------------------------------------------------------------------
// Procedure
//     LoadPropertyFile
//
// Description
//     Load properties into internal structure from IFS file
//
// Parameters
//     PropertyFile - Full path to the .properties file
//
// Return Value
//     n/a
//
//------------------------------------------------------------------------------
DCL-PROC LoadPropertyFile;
    DCL-PI *N IND;
        PropertyFile VARCHAR(1024) VALUE;
    END-PI;

    DCL-S Buffer       CHAR(1024);
    DCL-S FileHandle   LIKE(pFile);
    DCL-S Mode         VARCHAR(20) INZ('r, o_ccsid=0');
    DCL-S RecordHandle POINTER;
    DCL-S Split        INT(10);
    DCL-S Success      IND INZ(*ON);


    MONITOR;

        // Clear the key/value pair list
        CLEAR Properties;
        CLEAR NumProperties;

        // Open the IFS .properties file
        FileHandle = fOpen(PropertyFile:Mode);

        // Read each row in the file
        RecordHandle = fGets(%ADDR(Buffer):%SIZE(Buffer):FileHandle);
        DOW RecordHandle <> *NULL;

            // Translate null, CR, and LF characters into blanks
            Buffer = %XLATE(x'00250D':'   ':Buffer);

            // Trim off leading blanks to make next compare easier
            Buffer = %TRIM(Buffer);

            // Skip blank lines and comments
            IF Buffer <> ' ' AND %SUBST(Buffer:1:1) <> '#' AND %SUBST(Buffer:1:1) <> '!';

                // Properties can be defined using equals(=), colon(:), or space( )
                Split = %SCAN('=':Buffer);
                IF Split = 0;
                    Split = %SCAN(':':Buffer);
                    IF Split = 0;
                        Split = %SCAN(' ':Buffer);
                    ENDIF;
                ENDIF;

                // If we found a point on which to split to split the row then do it
                IF Split <> 0;

                    NumProperties += 1;

                    Properties(NumProperties).Key = %TRIMR(%SUBST(Buffer:1:Split-1));
                    Properties(NumProperties).Value = %TRIM(%SUBST(Buffer:Split+1));

                ENDIF;

            ENDIF;

            // Get the next row to process
            CLEAR Buffer;
            RecordHandle = fGets(%ADDR(Buffer):%SIZE(Buffer):FileHandle);
        ENDDO;

        // Close the IFS .properties file
        fClose(FileHandle);

        // Sort the list of key/value pairs to make retreival faster
        SORTA %SUBARR(Properties(*).Key:1:NumProperties);

    ON-ERROR;

        Success = *OFF;

    ENDMON;

    RETURN Success;

END-PROC;



//------------------------------------------------------------------------------
// Procedure
//     GetProperty
//
// Description
//     Get a property from a .properties file
//
// Parameters
//     PropertyFile - Full path to the .properties file
//     PropertyKey  - Case sensitive text of the property key
//
// Return Value
//     Property Value if found
//
//------------------------------------------------------------------------------
DCL-PROC GetProperty EXPORT;
    DCL-PI *N VARCHAR(100);
        PropertyFile VARCHAR(1024) VALUE;
        PropertyKey  VARCHAR(100) VALUE;
    END-PI;

    DCL-S Index    INT(10);
    DCL-S LastFile VARCHAR(1024) STATIC;

    IF PropertyFile <> LastFile;
        LoadPropertyFile(PropertyFile);
        LastFile = PropertyFile;
    ENDIF;

    Index = %LOOKUP(%TRIM(PropertyKey):Properties(*).Key:1:NumProperties);
    IF Index <> 0;
        RETURN Properties(Index).Value;
    ELSE;
        RETURN '';
    ENDIF;

END-PROC;

