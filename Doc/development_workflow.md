# Development Workflow - Photo Booth V2

## Overview
This document outlines the Git branching strategy and development workflow for the Photo Booth V2 project. The workflow ensures organized development, proper code review, and smooth deployment across multiple platforms (Android User App + Windows Operator App).

## Branch Structure

### Main Branches
- **`master`** - Production-ready code (main branch)
- **`dev`** - Development integration branch (where all feature branches merge)

### Feature Branches
- **`feature/<feature-name>`** - New features or major updates
- **`bugfix/<bug-description>`** - Bug fixes
- **`hotfix/<issue>`** - Critical fixes for production

## Development Flow

### 1. Starting New Development
```bash
# Ensure you're on dev branch and up-to-date
git checkout dev
git pull origin dev

# Create new feature branch
git checkout -b feature/grid-editor-ui
```

### 2. Development Process
```bash
# Make changes and commit regularly
git add .
git commit -m "feat: implement grid editor visual interface"

# Push feature branch to remote
git push -u origin feature/grid-editor-ui
```

### 3. Code Review & Integration
```bash
# When feature is complete, create Pull Request
# - Target branch: dev
# - Review code changes
# - Run tests if available
# - Merge when approved

# After merge to dev, delete feature branch
git branch -d feature/grid-editor-ui
git push origin --delete feature/grid-editor-ui
```

### 4. Release Process
```bash
# When dev is stable and ready for production
git checkout master
git merge dev

# Tag the release
git tag -a v1.0.0 -m "Release version 1.0.0"
git push origin master --tags
```

## Branch Naming Conventions

### Feature Branches
- `feature/grid-selection-screen` - New grid selection UI
- `feature/network-communication` - WebSocket implementation
- `feature/printer-integration` - Printer service enhancements

### Bugfix Branches
- `bugfix/camera-preview-crash` - Fix camera preview crash
- `bugfix/grid-layout-overflow` - Fix grid layout overflow issue

### Hotfix Branches
- `hotfix/critical-print-failure` - Emergency print fix
- `hotfix/app-crash-startup` - Fix app crash on startup

## Commit Message Format

Follow conventional commit format:
```
type(scope): description

[optional body]

[optional footer]
```

### Types:
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation
- `style`: Code style changes
- `refactor`: Code refactoring
- `test`: Testing
- `chore`: Maintenance

### Examples:
```
feat(grid): add visual grid editor interface
fix(camera): resolve preview mirroring issue
docs(workflow): add development workflow documentation
refactor(provider): optimize state management structure
```

## Platform-Specific Development

### Android User App
- Focus on user experience and touch interactions
- Test on multiple Android devices
- Ensure kiosk mode compatibility

### Windows Operator App
- Focus on desktop UX and productivity
- Test window management and printing
- Ensure proper system integration

## Testing Strategy

### Before Merging to dev:
- [ ] Code compiles without errors
- [ ] Basic functionality tested
- [ ] No breaking changes to existing features
- [ ] Documentation updated if needed

### Before Merging to master:
- [ ] All features in dev tested end-to-end
- [ ] Cross-platform compatibility verified
- [ ] Performance benchmarks met
- [ ] Documentation complete

## Conflict Resolution

When conflicts occur during merge:
1. Communicate with team about conflicting changes
2. Resolve conflicts carefully, preserving intended functionality
3. Test thoroughly after resolution
4. Commit with clear message: `fix: resolve merge conflicts in grid provider`

## Emergency Procedures

### Hotfix Process:
```bash
# Create hotfix from master
git checkout master
git checkout -b hotfix/critical-bug

# Fix the issue
# ... make changes ...

# Merge back to both master and dev
git checkout master
git merge hotfix/critical-bug
git checkout dev
git merge hotfix/critical-bug

# Clean up
git branch -d hotfix/critical-bug
```

## Current Status

### Active Development:
- **Current Branch**: `feature/network-websocket-setup`
- **Active Features**:
  - WebSocket server implementation (Windows Operator)
  - WebSocket client implementation (Android User)
  - Network communication protocol
  - Device discovery service

### Recent Branches:
- `feature/network-websocket-setup` - **ACTIVE** - Network communication setup
- `dev` - Development integration branch
- `master` - Production branch

### Completed Features:
- Project architecture setup
- Multi-platform build configuration
- Core service providers (Camera, Printer, Storage, Grid)
- Grid selection and configuration system
- Operator dashboard layout
- Basic camera and printer services

## AI Development Assistant Guidelines

This document is structured for AI assistants to understand the project workflow:

### Key Understanding Points:
1. **Branch Hierarchy**: master ← dev ← feature branches
2. **Merge Direction**: Features → dev → master
3. **Platform Context**: Android (User) vs Windows (Operator)
4. **Code Organization**: Features-based structure with providers/services

### AI Workflow Tasks:
- Always check current branch before making changes
- Create appropriate feature branches for new work
- Follow commit message conventions
- Update this document when workflow changes
- Ensure cross-platform compatibility in changes

### AI Code Generation Rules:
- Use Provider pattern for state management
- Follow Flutter best practices
- Include platform checks (`Platform.isWindows`)
- Add proper error handling
- Update documentation for new features

---

**Last Updated**: November 22, 2025
**Document Version**: 1.0
**Maintained by**: Development Team