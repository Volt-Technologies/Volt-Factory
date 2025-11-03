# BC Functional Designer - Multi-Agent Architecture

## Overview

The **BC Functional Designer** has been transformed from a single monolithic agent into a sophisticated **multi-agent orchestration system** with **11 specialized sub-agents**, each focused on a specific aspect of functional design. This architecture dramatically increases design quality, depth of reasoning, and ensures comprehensive coverage of all functional requirements.

---

## Why Multi-Agent Architecture?

### Problems with Single-Agent Design
- **Shallow Analysis**: One agent trying to do everything results in superficial coverage
- **Inconsistent Quality**: Varying depth across different design aspects
- **Missing Perspectives**: No critical review or alternative exploration
- **Template Drift**: Inconsistent documentation formats
- **Cognitive Overload**: Too many responsibilities for one agent

### Benefits of Multi-Agent System
✅ **Deep Expertise**: Each agent specializes in one domain
✅ **Critical Review**: Solution Critic challenges assumptions
✅ **BC Alignment**: Dedicated validator ensures BC best practices
✅ **Agent-Friendly Design**: Dedicated optimizer for automation
✅ **Consistent Quality**: Template Enforcer ensures uniformity
✅ **Comprehensive Coverage**: Nothing falls through the cracks
✅ **Iterative Refinement**: Design improves through multiple passes

---

## Agent Architecture

### 11 Specialized Sub-Agents

```
┌──────────────────────────────────────────────────────────────────┐
│                    BC FUNCTIONAL DESIGNER                         │
│                      (Orchestrator)                               │
└────────────────────────┬─────────────────────────────────────────┘
                         │
         ┌───────────────┴───────────────┐
         │                               │
    ┌────▼────┐                    ┌────▼────┐
    │ PHASE 1 │                    │ PHASE 2 │
    │Analysis │                    │Solution │
    └────┬────┘                    └────┬────┘
         │                               │
    ┌────┴────────────┐         ┌────────┴──────────────┐
    │                 │         │                        │
┌───▼───┐      ┌─────▼────┐  ┌─▼────┐  ┌────▼─────┐  ┌─▼─────┐
│01     │      │02        │  │03    │  │04        │  │05     │
│Require│      │Data      │  │Initia│  │Solution  │  │BC     │
│ments  │      │Model     │  │l     │  │Critic    │  │Integr │
│Analyz │      │Designer  │  │Soluti│  │& Refine  │  │ation  │
│er     │      │          │  │on    │  │          │  │Valid  │
└───┬───┘      └─────┬────┘  └─┬────┘  └────┬─────┘  └─┬─────┘
    │                │         │             │          │
    └────────────────┴─────────┴─────────────┴──────────┘
                     │
              ┌──────▼──────┐
              │   PHASE 3   │
              │Detailed     │
              │Design       │
              └──────┬──────┘
                     │
       ┌─────────────┼─────────────┐
       │             │             │
   ┌───▼───┐    ┌───▼───┐    ┌───▼───┐
   │06     │    │07     │    │08     │
   │UI/UX  │    │Busines│    │Agentic│
   │Flow   │    │s Logic│    │Design │
   │Design │    │Design │    │Optim  │
   └───┬───┘    └───┬───┘    └───┬───┘
       │            │            │
       └────────────┴────────────┘
                    │
             ┌──────▼──────┐
             │   PHASE 4   │
             │Work Items   │
             └──────┬──────┘
                    │
            ┌───────┴───────┐
            │               │
        ┌───▼───┐      ┌───▼───┐
        │11     │      │12     │
        │User   │      │Task   │
        │Story  │      │Decomp │
        │Create │      │osition│
        └───┬───┘      └───┬───┘
            │              │
            └──────┬───────┘
                   │
            ┌──────▼──────┐
            │   PHASE 5   │
            │Quality      │
            │Assurance    │
            └──────┬──────┘
                   │
               ┌───▼───┐
               │13     │
               │Templat│
               │e      │
               │Enforce│
               │r & QA │
               └───────┘
```

---

## Agent Catalog

### Phase 1: Analysis

