# RDLC Report Testing Guide

## Overview

For testing RDLC reports, use web service functions directly instead of AL Test Tool.

## Quick Start

### Auto-Test with Posted Invoice
```powershell
powershell -ExecutionPolicy Bypass -File ".claude/scripts/bc-test-report-rdlc-auto.ps1"
```

### Test Any Report
```powershell
powershell -ExecutionPolicy Bypass -File ".claude/scripts/bc-test-report-rdlc-api.ps1"
```

## PDF Validation Checklist

After generating a PDF, verify:

- [ ] **Page count**: 1-2 pages for single invoice (not 10+)
- [ ] **Invoice numbers**: Only ONE unique invoice number
- [ ] **Product lines**: Count matches expected for that invoice
- [ ] **Totals**: Header total matches sum of line items
- [ ] **Data integrity**: All lines belong to the header invoice

## AL vs RDLC Responsibilities

### AL Report Object (`.Report.al`)
Controls DATA:
- `DataItemLink` - Links child to parent
- `DataItemTableView` - Sorting/filtering
- Column definitions

### RDLC Layout (`.Report.rdlc`)
Controls VISUAL:
- Field visibility
- Colors, fonts, borders
- Grouping for display
- Page layout

## Common Issues

### Too Many Pages/Lines
**Symptom**: PDF shows 10+ pages instead of 1-2

**Cause**: RecordRef not filtered before `Report.SaveAs`

**Fix**: In test helper codeunit:
```al
RecRef.Reset();
FieldRef := RecRef.Field(1); // "No." field
FieldRef.SetRange(RecordNo);
```

### Wrong Data Relationships
**Symptom**: Lines don't match header

**Cause**: Incorrect `DataItemLink`

**Fix**: In AL report:
```al
dataitem(SalesInvoiceLine; "Sales Invoice Line")
{
    DataItemLink = "Document No." = field("No.");
}
```

### Multiple Invoice Numbers
**Symptom**: PDF shows data from multiple invoices

**Cause**: Missing filter on RecordRef

**Fix**: Filter by SystemId AND "No." field

## Diagnostic Workflow

```
Generate PDF
    ↓
Count pages (expected: 1-2)
    ↓
If too many pages → Check RecordRef filtering
    ↓
Check invoice numbers (expected: 1)
    ↓
If multiple → Fix DataItemLink or RecordRef filter
    ↓
Verify totals match
    ↓
If mismatch → Check column definitions
```

## PDF Analysis

Use Python to analyze:
```python
import fitz  # PyMuPDF

pdf = fitz.open('report.pdf')
print(f"Pages: {len(pdf)}")

text = pdf[0].get_text()
# Find invoice numbers
import re
invoices = set(re.findall(r'INV-\d+', text))
print(f"Invoices: {invoices}")
```
