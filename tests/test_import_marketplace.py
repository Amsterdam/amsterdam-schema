import json

import pytest

from scripts import import_marketplace_products


@pytest.fixture
def file_content() -> dict:
    return {
        "id": "table1",
        "schema": {
            "properties": {
                "field1": {"title": "Old Title", "description": "Old Description"},
                "field2": {"title": "Another Title", "description": "Another Description"},
            }
        },
    }


@pytest.fixture
def file_content_with_marketplace_data() -> dict:
    return {
        "id": "table1",
        "schema": {
            "properties": {
                "field1": {
                    "title": "Some Title",
                    "businessTerm": "Some Term",
                    "description": "Some Description",
                },
                "field2": {
                    "title": "Another Title",
                    "businessTerm": "Another Term",
                    "description": "Another Description",
                    "businessDescription": "Description",
                },
            }
        },
    }


def test_remove_business_fields(tmp_path, file_content_with_marketplace_data):

    file_path = tmp_path / "v1.json"
    file_path.write_text(json.dumps(file_content_with_marketplace_data))

    import_marketplace_products.remove_business_fields(str(file_path))

    new_data = json.loads(file_path.read_text())

    assert "businessTerm" not in new_data["schema"]["properties"]["field1"]
    assert "businessDescription" not in new_data["schema"]["properties"]["field2"]


def test_fetch_marketplace_data(monkeypatch):
    class MockResponse:
        def __init__(self, data):
            self._data = data

        def json(self):
            return self._data

    def mock_get(url, timeout):
        if url == import_marketplace_products.MARKETPLACE_URL:
            return MockResponse({"documents": [{"id": "1"}]})
        else:
            return MockResponse(
                {
                    "schema": {
                        "tables": [
                            {
                                "as_id": "table1",
                                "attributes": [
                                    {"field1": {"term": "Term", "description": "Desc"}}
                                ],
                            }
                        ]
                    }
                }
            )

    monkeypatch.setattr(import_marketplace_products.requests, "get", mock_get)

    result = import_marketplace_products.fetch_marketplace_data()

    assert "table1" in result

    assert result["table1"]["field1"]["term"] == "Term"
    assert result["table1"]["field1"]["description"] == "Desc"


def test_update_files(tmp_path, monkeypatch, file_content):

    monkeypatch.setattr(import_marketplace_products, "DATASETS_FOLDER_PATH", str(tmp_path))

    dataset = tmp_path / "dataset1"
    dataset.mkdir()

    table_dir = dataset / "tableA"
    table_dir.mkdir()

    file_path = table_dir / "v1.json"

    file_path.write_text(json.dumps(file_content))

    marketplace_map = {"table1": {"field1": {"term": "New Term", "description": "New Desc"}}}

    import_marketplace_products.update_files(marketplace_map)

    updated_data = json.loads(file_path.read_text())
    assert updated_data["schema"]["properties"]["field1"]["businessTerm"] == "New Term"
    assert updated_data["schema"]["properties"]["field1"]["businessDescription"] == "New Desc"


def test_remove_business_fields_invalid_json(tmp_path, capsys):
    file_path = tmp_path / "invalid.json"
    file_path.write_text("{invalid_json: true")

    result = import_marketplace_products.remove_business_fields(str(file_path))

    captured = capsys.readouterr()

    assert "Skipping invalid JSON in" in captured.out
    assert str(file_path) in captured.out
    assert result is None
