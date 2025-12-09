# Deep Performance Analysis

Systematic performance analysis for Volt Apparel Business Central features (currently uses static analysis - will be enhanced with profiling tools when available).

## When to Use This Command

- Systematic performance investigation required
- After quick triage identifies complex issues
- Performance regression after changes
- Optimization before production deployment
- User-reported slowness needs investigation

## Deep Analysis Workflow

### Step 1: Define Performance Scope

Ask the user:
1. **What operation is slow?** (page load, posting, report)
2. **How slow?** (seconds? minutes? acceptable vs actual)
3. **Data volume?** (number of styles, colors, sizes, transactions)
4. **Frequency?** (always slow, or only with specific data)
5. **Recent changes?** (new features, data model changes)

### Step 2: Invoke bc-debugger for Analysis

Use bc-debugger for systematic performance investigation:

```
Task(
  subagent_type: "bc-debugger",
  description: "Performance analysis",
  prompt: "Perform systematic performance analysis for: [operation]

  Performance Issue:
  - Operation: [description]
  - Current performance: [e.g., 30 seconds]
  - Expected performance: [e.g., < 5 seconds]
  - Data volume: [e.g., 10,000 styles, 50 colors per style]

  Analyze:
  1. Code structure (loops, queries, calculations)
  2. FlowField definitions and usage
  3. Database operations and keys
  4. Temporary table usage
  5. SetLoadFields implementation

  Provide:
  - Performance bottlenecks identified
  - Root cause analysis
  - Optimization recommendations
  - Implementation priority"
)
```

### Step 3: Analyze Code Patterns

bc-debugger will check:

**Database Operations**:
- FindSet without SetLoadFields
- Get/Find in loops (N+N pattern)
- Missing keys on filtered fields
- Complex table relations

**FlowFields**:
- Circular dependencies (AL0896)
- Complex CalcFormula
- Missing CalcFields calls
- Unnecessary FlowField calculations

**Calculations**:
- Repeated complex calculations
- Missing caching
- No temporary table usage
- Inefficient algorithms

**Apparel-Specific**:
- Style/color/size matrix loading
- Fabric BOM calculations
- Cut ticket line processing
- Seasonal data aggregations

### Step 4: Optimization Strategies

Based on analysis, bc-debugger recommends:

**Strategy 1: Optimize Database Access**
```al
// Before
procedure CalculateFabric()
begin
    CutTicketLine.FindSet();
    repeat
        Fabric.Get(CutTicketLine."Fabric No."); // N+N query
        TotalQty += Fabric."Qty Per" * CutTicketLine.Quantity;
    until CutTicketLine.Next() = 0;
end;

// After
procedure CalculateFabric()
begin
    CutTicketLine.SetLoadFields("Fabric No.", Quantity);
    CutTicketLine.FindSet();
    // Single calculation with cached data
    CutTicketLine.CalcSums(Quantity);
    TotalQty := CutTicketLine.Quantity * GetStandardFabricQty();
end;
```

**Strategy 2: Use Temporary Tables**
```al
// For complex calculations, use temporary table
procedure ProcessStyleMatrix()
var
    TempColorSize: Record "VT Style Color Size" temporary;
begin
    LoadToTemporary(TempColorSize); // Load once
    ProcessInMemory(TempColorSize); // Fast in-memory operations
    WriteResults(); // Single write back
end;
```

**Strategy 3: Fix Circular FlowFields**
```al
// Before: Circular FlowField
field(100; "Total Qty"; Decimal)
{
    FieldClass = FlowField;
    CalcFormula = Sum("Line"."Line Total"); // Circular
}

// After: Normal field with trigger
field(100; "Total Qty"; Decimal)
{
    trigger OnValidate()
    begin
        CalculateTotalQty(); // Controlled calculation
    end;
}
```

**Strategy 4: Add Appropriate Keys**
```al
// Add key for common filter combinations
keys
{
    key(PK; "No.") { Clustered = true; }
    key(Season; "Season Code", Department, Status) { } // Supports common queries
    key(Delivery; "Delivery Date", "Style Type") { } // Supports date filtering
}
```

### Step 5: Implement Optimizations

Once bc-debugger provides recommendations:

1. **Prioritize optimizations** by impact:
   - Critical: Fixes AL0896, N+N queries
   - High: SetLoadFields, key additions
   - Medium: Caching, temporary tables
   - Low: Minor refactoring

2. **Implement changes**:
   ```
   Task(
     subagent_type: "bc-al-developer",
     description: "Implement performance fixes",
     prompt: "Implement performance optimizations: [list]"
   )
   ```

3. **Verify improvements**:
   - Test with production data volumes
   - Measure actual performance gain
   - Check for regressions

### Step 6: Document Performance Profile

Create performance documentation:
- **Baseline**: Current performance metrics
- **Changes**: Optimizations implemented
- **Results**: Performance improvement achieved
- **Monitoring**: How to track performance over time

## Apparel Performance Patterns

### Pattern 1: Style List Optimization
```
Issue: Style List page slow with 10,000+ styles
Analysis: Loading all fields, complex matrix
Solution: SetLoadFields, lazy-load matrix, pagination
Result: Load time from 15s → 2s
```

### Pattern 2: Cut Ticket Posting Optimization
```
Issue: Posting 500-line cut ticket takes 5 minutes
Analysis: Line-by-line processing, repeated queries
Solution: Batch processing, temporary table, single commit
Result: Posting time from 5min → 15s
```

### Pattern 3: Season Planning Optimization
```
Issue: Season report generation timeout (>10min)
Analysis: Nested loops, no aggregation, missing keys
Solution: CalcSums, key additions, date range filtering
Result: Report time from timeout → 45s
```

## Performance Benchmarks

### Acceptable Performance Targets
- **Page Load**: < 3 seconds
- **List Refresh**: < 2 seconds
- **Posting**: < 1 second per 100 lines
- **Report Generation**: < 1 minute
- **Search/Filter**: < 1 second

### When Performance is Acceptable
- If within targets above
- No user complaints
- No timeout errors
- Scales with data volume

## Output

Provides:
1. Detailed performance analysis
2. Root cause identification
3. Prioritized optimization list
4. Implementation recommendations
5. Expected performance improvements
6. Verification strategy

## Note on Profiling Tools

When Business Central AL profiling tools become available in Claude Code, this command will be enhanced to include:
- CPU profiling analysis
- Memory usage tracking
- Query execution time measurement
- Automated bottleneck identification

Currently relies on static code analysis and systematic investigation via bc-debugger.
