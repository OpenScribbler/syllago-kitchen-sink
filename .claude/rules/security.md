---
description: Security best practices for all code
alwaysApply: true
globs:
  - "**/*.ts"
  - "**/*.js"
---

All code must validate user input at system boundaries. Never trust external data. Use parameterized queries for database access. Sanitize HTML output to prevent XSS.
