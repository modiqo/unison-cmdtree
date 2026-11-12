# Dependencies

Every library is installed by release, then pinned by its namespace hash: the installed namespace is deleted and
forked back from the hash written here, so the codebase holds exactly the reviewed content, and a release whose Share
copy changed stops the build with "I don't know of a namespace with that hash". The hashes are the ones UCM 1.5.0
records for these releases (`history lib.NAME` after an install in a scratch codebase); `@modiqo/olki` pins the same
two, so a program that uses both holds one copy of each.

```ucm
scratch/main> project.create-empty cmdtree
cmdtree/main> lib.install @unison/base/releases/7.20.0
cmdtree/main> lib.install @unison/json/releases/1.4.2
cmdtree/main> delete.namespace lib.unison_base_7_20_0
cmdtree/main> fork #e6omqhuko7mr7usqp79ifs7gb1eabl1g7jbevd0l47ngvh6i47944glea2juqig30djumik9jkedssua9f2hi6ip5jg4bg2jup2vfv8 lib.unison_base_7_20_0
cmdtree/main> delete.namespace lib.unison_json_1_4_2
cmdtree/main> fork #js5o8plfinkmgsovi24hh2ddn46v94mnm4sirvrdtmcd5of1t7tembll9fbg9tlghlm2iglorj3mfborle06cbjkhbmb7uloe8uq170 lib.unison_json_1_4_2
cmdtree/main> ls lib
```