**01 - Requirements Analyzer** (`01_requirements_analyzer.md`)
- **Purpose**: Deep analysis of research output, comprehensive requirements extraction
- **Input**: Research documents from bc-business-research
- **Output**: Requirements analysis document (01_requirements_analysis.md)
- **Key Responsibilities**:
  - Extract all functional requirements (FR-xxx)
  - Identify data requirements (DR-xxx)
  - Document business rules (BR-xxx)
  - Create traceability matrix
  - Map to BC modules

**02 - Data Model Designer** (`02_data_model_designer.md`)
- **Purpose**: Design all data structures required
- **Input**: Requirements analysis
- **Output**: Data model design document (02_data_model_design.md)
- **Key Responsibilities**:
  - Design table extensions
  - Specify all fields with IDs, types, properties
  - Design enumerations
  - Plan data integrity and relationships
  - Define migration strategy

---

### Phase 2: Solution Design (Iterative)

**03 - Initial Solution Designer** (`03_initial_solution_designer.md`)
- **Purpose**: Create first-pass functional solution
- **Input**: Requirements + Data model
- **Output**: Initial solution design (03_initial_solution_design.md)
- **Key Responsibilities**:
  - Research BC native capabilities
  - Propose solution architecture
  - Design feature implementation approach
  - Consider alternatives and trade-offs
  - Plan integration with BC

**04 - Solution Critic & Refinement** (`04_solution_critic.md`)
- **Purpose**: Challenge assumptions, identify weaknesses, propose improvements
- **Input**: Initial solution design
- **Output**: Critique report + Refined solution (04_solution_critique.md)
- **Iterations**: 2-3 cycles typical
- **Key Responsibilities**:
  - Challenge every major design decision
  - Propose alternative approaches
  - Identify edge cases
  - Enhance risk analysis
  - Refine until robust

**05 - BC Integration Validator** (`05_bc_integration_validator.md`)
- **Purpose**: Ensure BC alignment and best practices
- **Input**: Refined solution design
- **Output**: BC integration validation report (05_bc_integration_validation.md)
- **Key Responsibilities**:
  - Validate BC architecture alignment
  - Research BC objects using AL MCP
  - Verify event subscriptions
  - Check upgrade compatibility
  - Ensure app-only approach

---

### Phase 3: Detailed Design (Parallel Execution)

**06 - UI/UX Flow Designer** (`06_ui_ux_flow_designer.md`)
- **Purpose**: Design comprehensive, user-friendly interfaces and workflows
- **Input**: Refined solution + BC validation + UI requirements
- **Output**: UI/UX design document (06_ui_ux_design.md)
- **Key Responsibilities**:
  - Design all page extensions
  - Specify actions and field placements
  - Create user workflows with wireframes
  - Design visual indicators
  - Plan user messages and feedback

**07 - Business Logic Designer** (`07_business_logic_designer.md`)
- **Purpose**: Design all business rules, validations, calculations, process flows
- **Input**: Refined solution + BC validation + Business rule requirements
- **Output**: Business logic design (07_business_logic_design.md)
- **Key Responsibilities**:
  - Design all validation rules
  - Specify calculation formulas
  - Define state machines
  - Document process flows
  - Plan BC processing integration

**08 - Agentic Design Optimizer** (`08_agentic_design_optimizer.md`)
- **Purpose**: Make features executable by both humans AND AI agents
- **Input**: UI/UX + Business logic designs
- **Output**: Agentic optimization report (08_agentic_optimization.md)
- **Key Responsibilities**:
  - Design API access points
  - Plan MCP tool interfaces
  - Design automation workflows
  - Create agent-friendly error handling
  - Plan observability for agents

---

### Phase 4: Work Item Creation

**11 - User Story Creator** (`11_user_story_creator.md`)
- **Purpose**: Transform features into well-written Agile user stories
- **Input**: All functional design documents
- **Output**: User stories document + Azure DevOps user stories (11_user_stories.md)
- **Key Responsibilities**:
  - Write stories in "As a... I want... So that..." format
  - Define specific, testable acceptance criteria
  - Prioritize stories (MVP vs post-MVP)
  - Create stories in Azure DevOps
  - Link to parent features

