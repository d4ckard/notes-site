- [ ] install script to check path and install
- [x] build script for the site itself
- [ ] solution for quick access to subdir for working on notes
- [x] pandoc command
- [x] header and footer
- [ ] Automatic site upload for new notes
- [ ] check if mermaid-filter.err even exists first
- [x] Allow access to resources such as PDFs
- [ ] Incremental builds
- [ ] Site QR codes

# Creating and uploading notes

Notes reside in their own repository. This repository is a submodule
to the `notes-site` repository. On every push to this note repository,
the `notes-site` can be rebuilt.

This has multiple advantages. Most notably:

1. The notes can be tracked and maintained separately from the page.
2. Git can be used to track changes in the notes and build incrementally.
