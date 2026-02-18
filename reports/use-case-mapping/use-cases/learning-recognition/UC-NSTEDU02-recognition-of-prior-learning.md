# UC-NSTEDU02 — Recognition of Prior Learning

## 1. Summary
A prospective student seeks entry into a new qualification and credit based on existing skills obtained through work experience or non-accredited education. The use case requires validation evidence and mappings from occupational skills to learning outcomes.

## 2. Business Context
- Domain / policy area: Education (Tertiary Harmonisation)
- Institutions: VET providers, Higher Education (HE) providers, regulators; reference sources from employers
- Why now: need for consistent, explainable RPL decisions supported by portable evidence

## 3. Actors and Stakeholders
### Actors
- Prospective student
- Prospective VET or university institution (RPL assessor)

### Stakeholders
- Student
- Institution administration
- Institution subject matter experts
- Regulators
- Previous institution (where relevant)
- Reference sources (employers, industry bodies, portfolios/CVs)

## 4. Trigger
Student seeks credit for existing skills from education, employment, or otherwise.

## 5. Preconditions
- Skills held by prospective student can be mapped to learning outcomes
- Skills can be validated
- Area seeking credit has already been mapped (education, occupation, or other)
- Credit is granted in line with existing policy arrangements

## 6. Baseline Process
- Student provides narratives/portfolios/references/resumes
- Assessors interpret evidence manually
- Outcomes vary and evidence structures are inconsistent

## 7. Basic Flow (Target)
- Identify claimed skills and supporting evidence sources
- Map claimed skills to skill concepts (taxonomy)
- Align mapped skills to target learning outcomes/requirements
- Record validation evidence and decision rationale

## 8. Alternate Flows
- Alt 1: RPL based on occupation-based skills (work history evidence)
- Alt 2: RPL based on non-accredited education (course/provider evidence)

## 9. Pain Points
- Evidence quality varies widely
- No common structure for validation
- Inconsistent mapping from work skills / non-accredited training to education outcomes

## 10. Desired Capability
Enable structured, evidence-supported RPL decisions by aligning occupational/non-accredited skill evidence to education outcomes.

## 11. Information Requirements
- Claimed skills and descriptions
- Evidence artefacts (portfolio items, references, statements of service)
- Mapping from occupational skills to learning outcomes

## 12. Semantic / Model Requirements
- Skills are first-class entities with stable IDs
- Ability to attach evidence statements to skill claims
- Representation of validation status (validated / unvalidated / partial)
- Provenance for mapping sources and RPL assessor decisions

## 13. Enabling Assets
- NST skills taxonomy and supporting schemes
- Occupation/skills alignment artefacts (e.g., occupation classifications, qualificaiton alignments)
- Automated scoring of evidence quality
- Provenance model for evidence and mappings
- Profile validates model structure

## 14. Success Criteria
- More consistent outcomes across RPL assessors
- Improved transparency and explainability of decisions
- Reduced assessment time with reusable mappings

## 15. Out of Scope
- Institution-specific policy engines

## 16. Traceability
| Requirement | Proposed representation |
|---|---|
| Skills as reusable concepta | NST skills concepts (SKOS) |
| Evidence attachment | schema:citation / dcterms:source |
| Validation status | NST Profile validation |

## 17. Status
Draft

## 18. Links
- Related: UC-NSTEDU01
    
