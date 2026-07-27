// report 50151 "testing copy rec. doc"
// {
//     Caption = 'testing copy rec. doc';
//     UsageCategory = ReportsAndAnalysis;
//     ProcessingOnly = true;

//     requestpage
//     {
//         layout
//         {
//             area(content)
//             {
//                 group(GroupName)
//                 {
//                     field(CopyRecDocNo; CopyRecDocNo)
//                     {
//                         TableRelation = "LAX EDI Receive Document Hdr.";
//                     }
//                     field(NewRecDocNo; NewRecDocNo)
//                     {
//                     }
//                 }
//             }
//         }
//     }

//     trigger OnPreReport()
//     begin
//         CopyDocForTesting();
//     end;

//     var
//         CopyRecDocNo: Code[20];
//         NewRecDocNo: Code[20];


//     local procedure CopyDocForTesting()
//     var
//         LAXEDIReceiveDocumentHdr: Record "LAX EDI Receive Document Hdr.";
//         NewLAXEDIReceiveDocumentHdr: Record "LAX EDI Receive Document Hdr.";
//         LAXEDIReceiveDocumentField: Record "LAX EDI Receive Document Field";
//         NewLAXEDIReceiveDocumentField: Record "LAX EDI Receive Document Field";
//     begin
//         LAXEDIReceiveDocumentHdr.SetRange("Internal Doc. No.", CopyRecDocNo);
//         if LAXEDIReceiveDocumentHdr.FindFirst() then begin
//             NewLAXEDIReceiveDocumentHdr.TransferFields(LAXEDIReceiveDocumentHdr);
//             NewLAXEDIReceiveDocumentHdr."Internal Doc. No." := NewRecDocNo;
//             if NewLAXEDIReceiveDocumentHdr.Insert() then begin
//                 LAXEDIReceiveDocumentField.SetRange("Internal Doc. No.", CopyRecDocNo);
//                 if LAXEDIReceiveDocumentField.FindSet() then
//                     repeat
//                         NewLAXEDIReceiveDocumentField.Init();
//                         NewLAXEDIReceiveDocumentField.TransferFields(LAXEDIReceiveDocumentField);
//                         NewLAXEDIReceiveDocumentField."Internal Doc. No." := NewRecDocNo;
//                         NewLAXEDIReceiveDocumentField.Insert();
//                     until LAXEDIReceiveDocumentField.Next() = 0;
//             end;
//         end;
//     end;
// }