**12 - Task Decomposition** (`12_task_decomposition.md`)
- **Purpose**: Break user stories into granular functional tasks
- **Input**: User stories + All functional designs
- **Output**: Task decomposition document + Azure DevOps tasks (12_task_decomposition.md)
- **Key Responsibilities**:
  - Identify all functional-level work
  - Specify task scope and dependencies
  - Sequence tasks appropriately
  - Create tasks in Azure DevOps
  - Link to user stories

---

### Phase 5: Quality Assurance

**13 - Template Enforcer & QA** (`13_template_enforcer_qa.md`)
- **Purpose**: Final quality gate - ensure consistency, completeness, and readiness
- **Input**: ALL functional design documents
- **Output**: QA validation report (13_qa_validation_report.md)
- **Key Responsibilities**:
  - Verify template compliance
  - Validate completeness
  - Enforce consistency (terminology, naming, references)
  - Check traceability
  - Assess quality and readiness
  - Provide corrective actions plan

---

## Workflow Orchestration

### Standard Workflow

```
1. Phase 1: Analysis (Sequential)
   → 01: Requirements Analyzer
   → 02: Data Model Designer

2. Phase 2: Solution Design (Iterative, 2-3 cycles)
   → 03: Initial Solution Designer
   → 04: Solution Critic & Refinement
   → 05: BC Integration Validator
   [Repeat 03-05 if critic recommends another iteration]

3. Phase 3: Detailed Design (Parallel)
   → 06: UI/UX Flow Designer  ┐
   → 07: Business Logic Designer ├─ Run in parallel
   → 08: Agentic Design Optimizer ┘

4. Phase 4: Work Item Creation (Sequential)
   → 11: User Story Creator
   → 12: Task Decomposition

5. Phase 5: Quality Assurance (Final)
   → 13: Template Enforcer & QA
   [If QA fails: Fix issues and re-run QA]
   [If QA passes: Ready for technical design]
```

### Execution Modes

**Full Pipeline** (Recommended):
- Execute all agents in sequence/parallel as designed
- Maximum quality and detail
- Takes longer but produces best results

**Fast Track** (Skip Some Agents):
- Skip agent 08 (Agentic Optimizer) if not building APIs
- Skip iteration cycles in Phase 2 for simple features
- Still run QA agent (13) for quality gate

**Custom Pipeline**:
- Run only specific agents as needed
- Useful for updating specific design aspects
- Example: Re-run UI/UX designer after feedback

---

## How to Use This System

### For Orchestrator (Main Agent)

When the bc-functional-designer agent receives a request:

1. **Assess Scope**: Determine which agents are needed
2. **Phase 1**: Launch agents 01 → 02 sequentially
3. **Phase 2**: Launch agent 03, then 04, then 05. Check if critic recommends iteration.
4. **Phase 3**: Launch agents 06, 07, 08 in parallel (use single message with multiple Task calls)
5. **Phase 4**: Launch agents 11 → 12 sequentially
6. **Phase 5**: Launch agent 13 for final QA
7. **Iterate if Needed**: If QA finds critical issues, fix and re-run QA
8. **Handoff**: When QA passes, prepare handoff to bc-technical-designer

### For Users

Simply invoke the main bc-functional-designer agent. It will automatically orchestrate all sub-agents:

```
"Please create functional design for the order cancellation feature based on the research in factory/1research"
```

The orchestrator handles:
- Reading research output
- Launching appropriate sub-agents
- Coordinating their work
- Ensuring quality through QA
- Preparing handoff to technical design

---

## Output Structure

All functional design outputs are organized in:
```
factory/
└── 2functional_design/
    ├── input/                        # User-provided additional docs
    ├── 01_requirements_analysis.md    # Agent 01 output
    ├── 02_data_model_design.md       # Agent 02 output
    ├── 03_initial_solution_design.md  # Agent 03 output
    ├── 04_solution_critique.md        # Agent 04 output
    ├── 05_bc_integration_validation.md # Agent 05 output
    ├── 06_ui_ux_design.md            # Agent 06 output
    ├── 07_business_logic_design.md    # Agent 07 output
    ├── 08_agentic_optimization.md     # Agent 08 output
    ├── 11_user_stories.md            # Agent 11 output
    ├── 12_task_decomposition.md       # Agent 12 output
    └── 13_qa_validation_report.md     # Agent 13 output
```

