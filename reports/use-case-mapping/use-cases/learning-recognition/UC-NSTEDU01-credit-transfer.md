# UC-NSTEDU01 — Credit Transfer

## 1. Summary
A prospective student who holds an existing accredited qualification seeks entry into a new qualification with credit. The use case requires consistent mapping of skills and learning outcomes across frameworks to support repeatable credit decisions.

## 2. Business Context
- Domain / policy area: Education (Tertiary Harmonisation)
- Institutions: VET provider(s), University provider(s), regulators
- Why now: persistent inconsistency and manual effort in cross-sector credit decisions

## 3. Actors and Stakeholders
### Actors
- Prospective student
- Prospective VET or university institution (assessor / admissions)

### Stakeholders
- Student
- Institution administration
- Institution subject matter experts
- Regulators
- Previous institution

## 4. Trigger
Student seeks credit for education already completed.

## 5. Preconditions
- Skills held by student can be mapped to learning outcomes
- Previous education is accredited
- Previous education has been skills mapped
- Credit is granted in line with existing policy arrangements

## 6. Baseline Process
- Student submits transcripts/records
- Institution interprets equivalence manually
- Decision varies by assessor/institution; evidence trail inconsistent

## 7. Basic Flow (Target)
- Identify the completed qualification and its learning outcomes
- Map learning outcomes to skill entities
- Compare mapped skills against the target qualification requirements
- Produce a credit recommendation with traceable evidence references

## 8. Alternate Flows
- Alt 1: student does not wish to complete current qualification (partial completion evidence)
- Alt 2: qualification displaced/disbanded (archived/legacy evidence sources)

## 9. Pain Points
- Semantic mismatch between frameworks
- Manual interpretation and rework
- Inconsistent decision outcomes
- Weak traceability to evidence

## 10. Desired Capability
Enable evidence-based, repeatable credit transfer decisions using comparable skill entities across education frameworks.

## 11. Information Requirements
- Identifiers for qualifications/units
- Learning outcomes statements
- Mappings from learning outcomes to skills
- Policy constraints / rules (as external governance, not hardcoded)

## 12. Semantic / Model Requirements
- Skills are first-class entities with stable IDs
- Education outcomes can be aligned to skills (mapping artefact + provenance)
- Ability to represent “covers / partially covers” relationships
- Evidence links to source documents (handbook pages, training package units)

## 13. Enabling Assets
- NST skills concept scheme(s)
- Education-aligned schemes (e.g., IT2017 domains or similar bridging concepts)
- Provenance pattern for evidence (citations to authoritative sources)
- Profile/validator to ensure mappings are structurally consistent

## 14. Success Criteria
- Reduced assessment time
- Increased cross-institution consistency
- Transparent evidence trail supporting credit decisions

## 15. Out of Scope
- Institution-specific policy rule engines
- Grade equivalence and student eligibility checks

## 16. Traceability
| Requirement | Proposed representation |
|---|---|
| Comparable skills across frameworks | NST skills as SKOS concepts |
| Evidence trail | schema:citation / dcterms:source links to authoritative docs |
| Consistent mapping structure | SHACL validation under profile |

## 17. Status
Draft

## 18. Links
- Related: UC-NSTEDU02

