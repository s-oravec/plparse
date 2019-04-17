#!/usr/bin/env bash

sqlplus /nolog <<EOF
connect PLPARSE_000100/PLPARSE_000100@CMD_DEV
-- Test script
@test.sql
EOF