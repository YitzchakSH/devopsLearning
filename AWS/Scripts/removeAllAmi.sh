#!/bin/bash

# Fetch all owned AMI IDs
echo "Fetching your AMIs..."
AMIS=$(aws ec2 describe-images --owners self --query 'Images[*].ImageId' --output text)

for AMI in $AMIS; do
  echo "Processing AMI: $AMI"

  # Get associated snapshot(s)
  SNAPSHOTS=$(aws ec2 describe-images --image-ids "$AMI" \
    --query 'Images[*].BlockDeviceMappings[*].Ebs.SnapshotId' \
    --output text)

  # Deregister AMI
  echo "Deregistering $AMI..."
  aws ec2 deregister-image --image-id "$AMI"

  # Delete associated snapshots
  for SNAP in $SNAPSHOTS; do
    if [[ "$SNAP" != "None" ]]; then
      echo "Deleting snapshot: $SNAP"
      aws ec2 delete-snapshot --snapshot-id "$SNAP"
    fi
  done

  echo "Done with $AMI"
done

echo "✅ All AMIs and snapshots deleted."
