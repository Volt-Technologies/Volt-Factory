# RDLC Layout Structure and XML Rules

This document provides exhaustive documentation for creating and editing RDLC (Report Definition Language Client-side) files for Business Central reports. RDLC files are XML-based and extremely sensitive to errors - a single syntax error will prevent the report from rendering.

## CRITICAL WARNING

**RDLC files MUST be valid XML.** Common errors that break rendering:
- Unclosed tags
- Incorrect attribute quotes
- Missing namespace declarations
- Case sensitivity violations
- Invalid characters in values

---

## Table of Contents

1. [RDLC File Structure](#rdlc-file-structure)
2. [Namespaces](#namespaces)
3. [DataSources and DataSets](#datasources-and-datasets)
4. [Report Body Structure](#report-body-structure)
5. [Tablix (Tables)](#tablix-tables)
6. [Textboxes](#textboxes)
7. [Expressions and Fields](#expressions-and-fields)
8. [Styles and Formatting](#styles-and-formatting)
9. [Page Layout](#page-layout)
10. [Images and Embedded Resources](#images-and-embedded-resources)
11. [Custom Code](#custom-code)
12. [Common Patterns](#common-patterns)
13. [Troubleshooting](#troubleshooting)

---

## RDLC File Structure

### Complete RDLC Skeleton

Every RDLC file MUST follow this exact structure:

```xml
<?xml version="1.0" encoding="utf-8"?>
<Report xmlns="http://schemas.microsoft.com/sqlserver/reporting/2016/01/reportdefinition" xmlns:rd="http://schemas.microsoft.com/SQLServer/reporting/reportdesigner">
  <AutoRefresh>0</AutoRefresh>
  <DataSources>
    <DataSource Name="DataSource">
      <ConnectionProperties>
        <DataProvider>SQL</DataProvider>
        <ConnectString />
      </ConnectionProperties>
      <rd:DataSourceID>a1b2c3d4-e5f6-7890-abcd-ef1234567890</rd:DataSourceID>
    </DataSource>
  </DataSources>
  <DataSets>
    <!-- Dataset definitions here -->
  </DataSets>
  <ReportSections>
    <ReportSection>
      <Body>
        <!-- Report content here -->
      </Body>
      <Width>7.5in</Width>
      <Page>
        <PageHeader>
          <!-- Page header content -->
        </PageHeader>
        <PageFooter>
          <!-- Page footer content -->
        </PageFooter>
        <PageHeight>11in</PageHeight>
        <PageWidth>8.5in</PageWidth>
        <LeftMargin>0.5in</LeftMargin>
        <RightMargin>0.5in</RightMargin>
        <TopMargin>0.5in</TopMargin>
        <BottomMargin>0.5in</BottomMargin>
        <ColumnSpacing>0.13in</ColumnSpacing>
        <Style />
      </Page>
    </ReportSection>
  </ReportSections>
  <ReportParametersLayout>
    <GridLayoutDefinition>
      <NumberOfColumns>4</NumberOfColumns>
      <NumberOfRows>2</NumberOfRows>
    </GridLayoutDefinition>
  </ReportParametersLayout>
  <Code>
    <!-- VB.NET helper code here -->
  </Code>
  <rd:ReportUnitType>Inch</rd:ReportUnitType>
  <rd:ReportID>12345678-1234-1234-1234-123456789abc</rd:ReportID>
</Report>
```

---

## Namespaces

### Required Namespace Declaration

The root `<Report>` element MUST include these namespace declarations:

```xml
<Report
  xmlns="http://schemas.microsoft.com/sqlserver/reporting/2016/01/reportdefinition"
  xmlns:rd="http://schemas.microsoft.com/SQLServer/reporting/reportdesigner">
```

**CRITICAL**: The year in the namespace (`2016`) must match the RDLC version. BC uses 2016 format.

---

## DataSources and DataSets

### DataSource Definition

```xml
<DataSources>
  <DataSource Name="DataSource">
    <ConnectionProperties>
      <DataProvider>SQL</DataProvider>
      <ConnectString />
    </ConnectionProperties>
    <rd:DataSourceID>a1b2c3d4-e5f6-7890-abcd-ef1234567890</rd:DataSourceID>
  </DataSource>
</DataSources>
```

### DataSet Definition

The DataSet contains all fields from the AL report columns:

```xml
<DataSets>
  <DataSet Name="DataSet_Result">
    <Query>
      <DataSourceName>DataSource</DataSourceName>
      <CommandText />
    </Query>
    <Fields>
      <Field Name="No_Customer">
        <DataField>No_Customer</DataField>
        <rd:TypeName>System.String</rd:TypeName>
      </Field>
      <Field Name="Name_Customer">
        <DataField>Name_Customer</DataField>
        <rd:TypeName>System.String</rd:TypeName>
      </Field>
      <Field Name="Balance_LCY_Customer">
        <DataField>Balance_LCY_Customer</DataField>
        <rd:TypeName>System.Decimal</rd:TypeName>
      </Field>
    </Fields>
    <rd:DataSetInfo>
      <rd:DataSetName>DataSet</rd:DataSetName>
    </rd:DataSetInfo>
  </DataSet>
</DataSets>
```

### Field Type Mapping (AL to RDLC)

| AL Type | RDLC rd:TypeName |
|---------|------------------|
| Code, Text | `System.String` |
| Integer | `System.Int32` |
| Decimal | `System.Decimal` |
| Boolean | `System.Boolean` |
| Date | `System.DateTime` |
| DateTime | `System.DateTime` |
| Time | `System.DateTime` |
| Option, Enum | `System.Int32` |
| GUID | `System.String` |
| Blob (MediaSet) | `System.Byte[]` |

### Field Name Mapping Rules - CRITICAL

**AL column names are transformed for RDLC:**

| AL Column Definition | RDLC Field Name |
|---------------------|-----------------|
| `column(No_Customer; "No.")` | `No_Customer` |
| `column(Name; Name)` | `Name` |
| `column(Balance_LCY; "Balance (LCY)")` | `Balance_LCY` |
| `column(SellToNo; "Sell-to Customer No.")` | `SellToNo` |

**Transformation Rules:**
1. The column NAME (first parameter) becomes the RDLC field name
2. Spaces → Underscores
3. Periods → Underscores
4. Parentheses → Underscores
5. Hyphens → Underscores
6. Double underscores may occur (e.g., `Balance__LCY_`)

---

## Report Body Structure

### Body Element

```xml
<Body>
  <ReportItems>
    <!-- All visual elements go here -->
    <Tablix Name="Tablix1">...</Tablix>
    <Textbox Name="Title">...</Textbox>
    <Rectangle Name="Header">...</Rectangle>
  </ReportItems>
  <Height>6in</Height>
  <Style />
</Body>
```

### ReportItems Container

All visual elements MUST be inside `<ReportItems>`:

```xml
<ReportItems>
  <Tablix>...</Tablix>
  <Textbox>...</Textbox>
  <Line>...</Line>
  <Rectangle>...</Rectangle>
  <Image>...</Image>
</ReportItems>
```

---

## Tablix (Tables)

### Basic Tablix Structure

Tablix is the primary element for displaying data rows:

```xml
<Tablix Name="Tablix1">
  <TablixBody>
    <TablixColumns>
      <TablixColumn>
        <Width>1.5in</Width>
      </TablixColumn>
      <TablixColumn>
        <Width>2in</Width>
      </TablixColumn>
      <TablixColumn>
        <Width>1in</Width>
      </TablixColumn>
    </TablixColumns>
    <TablixRows>
      <!-- Header row -->
      <TablixRow>
        <Height>0.25in</Height>
        <TablixCells>
          <TablixCell>
            <CellContents>
              <Textbox Name="Header_No">
                <Paragraphs>
                  <Paragraph>
                    <TextRuns>
                      <TextRun>
                        <Value>No.</Value>
                        <Style>
                          <FontWeight>Bold</FontWeight>
                        </Style>
                      </TextRun>
                    </TextRuns>
                  </Paragraph>
                </Paragraphs>
              </Textbox>
            </CellContents>
          </TablixCell>
          <!-- More header cells... -->
        </TablixCells>
      </TablixRow>
      <!-- Data row (repeated for each record) -->
      <TablixRow>
        <Height>0.25in</Height>
        <TablixCells>
          <TablixCell>
            <CellContents>
              <Textbox Name="No_Customer">
                <Paragraphs>
                  <Paragraph>
                    <TextRuns>
                      <TextRun>
                        <Value>=Fields!No_Customer.Value</Value>
                      </TextRun>
                    </TextRuns>
                  </Paragraph>
                </Paragraphs>
              </Textbox>
            </CellContents>
          </TablixCell>
          <!-- More data cells... -->
        </TablixCells>
      </TablixRow>
    </TablixRows>
  </TablixBody>
  <TablixColumnHierarchy>
    <TablixMembers>
      <TablixMember />
      <TablixMember />
      <TablixMember />
    </TablixMembers>
  </TablixColumnHierarchy>
  <TablixRowHierarchy>
    <TablixMembers>
      <TablixMember>
        <KeepWithGroup>After</KeepWithGroup>
      </TablixMember>
      <TablixMember>
        <Group Name="Details" />
      </TablixMember>
    </TablixMembers>
  </TablixRowHierarchy>
  <DataSetName>DataSet_Result</DataSetName>
  <Top>0.5in</Top>
  <Left>0in</Left>
  <Height>0.5in</Height>
  <Width>7.5in</Width>
</Tablix>
```

### TablixColumnHierarchy Rules

The number of `<TablixMember />` elements MUST match the number of `<TablixColumn>` elements:

```xml
<TablixColumnHierarchy>
  <TablixMembers>
    <TablixMember />  <!-- Column 1 -->
    <TablixMember />  <!-- Column 2 -->
    <TablixMember />  <!-- Column 3 -->
  </TablixMembers>
</TablixColumnHierarchy>
```

### TablixRowHierarchy for Header and Detail

```xml
<TablixRowHierarchy>
  <TablixMembers>
    <!-- Static header row -->
    <TablixMember>
      <KeepWithGroup>After</KeepWithGroup>
    </TablixMember>
    <!-- Repeating detail row -->
    <TablixMember>
      <Group Name="Details" />
    </TablixMember>
  </TablixMembers>
</TablixRowHierarchy>
```

### Tablix with Grouping

For grouped reports (e.g., by Customer):

```xml
<TablixRowHierarchy>
  <TablixMembers>
    <!-- Group header -->
    <TablixMember>
      <Group Name="CustomerGroup">
        <GroupExpressions>
          <GroupExpression>=Fields!No_Customer.Value</GroupExpression>
        </GroupExpressions>
      </Group>
      <TablixMembers>
        <!-- Group header row -->
        <TablixMember>
          <KeepWithGroup>After</KeepWithGroup>
        </TablixMember>
        <!-- Detail rows within group -->
        <TablixMember>
          <Group Name="Details" />
        </TablixMember>
        <!-- Group footer row -->
        <TablixMember>
          <KeepWithGroup>Before</KeepWithGroup>
        </TablixMember>
      </TablixMembers>
    </TablixMember>
  </TablixMembers>
</TablixRowHierarchy>
```

---

## Textboxes

### Basic Textbox Structure

```xml
<Textbox Name="TextboxName">
  <CanGrow>true</CanGrow>
  <KeepTogether>true</KeepTogether>
  <Paragraphs>
    <Paragraph>
      <TextRuns>
        <TextRun>
          <Value>Static Text</Value>
          <Style>
            <FontFamily>Segoe UI</FontFamily>
            <FontSize>10pt</FontSize>
            <FontWeight>Normal</FontWeight>
            <Color>Black</Color>
          </Style>
        </TextRun>
      </TextRuns>
      <Style>
        <TextAlign>Left</TextAlign>
      </Style>
    </Paragraph>
  </Paragraphs>
  <Top>0in</Top>
  <Left>0in</Left>
  <Height>0.25in</Height>
  <Width>2in</Width>
  <Style>
    <Border>
      <Style>None</Style>
    </Border>
    <PaddingLeft>2pt</PaddingLeft>
    <PaddingRight>2pt</PaddingRight>
    <PaddingTop>2pt</PaddingTop>
    <PaddingBottom>2pt</PaddingBottom>
  </Style>
</Textbox>
```

### Textbox with Field Reference

```xml
<Textbox Name="CustomerNo">
  <Paragraphs>
    <Paragraph>
      <TextRuns>
        <TextRun>
          <Value>=Fields!No_Customer.Value</Value>
        </TextRun>
      </TextRuns>
    </Paragraph>
  </Paragraphs>
</Textbox>
```

### Multi-line Textbox (Address Pattern)

```xml
<Textbox Name="CustomerAddress">
  <CanGrow>true</CanGrow>
  <Paragraphs>
    <Paragraph>
      <TextRuns>
        <TextRun>
          <Value>=Fields!CustAddr1.Value</Value>
        </TextRun>
      </TextRuns>
    </Paragraph>
    <Paragraph>
      <TextRuns>
        <TextRun>
          <Value>=Fields!CustAddr2.Value</Value>
        </TextRun>
      </TextRuns>
    </Paragraph>
    <!-- Continue for CustAddr3-8 -->
  </Paragraphs>
</Textbox>
```

---

## Expressions and Fields

### Field Reference Syntax

```
=Fields!FieldName.Value
```

**CRITICAL**: The FieldName must EXACTLY match the Field Name in the DataSet (case-sensitive).

### Common Expressions

| Purpose | Expression |
|---------|------------|
| Field value | `=Fields!No_Customer.Value` |
| Formatted date | `=Format(Fields!PostingDate.Value, "MM/dd/yyyy")` |
| Formatted decimal | `=Format(Fields!Amount.Value, "#,##0.00")` |
| Conditional display | `=IIF(Fields!Amount.Value > 0, Fields!Amount.Value, "")` |
| Sum | `=Sum(Fields!Amount.Value)` |
| Count | `=Count(Fields!No_Customer.Value)` |
| Running total | `=RunningValue(Fields!Amount.Value, Sum, Nothing)` |
| Page number | `=Globals!PageNumber` |
| Total pages | `=Globals!TotalPages` |
| Current date | `=Today()` |
| Current time | `=Now()` |
| Report name | `=Globals!ReportName` |

### IIF (Conditional Expression)

```
=IIF(condition, value_if_true, value_if_false)
```

Examples:
```
=IIF(Fields!Amount.Value > 0, "Positive", "Negative")
=IIF(Fields!Blocked.Value = True, "Yes", "No")
=IIF(IsNothing(Fields!Name.Value), "N/A", Fields!Name.Value)
```

### IsNothing (Null Check)

```
=IIF(IsNothing(Fields!FieldName.Value), "Default", Fields!FieldName.Value)
```

### Formatting Expressions

```
=Format(Fields!Amount.Value, "N2")           ' Number with 2 decimals
=Format(Fields!Amount.Value, "C")            ' Currency
=Format(Fields!PostingDate.Value, "d")       ' Short date
=Format(Fields!PostingDate.Value, "D")       ' Long date
=Format(Fields!Percentage.Value, "P2")       ' Percentage
```

### Aggregate Functions

| Function | Usage | Scope |
|----------|-------|-------|
| `Sum()` | `=Sum(Fields!Amount.Value)` | Entire dataset or group |
| `Avg()` | `=Avg(Fields!Amount.Value)` | Average |
| `Count()` | `=Count(Fields!No.Value)` | Count of values |
| `CountDistinct()` | `=CountDistinct(Fields!CustomerNo.Value)` | Distinct count |
| `Min()` | `=Min(Fields!Amount.Value)` | Minimum value |
| `Max()` | `=Max(Fields!Amount.Value)` | Maximum value |
| `First()` | `=First(Fields!Name.Value)` | First value |
| `Last()` | `=Last(Fields!Name.Value)` | Last value |

### Aggregate with Scope

```
=Sum(Fields!Amount.Value, "CustomerGroup")  ' Sum within CustomerGroup
=Sum(Fields!Amount.Value, Nothing)          ' Sum for entire dataset
```

---

## Styles and Formatting

### Text Styles

```xml
<Style>
  <FontFamily>Segoe UI</FontFamily>
  <FontSize>10pt</FontSize>
  <FontWeight>Bold</FontWeight>
  <FontStyle>Italic</FontStyle>
  <TextDecoration>Underline</TextDecoration>
  <Color>Black</Color>
</Style>
```

### Font Weights

- `Normal`
- `Bold`
- `Light`
- `Medium`
- `SemiBold`

### Text Alignment

```xml
<Style>
  <TextAlign>Left</TextAlign>    <!-- Left, Center, Right -->
  <VerticalAlign>Middle</VerticalAlign>  <!-- Top, Middle, Bottom -->
</Style>
```

### Borders

```xml
<Style>
  <Border>
    <Color>Black</Color>
    <Style>Solid</Style>
    <Width>1pt</Width>
  </Border>
  <!-- Or individual borders -->
  <TopBorder>
    <Color>Black</Color>
    <Style>Solid</Style>
    <Width>1pt</Width>
  </TopBorder>
  <BottomBorder>
    <Style>None</Style>
  </BottomBorder>
</Style>
```

### Border Styles

- `None`
- `Solid`
- `Dashed`
- `Dotted`
- `Double`

### Background Color

```xml
<Style>
  <BackgroundColor>LightGray</BackgroundColor>
</Style>
```

### Conditional Formatting

```xml
<Style>
  <BackgroundColor>=IIF(RowNumber(Nothing) Mod 2 = 0, "White", "WhiteSmoke")</BackgroundColor>
  <Color>=IIF(Fields!Amount.Value &lt; 0, "Red", "Black")</Color>
</Style>
```

**CRITICAL**: Use `&lt;` for `<` and `&gt;` for `>` in XML attributes.

### Padding

```xml
<Style>
  <PaddingLeft>2pt</PaddingLeft>
  <PaddingRight>2pt</PaddingRight>
  <PaddingTop>2pt</PaddingTop>
  <PaddingBottom>2pt</PaddingBottom>
</Style>
```

---

## Page Layout

### Page Settings

```xml
<Page>
  <PageHeader>
    <Height>1in</Height>
    <PrintOnFirstPage>true</PrintOnFirstPage>
    <PrintOnLastPage>true</PrintOnLastPage>
    <ReportItems>
      <!-- Header content -->
    </ReportItems>
    <Style>
      <Border>
        <Style>None</Style>
      </Border>
    </Style>
  </PageHeader>
  <PageFooter>
    <Height>0.5in</Height>
    <PrintOnFirstPage>true</PrintOnFirstPage>
    <PrintOnLastPage>true</PrintOnLastPage>
    <ReportItems>
      <!-- Footer content -->
    </ReportItems>
  </PageFooter>
  <PageHeight>11in</PageHeight>
  <PageWidth>8.5in</PageWidth>
  <LeftMargin>0.5in</LeftMargin>
  <RightMargin>0.5in</RightMargin>
  <TopMargin>0.5in</TopMargin>
  <BottomMargin>0.5in</BottomMargin>
  <ColumnSpacing>0.13in</ColumnSpacing>
  <Style />
</Page>
```

### Common Page Sizes

| Size | PageWidth | PageHeight |
|------|-----------|------------|
| Letter | 8.5in | 11in |
| A4 | 8.27in | 11.69in |
| Legal | 8.5in | 14in |
| Landscape Letter | 11in | 8.5in |

### Page Header with Logo and Title

```xml
<PageHeader>
  <Height>1in</Height>
  <PrintOnFirstPage>true</PrintOnFirstPage>
  <PrintOnLastPage>true</PrintOnLastPage>
  <ReportItems>
    <Image Name="Logo">
      <Source>Database</Source>
      <Value>=First(Fields!CompanyLogo.Value)</Value>
      <MIMEType>image/png</MIMEType>
      <Sizing>FitProportional</Sizing>
      <Top>0in</Top>
      <Left>0in</Left>
      <Height>0.75in</Height>
      <Width>1.5in</Width>
    </Image>
    <Textbox Name="ReportTitle">
      <Paragraphs>
        <Paragraph>
          <TextRuns>
            <TextRun>
              <Value>=First(Fields!ReportTitle.Value)</Value>
              <Style>
                <FontSize>16pt</FontSize>
                <FontWeight>Bold</FontWeight>
              </Style>
            </TextRun>
          </TextRuns>
        </Paragraph>
      </Paragraphs>
      <Top>0in</Top>
      <Left>2in</Left>
      <Height>0.4in</Height>
      <Width>4in</Width>
    </Textbox>
  </ReportItems>
</PageHeader>
```

### Page Footer with Page Numbers

```xml
<PageFooter>
  <Height>0.5in</Height>
  <PrintOnFirstPage>true</PrintOnFirstPage>
  <PrintOnLastPage>true</PrintOnLastPage>
  <ReportItems>
    <Textbox Name="PageNumber">
      <Paragraphs>
        <Paragraph>
          <TextRuns>
            <TextRun>
              <Value>="Page " &amp; Globals!PageNumber &amp; " of " &amp; Globals!TotalPages</Value>
            </TextRun>
          </TextRuns>
          <Style>
            <TextAlign>Right</TextAlign>
          </Style>
        </Paragraph>
      </Paragraphs>
      <Top>0.1in</Top>
      <Left>5.5in</Left>
      <Height>0.25in</Height>
      <Width>2in</Width>
    </Textbox>
  </ReportItems>
</PageFooter>
```

---

## Images and Embedded Resources

### Database Image (from BC Media/MediaSet)

```xml
<Image Name="CompanyLogo">
  <Source>Database</Source>
  <Value>=First(Fields!CompanyPicture.Value)</Value>
  <MIMEType>image/png</MIMEType>
  <Sizing>FitProportional</Sizing>
  <Top>0in</Top>
  <Left>0in</Left>
  <Height>1in</Height>
  <Width>2in</Width>
</Image>
```

### Sizing Options

- `AutoSize` - Image at natural size
- `Fit` - Stretch to fill (may distort)
- `FitProportional` - Fit while maintaining aspect ratio
- `Clip` - Clip to fit container

---

## Custom Code

### VB.NET Code Block

Place custom VB.NET code in the `<Code>` element:

```xml
<Code>
Public Function BlankZero(ByVal Value As Decimal) As String
  If Value = 0 Then
    Return ""
  Else
    Return Value.ToString()
  End If
End Function

Public Function BlankPos(ByVal Value As Decimal) As String
  If Value > 0 Then
    Return ""
  Else
    Return Value.ToString()
  End If
End Function

Public Function BlankZeroAndPos(ByVal Value As Decimal) As String
  If Value >= 0 Then
    Return ""
  Else
    Return Value.ToString()
  End If
End Function

' Alternating row colors
Shared offset As Integer = 0
Public Shared Function GetRowColor(ByVal NewGroup As Boolean) As String
  If NewGroup Then
    offset = 0
  Else
    offset = offset + 1
  End If

  If offset Mod 2 = 0 Then
    Return "White"
  Else
    Return "WhiteSmoke"
  End If
End Function
</Code>
```

### Calling Custom Code in Expressions

```xml
<Value>=Code.BlankZero(Fields!Amount.Value)</Value>
<BackgroundColor>=Code.GetRowColor(Fields!NewGroup.Value)</BackgroundColor>
```

### Common Helper Functions

```vb
' Format amount with blank for zero
Public Function BlankZero(ByVal Value As Decimal) As String
  If Value = 0 Then Return "" Else Return FormatNumber(Value, 2)
End Function

' Format negative in parentheses
Public Function FormatNegative(ByVal Value As Decimal) As String
  If Value < 0 Then
    Return "(" & FormatNumber(Math.Abs(Value), 2) & ")"
  Else
    Return FormatNumber(Value, 2)
  End If
End Function

' Truncate text
Public Function Truncate(ByVal Text As String, ByVal MaxLength As Integer) As String
  If String.IsNullOrEmpty(Text) Then Return ""
  If Text.Length <= MaxLength Then Return Text
  Return Text.Substring(0, MaxLength) & "..."
End Function
```

---

## Common Patterns

### List Report Layout

```xml
<Body>
  <ReportItems>
    <!-- Report Header -->
    <Textbox Name="ReportTitle">
      <Paragraphs>
        <Paragraph>
          <TextRuns>
            <TextRun>
              <Value>=First(Fields!ReportTitle.Value)</Value>
              <Style>
                <FontSize>14pt</FontSize>
                <FontWeight>Bold</FontWeight>
              </Style>
            </TextRun>
          </TextRuns>
        </Paragraph>
      </Paragraphs>
      <Top>0in</Top>
      <Left>0in</Left>
      <Height>0.35in</Height>
      <Width>7.5in</Width>
    </Textbox>

    <!-- Data Table -->
    <Tablix Name="DataTable">
      <TablixBody>
        <!-- Columns and rows as shown earlier -->
      </TablixBody>
      <Top>0.5in</Top>
      <Left>0in</Left>
    </Tablix>
  </ReportItems>
  <Height>8in</Height>
</Body>
```

### Document Report Layout (Invoice Style)

```xml
<Body>
  <ReportItems>
    <!-- Company Info Section -->
    <Rectangle Name="CompanySection">
      <ReportItems>
        <Textbox Name="CompanyName">...</Textbox>
        <Textbox Name="CompanyAddress">...</Textbox>
      </ReportItems>
      <Top>0in</Top>
      <Left>0in</Left>
      <Height>1in</Height>
      <Width>3.5in</Width>
    </Rectangle>

    <!-- Customer Info Section -->
    <Rectangle Name="CustomerSection">
      <ReportItems>
        <Textbox Name="CustomerName">...</Textbox>
        <Textbox Name="CustomerAddress">...</Textbox>
      </ReportItems>
      <Top>0in</Top>
      <Left>4in</Left>
      <Height>1in</Height>
      <Width>3.5in</Width>
    </Rectangle>

    <!-- Document Header Info -->
    <Textbox Name="DocumentNo">
      <Paragraphs>
        <Paragraph>
          <TextRuns>
            <TextRun>
              <Value>="Invoice No: " &amp; First(Fields!No_Header.Value)</Value>
            </TextRun>
          </TextRuns>
        </Paragraph>
      </Paragraphs>
      <Top>1.2in</Top>
    </Textbox>

    <!-- Lines Table -->
    <Tablix Name="LinesTable">
      <!-- Detail lines -->
      <Top>2in</Top>
    </Tablix>

    <!-- Totals Section -->
    <Rectangle Name="TotalsSection">
      <ReportItems>
        <Textbox Name="SubTotal">...</Textbox>
        <Textbox Name="VATAmount">...</Textbox>
        <Textbox Name="GrandTotal">...</Textbox>
      </ReportItems>
      <Top>7in</Top>
      <Left>4.5in</Left>
    </Rectangle>
  </ReportItems>
</Body>
```

---

## Troubleshooting

### Common Errors and Solutions

| Error | Cause | Solution |
|-------|-------|----------|
| Report won't render | Invalid XML | Validate XML syntax, check all tags closed |
| Field not found | Mismatched field name | Check exact field name in DataSet, case-sensitive |
| #Error in cell | Expression error | Verify expression syntax, check for nulls with IsNothing |
| Blank output | No data | Check DataSet has data, verify filters |
| Wrong column count | TablixMember mismatch | Ensure TablixColumnHierarchy members match column count |
| Page overflow | Content too wide | Check total width vs page width minus margins |

### XML Validation Checklist

1. **Root element**: `<Report>` with correct namespace
2. **All tags closed**: Every `<Tag>` has `</Tag>`
3. **Attributes quoted**: `attribute="value"` not `attribute=value`
4. **Special characters escaped**: `&lt;` `&gt;` `&amp;` `&quot;` `&apos;`
5. **Case consistency**: XML is case-sensitive
6. **Valid GUID format**: DataSourceID and ReportID

### Field Reference Checklist

1. Field name EXACTLY matches DataSet Field Name
2. Using `Fields!` prefix
3. Using `.Value` suffix
4. Case matches exactly

### Expression Debugging

Replace expression with static value to isolate issue:
```xml
<!-- Debug: Replace this -->
<Value>=Fields!Amount.Value</Value>

<!-- With static value -->
<Value>TEST</Value>
```

### Width Calculation

```
Available Width = PageWidth - LeftMargin - RightMargin
Example: 8.5in - 0.5in - 0.5in = 7.5in
```

All Tablix column widths MUST sum to less than or equal to available width.

---

## Critical Rules Summary

1. **Valid XML is mandatory** - any syntax error breaks the entire report
2. **Field names are case-sensitive** - must match DataSet exactly
3. **Column count must match TablixMember count** - in TablixColumnHierarchy
4. **Use proper escaping** - `&lt;` `&gt;` `&amp;` in expressions
5. **Width must fit page** - content width ≤ page width minus margins
6. **Namespace required** - Report element must have xmlns
7. **DataSetName must match** - Tablix DataSetName = DataSet Name attribute
8. **Aggregates need scope** - use Nothing for entire dataset
9. **Test expressions incrementally** - replace with static values to debug
10. **Save frequently** - RDLC corruption from bad edits is common
