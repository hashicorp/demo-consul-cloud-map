unit:
	terraform fmt
	terraform validate

key:
	@echo "$(shell terraform output private_key)" > key.pem && chmod 0600 key.pem

split:
	CONSUL_HTTP_ADDR=http://$(shell terraform output consul_server_aws):8500 consul config write consul_config/service-defaults.hcl
	CONSUL_HTTP_ADDR=http://$(shell terraform output consul_server_aws):8500 consul config write consul_config/service-resolver.hcl

open:
	open http://$(shell terraform output shared_services):16686
	open http://$(shell terraform output web_onprem):9090/ui
	open http://$(shell terraform output consul_server_onprem):8500
	open http://$(shell terraform output consul_server_aws):8500
	open http://$(shell terraform output web_aws):9090/ui


clean:
	bash delete-cloud-map.sh