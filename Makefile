key:
	@echo "$(shell terraform output private_key)" > key.pem && chmod 0600 key.pem

delete:
	aws servicediscovery list-services --filters Name=NAMESPACE_ID,Values=$(shell terraform output namespace_id),Condition=EQ