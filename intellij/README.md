# IntelliJ IDEA Setup

## Code Style

Import the shared code style:

1. Open IntelliJ IDEA
2. **Settings > Editor > Code Style**
3. Click the gear icon > **Import Scheme > IntelliJ IDEA code style XML**
4. Select `devkit/intellij/codestyle.xml`
5. Set it as the active scheme

### Style highlights

- 2-space indent, 4-space continuation
- 120-character line width
- Allman brace style (braces on next line)
- Force braces on all if/while/for/do-while
- No wildcard imports
- Underscore prefix for fields (`_fieldName`)
- Import order: all non-static, blank line, all static

## VM Options

For large projects, increase the heap:

1. **Help > Edit Custom VM Options**
2. Set `-Xmx8192m` (or copy `devkit/intellij/idea.vmoptions`)

## Recommended Plugins

- GitHub Copilot
- Claude Code
- Scala (if needed)

## Project Defaults

Set these once in **File > New Projects Setup > Settings for New Projects**:

- **Project tool window**: Autoscroll from Source = ON, Autoscroll to Source = ON
- **Appearance**: Hide Empty Middle Packages = ON
- **Show Library Contents** = ON
