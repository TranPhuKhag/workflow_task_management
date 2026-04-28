@EndUserText.label: 'Custom Entity for Wf Comments Query'
@ObjectModel.query.implementedBy: 'ABAP:ZCL_WF_QUERY_COMMENT'

define custom entity ZCE_GSP26SAP02_WF_COMMENT_UQ
{
  key WorkItemID  : sww_wiid;
  key CommentID   : abap.string (0);
      line        : char255; // Text of the comment
      title       : so_obj_nam;
      owner       : so_own_nam;
      created     : so_cro_nam; // User who created the comment
      dateCreated : so_dat_cr;
      createdAt   : so_tim_cr; // Timestamp when the comment was created
}
