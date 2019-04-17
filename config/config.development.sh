#!/usr/bin/env bash

# TODO: move package to physical schema to package_deployment.json

export ORACLE_CONNECT_STRING="${ORACLE_CONNECT_STRING:-CMD_DEV}"
export ORACLE_AS_SYSDBA="${ORACLE_AS_SYSDBA:- AS SYSDBA}"
export ORACLE_SYSDBA="${ORACLE_SYSDBA:-SYS}"
export ORACLE_SYSDBA_PWD="${ORACLE_SYSDBA_PWD:-Pah-Zaid5ti}"
