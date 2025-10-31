/// <summary>
/// Test Codeunit VT Allocation Cancel Tests (ID 50100)
/// Unit tests for the allocation cancellation feature
/// </summary>
codeunit 50100 "VT Allocation Cancel Tests"
{
    Subtype = Test;
    TestPermissions = Disabled;

    [Test]
    procedure TestAllocationStatusEnum()
    var
        AllocationStatus: Enum "VT Allocation Status";
    begin
        // Test enum values exist
        AllocationStatus := AllocationStatus::Active;
        if Format(AllocationStatus) <> 'Active' then
            Error('Active enum value not working correctly');

        AllocationStatus := AllocationStatus::Cancelled;
        if Format(AllocationStatus) <> 'Cancelled' then
            Error('Cancelled enum value not working correctly');
    end;

    [Test]
    procedure TestCancellationHistoryTableStructure()
    var
        VTAllocCancelHistory: Record "VT Allocation Cancel History";
    begin
        // Test table structure exists and can be initialized
        VTAllocCancelHistory.Init();
        VTAllocCancelHistory."Entry No." := 1;
        VTAllocCancelHistory."Document Type" := VTAllocCancelHistory."Document Type"::Order;
        VTAllocCancelHistory."Document No." := 'TEST001';
        VTAllocCancelHistory."Line No." := 10000;
        VTAllocCancelHistory."Source Type" := DATABASE::"Sales Line";
        VTAllocCancelHistory."Item No." := 'ITEM001';
        VTAllocCancelHistory."Location Code" := 'MAIN';
        VTAllocCancelHistory."Quantity Cancelled" := 10;
        VTAllocCancelHistory."Cancellation Date" := Today;
        VTAllocCancelHistory."Cancelled By User ID" := UserId;
        VTAllocCancelHistory."Cancellation Reason Code" := 'CANC-TEST';

        // Test that record can be inserted
        if not VTAllocCancelHistory.Insert() then
            Error('Failed to insert cancellation history record');

        // Clean up
        VTAllocCancelHistory.Delete();
    end;

    [Test]
    procedure TestSalesLineExtensionFields()
    var
        SalesLine: Record "Sales Line";
        SalesHeader: Record "Sales Header";
    begin
        // Test that extension fields exist
        CreateTestSalesOrder(SalesHeader, SalesLine);

        // Test allocation status field
        SalesLine."VT Allocation Status" := SalesLine."VT Allocation Status"::Active;
        if SalesLine."VT Allocation Status" <> SalesLine."VT Allocation Status"::Active then
            Error('Failed to set allocation status to Active');

        SalesLine."VT Allocation Status" := SalesLine."VT Allocation Status"::Cancelled;
        if SalesLine."VT Allocation Status" <> SalesLine."VT Allocation Status"::Cancelled then
            Error('Failed to set allocation status to Cancelled');

        // Test date and user fields
        SalesLine."VT Allocation Cancelled Date" := Today;
        if SalesLine."VT Allocation Cancelled Date" <> Today then
            Error('Failed to set cancellation date');

        SalesLine."VT Allocation Cancelled By" := UserId;
        if SalesLine."VT Allocation Cancelled By" <> UserId then
            Error('Failed to set cancelled by user');

        // Clean up
        CleanupSalesOrder(SalesHeader);
    end;

    [Test]
    procedure TestPurchaseLineExtensionFields()
    var
        PurchaseLine: Record "Purchase Line";
        PurchaseHeader: Record "Purchase Header";
    begin
        // Test that extension fields exist
        CreateTestPurchaseOrder(PurchaseHeader, PurchaseLine);

        // Test allocation status field
        PurchaseLine."VT Allocation Status" := PurchaseLine."VT Allocation Status"::Active;
        if PurchaseLine."VT Allocation Status" <> PurchaseLine."VT Allocation Status"::Active then
            Error('Failed to set allocation status to Active');

        PurchaseLine."VT Allocation Status" := PurchaseLine."VT Allocation Status"::Cancelled;
        if PurchaseLine."VT Allocation Status" <> PurchaseLine."VT Allocation Status"::Cancelled then
            Error('Failed to set allocation status to Cancelled');

        // Test date and user fields
        PurchaseLine."VT Allocation Cancelled Date" := Today;
        if PurchaseLine."VT Allocation Cancelled Date" <> Today then
            Error('Failed to set cancellation date');

        PurchaseLine."VT Allocation Cancelled By" := UserId;
        if PurchaseLine."VT Allocation Cancelled By" <> UserId then
            Error('Failed to set cancelled by user');

        // Clean up
        CleanupPurchaseOrder(PurchaseHeader);
    end;

    [Test]
    procedure TestReservationEntryExtensionFields()
    var
        ReservationEntry: Record "Reservation Entry";
    begin
        // Test that extension fields exist
        ReservationEntry.Init();
        ReservationEntry."Entry No." := 999999;

        // Test cancellation fields
        ReservationEntry."VT Is Cancelled" := false;
        if ReservationEntry."VT Is Cancelled" then
            Error('Failed to set Is Cancelled to false');

        ReservationEntry."VT Is Cancelled" := true;
        if not ReservationEntry."VT Is Cancelled" then
            Error('Failed to set Is Cancelled to true');

        ReservationEntry."VT Cancellation Entry No." := 12345;
        if ReservationEntry."VT Cancellation Entry No." <> 12345 then
            Error('Failed to set Cancellation Entry No.');

        ReservationEntry."VT Cancellation DateTime" := CurrentDateTime;
        if ReservationEntry."VT Cancellation DateTime" = 0DT then
            Error('Failed to set Cancellation DateTime');
    end;

    [Test]
    procedure TestCancellationManagementCodeunitExists()
    var
        VTAllocCancelMgt: Codeunit "VT Allocation Cancellation Mgt";
        ReasonCode: Code[10];
        Comments: Text[250];
    begin
        // Test that the codeunit exists and can be instantiated
        // This just verifies the codeunit compiles and exists
        Clear(VTAllocCancelMgt);

        // Note: We cannot test the actual methods without proper test data setup
        // but this confirms the codeunit is available
    end;

    [Test]
    procedure TestHistoryRecordCreation()
    var
        VTAllocCancelHistory: Record "VT Allocation Cancel History";
        SalesLine: Record "Sales Line";
        SalesHeader: Record "Sales Header";
        ReservationEntry: Record "Reservation Entry";
    begin
        // Create test sales order
        CreateTestSalesOrder(SalesHeader, SalesLine);

        // Create test reservation entry
        CreateTestReservationEntry(ReservationEntry, SalesLine);

        // Test history creation for sales
        VTAllocCancelHistory.CreateSalesCancellationEntry(
            SalesLine,
            ReservationEntry,
            'CANC-TEST',
            'Test cancellation comment'
        );

        // Verify history record was created
        VTAllocCancelHistory.SetRange("Document No.", SalesLine."Document No.");
        VTAllocCancelHistory.SetRange("Line No.", SalesLine."Line No.");
        if not VTAllocCancelHistory.FindFirst() then
            Error('History record was not created');

        // Verify fields
        if VTAllocCancelHistory."Item No." <> SalesLine."No." then
            Error('Item No. not set correctly in history');

        if VTAllocCancelHistory."Cancellation Reason Code" <> 'CANC-TEST' then
            Error('Reason code not set correctly in history');

        // Clean up
        VTAllocCancelHistory.Delete();
        CleanupSalesOrder(SalesHeader);
        if ReservationEntry.Get(ReservationEntry."Entry No.") then
            ReservationEntry.Delete();
    end;

    [Test]
    procedure TestCanCancelAllocationValidation()
    var
        SalesLine: Record "Sales Line";
        SalesHeader: Record "Sales Header";
    begin
        // Create test sales order
        CreateTestSalesOrder(SalesHeader, SalesLine);

        // Test when no reservation exists
        if SalesLine.CanCancelAllocation() then
            Error('Should not be able to cancel when no reservation exists');

        // Clean up
        CleanupSalesOrder(SalesHeader);
    end;

    local procedure CreateTestSalesOrder(var SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line")
    var
        Customer: Record Customer;
        Item: Record Item;
    begin
        // Find or create a test customer
        if not Customer.Get('TEST-CUST') then begin
            Customer.Init();
            Customer."No." := 'TEST-CUST';
            Customer.Name := 'Test Customer';
            if not Customer.Insert() then
                Customer.Get('TEST-CUST');
        end;

        // Find or create a test item
        if not Item.Get('TEST-ITEM') then begin
            Item.Init();
            Item."No." := 'TEST-ITEM';
            Item.Description := 'Test Item';
            Item."Base Unit of Measure" := 'PCS';
            if not Item.Insert() then
                Item.Get('TEST-ITEM');
        end;

        // Create sales header
        SalesHeader.Init();
        SalesHeader."Document Type" := SalesHeader."Document Type"::Order;
        SalesHeader."No." := 'TEST-SO-' + Format(Random(99999));
        SalesHeader."Sell-to Customer No." := Customer."No.";
        SalesHeader."Bill-to Customer No." := Customer."No.";
        SalesHeader."Posting Date" := Today;
        SalesHeader."Document Date" := Today;
        SalesHeader.Insert();

        // Create sales line
        SalesLine.Init();
        SalesLine."Document Type" := SalesHeader."Document Type";
        SalesLine."Document No." := SalesHeader."No.";
        SalesLine."Line No." := 10000;
        SalesLine.Type := SalesLine.Type::Item;
        SalesLine."No." := Item."No.";
        SalesLine.Description := Item.Description;
        SalesLine.Quantity := 10;
        SalesLine."Unit Price" := 100;
        SalesLine.Insert();
    end;

    local procedure CreateTestPurchaseOrder(var PurchaseHeader: Record "Purchase Header"; var PurchaseLine: Record "Purchase Line")
    var
        Vendor: Record Vendor;
        Item: Record Item;
    begin
        // Find or create a test vendor
        if not Vendor.Get('TEST-VEND') then begin
            Vendor.Init();
            Vendor."No." := 'TEST-VEND';
            Vendor.Name := 'Test Vendor';
            if not Vendor.Insert() then
                Vendor.Get('TEST-VEND');
        end;

        // Find or create a test item
        if not Item.Get('TEST-ITEM') then begin
            Item.Init();
            Item."No." := 'TEST-ITEM';
            Item.Description := 'Test Item';
            Item."Base Unit of Measure" := 'PCS';
            if not Item.Insert() then
                Item.Get('TEST-ITEM');
        end;

        // Create purchase header
        PurchaseHeader.Init();
        PurchaseHeader."Document Type" := PurchaseHeader."Document Type"::Order;
        PurchaseHeader."No." := 'TEST-PO-' + Format(Random(99999));
        PurchaseHeader."Buy-from Vendor No." := Vendor."No.";
        PurchaseHeader."Pay-to Vendor No." := Vendor."No.";
        PurchaseHeader."Posting Date" := Today;
        PurchaseHeader."Document Date" := Today;
        PurchaseHeader.Insert();

        // Create purchase line
        PurchaseLine.Init();
        PurchaseLine."Document Type" := PurchaseHeader."Document Type";
        PurchaseLine."Document No." := PurchaseHeader."No.";
        PurchaseLine."Line No." := 10000;
        PurchaseLine.Type := PurchaseLine.Type::Item;
        PurchaseLine."No." := Item."No.";
        PurchaseLine.Description := Item.Description;
        PurchaseLine.Quantity := 10;
        PurchaseLine."Direct Unit Cost" := 50;
        PurchaseLine.Insert();
    end;

    local procedure CreateTestReservationEntry(var ReservationEntry: Record "Reservation Entry"; SalesLine: Record "Sales Line")
    begin
        ReservationEntry.Init();
        ReservationEntry."Entry No." := 999000 + Random(999);
        ReservationEntry."Item No." := SalesLine."No.";
        ReservationEntry."Location Code" := SalesLine."Location Code";
        ReservationEntry."Quantity (Base)" := -SalesLine.Quantity;
        ReservationEntry.Quantity := -SalesLine.Quantity;
        ReservationEntry."Reservation Status" := ReservationEntry."Reservation Status"::Reservation;
        ReservationEntry."Source Type" := DATABASE::"Sales Line";
        ReservationEntry."Source Subtype" := SalesLine."Document Type".AsInteger();
        ReservationEntry."Source ID" := SalesLine."Document No.";
        ReservationEntry."Source Ref. No." := SalesLine."Line No.";
        ReservationEntry."Creation Date" := Today;
        ReservationEntry."Created By" := UserId;
        ReservationEntry.Insert();
    end;

    local procedure CleanupSalesOrder(var SalesHeader: Record "Sales Header")
    var
        SalesLine: Record "Sales Line";
    begin
        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        SalesLine.DeleteAll();
        SalesHeader.Delete();
    end;

    local procedure CleanupPurchaseOrder(var PurchaseHeader: Record "Purchase Header")
    var
        PurchaseLine: Record "Purchase Line";
    begin
        PurchaseLine.SetRange("Document Type", PurchaseHeader."Document Type");
        PurchaseLine.SetRange("Document No.", PurchaseHeader."No.");
        PurchaseLine.DeleteAll();
        PurchaseHeader.Delete();
    end;
}