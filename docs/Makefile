ams-schema-spec.html: ams-schema-spec.bs
	bikeshed spec $< $@
	sed -i.bak -e 's/ *$$//' $@
	rm $@.bak
