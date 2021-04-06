.PHONY: install
install:
	pip install -e '.[dev,tests]'
	pre-commit install

.PHONY: clean
clean:
	find . -type d -name __pycache__ -exec rm -r {} \+
	rm -rf build dist

.PHONY: build
build: clean
	python -m build --sdist --wheel .

.PHONY: release
release:
	publish
