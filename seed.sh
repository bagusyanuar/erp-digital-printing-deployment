#!/bin/bash

# Run seeder
echo "Running database seeder..."
docker exec -it erp-app ./seed
