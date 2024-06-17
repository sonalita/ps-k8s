#!/bin/bash

ansible all -i inventory/proxmox -m ping
