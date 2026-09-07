# SDD

The name of the engineering practice becoming popular in 25, 26 is spec-driven development where Humans write markdown specification of engineering intent and then hand over to AI agents for implementation.
There are steps: specify, plan, tasks and implementation.
Markdown Knowledge Graph Is an organization strategy that links markdown files together making them easy to navigate for humans and agents, saving context.

So from basic to auxiliary, Markdown as the file format, English as the language, I'd use OKF in everything.
You only stand to gain from this, Machine readable, organizable, extensible.
Save everything in git, review and commit in the repository Alongside the code.
Existing markdown files can be left alone but should be given an OKF front matter.
I think SDD is only for specs and OKF Markdown can be anything, not just specs.
SDD is a methodology for writing markdown files describing implementation.
Specs should live in the SPC directory.

Specifications can be reversed engineered from current implementation code.
If so, they should be marked in their metadata reverse-engineered: true.
Existing documentation can be left alone with just the addition of a front matter, Documentation is not a specification, but can be made into one.
For a specification to be reverse engineered, it should be reviewed carefully.

- Markdown -> representation.
- English -> human/agent-readable content.
- OKF -> lightweight structure/metadata convention.
- wikilinks -> relationships.
- software metadata -> more nuanced relationships between spec files in the frontmatter.
- Git -> persistence/history/review.
- Graph -> derived structure.
- IWE/OKq -> tooling over the structure, visual graph navigation.
- SPC -> location/convention for specifications.
- SDD -> methodology for creating and maintaining specifications.
- Agent/Human -> consumer/producer of all of the above.

> Reading list in order
>
> - [x] https://martinfowler.com/articles/exploring-gen-ai/sdd-3-tools.html
> - [ ] https://www.thoughtworks.com/en-br/insights/blog/agile-engineering-practices/spec-driven-development-unpacking-2025-new-engineering-practices
> - [ ] https://www.thoughtworks.com/radar/techniques/spec-driven-development
> - [ ] https://github.com/github/spec-kit/blob/main/README.md
> - [ ] https://kiro.dev/blog/from-chat-to-specs-deep-dive/

| Level | Artifact      | Kind                          |
| ----- | ------------- | ----------------------------- |
| 3     | Spec          | Intent, behavior, description |
| 2     | Documentation | Software knowledge            |
| 1     | Document      | Knowledge                     |
| 0     | `.md` file    | Text                          |

```
Constitution, markdown file with high level guidelines
    -> is read as a starting point to
Specify, describe behavior and intent of a change to the software
    -> refine iterate explore and organize into
Plan, an organized and validated document of intent, behavior and decisions
    -> review and analyze, then subdivide into
Tasks, steps to implement a plan, in logical order
    -> implemented by agents
Code, reviewed and iterated by the team
    -> spec author performs quality assurance and review
Ship
```

### metadata

Front matter metadata should be used to enrich documents.
Nuanced software relationships between files, Implemented by, Super seeds, Consumer.
Fields like author can help identify the type of artifact, Specs will mostly be human authored.
Reverse engineered expectations will be authored by agents and should have reverse engineered set to true.

## Software modelling

A methodology that produces markdown files with implementation details.
After sdd is used to produce specs and agents write the code, The next step is to collect details from the code and produce a model document.
The model document is then reviewed and saved together with the spec.
It can be used to reason about the software in more detail and inform spec and software changes, allowing easier maintenance and changes over time.
Agents and humans can navigate the software at a middle level quickly, treating the source code as a compiled representation of the model.
Human developers no longer need to read code to understand the structure of the software.
Model file metadata will be authored by agents, Software model, true.

```
| non technical     technical
|--------------|-----------------|
Intent         |
↓              |
Requirements   |
↓              |
Behavior       |
↓              |
Design         | Constitution
↓              | ↓
----------------
Spec
↓
Plan
↓
Tasks
↓
Code -> Ships
├── modules
├── functions
├── types
├── public APIs
├── interfaces
├── database
└── tests
↓
Model
```

| level   | file       | language             |
| ------- | ---------- | -------------------- |
| high    | spec       | english              |
| middle  | model      | english, pseudo code |
| low     | code       | programming          |
| machine | executable | machine              |

## future considerations

Automation on generation and verification of model files, synchronization, extraction.

# tools

- github.com/iwe-org/iwe
- https://github.com/GoogleCloudPlatform/knowledge-catalog/blob/main/okf/SPEC.md

# workflows

## foundation

- add a spc directory.
- adopt OKF frontmatter for all files.
- write spc/constitution.md with high level guidelines.
- define your OKF metadata fields and rules in the constitution.
- organize spec files by feature directories.
- add a model sub directory to each feature with implementation details.

## new work

- write rough spec files after discussing behavior and design with non technical folks.
- work through SDD steps, constitution, spec plan tasks code ship.
- generate model after final QA'd code.

## spec from files

- agent reads code for a feature and/or reviews documentation.
- produces a reverse-engineered spec for review, adds proper metadata.
- review, discussion.
- spec is commited.
- models are generated.

## spec change

- same as new work but mostly updating existing specs and models
