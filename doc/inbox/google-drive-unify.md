# Unify local docs and pictures into Google Drive

Organize Google Drive and consolidate local documents and photos into it as the single source of truth.

## Motivation

Docs and pictures are currently scattered across local machines. Centralizing them in Google Drive makes them accessible from any device and reduces the risk of losing files when a machine dies or is replaced.

## Rough Design

- Audit current local docs and pictures across machines
- Define a folder structure in Google Drive
- Migrate local files into Drive
- Remove local-only copies once confirmed in Drive
- Set up Drive sync on all machines so future files land there automatically
