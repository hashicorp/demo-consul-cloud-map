key:
	@echo "$(shell terraform output private_key)" > key.pem && chmod 0600 key.pem