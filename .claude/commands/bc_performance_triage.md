# Quick Performance Triage

Perform quick performance diagnosis using static code analysis for Volt Apparel Business Central code.

## When to Use This Command

- Quick performance check before deployment
- Identify obvious performance bottlenecks
- Review code for common anti-patterns
- Pre-review before detailed profiling

## Quick Triage Workflow

### Step 1: Identify Performance Area

Ask the user:
1. **Which objects?** (VT Style List, Cut Ticket posting, etc.)
2. **What's slow?** (Page load, report generation, posting)
3. **Data volume?** (How many styles, colors, sizes?)
4. **Recent changes?** (New FlowFields, additional queries?)

### Step 2: Static Code Analysis

Use Grep and Read to analyze code patterns:

```
1. Find FlowField definitions:
   Grep(pattern: "FieldClass = FlowField", path: "BC/src", output_mode: "content")

2. Check for CalcFormula complexity:
   Grep(pattern: "CalcFormula = Sum\\(|Count\\(", path: "BC/src", output_mode: "content")

3. Look for loops:
   Grep(pattern: "repeat|while|for", path: "BC/src", output_mode: "content")

4. Find database operations in loops:
   Grep(pattern: "FindSet\\(\\)|FindFirst\\(\\)|Get\\(", path: "BC/src", output_mode: "content")
```

### Step 3: Check Common Anti-Patterns

**Anti-Pattern 1: N+N Queries**
```al
// BAD: Query in loop
repeat
    if Style.Get(Line."Style No.") then // Database call per line!
        Qty += Style."Qty Per";
until Line.Next() = 0;

// GOOD: Single aggregation
Line.SetLoadFields("Style No.", Quantity);
Line.CalcSums(Quantity);
```

**Anti-Pattern 2: Missing SetLoadFields**
```al
// BAD: Loads all fields
CutTicketLine.FindSet();

// GOOD: Load only needed fields
CutTicketLine.SetLoadFields("Document No.", "Style No.", Quantity);
CutTicketLine.FindSet();
```

**Anti-Pattern 3: Circular FlowFields (AL0896)**
```al
// BAD: Circular dependency
table "VT Cut Ticket Header"
{
    field(100; "Total Qty"; Decimal)
    {
        CalcFormula = Sum("VT Cut Ticket Line"."Line Total"...);
    }
}

table "VT Cut Ticket Line"
{
    field(50; "Line Total"; Decimal)
    {
        CalcFormula = Sum("VT Cut Ticket Header"."Total Qty"...); // CIRCULAR!
    }
}
```

**Anti-Pattern 4: Inefficient Filtering**
```al
// BAD: Filter on non-indexed field
Style.SetFilter(Description, '*Summer*'); // Full table scan

// GOOD: Filter on indexed field
Style.SetRange("Season Code", 'SS2024'); // Uses key
```

### Step 4: Report Findings

Create summary:
1. **Performance Issues Found**: List anti-patterns detected
2. **Severity**: High/Medium/Low
3. **Affected Objects**: VT objects with issues
4. **Quick Wins**: Easy fixes (add SetLoadFields, fix filters)
5. **Needs Profiling**: Complex issues requiring bc_performance command

### Step 5: Recommend Actions

For each issue:
- **Immediate fix**: Simple changes (add SetLoadFields)
- **Refactor needed**: Structural changes (break circular FlowFields)
- **Deep analysis needed**: Use `/bc_performance` for profiling

## Apparel-Specific Performance Checks

### VT Style List Performance
- Check SetLoadFields on Style List page
- Verify color/size matrix not loading all variants
- Check fabric BOM calculations

### VT Cut Ticket Posting Performance
- Verify batch operations (not line-by-line)
- Check SetLoadFields on line processing
- Review fabric quantity calculations

### VT Season Planning Performance
- Check date range filters on large datasets
- Verify aggregations use CalcSums not loops
- Review historical data queries

## Quick Triage Checklist

- [ ] FlowFields reviewed for complexity
- [ ] SetLoadFields used before FindSet
- [ ] No database queries in loops
- [ ] Filters use indexed fields
- [ ] No circular FlowField dependencies
- [ ] CalcSums used for aggregations
- [ ] Temporary tables for intermediate data

## When to Escalate

If quick triage finds:
- **Circular FlowFields** → Fix immediately (AL0896)
- **N+N queries** → Refactor to set-based operations
- **Complex performance issues** → Use `/bc_performance` for profiling
- **Unexplained slowness** → Invoke bc-debugger for investigation

## Output

Provides:
1. List of performance anti-patterns found
2. Severity assessment
3. Quick fix recommendations
4. Objects requiring deeper analysis
5. Next steps (immediate fixes vs profiling needed)
