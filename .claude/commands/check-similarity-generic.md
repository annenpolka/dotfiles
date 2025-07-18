# similarity-generic: AI Assistant Guide

## Purpose

Detects duplicate code across multiple languages (Go, Java, C, C++, C#, Ruby) using tree-sitter AST comparison for refactoring.

## AI用プロンプト / AI Prompt

日本語:
```
`similarity-generic .` でコードの意味的な類似が得られます。あなたはこれを実行し、ソースコードの重複を検知して、リファクタリング計画を立てます。細かいオプションは similarity-generic -h で確認してください。
```

English:
```
Run `similarity-generic .` to detect semantic code similarities across multiple languages. Execute this command, analyze the duplicate code patterns, and create a refactoring plan. Check `similarity-generic -h` for detailed options.
```

## Installation

```bash
cargo install similarity-generic
# check options
similarity-generic --help
# check supported languages
similarity-generic --supported
```

## Supported Languages

- Go - `--language go`
- Java - `--language java`
- C - `--language c`
- C++ - `--language cpp`
- C# - `--language csharp`
- Ruby - `--language ruby`

Note: For Python, TypeScript, and Rust, use dedicated tools:
- `similarity-py` for Python
- `similarity-ts` for TypeScript/JavaScript
- `similarity-rs` for Rust (future)

## Key Options

- `--language <name>`: Specify language (go, java, c, cpp, csharp, ruby)
- `--config <file>`: Use custom language configuration (JSON)
- `--threshold <0-1>`: Similarity threshold (default: 0.85)
- `--show-functions`: Display extracted functions for debugging
- `--show-config <lang>`: Show example configuration for a language
- `--experimental-overlap`: Enable overlap detection mode
- `--overlap-min-window <n>`: Minimum window size for overlap (default: 8)
- `--overlap-max-window <n>`: Maximum window size for overlap (default: 25)
- `--overlap-size-tolerance <0-1>`: Size tolerance for overlap (default: 0.25)

## AI Refactoring Workflow

### 1. Language Detection & Setup

Auto-detect or specify language:

```bash
# Auto-detect based on file extensions
similarity-generic src/

# Specify language explicitly
similarity-generic src/ --language go
similarity-generic src/ --language java
```

### 2. Broad Scan

Find all duplicates in codebase:

```bash
# Go projects
similarity-generic . --language go --threshold 0.85

# Java projects
similarity-generic src/ --language java --threshold 0.85

# C/C++ projects
similarity-generic . --language cpp --threshold 0.85
```

### 3. Focused Analysis

Examine specific files:

```bash
# Compare specific files
similarity-generic file1.go file2.go --language go --threshold 0.8

# Show extracted functions for debugging
similarity-generic main.go --language go --show-functions
```

### 4. Custom Configuration

For advanced use cases, create custom language configs:

```bash
# Show example config for a language
similarity-generic --show-config go > go-config.json

# Use custom config
similarity-generic . --config go-config.json --threshold 0.8
```

### 5. Overlap Detection (Experimental)

Find overlapping code patterns:

```bash
similarity-generic . --language go --experimental-overlap --overlap-min-window 10
```

## Output Format

```
Function: functionName (file.go:startLine-endLine)
Similar to: otherFunction (other.go:startLine-endLine)
Similarity: 85%
```

## Effective Thresholds

- `0.95+`: Nearly identical (variable renames only)
- `0.85-0.95`: Same algorithm, minor differences
- `0.75-0.85`: Similar structure, different details
- `0.7-0.75`: Related logic, worth investigating

## Language-Specific Patterns

### Go
- **Handler functions** with similar HTTP processing
- **Method receivers** with repeated validation
- **Error handling** patterns across packages
- **Interface implementations** with similar logic

### Java
- **Service methods** with similar business logic
- **DTO/Entity conversions** with repeated mapping
- **Exception handling** patterns
- **Builder patterns** with similar structure

### C/C++
- **Memory management** patterns
- **Error checking** routines
- **Data structure operations**
- **Algorithm implementations**

### C#
- **Property getters/setters** with validation
- **LINQ queries** with similar filtering
- **Event handlers** with repeated logic
- **Extension methods** with similar functionality

### Ruby
- **Active Record models** with similar validations
- **Controller actions** with repeated patterns
- **Helper methods** with similar transformations
- **Class methods** with similar initialization

## Refactoring Strategy

1. **Start with language detection** - ensure correct parser
2. **Use appropriate threshold** (0.85) for initial scan
3. **Focus on high-similarity pairs** first (90%+)
4. **Extract language-specific abstractions**:
   - Go: interfaces and composition
   - Java: abstract classes and inheritance
   - C/C++: function pointers and macros
   - C#: generics and extension methods
   - Ruby: modules and mixins
5. **Re-run after refactoring** to verify improvements

## Configuration Examples

### Custom Go Configuration
```json
{
  "language": "go",
  "function_nodes": ["function_declaration", "method_declaration"],
  "type_nodes": ["type_declaration", "struct_type", "interface_type"],
  "field_mappings": {
    "name_field": "name",
    "params_field": "parameters",
    "body_field": "body"
  }
}
```

### Custom Java Configuration
```json
{
  "language": "java",
  "function_nodes": ["method_declaration", "constructor_declaration"],
  "type_nodes": ["class_declaration", "interface_declaration"],
  "field_mappings": {
    "name_field": "name",
    "params_field": "formal_parameters",
    "body_field": "body"
  }
}
```

## Best Practices

- **Specify language explicitly** for mixed codebases
- **Use show-functions** to debug extraction issues
- **Start with higher thresholds** (0.9) for obvious duplicates
- **Consider language idioms** when refactoring
- **Test configurations** with show-config before custom setups
- **Use overlap detection** for complex similarity patterns

## Common Usage Patterns

```bash
# Quick language-specific scan
similarity-generic . --language go

# Debug function extraction
similarity-generic main.go --language go --show-functions

# Custom threshold for stricter matching
similarity-generic src/ --language java --threshold 0.9

# Experimental overlap detection
similarity-generic . --language cpp --experimental-overlap

# Compare specific files with detailed output
similarity-generic file1.rb file2.rb --language ruby --threshold 0.8
```

## Troubleshooting

- **No results found**: Lower threshold or check language detection
- **Wrong functions extracted**: Use --show-functions to debug
- **Mixed languages**: Run separately for each language
- **Parse errors**: Verify file syntax or try custom config