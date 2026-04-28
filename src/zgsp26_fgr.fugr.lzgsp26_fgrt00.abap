*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZGSP26_WF_CONF..................................*
DATA:  BEGIN OF STATUS_ZGSP26_WF_CONF                .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZGSP26_WF_CONF                .
CONTROLS: TCTRL_ZGSP26_WF_CONF
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZGSP26_WF_CONF                .
TABLES: ZGSP26_WF_CONF                 .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