---

## Key Design Principles

### 1. Feature-Agnostic
All sub-agents are generic and reusable for ANY feature. They don't contain feature-specific logic.

### 2. Template-Driven
Each agent has a defined output template ensuring consistency across all functional designs.

### 3. Traceable
Every requirement, story, and task maintains traceability back to business needs.

### 4. BC-Native
Designs leverage Business Central's native capabilities and follow Microsoft best practices.

### 5. Agent-Friendly
Features designed to be executable by both humans and AI agents (MCP tools).

### 6. Quality-Gated
Final QA agent ensures nothing proceeds to technical design unless it meets quality standards.

---

## Integration with Volt Factory Workflow

### Input (from Previous Phase)
- **bc-business-research** outputs:
  - factory/1research/[INDUSTRY]_business_research.md
  - Azure DevOps Epics and Features

### Output (to Next Phase)
- **bc-technical-designer** receives:
  - All 11+ functional design documents
  - Azure DevOps User Stories and Tasks
  - QA sign-off for readiness

### Workflow Position
```
Phase 0: bc-business-research
    ↓
Phase 1: bc-functional-designer (THIS MULTI-AGENT SYSTEM)
    ↓
Phase 2: bc-technical-designer
    ↓
Phase 3: bc-al-developer
    ↓
Phase 4: bc-app-compiler
    ↓
Phase 5: bc-test-runner
```

---

## Advanced Usage

### Parallel Execution
Launch Phase 3 agents in parallel for faster execution:
```
In single orchestrator message, use multiple Task tool calls:
- Task(subagent: 06-ui-ux)
- Task(subagent: 07-business-logic)
- Task(subagent: 08-agentic-optimizer)
```

### Iteration Control
Solution Critic (agent 04) determines if another design iteration is needed. Typically 2-3 iterations produce optimal results.

### Quality Gates
Template Enforcer (agent 13) has three outcomes:
- ✅ **Pass**: Ready for technical design
- ⚠️ **Conditional Pass**: Fix minor issues then proceed
- ❌ **Fail**: Fix critical issues and re-run QA

---

## Maintenance & Extension

### Adding New Sub-Agents
1. Create new agent file: `XX_agent_name.md`
2. Follow template structure from existing agents
3. Update this README with new agent details
4. Update orchestrator logic if needed

### Modifying Agents
- Each agent is independent
- Changes to one agent don't affect others
- Maintain template compliance

### Agent Dependencies
- Phase 1 agents are prerequisites for Phase 2
- Phase 2 validation gates Phase 3
- Phase 3 complete before Phase 4
- Phase 4 complete before Phase 5 QA

---

## Troubleshooting

**Issue**: Agent produces incomplete output
- **Solution**: Check that agent has access to all required input documents

**Issue**: Inconsistent terminology across documents
- **Solution**: Template Enforcer (agent 13) will catch and fix this

**Issue**: QA fails repeatedly
- **Solution**: Review critical issues list, address blocking problems first

**Issue**: Design iteration takes too long
- **Solution**: Skip solution critic for simple features, or limit to 1-2 iterations

---

## Success Metrics

Functional design is successful when:
- ✅ All requirements traced to user stories and tasks
- ✅ BC integration validated and approved
- ✅ UI/UX designed with complete workflows
- ✅ Business logic specified with clear rules
- ✅ Features designed for both human and agent use
- ✅ Template QA passes
- ✅ Azure DevOps work items created and linked
- ✅ Technical design team can implement without ambiguity

---

## Contact & Support

For issues or questions about the multi-agent functional designer:
1. Review this README
2. Check individual agent documentation
3. Consult Volt Factory main documentation

---

**Version**: 1.0
**Last Updated**: 2025-01-15
**Agents Count**: 11 specialized sub-agents
**Total Lines of Agent Specs**: ~15,000 lines
