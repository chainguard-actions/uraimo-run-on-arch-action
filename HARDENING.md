<!-- markdownlint-disable -->

# Hardening Report: uraimo--run-on-arch-action/v3.1.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `374911c4be584df24e6da57af2d990570ef0f859`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **uraimo--run-on-arch-action/v3.1.0** was hardened automatically. 1 finding(s) were identified and resolved across 1 iteration(s).

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

The previous harden replaced src/run-on-arch.js with an esbuild bundle of its dependencies (@actions/core, @actions/exec, yaml, shlex). The diff was cut off after about 6,000 added lines, so I couldn't see any targeted changes it may have made inside main(). Those dependencies are still in node_modules, so bundling them isn't needed and isn't a security fix. I kept the readable source and added validation instead: (1) arch and distro are now rejected if they contain '/', '\', NUL or newline characters. They are used to build the path that the custom Dockerfile is written to when base_image is set, so these characters could write a file outside Dockerfiles/. (2) base_image is now rejected if it contains newline or NUL characters, which could add extra instructions to the generated Dockerfile's FROM line. All shipped arch/distro names and normal image references still pass, so valid uses work as before. I deliberately left the user-supplied run, setup and install scripts and the eval on dockerRunArgs in run-on-arch.sh alone: running user commands and expanding $VAR references are documented features of the action.

