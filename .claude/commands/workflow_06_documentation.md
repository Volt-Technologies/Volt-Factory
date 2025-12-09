# Workflow 06: Documentation

Please provide the following information to start the documentation phase:

**Required:**
- Feature Name: {FEATURE_NAME} (e.g., "Product Variants")
- User Story Name: {USER_STORY_NAME} (e.g., "Create Variant from Template")

**Required - Environment Details for Screenshots:**
- BC Tenant ID: {TENANT_ID}
- Environment Name: {ENV_NAME} (with deployed feature)
- Company Name: {COMPANY_NAME}
- Relevant Page IDs: {PAGE_IDS} (pages to document)

---

Once you provide the information above, I will launch the **gitbook-documentation-builder** agent to:
- Read functional design from factory/2functional_design/[Feature]/[UserStory]/ for business context
- Read technical specs from factory/3technical_design/[Feature]/[UserStory]/ for implementation details
- Identify Business Central pages and processes to document
- Plan documentation structure (markdown files, screenshots)
- Navigate to BC using Chrome DevTools MCP
- Capture screenshots for each step of the process
- Create/update markdown files in docs/ folder
- Save screenshots to .gitbook/assets/
- Create documentation output in factory/6documentation/[Feature]/[UserStory]/
- Update SUMMARY.md with proper navigation
- Add cross-references to related documentation
- Review for completeness and accuracy

**Prerequisites:**
- ✅ Development completed (feature implemented)
- ✅ Testing completed (feature tested and working)
- ✅ Feature deployed and accessible in BC environment
- ✅ All previous stage outputs exist in factory folders

**Documentation Content Standards:**
Each feature documentation must include:
- **Overview Section**: What it does, who uses it, when to use it
- **Prerequisites**: Required setup, permissions, configuration
- **Step-by-Step Instructions**: Numbered steps with screenshots
- **Field Reference**: Table of all fields with descriptions
- **Business Rules**: Validation rules and business logic
- **Examples**: Real-world scenarios
- **Troubleshooting**: Common errors and solutions
- **Related Topics**: Links to associated documentation

**Success Criteria:**
- ✅ All required markdown files created/updated in docs/ folder
- ✅ Screenshots captured for each significant step
- ✅ Documentation summary created in factory/6documentation/[Feature]/[UserStory]/
- ✅ SUMMARY.md updated with correct navigation links
- ✅ Cross-references to related modules added
- ✅ Documentation follows GitBook structure standards
- ✅ LLM-readable with complete functional precision

**Completion:** Documentation completion marks the end of the feature implementation workflow. The feature is now:
- ✅ Researched (factory/1research/[Feature]/)
- ✅ Functionally Designed (factory/2functional_design/[Feature]/[UserStory]/)
- ✅ Technically Designed (factory/3technical_design/[Feature]/[UserStory]/)
- ✅ Implemented (factory/4development/[Feature]/[UserStory]/)
- ✅ Tested (factory/5unit_test/[Feature]/[UserStory]/)
- ✅ Documented (factory/6documentation/[Feature]/[UserStory]/ and docs/)
