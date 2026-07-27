/// <summary>
/// This table serves as the SpecRight item update queue. Additional processing is done against the items within this table when they are written to BC.
/// </summary>
table 50036 "SBC SpecRight Interface"
{
    Caption = 'SpecRight Interface';
    DataClassification = CustomerContent;
    //ObsoleteState = PendingMoved;
    //MovedTo = "8618a4f4-c90a-49ce-802c-0fba934cc41e";
    //ObsoleteReason = 'When the Move to Move From feature is implemented, this table will be moved to the SpecRight app.';
 
    
    fields
    {
        field(1; "Item No."; Text[20])
        {
            Caption = 'Item No.';
            DataClassification = CustomerContent;
            Description = 'This is an update queue that notifies SBC that an update to the item identified by the written key has been updated.';
        }
        field(10; "Item ID"; Guid)
        {
            Caption = 'Item ID';
            DataClassification = CustomerContent;
            Description = 'The unique identifier of the item that was updated.';

        }
        field(11;"External Item ID"; Text[100])
        {
            Caption = 'External Item ID';
            DataClassification = CustomerContent;
            Description = 'The external identifier of the item that was updated.';
        }
        field(20; "Processed Timestamp"; DateTime)
        {
            Caption = 'Processed Timestamp';
            DataClassification = CustomerContent;
            Description = 'The last sync time of the item from SpecRight.';
        }
  
    }
    keys
    {
        key(PK; "Item No.")
        {
            Clustered = true;
        }
    }
}