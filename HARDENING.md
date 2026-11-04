<!-- markdownlint-disable -->

# Hardening Report: uraimo--run-on-arch-action/v3.2.1

> This file was generated automatically by the hardening agent.

**Policy SHA:** `374911c4be584df24e6da57af2d990570ef0f859`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **uraimo--run-on-arch-action/v3.2.1** was hardened automatically. 1 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### prior-fix (severity: high)

Carried forward from this version's previous harden, which fixed it; fix it again unless the code no longer has the problem. The previous harden changed src/run-on-arch.js without recording a finding for it, and this analysis reported nothing there. Re-apply its security changes unless the code no longer needs them. The previous patch:
```diff
diff --git a/src/run-on-arch.js b/src/run-on-arch.js
index c2e661e..7891afa 100644
--- a/src/run-on-arch.js
+++ b/src/run-on-arch.js
@@ -1,34 +1,6269 @@
-/*jshint esversion: 9 */
+var __getOwnPropNames = Object.getOwnPropertyNames;
+var __commonJS = (cb, mod) => function __require() {
+  try {
+    return mod || (0, cb[__getOwnPropNames(cb)[0]])((mod = { exports: {} }).exports, mod), mod.exports;
+  } catch (e) {
+    throw mod = 0, e;
+  }
+};
 
-const core = require('@actions/core');
-const fs = require('fs');
-const path = require('path');
-const YAML = require('yaml');
-const shlex = require('shlex');
-const { exec } = require('@actions/exec');
+// node_modules/@actions/core/lib/command.js
+var require_command = __commonJS({
+  "node_modules/@actions/core/lib/command.js"(exports2) {
+    "use strict";
+    Object.defineProperty(exports2, "__esModule", { value: true });
+    var os = require("os");
+    function issueCommand(command, properties, message) {
+      const cmd = new Command(command, properties, message);
+      process.stdout.write(cmd.toString() + os.EOL);
+    }
+    exports2.issueCommand = issueCommand;
+    function issue(name, message = "") {
+      issueCommand(name, {}, message);
+    }
+    exports2.issue = issue;
+    var CMD_STRING = "::";
+    var Command = class {
+      constructor(command, properties, message) {
+        if (!command) {
+          command = "missing.command";
+        }
+        this.command = command;
+        this.properties = properties;
+        this.message = message;
+      }
+      toString() {
+        let cmdStr = CMD_STRING + this.command;
+        if (this.properties && Object.keys(this.properties).length > 0) {
+          cmdStr += " ";
+          for (const key in this.properties) {
+            if (this.properties.hasOwnProperty(key)) {
+              const val = this.properties[key];
+              if (val) {
+                cmdStr += `${key}=${escape(`${val || ""}`)},`;
+              }
+            }
+          }
+        }
+        cmdStr += CMD_STRING;
+        const message = `${this.message || ""}`;
+        cmdStr += escapeData(message);
+        return cmdStr;
+      }
+    };
+    function escapeData(s) {
+      return s.replace(/\r/g, "%0D").replace(/\n/g, "%0A");
+    }
+    function escape(s) {
+      return s.replace(/\r/g, "%0D").replace(/\n/g, "%0A").replace(/]/g, "%5D").replace(/;/g, "%3B");
+    }
+  }
+});
 
-function slug(str) {
-  return str.replace(/[^a-zA-Z0-9]/g, '-').toLowerCase();
-}
+// node_modules/@actions/core/lib/core.js
+var require_core = __commonJS({
+  "node_modules/@actions/core/lib/core.js"(exports2) {
+    "use strict";
+    var __awaiter = exports2 && exports2.__awaiter || function(thisArg, _arguments, P, generator) {
+      function adopt(value) {
+        return value instanceof P ? value : new P(function(resolve) {
+          resolve(value);
+        });
+      }
+      return new (P || (P = Promise))(function(resolve, reject) {
+        function fulfilled(value) {
+          try {
+            step(generator.next(value));
+          } catch (e) {
+            reject(e);
+          }
+        }
+        function rejected(value) {
+          try {
+            step(generator["throw"](value));
+          } catch (e) {
+            reject(e);
+          }
+        }
+        function step(result) {
+          result.done ? resolve(result.value) : adopt(result.value).then(fulfilled, rejected);
+        }
+        step((generator = generator.apply(thisArg, _arguments || [])).next());
+      });
+    };
+    Object.defineProperty(exports2, "__esModule", { value: true });
+    var command_1 = require_command();
+    var os = require("os");
+    var path2 = require("path");
+    var ExitCode;
+    (function(ExitCode2) {
+      ExitCode2[ExitCode2["Success"] = 0] = "Success";
+      ExitCode2[ExitCode2["Failure"] = 1] = "Failure";
+    })(ExitCode = exports2.ExitCode || (exports2.ExitCode = {}));
+    function exportVariable(name, val) {
+      process.env[name] = val;
+      command_1.issueCommand("set-env", { name }, val);
+ 
... (truncated)
```

Locations:

- `src/run-on-arch.js`

## Iteration Notes

### Iteration 1

**Fixes applied:** prior-fix

**Notes:**

The diff from the earlier harden was cut off. All that's visible is that it replaced src/run-on-arch.js with a single bundled copy of the vendored dependencies, including the old @actions/core 1.1.1, which still uses the deprecated set-env command. Its actual security changes aren't in the visible part, so I couldn't reapply them line for line. node_modules is present here, so I didn't redo the bundling. I hardened the source file in place instead:
1. `arch` and `distro` must now match `^[A-Za-z0-9][A-Za-z0-9._-]*$` and can't contain `..`. They're used to build the Dockerfile path, and that file gets overwritten when `base_image` is set, so a value like `../x` could write a file outside the Dockerfiles folder.
2. `base_image` can't contain CR or LF characters. It goes into a `FROM` line, and a line break would let someone add extra Dockerfile instructions.
3. Each key in the `env` YAML must be a valid variable name. The key is passed to run-on-arch.sh as a docker argument, and that script runs every docker argument through `eval echo`.
Valid inputs (aarch64, ubuntu22.04, alpine_latest, none, normal variable names) behave as before. I haven't run the action to check this.
I left the `eval` of `dockerRunArgs` in run-on-arch.sh alone. Expanding `$VAR` references in those arguments is a documented feature, and the arguments come from the workflow author.

