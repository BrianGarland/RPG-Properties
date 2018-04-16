**FREE
CTL-OPT BNDDIR('PROPERTY') ACTGRP(*NEW);
/INCLUDE property_h.rpgle
DCL-S PropFile VARCHAR(1024) INZ('/home/brian/test.property');
DCL-S Field VARCHAR(1024);

Field = GetProperty(PropFile:'name');
Field = GetProperty(PropFile:'job');

*INLR = *ON;
RETURN;
