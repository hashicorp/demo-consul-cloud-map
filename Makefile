unit:
	terraform fmt
	terraform validate

key:
	@echo "$$(terraform output private_key)" > key.pem && chmod 0600 key.pem

api-traffic:
	CONSUL_HTTP_ADDR=http://$$(terraform output consul_server_onprem):8500 consul config write consul_config/service-defaults.hcl
	CONSUL_HTTP_ADDR=http://$$(terraform output consul_server_onprem):8500 consul config write consul_config/service-resolver-api.hcl
	CONSUL_HTTP_ADDR=http://$$(terraform output consul_server_onprem):8500 consul config write consul_config/service-splitter.hcl

web-traffic:
	CONSUL_HTTP_ADDR=http://$$(terraform output consul_server_onprem):8500 consul config write consul_config/service-resolver-web.hcl
	CONSUL_HTTP_ADDR=http://$$(terraform output consul_server_onprem):8500 consul config write consul_config/service-router.hcl

open:
	open http://$$(terraform output shared_services):16686
	open http://$$(terraform output web_onprem):9090/ui
	open http://$$(terraform output consul_server_onprem):8500/ui/onprem

register-api:
	aws servicediscovery register-instance --service-id $$(terraform output service_id) --instance-id $$(terraform output instance_id) --attributes AWS_INSTANCE_IPV4=$$(terraform output api_aws),AWS_INSTANCE_PORT=9090

test:
	ssh -i key.pem ubuntu@$$(terraform output tester) 'curl -s localhost:9092'
	ssh -i key.pem ubuntu@$$(terraform output tester) 'curl -s -H "datacenter:aws" localhost:9092'

clean:
	bash delete-cloud-map.sh