# Contributing

## Reporting Bugs

Before creating a bug report:

1. Search existing issues
2. Update to the latest version
3. Use the bug report template

Include:

- Zsh version (`zsh --version`)
- Your configuration
- Steps to reproduce
- Expected vs actual behavior

## Development Setup

```bash
# Fork and clone
git clone https://github.com/YOUR_USERNAME/zsh-vi-man.git
cd zsh-vi-man

# Create a branch
git checkout -b feature/your-feature-name

# Test your changes
zsh test_patterns.zsh
```

## Code Style

- 2 spaces for indentation
- Add comments for complex logic
- Follow existing patterns

## Commit Messages

Use conventional commit format:

```
feat: add support for custom pager options
fix: handle options with equals sign correctly
docs: update installation instructions
test: add tests for slash-separated options
```

## Writing Tests

Add tests to `test_patterns.zsh` for pattern changes:

```zsh
pattern=$(build_your_pattern_function "input")

assert_matches "$pattern" \
  "     expected match line" \
  "Description of what should match"
```

## Pull Requests

1. Create PR using the template
2. Link related issues (use "Fixes #123")
3. Ensure tests pass
4. Respond to review feedback

## CI/CD

GitHub Actions automatically:

- Runs pattern tests
- Verifies plugin loads
- Tests on Ubuntu and macOS
- Checks compatibility with plugin managers
