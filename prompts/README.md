# Volt-Factory Workflow Prompts

This directory contains ready-to-use prompts for different workflow scenarios in the Volt-Factory. Each prompt is designed to be copy-pasted directly into Claude Code or given to a global agent to execute a specific portion of the development lifecycle.

## 📋 Available Workflows

### 1️⃣ Full Workflow (`01_full_workflow.md`)
**Use when:** You have a business requirement and want to go through the complete development lifecycle.

**Workflow:** Business Requirement → Functional Design → Technical Design → Development → Compilation/Publishing → Testing → Documentation

**Result:** Complete feature from business requirement to published, tested, and documented implementation.

---

### 2️⃣ Business to Functional Design (`02_business_to_functional_design.md`)
**Use when:** You need to analyze a business requirement and create a functional design only, without proceeding to technical implementation.

**Workflow:** Business Requirement → Functional Design ✋ (STOP)

**Result:** Functional design with Azure DevOps work items (Epic, Features, User Stories, Tasks), but no technical specifications or code.

---

### 3️⃣ Functional to Technical Design (`03_functional_to_technical_design.md`)
**Use when:** You already have a functional design and need to create detailed technical specifications, but not develop the code yet.

**Workflow:** Existing Functional Design → Technical Design ✋ (STOP)

**Result:** Technical design with detailed AL object specifications, algorithms, and technical subtasks in Azure DevOps, but no code implementation.

---

### 4️⃣ Functional Design to Completion (`04_functional_to_completion.md`)
**Use when:** You have a completed functional design and want to execute the entire technical workflow through to documentation.

**Workflow:** Existing Functional Design → Technical Design → Development → Compilation/Publishing → Testing → Documentation

**Result:** Complete implementation from existing functional design to published, tested, and documented feature.

---

### 5️⃣ Development to Completion (`05_development_to_completion.md`)
**Use when:** You have technical specifications ready and want to develop, compile, test, and document the feature.

**Workflow:** Existing Technical Design → Development → Compilation/Publishing → Testing → Documentation

**Result:** Developed, compiled, tested, and documented feature from existing technical specifications.

---

### 6️⃣ Testing Only (`06_testing_only.md`)
**Use when:** Code has been developed and compiled, and you need to run tests and iterate on failures.

**Workflow:** Existing Code (compiled) → Testing (with iteration loop to development/compilation if tests fail)

**Result:** All unit tests passing, with automated iteration cycle for fixing test failures.

---

### 7️⃣ Documentation Only (`07_documentation_only.md`)
**Use when:** A feature is already implemented and tested, and you need to generate user documentation.

**Workflow:** Existing Feature (implemented & tested) → Documentation

**Result:** Complete end-user documentation with screenshots, organized in GitBook structure.

---

## 🎯 How to Use These Prompts

1. **Choose the appropriate workflow** based on your starting point and desired endpoint
2. **Open the corresponding markdown file** (e.g., `03_functional_to_technical_design.md`)
3. **Copy the entire content** of the file
4. **Paste it into Claude Code** or provide it to your global agent
5. **Customize the feature description** in the prompt to match your specific requirement
6. **Execute** and let the Volt-Factory agents handle the workflow

## 🔄 Workflow Phase Reference

| Phase | Agent | Description |
|-------|-------|-------------|
| **Functional Design** | `bc-functional-designer` | Analyzes business requirements and creates functional specifications with Azure DevOps work items |
| **Technical Design** | `bc-technical-designer` | Translates functional specs into detailed AL technical design with object specifications |
| **Development** | `bc-al-developer` | Implements AL code in the `BC` folder and unit tests in the `BC Test` folder |
| **Compilation & Publishing** | `bc-app-compiler` | Compiles and publishes the BC app to the environment |
| **Testing** | `bc-test-runner` | Executes unit tests via AL Test Tool and reports results |
| **Documentation** | `gitbook-documentation-builder` | Creates end-user documentation with screenshots in GitBook format |

## 🔗 Azure DevOps Work Item Hierarchy

All workflows that include functional or technical design follow this Azure DevOps structure:

```
Epic (Business Capability)
└── Feature (Major Functional Area)
    └── User Story (User-facing functionality)
        └── Task (Functional-level work items)
            └── Subtask (Technical implementation items)
```

## 💡 Tips

- **Iteration Cycles**: Development, compilation, and testing phases include automatic iteration loops. If compilation fails, the developer agent will fix and retry. If tests fail, the developer will fix, recompile, and retest.
- **Stopping Points**: Workflows with explicit STOP points will not proceed further automatically. You can then use another workflow prompt to continue from that point.
- **Customization**: Each prompt has placeholder feature descriptions. Replace them with your specific requirements before execution.
- **Azure DevOps**: Most workflows integrate with Azure DevOps for work item tracking. Ensure your Azure DevOps MCP server is configured.

## 📝 Example Usage

**Scenario**: You have a business requirement for a new feature.

1. Start with `01_full_workflow.md` if you want everything done end-to-end
2. Or start with `02_business_to_functional_design.md` to just create the functional design
3. Later, continue with `04_functional_to_completion.md` to complete the implementation

**Scenario**: You already have code but need tests.

1. Use `06_testing_only.md` to run the test suite and iterate on failures

**Scenario**: Everything is done except documentation.

1. Use `07_documentation_only.md` to generate comprehensive user guides

---

**Need a custom workflow?** You can create your own by combining phases from the existing prompts or modifying them to suit your specific needs.
