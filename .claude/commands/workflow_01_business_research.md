# Workflow 01: Business Research

Please provide the following information to start the business research phase:

**Required:**
- Industry name (e.g., "apparel", "wholesale distribution", "food manufacturing"): {INDUSTRY_NAME}

**Optional:**
- Any specific requirements or focus areas: {FOCUS_AREAS}

---

Once you provide the information above, I will launch the **bc-business-research** agent to:
- Conduct comprehensive industry research (20+ web searches)
- Analyze Business Central capabilities
- Identify business journeys (8-12 major areas)
- Break down into business capabilities (30-50 features)
- Generate research documentation organized by feature in factory/1research/[Feature]/

**Note:** Documents in `factory/1research/` will be automatically analyzed.

**Success Criteria:**
- ✅ 8-12 major business journeys identified
- ✅ 30-50 features documented
- ✅ Research documents created in factory/1research/[Feature]/ folders
- ✅ Research document (5,000+ words) per feature
- ✅ Handoff document prepared

**Next Stage:** Use `/workflow_02_functional_design` to process the created Features.
