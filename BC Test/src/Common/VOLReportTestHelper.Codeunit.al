/// <summary>
/// Codeunit VOL Report Test Helper (ID 90200).
/// Helper codeunit for testing RDLC reports by generating PDF output as Base64.
/// Used by test codeunits and web services to validate report rendering.
/// </summary>
codeunit 90200 "VOL Report Test Helper"
{
    var
        RecordNotFoundErr: Label 'Record not found in table %1 with SystemId %2.', Comment = '%1 = Table No., %2 = SystemId';
        ReportGenerationFailedErr: Label 'Failed to generate report %1 as PDF.', Comment = '%1 = Report ID';
        ReportNotFoundErr: Label 'Report %1 does not exist.', Comment = '%1 = Report ID';
        InvalidTableNoErr: Label 'Invalid table number: %1.', Comment = '%1 = Table No.';
        EmptyPdfErr: Label 'Report %1 generated an empty PDF.', Comment = '%1 = Report ID';

    /// <summary>
    /// Runs a report with a specific record and returns the PDF output as Base64.
    /// This is the main procedure for testing reports.
    /// </summary>
    /// <param name="ReportId">The ID of the report to run.</param>
    /// <param name="TableNo">The table number of the record.</param>
    /// <param name="RecordSystemId">The SystemId of the record to use as data source.</param>
    /// <returns>Base64 encoded string of the PDF output.</returns>
    procedure RunReportAsPdfBase64(ReportId: Integer; TableNo: Integer; RecordSystemId: Guid): Text
    var
        RecRef: RecordRef;
        TempBlob: Codeunit "Temp Blob";
        InStr: InStream;
        OutStr: OutStream;
        Base64Convert: Codeunit "Base64 Convert";
    begin
        ValidateReportExists(ReportId);
        ValidateTableNo(TableNo);

        RecRef.Open(TableNo);
        if not RecRef.GetBySystemId(RecordSystemId) then
            Error(RecordNotFoundErr, TableNo, RecordSystemId);

        TempBlob.CreateOutStream(OutStr);
        if not Report.SaveAs(ReportId, '', ReportFormat::Pdf, OutStr, RecRef) then
            Error(ReportGenerationFailedErr, ReportId);

        TempBlob.CreateInStream(InStr);
        exit(Base64Convert.ToBase64(InStr));
    end;

    /// <summary>
    /// Runs a report with filtered records and returns the PDF output as Base64.
    /// Use this when you need to test reports with multiple records.
    /// </summary>
    /// <param name="ReportId">The ID of the report to run.</param>
    /// <param name="RecRef">A RecordRef with filters already applied.</param>
    /// <returns>Base64 encoded string of the PDF output.</returns>
    procedure RunReportWithFilterAsPdfBase64(ReportId: Integer; var RecRef: RecordRef): Text
    var
        TempBlob: Codeunit "Temp Blob";
        InStr: InStream;
        OutStr: OutStream;
        Base64Convert: Codeunit "Base64 Convert";
    begin
        ValidateReportExists(ReportId);

        TempBlob.CreateOutStream(OutStr);
        if not Report.SaveAs(ReportId, '', ReportFormat::Pdf, OutStr, RecRef) then
            Error(ReportGenerationFailedErr, ReportId);

        TempBlob.CreateInStream(InStr);
        exit(Base64Convert.ToBase64(InStr));
    end;

    /// <summary>
    /// Runs a report with request page XML parameters and returns the PDF output as Base64.
    /// Use this when you need to test reports with specific request page parameters.
    /// </summary>
    /// <param name="ReportId">The ID of the report to run.</param>
    /// <param name="RequestPageXml">XML string with request page parameters.</param>
    /// <param name="TableNo">The table number of the record.</param>
    /// <param name="RecordSystemId">The SystemId of the record to use as data source.</param>
    /// <returns>Base64 encoded string of the PDF output.</returns>
    procedure RunReportWithParamsAsPdfBase64(ReportId: Integer; RequestPageXml: Text; TableNo: Integer; RecordSystemId: Guid): Text
    var
        RecRef: RecordRef;
        TempBlob: Codeunit "Temp Blob";
        InStr: InStream;
        OutStr: OutStream;
        Base64Convert: Codeunit "Base64 Convert";
    begin
        ValidateReportExists(ReportId);
        ValidateTableNo(TableNo);

        RecRef.Open(TableNo);
        if not RecRef.GetBySystemId(RecordSystemId) then
            Error(RecordNotFoundErr, TableNo, RecordSystemId);

        TempBlob.CreateOutStream(OutStr);
        if not Report.SaveAs(ReportId, RequestPageXml, ReportFormat::Pdf, OutStr, RecRef) then
            Error(ReportGenerationFailedErr, ReportId);

        TempBlob.CreateInStream(InStr);
        exit(Base64Convert.ToBase64(InStr));
    end;

    /// <summary>
    /// Tries to run a report and returns success status.
    /// Does not throw errors, useful for testing error scenarios.
    /// </summary>
    /// <param name="ReportId">The ID of the report to run.</param>
    /// <param name="TableNo">The table number of the record.</param>
    /// <param name="RecordSystemId">The SystemId of the record to use as data source.</param>
    /// <param name="PdfBase64">Output parameter with the Base64 PDF if successful.</param>
    /// <returns>True if report generated successfully, false otherwise.</returns>
    procedure TryRunReportAsPdfBase64(ReportId: Integer; TableNo: Integer; RecordSystemId: Guid; var PdfBase64: Text): Boolean
    begin
        if not TryRunReportInternal(ReportId, TableNo, RecordSystemId, PdfBase64) then
            exit(false);

        exit(PdfBase64 <> '');
    end;

    /// <summary>
    /// Gets the size in bytes of a Base64 encoded PDF.
    /// Useful for validating that a report generated content.
    /// </summary>
    /// <param name="Base64Pdf">The Base64 encoded PDF string.</param>
    /// <returns>Size in bytes of the decoded PDF.</returns>
    procedure GetPdfSizeFromBase64(Base64Pdf: Text): Integer
    var
        TempBlob: Codeunit "Temp Blob";
        Base64Convert: Codeunit "Base64 Convert";
        InStr: InStream;
        OutStr: OutStream;
        ByteCount: Integer;
        Buffer: Text;
    begin
        if Base64Pdf = '' then
            exit(0);

        TempBlob.CreateOutStream(OutStr);
        Base64Convert.FromBase64(Base64Pdf, OutStr);
        TempBlob.CreateInStream(InStr);

        while not InStr.EOS do begin
            InStr.ReadText(Buffer, 1000);
            ByteCount += StrLen(Buffer);
        end;

        exit(ByteCount);
    end;

    /// <summary>
    /// Validates that a report generated a non-empty PDF.
    /// Throws an error if the PDF is empty.
    /// </summary>
    /// <param name="ReportId">The Report ID for error message.</param>
    /// <param name="Base64Pdf">The Base64 encoded PDF to validate.</param>
    procedure ValidatePdfNotEmpty(ReportId: Integer; Base64Pdf: Text)
    begin
        if Base64Pdf = '' then
            Error(EmptyPdfErr, ReportId);

        if GetPdfSizeFromBase64(Base64Pdf) = 0 then
            Error(EmptyPdfErr, ReportId);
    end;

    /// <summary>
    /// Runs a report and returns JSON with execution details.
    /// Useful for web service testing and debugging.
    /// </summary>
    /// <param name="ReportId">The ID of the report to run.</param>
    /// <param name="TableNo">The table number of the record.</param>
    /// <param name="RecordSystemId">The SystemId of the record to use as data source.</param>
    /// <returns>JSON string with execution results and Base64 PDF.</returns>
    procedure RunReportAsJson(ReportId: Integer; TableNo: Integer; RecordSystemId: Guid): Text
    var
        JsonObj: JsonObject;
        PdfBase64: Text;
        Success: Boolean;
        ErrorText: Text;
        StartTime: DateTime;
        EndTime: DateTime;
        ResultText: Text;
    begin
        StartTime := CurrentDateTime;

        Success := TryRunReportAsPdfBase64(ReportId, TableNo, RecordSystemId, PdfBase64);

        if not Success then
            ErrorText := GetLastErrorText();

        EndTime := CurrentDateTime;

        JsonObj.Add('reportId', ReportId);
        JsonObj.Add('tableNo', TableNo);
        JsonObj.Add('recordSystemId', Format(RecordSystemId));
        JsonObj.Add('success', Success);
        JsonObj.Add('startTime', Format(StartTime, 0, 9));
        JsonObj.Add('endTime', Format(EndTime, 0, 9));
        JsonObj.Add('durationMs', EndTime - StartTime);

        if Success then begin
            JsonObj.Add('pdfSizeBytes', GetPdfSizeFromBase64(PdfBase64));
            JsonObj.Add('pdfBase64', PdfBase64);
        end else
            JsonObj.Add('error', ErrorText);

        JsonObj.WriteTo(ResultText);
        exit(ResultText);
    end;

    [TryFunction]
    local procedure TryRunReportInternal(ReportId: Integer; TableNo: Integer; RecordSystemId: Guid; var PdfBase64: Text)
    begin
        PdfBase64 := RunReportAsPdfBase64(ReportId, TableNo, RecordSystemId);
    end;

    local procedure ValidateReportExists(ReportId: Integer)
    var
        AllObjWithCaption: Record AllObjWithCaption;
    begin
        AllObjWithCaption.SetRange("Object Type", AllObjWithCaption."Object Type"::Report);
        AllObjWithCaption.SetRange("Object ID", ReportId);
        if AllObjWithCaption.IsEmpty() then
            Error(ReportNotFoundErr, ReportId);
    end;

    local procedure ValidateTableNo(TableNo: Integer)
    var
        AllObjWithCaption: Record AllObjWithCaption;
    begin
        if TableNo <= 0 then
            Error(InvalidTableNoErr, TableNo);

        AllObjWithCaption.SetRange("Object Type", AllObjWithCaption."Object Type"::Table);
        AllObjWithCaption.SetRange("Object ID", TableNo);
        if AllObjWithCaption.IsEmpty() then
            Error(InvalidTableNoErr, TableNo);
    end;
}
