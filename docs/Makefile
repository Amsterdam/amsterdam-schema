ams-schema-spec.html: ams-schema-spec.bs
	bikeshed spec $< $@
# Clear trailing whitespace
	sed -i.bak -e 's/ *$$//' $@
	rm $@.bak

watch:
	bikeshed watch ams-schema-spec.bs ams-schema-spec.html
