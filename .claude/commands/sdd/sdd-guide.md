# Claude Code Commands for Spec-Driven Development

## Generate Requirements (`/sdd:req`)

Extract user stories and detailed EARS-style acceptance criteria.

### Usage

```bash
/sdd:req "<high-level prompt>"
```

Where:

* `<high-level prompt>` clearly describes the intended feature or functionality.

### Examples

```bash
/sdd:req "Allow filtering job listings by salary"
```

### Description

This command:

1. Gathers project context (current branch, staged changes, README).

2. Produces user stories following:

   ```text
   As a [role], I want [feature], so that [benefit].
   ```

3. Defines EARS acceptance criteria using:

   ```text
   WHEN [event] THEN [system] SHALL [response].
   IF [condition] THEN [system] SHALL [response].
   ```

4. Generates structured YAML for `requirements.md`.

---

## Generate Technical Design (`/sdd:design`)

Creates detailed technical specifications from requirements.

### Usage

```bash
/sdd:design
```

### Examples

```bash
/sdd:design
```

### Description

This command:

1. Reads `requirements.md`.
2. Generates documentation including:

   * Mermaid architecture diagrams
   * Component responsibilities
   * Data models and validation rules (Go/TypeScript)
   * API specifications
   * Error handling and testing strategies
3. Saves structured output to `design.md`.

---

## Task Breakdown (`/sdd:tasks`)

Breaks design into actionable, traceable implementation tasks.

### Usage

```bash
/sdd:tasks
```

### Examples

```bash
/sdd:tasks
```

### Description

This command:

1. Parses `requirements.md` and `design.md`.

2. Decomposes work into hierarchical tasks:

   ```markdown
   - [ ] 1. Setup project structure
     - Create directories
     - Define core interfaces
     - _Requirements: 1.1, 1.2_

   - [ ] 2. Implement data models
     - [ ] 2.1 Define user model interface
       - TypeScript/Go interface definition
       - Validation implementation
       - Unit tests
       - _Requirements: 2.1_
   ```

3. Ensures clear traceability to requirements.

---

## Update Specifications (`/sdd:update-spec`)

Keeps specifications synchronized with code changes.

### Usage

```bash
/sdd:update-spec
```

### Examples

```bash
/sdd:update-spec
```

### Description

This command:

1. Detects recent code changes via `git diff`.
2. Updates impacted sections in `requirements.md` and `design.md`.
3. Inserts current date to modified sections.
4. Outputs `NO-UPDATE` if no relevant changes found.

---

## Implementation Workflow

### 1. Write Requirements

* Trigger `/sdd:req` with a clear prompt.
* Review and approve generated user stories and acceptance criteria.

### 2. Write Design

* Use `/sdd:design` to generate design from requirements.
* Review architecture diagrams, data models, and API specifications.

### 3. Task Breakdown

* Execute `/sdd:tasks` to create actionable tasks.
* Validate task hierarchy and requirement traceability.

### 4. Continuous Synchronization

* Configure pre-commit hook for `/sdd:update-spec`.
* Automatically maintain synchronization between implementation and specs.

---

## Quality Assurance Mechanism

### Requirements Phase Checks

* Completeness, consistency, verifiability

### Design Phase Checks

* Architectural validity, non-functional requirements coverage

### Tasks Phase Checks

* Completeness, independence, test strategy validation

---

## Benefits of Claude Code + Kiro Approach

* Accelerated development through clear, detailed specifications.
* Improved quality via structured, iterative reviews.
* Enhanced team alignment with automated synchronization and traceability.
