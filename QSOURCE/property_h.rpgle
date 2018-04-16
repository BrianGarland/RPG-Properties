**FREE



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
DCL-PR GetProperty VARCHAR(100);
    PropertyFile VARCHAR(1024) VALUE;
    PropertyKey  VARCHAR(100) VALUE;
END-PR;

