---
name: eleanor-axlehealth-docs
description: Use when working with the Axle Health API — looking up endpoints, understanding objects like Visit, Patient, Clinician, Shift, Service, or Territory, checking request/response shapes, authentication, webhooks, or standard workflows.
always-apply: false
---

# Axle Health API Documentation

This skill gives you semantic search over the full Axle Health developer documentation (95 pages), ingested into the LGA RAG engine.

## How to use this skill

When the user asks anything about the Axle Health API, call the `query_axlehealth_docs` tool (defined below) **before** answering. Do not guess at field names, endpoint paths, or object shapes — look them up.

## Tool: query_axlehealth_docs

POST to the RAG API from inside the Docker network, using the bench:

```
POST http://rag_api:8000/query_multiple
Authorization: Bearer <jwt>
Content-Type: application/json

{
  "query": "<natural language question>",
  "file_ids": [<all 96 file IDs listed below>],
  "k": 6
}
```

Return the `page_content` from each result chunk. Use them to compose your answer. The source URL is embedded as an HTML comment at the top of each chunk's `page_content` — extract it with: `re.search(r'<!-- source: (.*?) -->', page_content).group(1)`. Use it as the reference URL in your answer.

## JWT generation

Mint a short-lived HS256 token at call time:

```python
import base64, hashlib, hmac, json, time

secret = "4e32ed61046ce7d421e0252a7a8dbd9e65c5b666ee25360b2aa3dec43ab61275".encode()
header  = base64.urlsafe_b64encode(json.dumps({"alg":"HS256","typ":"JWT"},separators=(",",":")).encode()).rstrip(b"=").decode()
payload = base64.urlsafe_b64encode(json.dumps({"id":"axlehealth-docs","iat":int(time.time()),"exp":int(time.time())+3600},separators=(",",":")).encode()).rstrip(b"=").decode()
sig     = base64.urlsafe_b64encode(hmac.new(secret, f"{header}.{payload}".encode(), hashlib.sha256).digest()).rstrip(b"=").decode()
token   = f"{header}.{payload}.{sig}"
```

## All file IDs (96 total)

```json
[
  "docs_api-endpoint_cancel-shift",
  "docs_api-endpoint_clinician-options-for-existing-visit-at-existing-time",
  "docs_api-endpoint_clinician-options-for-potential-visit-at-proposed-time",
  "docs_api-endpoint_clinician-options-for-potential-visit-over-date-range",
  "docs_api-endpoint_coverage-lookup",
  "docs_api-endpoint_create-care-team",
  "docs_api-endpoint_create-clinician",
  "docs_api-endpoint_create-patient",
  "docs_api-endpoint_create-payer",
  "docs_api-endpoint_create-qualification",
  "docs_api-endpoint_create-service",
  "docs_api-endpoint_create-service-bundle",
  "docs_api-endpoint_create-shift",
  "docs_api-endpoint_create-shift-block",
  "docs_api-endpoint_create-territory",
  "docs_api-endpoint_create-visit",
  "docs_api-endpoint_create-visit-reservation",
  "docs_api-endpoint_delete-qualification",
  "docs_api-endpoint_delete-reservation",
  "docs_api-endpoint_delete-shift-block",
  "docs_api-endpoint_edit-care-team",
  "docs_api-endpoint_edit-clinician",
  "docs_api-endpoint_edit-patient",
  "docs_api-endpoint_edit-payer",
  "docs_api-endpoint_edit-qualification",
  "docs_api-endpoint_edit-service",
  "docs_api-endpoint_edit-service-bundle",
  "docs_api-endpoint_edit-shift",
  "docs_api-endpoint_edit-shift-block",
  "docs_api-endpoint_edit-territory",
  "docs_api-endpoint_edit-visit",
  "docs_api-endpoint_generate-download-link-for-document",
  "docs_api-endpoint_generate-potential-visit-from-service-bundle",
  "docs_api-endpoint_get-care-team",
  "docs_api-endpoint_get-clinician",
  "docs_api-endpoint_get-patient",
  "docs_api-endpoint_get-qualification",
  "docs_api-endpoint_get-service",
  "docs_api-endpoint_get-service-bundle",
  "docs_api-endpoint_get-shift",
  "docs_api-endpoint_get-shift-block",
  "docs_api-endpoint_get-territory",
  "docs_api-endpoint_get-visit",
  "docs_api-endpoint_list-care-teams",
  "docs_api-endpoint_list-clinicians",
  "docs_api-endpoint_list-payers",
  "docs_api-endpoint_list-qualifications",
  "docs_api-endpoint_list-service-bundles",
  "docs_api-endpoint_list-services",
  "docs_api-endpoint_list-shift-block-instances",
  "docs_api-endpoint_list-shift-blocks",
  "docs_api-endpoint_list-shift-instances",
  "docs_api-endpoint_list-shifts",
  "docs_api-endpoint_list-territories",
  "docs_api-endpoint_list-visits",
  "docs_api-endpoint_standard-objects",
  "docs_api-endpoint_visit-time-options-for-existing-visit",
  "docs_api-endpoint_visit-time-options-for-potential-visit",
  "docs_api-overview_general-api-overview",
  "docs_api-overview_general-api-overview_api-urls",
  "docs_api-overview_general-api-overview_authentication",
  "docs_api-overview_general-api-overview_error-response",
  "docs_api-overview_general-api-overview_http-response",
  "docs_api-overview_general-api-overview_must-ignore-policy",
  "docs_api-overview_glossary",
  "docs_api-overview_glossary_availability",
  "docs_api-overview_glossary_available",
  "docs_api-overview_glossary_care-team",
  "docs_api-overview_glossary_clinic",
  "docs_api-overview_glossary_clinician",
  "docs_api-overview_glossary_clinician-appointment",
  "docs_api-overview_glossary_clinician-option",
  "docs_api-overview_glossary_delivery-model",
  "docs_api-overview_glossary_eligible",
  "docs_api-overview_glossary_encounter",
  "docs_api-overview_glossary_in-clinic",
  "docs_api-overview_glossary_mobile",
  "docs_api-overview_glossary_patient",
  "docs_api-overview_glossary_patient-appointment",
  "docs_api-overview_glossary_potential-visit",
  "docs_api-overview_glossary_qualification",
  "docs_api-overview_glossary_service",
  "docs_api-overview_glossary_service-area",
  "docs_api-overview_glossary_service-bundle",
  "docs_api-overview_glossary_shift",
  "docs_api-overview_glossary_shift-block",
  "docs_api-overview_glossary_territories",
  "docs_api-overview_glossary_territory",
  "docs_api-overview_glossary_visit",
  "docs_api-overview_standard-workflow",
  "docs_api-overview_standard-workflow_axle-visit",
  "docs_api-overview_standard-workflow_editing-visit",
  "docs_api-overview_webhook_webhook-signature",
  "docs_api-overview_webhooks",
  "introduction"
]
```

## Query strategy

- **Broad question** ("how does scheduling work?") → use `k: 8`, rephrase as a specific question
- **Specific endpoint** ("create visit request body") → use `k: 4`
- **Object definition** ("what is a Service Area?") → include glossary file IDs in the search; `k: 3` is usually enough
- If the first result is clearly irrelevant, retry with a rephrased query before saying "I don't know"
