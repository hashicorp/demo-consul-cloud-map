#!/bin/bash
set -e

namespace=$(terraform output namespace_id)
service_ids=$(aws servicediscovery list-services --filters Name=NAMESPACE_ID,Values=${namespace},Condition=EQ --query 'Services[*].Id' --output text)

for service_id in ${service_ids}
do
  instance_ids=$(aws servicediscovery list-instances --service-id ${service_id} --query 'Instances[*].Id' --output text)
  for instance_id in ${instance_ids}
  do
    echo "deregistering instance ${instance_id}"
    aws servicediscovery deregister-instance --service-id ${service_id} --instance-id ${instance_id}
  done
done

for service_id in ${service_ids}
do
  echo "deleting service ${service_id}"
  aws servicediscovery delete-service --id ${service_id}
done