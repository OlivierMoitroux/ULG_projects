#!/bin/bash

echo "DIFF STAGE"
diff -burN clean-4.4.50 linux-4.4.50 > g19-s06-source.patch
