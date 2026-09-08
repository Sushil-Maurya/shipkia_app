# Workspace maintenance

After every improvement, fix, or other change, run a cleanup pass before handing off the work.

- Remove temporary reference images, screenshots, browser captures, preview-only test scripts, scratch files, and task-generated check logs once verification is complete.
- Keep production assets, existing developer tooling, meaningful regression tests and their fixtures, maintained documentation, and requested deliverables such as APKs.
- Check references before deleting files and update documentation links when removing reference artifacts. Do not infer that an untracked file is unused.
- On Windows, resolve and verify every recursive deletion target is inside this workspace. Use native PowerShell operations with literal paths.
- Verify the cleanup with repository status and a check for broken references. Run application tests when code changes require them; documentation/artifact cleanup alone does not require an APK rebuild.
