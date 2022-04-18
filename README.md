# directory_watch

A process to watch a directory and, after a suitable delay, write the names of the new files to stdout. Intended as a `find` replacement for situations where files are added to the directory over a period of time and we don't want to break the pipe. My use case is:

```bash
$ dw --path "task/task_*.sh" | xargs -P 12 -L 1 sh
```

This will watch a directory for new files and pass them to `xargs` as they appear. Under normal circumstances `find` would quit once it had processed all the existing files and the pipeline would collapse. `dw` will just wait until new files are added to the directory

