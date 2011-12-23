#!/bin/bash

find -name '*.lua' ! -path './.git/*' -print0 | xargs -0 ./bin/run-test
