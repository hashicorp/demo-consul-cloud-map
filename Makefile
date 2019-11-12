key:
	@echo "$(shell terraform output private_key)" > key.pem && chmod 0600 key.pem

delete:
	aws servicediscovery list-services --filters Name=NAMESPACE_ID,Values=$(shell terraform output namespace_id),Condition=EQ

ui:
	open http://$(shell terraform output shared_services):16686
	open http://$(shell terraform output web):9090/ui 